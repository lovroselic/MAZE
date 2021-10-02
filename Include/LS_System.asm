#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_System.asm
v0.03

dependencies:
	standard includes
memory:
	none

*****************************************************************/
#import "LIB_SYS.asm"
#import "LIB_Basic.asm"
//-----------------------CONST-----------------------------------

//--- SUBS -------------------------------------------------------

//--- MACRO ------------------------------------------------------
.macro StringToInt8(pointer){
/*
arguments: pointer to zero terminated string
return: X: 8-bit int
*/
			lda #>pointer
			ldx #<pointer
			stx TXTPTR
			sta TXTPTR+1
			jsr CHRGET
			jsr EVALNUM
}
.macro MOV8(X, Y){
/*
arguments: X origin, Y destination
*/
			lda X
			sta Y
}
.macro MOV16(X, Y){
/*
arguments: X origin, Y destination
*/
			lda X
			sta Y
			lda X + 1
			sta Y + 1
}
.macro CLEAR16(X){
/*
arguments: X 16 bit address to be set to 0
*/
			lda #0
			sta X
			sta X+1
}
.macro ASL16(X){
/*
arguments: X 16 bit address, value shifted left

*/
			asl X
			rol X+1	
}

.macro ADD16(X,Y){
/*
arguments: X,Y 16 bit addresses; add value of Y to X
result in X
16 bit overflow ignored, but carry is set
*/	
		clc
		lda X
		adc Y
		sta X
		bcc skip
		inc X+1
skip:	clc
		lda X+1
		adc Y+1
		sta X+1	
}

.macro ADD8to16(X,y){
/*
arguments: 	X 16 bit address; 
			y B bit
add value of y to X
result in X
16 bit overflow ignored, but carry is set
*/		
		clc
		lda X
		adc y	
		sta X
		bcc out+2
out:	inc X+1
}

.macro SET_ADDR(addr,X){
/*
arguments: 
	addr  	address
	X 		storage location (pointer)	
*/
		lda #<addr
		sta X
		lda #>addr
		sta X+1
}
//----------------------------------------------------------------	
