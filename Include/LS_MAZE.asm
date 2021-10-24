#importonce

//----------------------------------------------------------------			
/*****************************************************************
LS_MAZE.asm
v0.20

MAZE structs and methods

dependencies:
	standard includes
memory:
	C000 stack
known bugs:

	
*****************************************************************/

#import "LS_System.asm"
#import "LS_GRID.asm"
#import "LS_Random.asm"
#import "LS_Screen.asm"
#import "LIB_SymbolTable.asm"

//-----------------------CONST-----------------------------------

.const WALL 			= $00
//.const DOT 				= $20
//.const DOT 				= $2E
.const DOT 				= $E0
.label STACK			= $C000
.const DSIZE			= 4
.const MAX_X			= 38
.const MIN_X			= 1
.const MAX_Y 			= 23
.const MIN_Y 			= 1
.label DEAD_END_STACK 	= $C600 	//max 256 bytes expected
.label DE_REMAINDER		= $C700
.const MIN_W			= 3
.const MAX_W			= 4
.const ROOM_NUMBER		= 4

//-----------------------MACROS-----------------------------

.macro INIT_MAZE(memory){

/*
arguments: memory: 	memory address of where to create maze
					default $0400 (screen)
*/

	SET_ADDR(memory, maze_memory_alloc)
	SET_ADDR(STACK, STKPTR1)
	SET_ADDR(DEAD_END_STACK, STKPTR3)
	SET_ADDR(DE_REMAINDER, STKPTR5)
	lda #00
	sta DE_counter
	sta REM_DE_counter

	jsr MAZE_FILL
	FillColor(LIGHTGREY)					//debug
}

/*****************************************************************/

SWAP_DEAD_END_STACK:
/** 
set pointers to repead DE connection
*/
{
		lda DE_counter
		sta BV0
		lda REM_DE_counter
		sta DE_counter
		lda BV0
		sta REM_DE_counter

		SET_ADDR(DEAD_END_STACK, STKPTR5)
		SET_ADDR(DE_REMAINDER, STKPTR3)
		rts
}

/*****************************************************************/

.macro MAZE_BIAS(B){
/**
arguments: bias
*/
		lda #B
		sta bias
		lda #00
		sta bias_counter
}

/*****************************************************************/

.macro BIAS_NEXT(){
		inc bias_counter
		lda bias_counter
		cmp bias
		bne out+3
		lda #00
out:	sta bias_counter
}

/*****************************************************************/

.macro CALC_GRID_LOCATION(grid){
	
/**
	arguments,
		grid as grid.x, 
		grid.y = grid.x + 1

	assumes:
		maze_memory_alloc in ZP1
	
	destroys: 
		ZP1,ZP3
		y,a
	result:
		ZP1 holds address of grid

 */

			lda #0
			sta ZP4				
			lda grid+1		
			sta ZP3
		
			ldy #03
mul8:		ASL16(ZP3)
			dey
			bne mul8
			ADD16(ZP1, ZP3)
			ldy #02	
mul32:		ASL16(ZP3)
			dey
			bne mul32
			ADD16(ZP1, ZP3)	
			ADD8to16(ZP1, grid)
}

/*****************************************************************/

.macro CALC_COLOR_LOCATION(grid){
	
/**
	arguments,
		grid as grid.x, 
		grid.y = grid.x + 1
	
	destroys: 
		ZP1,ZP3
		y,a
	result:
		ZP1 holds address of color ram

 */
			SET_ADDR(COLOR_RAM, ZP1)
			lda #0
			sta ZP4				
			lda grid+1		
			sta ZP3
		
			ldy #03
mul8:		ASL16(ZP3)
			dey
			bne mul8
			ADD16(ZP1, ZP3)
			ldy #02	
mul32:		ASL16(ZP3)
			dey
			bne mul32
			ADD16(ZP1, ZP3)	
			ADD8to16(ZP1, grid)
}

/*****************************************************************/
//--- SUBS -------------------------------------------------------

MAZE_FILL:
{
			MOV16(maze_memory_alloc, ZP1)
			lda	#WALL
			ldx #4
block:		ldy #0
fill:
			sta (ZP1),y
			iny
			bne fill
			inc ZP2
			dex
			bne block
			rts
}

/*****************************************************************/

