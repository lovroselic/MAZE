#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_System.asm
v0.01

dependencies:
	standard includes
memory:
	none

*****************************************************************/
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
//----------------------------------------------------------------	
