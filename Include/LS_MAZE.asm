#importonce

//----------------------------------------------------------------			
/*****************************************************************
LS_MAZE.asm
v0.15

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

//-----------------------CONST-----------------------------------

//.const WALL 	= $E0
.const WALL 	= $00
.const DOT 		= $20
.label STACK	= $C000
.const DSIZE	= 4
.const MAX_X	= 38
.const MIN_X	= 1
.const MAX_Y 	= 23
.const MIN_Y 	= 1
.label DEAD_END_STACK 	= $C400 	//max 256 bytes expected
.label DE_REMAINDER		= $C500

//-----------------------MACROS-----------------------------

.macro INIT_MAZE(memory){

/*
arguments: memory: 	memory address of where to create maze
					default $0400 (screen)
*/

	SET_ADDR(memory, maze_memory_alloc)
	//MOV16(start, maze_start)
	SET_ADDR(STACK, STKPTR1)
	//dead end stacks
	SET_ADDR(DEAD_END_STACK, STKPTR3)
	SET_ADDR(DE_REMAINDER, STKPTR5)
	lda #00
	sta DE_counter
	sta REM_DE_counter

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
/** assumes start grid set */
{
			MOV16(maze_memory_alloc, ZP1)
			CALC_GRID_LOCATION(maze_start)

			lda #DOT
			ldy #0
			sta (ZP1),y
			rts
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

FILTER_IF_CLOSE_PRIMARY:
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
			cmp #DOT									//is dot? (empty)
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
*/
{
				ldy #0
				lda maze_start			//x
				sta (STKPTR3),y
				iny
				lda maze_start+1		//y
				sta (STKPTR3),y
				inc DE_counter			//assumption always less than 255
				ADD_C_16(STKPTR3, 2)
	out:		rts
}

/*****************************************************************/

CONNECT_DEAD_ENDS: {
/**
	expects dead ends pointer at (datasize 2) at STKPTR3
	DE_counter (< 256)
*/
	//check if still DE (only one grid is dot, rest are wall)

	out:		rts
}

/*****************************************************************/
//--- MAIN -------------------------------------------------------
MAZE:
{
				jsr MAZE_FILL
				//start grid might be DE!!
				jsr STORE_DEAD_END
outer:
	/** single branch loop */
	P_LOOP:
				jsr MAZE_DOT
				jsr POINTERS_FROM_START
				jsr FILTER_IF_OUT
				jsr FILTER_IF_DOT
				jsr FILTER_IF_CLOSE_PRIMARY
				jsr FILTER_SIDE_PROXIMIY
															//select candidate
				lda candidates_length						//check how many we have
				cmp #00										//if zero break;
				//beq S_LOOP								//goto stack loop
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
				jsr FILTER_IF_CLOSE_PRIMARY					//recheck if they are still 'safe'
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
//----------------------------------------------------------------	