MAZE_DOT:
/** 
assumes start grid set 
uses ZP1,y
*/
{
			MOV16(maze_memory_alloc, ZP1)
			CALC_GRID_LOCATION(maze_start)

			lda #DOT
			ldy #0
			sta (ZP1),y
			rts
}

/*****************************************************************/

ROOMS: 
/** room creation wrapper */
{
			jsr MAKE_ROOMS
			jsr PAINT_ROOMS
			rts
}

/*****************************************************************/

PAINT_ROOMS:
/** */
{
			ldx #00
	each:	stx TEMPX				//each room
			txa
			asl
			asl
			tay
							
			lda rooms,y				//get top left x of room
			sta BV9
			iny
			lda rooms,y				//get top left y of room
			sta BV10
			iny
			lda rooms,y 			//w
			sta ZP0
			iny
			lda rooms,y 			//h
			sta BV0
									//cal call dots
			ldx #0
	cont_w:		ldy #0
	cont_h:
									//bv9 +x -> maze start
				stx TEMPA1
				lda BV9
				clc
				adc TEMPA1
				sta maze_start

									//b910 +y ->maze start+1
				sty TEMPA1
				lda BV10
				clc
				adc TEMPA1
				sta maze_start+1

				sty TEMPY
				jsr MAZE_DOT

				ldy TEMPY
				iny
				cpy BV0
				bne cont_h
			inx
			cpx ZP0
			bne cont_w
			
			ldx TEMPX
			inx
			cpx #ROOM_NUMBER
			bne each
	out: 	rts

}

/*****************************************************************/

POINTERS_FROM_START:
{
												//calc candidates
			ldx #03
	add:	txa
			asl
			tay		
												//x
			clc
			lda maze_start
			adc BASIC_DIRS,y
			sta candidates,y
			iny
												//y
			clc
			lda maze_start+1
			adc BASIC_DIRS,y
			sta candidates,y
			dex
			bpl add

												//copy vectors
			ldx #03
	copy:	txa
			asl
			tay	
			lda BASIC_DIRS,y
			sta candidates_vectors,y
			iny
			lda BASIC_DIRS,y
			sta candidates_vectors,y
			dex
			bpl copy

			lda #04
			sta candidates_length
			rts
			
}

/*****************************************************************/

FILTER_IF_OUT:
{
			lda candidates_length
			cmp #1
			bcs start
			rts
			
	start:		
			ldx candidates_length				//number of grids yet to check
			dex
	each:	txa
			asl
			tay
			clc
												//x
			lda candidates,y
			cmp #MAX_X+1
			bcs shift
			cmp #MIN_X
			bcc shift
												//y
			iny
			clc
			lda candidates,y
			cmp #MAX_Y+1
			bcs shift
			cmp #MIN_Y
			bcc shift
	cont:	dex
			bmi out
			jmp each
	out:	rts
	shift:
			stx TEMPX									//save x							
			stx VAR_A									//set index to VAR_A
			MOV8(candidates_length, VAR_B)				//set length to VAR_B
			SPLICE_ARRAY(candidates, 2)					//splice candidates at x
			MOV8(candidates_length, VAR_B)				//set length to VAR_B, as splice is changing that
			SPLICE_ARRAY(candidates_vectors, 2)			//splice candidates_vectors at x
			dec candidates_length						//dec array length
			ldx TEMPX									//restore x
			jmp cont									//return to loop
}

/*****************************************************************/

FILTER_IF_DOT:
{		

			lda candidates_length
			cmp #1
			bcs start
			rts

start:
			ldx candidates_length						//number of grids yet to check
			dex
														//checking each remaining grid
each:		txa
			asl
			tay
														//x
			lda candidates,y
			sta grid_pointer
														//y
			iny
			lda candidates,y
			sta grid_pointer+1
			MOV16(maze_memory_alloc, ZP1)
			CALC_GRID_LOCATION(grid_pointer)			//grid address now in ZP1

			ldy #0
			lda (ZP1),y
			cmp #DOT
			beq shift
														//end of grid check
	cont:	dex
			bpl each
	out:	rts
	shift:
			stx TEMPX									//save x
			stx VAR_A									//set index to VAR_A
			MOV8(candidates_length, VAR_B)				//set length to VAR_B
			SPLICE_ARRAY(candidates, 2)					//splice candidates at x, uses BV1
			MOV8(candidates_length, VAR_B)				//set length to VAR_B, as splice is changing that
			SPLICE_ARRAY(candidates_vectors, 2)			//splice candidates_vectors at x, uses BV1
			dec candidates_length						//dec array length
			ldx TEMPX									//restore x
			jmp cont									//return to loop
}

