#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_System.asm
v0.02

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
//----------------------------------------------------------------	
