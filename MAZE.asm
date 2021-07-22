/*
	Empty Template

*/
//java -jar kickass.jar MAZE.asm

.const VER	= "0.01"
#import "Include\LIB_SymbolTable.asm"

//------------------------DISK------------------------------

.disk [filename= "MAZE.d64", name = "MAZE"]
{
[name="MAZE", type="prg", segments="MAZE" ],
}

//------------------------BASIC-----------------------------

.segment MAZE []
#import "Include\LS_StandardBasicStart.asm"

//-----------------------CONST-------------------------------


//-----------------------START------------------------------

		* = $0810 "Main"
begin:
		FillScreen(SCREEN, $E0)
		WaitAnyKey()
		
end:
		rts


//-----------------------SUBS-------------------------------
subs:	* = subs "Subroutines"

//------ IMPORTS ----

//#import "Include\LS_ConsolePrint.asm" 
//#import "Include\LS_Interrupt.asm"
//#import "Include\LS_System.asm"
#import "Include\LS_Keyboard.asm"
#import "Include\LS_Screen.asm"
//#import "Include\LS_Random.asm"


//-----------------------TEXT-------------------------------
text: 		* = text "Text"

		
//-----------------------DATA-------------------------------
data: 		* = data "Data"

//--------------------MACROS--------------------------------