/*****************************************************************/

PUSH_REST_ON_STACK:
{
														//splice selected grid out of candidates
			lda ZP0										//index was stored in ZP0
			sta VAR_A									//set index to VAR_A
			MOV8(candidates_length, VAR_B)				//set length to VAR_B
			SPLICE_ARRAY(candidates, 2)					//splice candidates at x, uses BV1
			MOV8(candidates_length, VAR_B)				//set length to VAR_B, as splice is changing that
			SPLICE_ARRAY(candidates_vectors, 2)			//splice candidates_vectors at x, uses BV1
			dec candidates_length						//dec array length
														//copy remaining on stack
			ldx #0
each:		ldy #0
			stx TEMPX									//save x
			txa											//x = x *2	
			asl 
			tax									
														//grids
			lda candidates,x							//x
			sta (STKPTR1),y
			iny
			inx
			lda candidates,x							//y
			sta (STKPTR1),y
			ADD_C_16(STKPTR1, 2)
			dey
			dex
														//directions
			lda candidates_vectors,x					//x
			sta (STKPTR1),y
			iny
			inx
			lda candidates_vectors,x					//y
			sta (STKPTR1),y
			ADD_C_16(STKPTR1, 2)

			ldx TEMPX									//restore x
			inx
			cpx candidates_length
			bne each
	out:	rts		
}

/*****************************************************************/

.macro Filter_If_Next_Primary_Is(test)
/**  test is the value to be compared,  if not equal to test candidate is removed */
{
		lda #test
		sta BV0
		jsr FILTER_IF_NEXT_PRIMARY
}

FILTER_IF_NEXT_PRIMARY:
/** first pass: remove those that are close from primary direction */
{	
			lda candidates_length
			cmp #1
			bcs start										//cont if 1 or more
			rts												//else exit, if no candidates

	start:	
			ldx candidates_length							//number of grids yet to check
			dex												//to zero offset

	each:	txa
			asl												//double, because datasize is 2
			tay												//offset in y (zero based x * datasize)
															//x
			lda candidates,y
			sta grid_pointer
			lda candidates_vectors,y
			sta direction_pointer
															//y
			iny
			lda candidates,y
			sta grid_pointer+1
			lda candidates_vectors,y
			sta direction_pointer+1
															//add dir to grid
			clc
			lda grid_pointer
			adc direction_pointer
			sta test_pointer

			clc
			lda grid_pointer+1
			adc direction_pointer+1
			sta test_pointer+1

			MOV16(maze_memory_alloc, ZP1)				//move pointer to ZP1
			CALC_GRID_LOCATION(test_pointer)			//grid address now in ZP1

			ldy #0
			lda (ZP1),y
			cmp BV0										//BV0 holds the value to filter out
			beq shift									//yes
			
	cont:	dex
			bmi out										//less than zero, stop
			jmp each									//loop back, branch too far
	out:	rts
	shift:
			stx TEMPX									//save x
			stx VAR_A									//set index to VAR_A
			MOV8(candidates_length, VAR_B)				//set length to VAR_B
			SPLICE_ARRAY(candidates, 2)					//splice candidates at x, uses BV1
			MOV8(candidates_length, VAR_B)				//set length to VAR_B, as splice is changing that
			SPLICE_ARRAY(candidates_vectors, 2)			//splice candidates_vectors at x, uses BV1
			dec candidates_length						//dec array length
			ldx TEMPX									//restore x
			jmp cont									//return to loop
}

/*****************************************************************/

.macro Filter_if_N_Connections(N)
/** N number of connections, must be N, otherwise removed */
{
			lda #N
			sta BV0
			jsr FILTER_N_CONNECTIONS
}

