#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_MAZE.asm
v0.01

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

//-----------------------STRUCT-----------------------------------

//.struct Grid {x, y}
//.struct Vector {x, y}

//--- SUBS -------------------------------------------------------

//-----------------------DATA-------------------------------
//#name#: 		* = #name# "#name#"


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
		lda ZP1
		ldy grid+1		//grid.y
loop:	clc
		adc #$28
		sta ZP1
		bcc skip
		inc ZP2
skip:	dey
		bne loop
		clc
		adc grid		//grid.x
		sta ZP1
		bcc skip2
		inc ZP2
skip2:	lda #DOT
		ldy #0
		sta (ZP1),y
}
//.const WALL = $E0
.macro MAZE(start){
/*
arguments: start: grid(x,y)
*/
		.const WALL = $E0
		MAZE_fill(WALL)

begin:	MAZE_dot(start)
}


//-----------------------DATA-------------------------------

MAZE_memory: 		* = MAZE_memory "MAZE Memory"
maze_memory_alloc:	.word $0040 	//screen by default, safe

//----------------------------------------------------------------	