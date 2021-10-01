#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_MAZE.asm
v0.02

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
.macro INIT_MAZE(memory){
/*
arguments: memory: 	memory address of where to create maze
					default $0400 (screen)
*/
	lda #<memory
	sta maze_memory_alloc
	lda #>memory
	sta maze_memory_alloc+1

}
.macro MAZE_fill(value){
/*
arguments: 	value	fill memory with value
implicit: memory of MAZE
*/
		MOV16(maze_memory_alloc, ZP1)
		lda	#value
		ldx #4
block:	ldy #0
fill:
		sta (ZP1),y
		iny
		bne fill
		inc ZP2
		dex
		bne block
}

.macro MAZE_dot(grid){
/*
arguments: grid 16 bit, address of x and y component
*/
.const DOT = $20
			MOV16(maze_memory_alloc, ZP1)
			lda #0
			sta ZP4			//clear, we don't know what is there
			lda grid+1		//grid.y
			sta ZP3
		
maze_dot:	ldy #03
mul8:		ASL16(ZP3)
			dey
			bne mul8
			ADD16(ZP1,ZP3)
			ldy #02	
mul32:		ASL16(ZP3)
			dey
			bne mul32
			ADD16(ZP1,ZP3)	
			ADD8to16(ZP1,grid)

			lda #DOT
			ldy #0
			sta (ZP1),y
}

.macro MAZE(start){
/*
arguments: start: grid(x,y)
*/
		.const WALL = $E0
		MAZE_fill(WALL)
		MAZE_dot(start)
		//jsr carve_maze
}

//--- SUBS -------------------------------------------------------




//-----------------------DATA-------------------------------

MAZE_memory: 		* = MAZE_memory "MAZE Memory"
maze_memory_alloc:	.word $0040 	//screen by default, safe
maze_start:			.word 0

//----------------------------------------------------------------	