FILTER_N_CONNECTIONS:
{
			lda candidates_length
			cmp #1
			bcs start										//cont if 1 or more
			rts												//else exit, if no candidates
	start:	
			ldx candidates_length							//number of grids yet to check
			dex												//to zero offset	
	each:	
			stx TEMPX										// save x 
			txa
			asl												//double, because datasize is 2
			tay												//offset in y (zero based x * datasize)
			
			lda candidates,y
			sta grid_pointer
			iny
			lda candidates,y
			sta grid_pointer+1
			CheckConnection(grid_pointer) 					//return in VARD_D
			ldx TEMPX										//restore x
			lda VAR_D										//value to compare is in BV0
			cmp BV0
			bne shift										//not equal, shift											
	cont:	
			dex
			bmi out											//less than zero, stop
			jmp each										//loop back, branch too far
	out:	rts
	shift:
			stx TEMPX									//save x
			stx VAR_A									//set index to VAR_A
			MOV8(candidates_length, VAR_B)				//set length to VAR_B
			SPLICE_ARRAY(candidates, 2)					//splice candidates at x, uses BV1
			MOV8(candidates_length, VAR_B)				//set length to VAR_B, as splice is changing that
			SPLICE_ARRAY(candidates_vectors, 2)			//splice candidates_vectors at x, uses BV1
			dec candidates_length						//dec array length
			ldx TEMPX									//restore x
			jmp cont									//return to loop
}
/*****************************************************************/

FILTER_SIDE_PROXIMIY:
/** second pass: filter side and corner proximities */
{		
			lda candidates_length
			cmp #1
			bcs start										//cont if 1 or more
			rts												//else exit, if no candidates
	start:	
			ldx candidates_length							//number of grids yet to check
			dex												//to zero offset
	each:	
			txa
			asl												//double, because datasize is 2
			tay												//offset in y (zero based x * datasize)

			lda candidates, y
			sta grid_pointer
			lda candidates_vectors,y
			sta direction_pointer
			iny
			lda candidates, y
			sta grid_pointer+1
			lda candidates_vectors,y
			sta direction_pointer+1
															//set directions table
															//first copy PROX_TEMPLATE to proximity

			MEM_COPY(PROX_TEMPLATE, proximity_vectors, 8)

															//expand direction pointer into head and side pointers
															//first find out which dimension is not zero in direction_pointer
			ldy #01											//y?
			lda direction_pointer,y
			bne ok											//if not zero, than this is right dimension
			dey												//not y, but x
	ok:		lda direction_pointer,y							//index of dimension now in y register
			sta proximity_vectors,y							//set sequence 1,1,0,0 on the right dimension, datasize=2
			iny
			iny
			sta proximity_vectors,y	
			iny
			iny
			lda #0
			sta proximity_vectors,y	
			iny
			iny
			sta proximity_vectors,y							//proximity vectors ready
															//calc location for each proximity vector, from grid_pointer
			ldy #00
	repeat:	lda grid_pointer
			clc
			adc proximity_vectors,y
			sta test_pointer
			iny
			lda grid_pointer+1
			clc
			adc proximity_vectors,y
			sta test_pointer+1								//next grid now in test_pointer
			sty TEMPY										//save y

			MOV16(maze_memory_alloc, ZP1)					//move pointer to ZP1
			CALC_GRID_LOCATION(test_pointer)				//grid address now in ZP1

			ldy #0
			lda (ZP1),y
			cmp #DOT										//is dot? (empty)
			beq shift										//yes, shift on x
															//no, check others
			ldy TEMPY										//restore y
			iny
			cpy #08
			bne repeat
	cont:	
			dex
			bmi out										//less than zero, stop
			jmp each									//loop back, branch too far
	out:	rts
	shift:
			stx TEMPX									//save x
			stx VAR_A									//set index to VAR_A
			MOV8(candidates_length, VAR_B)				//set length to VAR_B
			SPLICE_ARRAY(candidates, 2)					//splice candidates at x, uses BV1
			MOV8(candidates_length, VAR_B)				//set length to VAR_B, as splice is changing that
			SPLICE_ARRAY(candidates_vectors, 2)			//splice candidates_vectors at x, uses BV1
			dec candidates_length						//dec array length
			ldx TEMPX									//restore x
			jmp cont									//return to loop
}

/*****************************************************************/

CANDIDATE_FROM_STACK:
{
														//direction
				SUB_C_16(STKPTR1, 2)					//stackpointer - 2
				ldy #0									//x
				lda (STKPTR1),y
				sta candidates_vectors,y
				iny										//y
				lda (STKPTR1),y
				sta candidates_vectors,y
														//grid
				SUB_C_16(STKPTR1, 2)					//stackpointer - 2
				ldy #0									//x
				lda (STKPTR1),y
				sta candidates,y
				iny										//y
				lda (STKPTR1),y
				sta candidates,y

				lda #01
				sta candidates_length
	out: 		rts
}

/*****************************************************************/

