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
//-----------------------CONST-----------------------------------

.const WALL 	= $E0
.const DOT 		= $20

//-----------------------MACROS-----------------------------
.macro INIT_MAZE(memory, start){
/*
arguments: memory: 	memory address of where to create maze
					default $0400 (screen)
*/
	lda #<memory
	sta maze_memory_alloc
	lda #>memory
	sta maze_memory_alloc+1
	MOV16(start, maze_start)

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

//--- MAIN -------------------------------------------------------
MAZE:
{
			jsr MAZE_FILL
outer:
	P_LOOP:
			jsr MAZE_DOT
	S_LOOP:

quit:
			rts
}

//-----------------------DATA-------------------------------

MAZE_memory: 		* = MAZE_memory "MAZE Memory"
maze_memory_alloc:	.word $0040 	//screen by default, safe
maze_start:			.word 0

//----------------------------------------------------------------	