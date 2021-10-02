#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_MAZE.asm
v0.03

MAZE structs and methods

dependencies:
	standard includes
memory:
	
*****************************************************************/
#import "LS_System.asm"
#import "LS_ConsolePrint.asm"
#import "LS_GRID.asm"
//-----------------------CONST-----------------------------------

.const WALL 	= $E0
.const DOT 		= $20
.const STACK	= $C000
.const DSIZE	= 4

//-----------------------MACROS-----------------------------
.macro INIT_MAZE(memory, start){
/*
arguments: memory: 	memory address of where to create maze
					default $0400 (screen)
*/

	.const STACK	= $C000

	SET_ADDR(memory, maze_memory_alloc)
	MOV16(start, maze_start)
	SET_ADDR(STACK, stack_pointer)

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

MAZE_DOT:
/** assumes start grid set */
{
			MOV16(maze_memory_alloc, ZP1)
			lda #0
			sta ZP4				
			lda maze_start+1		
			sta ZP3
		
			ldy #03
mul8:		ASL16(ZP3)
			dey
			bne mul8
			ADD16(ZP1,ZP3)
			ldy #02	
mul32:		ASL16(ZP3)
			dey
			bne mul32
			ADD16(ZP1,ZP3)	
			ADD8to16(ZP1,maze_start)

			lda #DOT
			ldy #0
			sta (ZP1),y
			rts
}

POINTERS_FROM_START:
{
			cld
			SET_ADDR(candidates, ZP1)
			SET_ADDR(BASIC_DIRS, ZP3)
			ldx #03
	add:	txa
			asl
			tay		//y= (x-1) *2; offset
			//x
			clc
			lda maze_start
			adc (ZP3),y
			sta (ZP1),y
			iny
			//y
			clc
			lda maze_start+1
			adc (ZP3),y
			sta (ZP1),y
			dex
			bpl add
			rts
			
}

//--- MAIN -------------------------------------------------------
MAZE:
{
			jsr MAZE_FILL
outer:
	P_LOOP:
			jsr MAZE_DOT
			jsr POINTERS_FROM_START
	S_LOOP:

quit:
			rts
}

//-----------------------MEMORY-------------------------------

MAZE_memory: 				* = MAZE_memory "MAZE Memory"
maze_memory_alloc:			.word $0040 	//screen by default, safe
maze_start:					.word 0
stack_pointer:				.word 0
candidates:
.for(var i=0; i<4; i++)		.fill 2,0
candidates_vectors:
.for(var i=0; i<4; i++)		.fill 2,0
candidates_length: 			.byte 0

//----------------------------------------------------------------	