CHECK_BIAS:
/** returns found index or -1 in accumulator */
{
				ldx candidates_length
				dex
	each:		txa
				asl 								// length to offset in
				tay									// y
				lda candidates_vectors,y			// x dim
				cmp bias_direction
				bne not 							//not same
				iny
				lda	candidates_vectors,y			// y dim	
				cmp bias_direction+1				//the same
				beq found
	not:		dex
				bpl each
				lda #-1								//not found: -1
				rts
	found:		txa									//index in acc
				rts
}

/*****************************************************************/
STORE_DEAD_END:
/**
	DE pointer in STKPTR3
	data size 2
	DE in maze_start
*/
{
.break
				ldy #0
				lda maze_start			//x
				sta (STKPTR3),y
				iny
				lda maze_start+1		//y
				sta (STKPTR3),y
				inc DE_counter			//assumption always less than 255
				ADD_C_16(STKPTR3, 2)

				//debug start
				CALC_COLOR_LOCATION(maze_start)			//color loc in ZP1
				lda #RED
				ldy #0
				sta (ZP1),y
				//debug end
.break

	out:		rts
}

/*****************************************************************/

CONNECT_DEAD_ENDS: 
/**
	expects dead ends pointer at (datasize 2) at STKPTR3
	DE_counter (<= 255)
	uses GLOBAL_X, all subroutines must stay away from it
*/
{			
.break
				SET_ADDR(DEAD_END_STACK, STKPTR3)		//reset address to point to start of the stack
.break
				ldx DE_counter							//starting from last DE towards 0th
				dex
	each_DE:	stx GLOBAL_X
				txa
				asl 									//datasize=2
				tay										//offset in y
				
.break
				lda (STKPTR3),y
				sta maze_start
				iny
				lda (STKPTR3),y
				sta maze_start+1						//selected Dead End --> in maze_start
.break

				//debug start, green currently considered
				/*
				CALC_COLOR_LOCATION(maze_start)			//color loc in ZP1
				lda #GREEN
				ldy #0
				sta (ZP1),y
				*/
				//debug end
				//DEBUG
.break
				//jmp end_loop
				//DEBUG

				CheckConnection(maze_start)				//result in VAR_D
				lda VAR_D								//check if still DE (only one grid is dot, rest are wall)
				cmp #01									//--> number of connections is exactly 1
				beq still_DE							//yes
														//no, paint neutral

				//debug start, not DE anymore --> lightgrey
				
				CALC_COLOR_LOCATION(maze_start)			//color loc in ZP1
				lda #LIGHTGREY
				ldy #0
				sta (ZP1),y
				
				//debug end
				jmp end_loop							//no, check next
	still_DE:
				jsr POINTERS_FROM_START					//candidates for bridges in candidates
				jsr FILTER_IF_OUT
				jsr FILTER_IF_DOT
				Filter_If_Next_Primary_Is(WALL)
				Filter_if_N_Connections(2)

				//debug start, DE already considered
				
				CALC_COLOR_LOCATION(maze_start)			//color loc in ZP1
				lda #LIGHTGREY
				ldy #0
				sta (ZP1),y
				
				//debug end
				
				
				lda candidates_length						//check how many we have
				cmp #00										//if zero break;
				bne more									//more than 0

															//zero options
				ldy #0										//store into remainder stack
				lda maze_start								//x
				sta (STKPTR5),y
				iny
				lda maze_start+1							//y
				sta (STKPTR5),y
				inc REM_DE_counter							//assumption always less than 255
				ADD_C_16(STKPTR5, 2)						//inc REM DE stackpointer

				//debug start, DE already considered, but not solved -> to purple
				
				CALC_COLOR_LOCATION(maze_start)				//color loc in ZP1
				lda #PURPLE
				ldy #0
				sta (ZP1),y
				
				//debug end

				jmp end_loop								//nothing to paint
	more:
				cmp #02										//if it is two or more
				bcs select_random							//go to else/select_random
				lda #0										//otherwise, index->0 in A									
				jmp skip_else
select_random:
				lda candidates_length						//random index (, candidates length-1)
				tax
				dex
				stx ZP0
				RandomX(ZP0)
				lda WINT
	skip_else:												//index in a	
				asl 										//datasize=2	
				tay											//offset in y
															//selected candidate to maze_start 
				lda candidates,y	
				sta maze_start
				iny
				lda candidates,y
				sta maze_start+1
				jsr MAZE_DOT								//and paint

				//debug start							//DE solved as blue
				/*
				CALC_COLOR_LOCATION(maze_start)			//color loc in ZP1
				lda #BLUE
				ldy #0
				sta (ZP1),y
				*/
				//debug end
				
.break
	end_loop:	
				ldx GLOBAL_X
				dex
				bmi out
				jmp each_DE
	out:		rts
}

