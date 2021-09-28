#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_Keyboard.asm
v0.01

dependencies:
	standard includes
memory:
	none

*****************************************************************/
#import "LIB_SymbolTable.asm"
//-----------------------CONST-----------------------------------

//--- SUBS -------------------------------------------------------

//--- MACRO ------------------------------------------------------
.macro WaitAnyKey(){
/*
	keycode still in A
*/
key:		
			lda LSTX		//get character in A
			cmp #64			//no key
			beq key
}
//----------------------------------------------------------------	