/*****************************************************************/

MAKE_ROOMS:
/** 
	by default only four rooms are made
	room definition:
		x,y grid top left
		sizex, sizey: width, height
*/

{	
				ldx #0
		each:	stx TEMPX
				txa
				asl
				asl
				tay					//datasize 4 from x to y
									//top x
				lda #0
				sta ZP2
				sta ZP4
				lda room_def,y
				sta ZP1				//x from
				lda room_def+1,y
				sta ZP3				//x to
				sty TEMPY
				jsr rnd_XY
				lda WINT
				ldy TEMPY
				sta rooms,y			//top x random(from, to)
									//top y
				lda #0
				sta ZP2
				sta ZP4
				lda room_def+2,y
				sta ZP1				//y from
				lda room_def+3,y
				sta ZP3				//y to
				sty TEMPY
				jsr rnd_XY
				lda WINT
				ldy TEMPY
				iny
				sta rooms,y			//top y random(from, to)
									//w
				lda #0
				sta ZP2
				sta ZP4
				lda #MIN_W
				sta ZP1
				lda #MAX_W
				sta ZP3
				sty TEMPY
				jsr rnd_XY
				lda WINT
				ldy TEMPY
				iny	
				sta rooms,y			//w
									//h
				lda #0
				sta ZP2
				sta ZP4
				lda #MIN_W
				sta ZP1
				lda #MAX_W
				sta ZP3
				sty TEMPY
				jsr rnd_XY
				lda WINT
				ldy TEMPY
				iny	
				sta rooms,y			//h

				ldx TEMPX
				inx
				cpx #ROOM_NUMBER
				bne each

	out:		rts
}

/*****************************************************************/
GET_EXIT_CANDIDATES:
/**

room index in A
uses x,y,a
TEMPX,2
TEMPY,2
ZP0,BV0

*/
{
	init:		ldx #0
				stx exit_candidates_length		//reset ...
				asl 							//room index in A
				asl 							//* 4 and to y	
				tay								//y offset of room index, datzasize = 4
												//x +i, y-1, i = 0, w+1 
												//x +i, y+h, i = 0, w+1 
				lda rooms+1,y					//y
				sta TEMPY
				dec TEMPY						//y-1
				clc
				adc rooms+3,y
				sta TEMPY2						//y+h
				lda rooms+2,y
				sta ZP0	
				lda rooms,y
				sta BV0							//x + i

				sty VAR_A						//save offset of room index
				ldx #00
	width_loop:		lda	exit_candidates_length
					asl 							//datasize of candidates = 2
					tay								//exit_candidates offset in y
													//up
					lda	BV0							//x+i
					sta exit_candidates,y	
					lda #0
					sta exit_candidate_dirs,y
					iny
					lda TEMPY						//y-1
					sta exit_candidates,y
					lda #-1							
					sta exit_candidate_dirs,y
					iny
					inc exit_candidates_length
													//down
					lda	BV0							//x+i
					sta exit_candidates,y	
					lda #0
					sta exit_candidate_dirs,y
					iny
					lda TEMPY2						//y+h
					sta	exit_candidates,y	
					lda #1
					sta exit_candidate_dirs,y
					inc exit_candidates_length		
					
					inc BV0							//i++
					inx
					cpx ZP0
					bne width_loop
												
												//cont with height loop
				ldy VAR_A						//restore offset of room index
												//x-1, y + i, i= 0, h+1
												//x + w, y+i, i = 0,h+1
				lda rooms,y						//x
				sta TEMPX
				dec TEMPX						//x-1
				clc
				adc rooms+2,y
				sta TEMPX2						//x+w
				lda rooms+3,y					//h
				sta ZP0
				lda rooms+1,y
				sta BV0							//y + i

				ldx #00
	height_loop:	lda	exit_candidates_length
					asl 							//datasize of candidates = 2
					tay								//exit_candidates offset in y
													//left
					lda TEMPX						//x-1
					sta exit_candidates,y
					lda #-1
					sta exit_candidate_dirs,y
					iny
					lda BV0							//y+i
					sta exit_candidates,y
					lda #0
					sta exit_candidate_dirs,y
					iny
					inc exit_candidates_length
													//right
					lda TEMPX2						//x+w
					sta exit_candidates,y
					lda #01
					sta exit_candidate_dirs,y
					iny
					lda BV0							//y+i
					sta exit_candidates,y
					lda #0
					sta exit_candidate_dirs,y
					iny
					inc exit_candidates_length

					inc BV0							//i++
					inx
					cpx ZP0
					bne height_loop				
	out: 		rts
}

/*****************************************************************/

SET_START:
{
				lda #0							//room index in A
				jsr GET_EXIT_CANDIDATES
				lda exit_candidates_length
				sta ZP0
				dec ZP0
				RandomX(ZP0)
				lda WINT
				asl 
				tay
				lda exit_candidates,y
				sta maze_start
				iny
				lda exit_candidates,y
				sta maze_start+1
	out: 		rts
}

/*****************************************************************/

CONNECT_ROOMS:
/** 
room with index 0 is already connected
room length = 4; data only for 4 rooms 
*/

{
				ldx #01												//start with index 1, 0 should be already connected
	each:		stx GLOBAL_X											//save x
				txa													//GET_EXIT_CANDIDATES expects room index in A
				jsr GET_EXIT_CANDIDATES								//trashes TEMPX
																	//each room
	get_one:	ldy exit_candidates_length
				dey
				sty ZP0
				RandomX(ZP0)
				lda WINT											//random index
				asl 
				tay													//offset in y
																	//storing bridge and dir
				lda exit_candidates,y
				sta grid_pointer									//bridge
				lda exit_candidate_dirs,y
				sta direction_pointer								//dir to test
				iny
				lda exit_candidates,y
				sta grid_pointer+1
				lda exit_candidate_dirs,y
				sta direction_pointer+1							
																	//calc test
				lda grid_pointer
				clc
				adc direction_pointer
				sta test_pointer
				lda grid_pointer+1
				clc
				adc direction_pointer+1
				sta test_pointer+1
																	//check if test pointer is dot
				MOV16(maze_memory_alloc, ZP1)
				CALC_GRID_LOCATION(test_pointer)
				ldy #0
				lda (ZP1),y
				cmp #DOT											//is it dot
				beq check_connections								//yes, check connections
																	//no, splice and repeat, index still in WINT
				lda WINT											//random index was still in WINT
				sta VAR_A											//store index in VAR_A
				MOV8(exit_candidates_length, VAR_B)					//set length to VAR_B
				SPLICE_ARRAY(exit_candidates, 2)					//splice candidates at x, uses BV1
				MOV8(exit_candidates_length, VAR_B)					//set length to VAR_B
				SPLICE_ARRAY(exit_candidate_dirs, 2)				//splice candidates at x, uses BV1
				dec exit_candidates_length							//exit_candidates_length--
				jmp get_one											//try another

check_connections:													//check connections of the bridge
				CheckConnection(grid_pointer)						//number of connections in VAR_D
				lda VAR_D
				cmp #02												//exactly two directions required for bridge
				beq yes												//yes, paint
				jmp get_one											//not ok, get another
	yes:															//paint
				MOV16(maze_memory_alloc, ZP1)
				CALC_GRID_LOCATION(grid_pointer)					//paint dot of bridge, which is in grid_pointer
				lda #DOT
				ldy #0
				sta (ZP1),y
				
				ldx GLOBAL_X										//restore x
				inx													//next room
				cpx #ROOM_NUMBER
				beq out
				jmp each
	out: 		rts
}

/*****************************************************************/

.macro CheckConnection(bridge){
/**
bridge: pointer to bridge x: bridge, y: bridge + 1 --> BV7, BV8
uses: BV7,BV8,BV9,BV10, VAR_D
uses: ZP1,ZP2
uses: x,y,a
result: VAR_D number of connections
*/
				lda bridge
				sta BV7
				lda bridge+1
				sta BV8
				lda #0
				sta VAR_D
				jsr CHECK_CONNECTION
}

CHECK_CONNECTION:
{
				ldx #03						//iterate over directions
	each:		txa
				asl
				tay							//offset in y
				lda BV7
				clc
				adc BASIC_DIRS,y
				sta BV9						//test.x
				iny
				lda BV8
				clc
				adc BASIC_DIRS,y
				sta BV10					//test.y
											
				MOV16(maze_memory_alloc, ZP1)
				CALC_GRID_LOCATION(BV9)
				ldy #0
				lda (ZP1),y
				cmp #DOT
				bne skip
				inc VAR_D
											
	skip:		dex
				bpl each

	out:		rts
}


/*****************************************************************/

//--- MAIN -------------------------------------------------------

MAZE:
{
				jsr STORE_DEAD_END							//start grid might remain DE!!
outer:
	/** single branch loop */
	P_LOOP:
				jsr MAZE_DOT
				jsr POINTERS_FROM_START
				jsr FILTER_IF_OUT
				jsr FILTER_IF_DOT
				Filter_If_Next_Primary_Is(DOT)
				jsr FILTER_SIDE_PROXIMIY
															//select candidate
				lda candidates_length						//check how many we have
				cmp #00										//if zero break;
				bne more									//more than 0
															//zero options
				jsr STORE_DEAD_END							//store dead end
				jmp S_LOOP

		more:	cmp #02										//if it is two or more
				bcs then									//go to else/then
				lda #0										//otherwise, index->0 in A									
				jmp skip_else
		then:	
															//check bias
				lda bias_counter
				cmp #00
				beq select_random							//use random, not bias
															//use bias
				jsr CHECK_BIAS								//index in a, or -1 if not found
				cmp #-1
				bne skip_else								//not -1, select this direction
select_random:	
				lda #0										//reset bias counter when selection is random	
				sta bias_counter
				lda candidates_length						//random index (, candidates length-1)
				tax
				dex
				stx ZP0
				RandomX(ZP0)
				lda WINT

		skip_else:
				sta ZP0										//store index in ZP0	
				asl 										//datasize=2	
				tay											//offset in y
															//selected candidate to maze_start 
				lda candidates,y
				sta maze_start
				lda candidates_vectors,y
				sta bias_direction
				iny
				lda candidates,y
				sta maze_start+1
				lda candidates_vectors,y
				sta bias_direction+1
				BIAS_NEXT()
															//store remaining candidates on STACK
				lda candidates_length
				cmp #02										//if there are 2 or more, selected has not been discarded yet
				bcc repeat_P								//no, repeat loop
															//yes
				jsr PUSH_REST_ON_STACK													
			
	repeat_P:	jmp P_LOOP
	
	/** take from stack */
	S_LOOP:
															//check stack pointer: STKPZR1 vs STACK
				lda STKPTR1
				cmp #<STACK
				bne cont
				lda STKPTR2
				cmp #>STACK
				bne cont
				jmp quit									//stack pointer == STACK, stack is empty

		cont:
				jsr CANDIDATE_FROM_STACK					//take on grid an its direction from stack
				Filter_If_Next_Primary_Is(DOT)				//recheck if they are still 'safe'
				jsr FILTER_SIDE_PROXIMIY					//in terms of proximity

				lda candidates_length						//check if it is still ok
				cmp #00										//if zero break; 
				beq S_LOOP									//no, find another
															//yes
				lda candidates								//set it to maze_start
				sta maze_start
				lda candidates+1
				sta maze_start+1
				jmp P_LOOP									//make next branch
quit:
				rts
}

//-----------------------MEMORY-------------------------------

MAZE_memory: 				* = MAZE_memory "MAZE Memory"
maze_memory_alloc:			.word $0004 					//screen by default
maze_start:					.word 0
grid_pointer:				.word 0
direction_pointer:			.word 0
test_pointer:				.word 0
candidates:
.for(var i=0; i<4; i++)		.fill 2,0
candidates_vectors:
.for(var i=0; i<4; i++)		.fill 2,0
candidates_length: 			.byte 0
proximity_vectors:
.for(var i=0; i<4; i++)		.fill 2,0
bias:						.byte 2
bias_counter:				.byte 0
bias_direction:				.word 0
DE_counter:					.byte 0
REM_DE_counter:				.byte 0
rooms:
.for(var i=0; i<4; i++)		.fill 4,0
room_def:					
							.byte 3, 14, 3, 6
							.byte 23, 33, 3, 6
							.byte 3, 14, 14, 17
							.byte 23, 33, 14, 17
exit_candidates:			.fill MAX_W * 4 * 2, 0
exit_candidate_dirs:		.fill MAX_W * 4 * 2, 0
exit_candidates_length:		.byte 0
//----------------------------------------------------------------	