/*
	MAZE demo
	in progress

http://unusedino.de/ec64/technical/project64/mapping_c64.html
https://www.c64-wiki.com/wiki/Zeropage
http://www.c64os.com/post/6502instructions

*/
//java -jar kickass.jar MAZE.asm

.const VER	= "0.02.08"
#import "Include\LIB_SymbolTable.asm"

//------------------------DISK------------------------------
/*
.disk [filename= "MAZE.d64", name = "MAZE"]
{
[name="MAZE", type="prg", segments="MAZE" ],
}
*/
//------------------------BASIC-----------------------------
/*
.segment MAZE []
*/
#import "Include\LS_StandardBasicStart.asm"

//-----------------------CONST-------------------------------

.const startRaster = 50
.const endRaster = 250

//-----------------------START------------------------------

		* = $0810 "Main"

		//interupt
		sei							//set interrupt
		TurnOffCiaInterrupt()
		EnableRasterInterrupt()
		Clear_RST8()
		lda #startRaster
		sta RASTER_COUNTER
		SetIrqVector(irqcode)
		cli
		//interrupt end

begin:
		//FillScreen(SCREEN, $E0)
		//WaitAnyKey()

init:
		SetSIDforRandom()
		RandomNumber(1, 38)
		//debug
		//lda #38
		//sta WINT
		//
		MOV8(WINT,startX)
		RandomNumber(1, 23)
		//debug
		//lda #23
		//sta WINT
		//
		MOV8(WINT,startY)

		INIT_MAZE(SCREEN, startX)

		jsr MAZE
		//MAZE(startX)

		//WaitAnyKey()
		//debug
		/*
		Console8(startX)
		Comma()
		Console8(startY)
		EndLine()
		EndLine()
		*/
		//debug candidates
		/*
		.for(var i = 0;i<4;i++){
			.var t = candidates + 2*i
			Console8(t)
			Comma()
			Console8(t+1)
			EndLine()
		}
		*/
		
		
end:
		WaitAnyKey()
		rts


//-----------------------SUBS-------------------------------
imports:	* = imports "Imports"

//------ IMPORTS ----

#import "Include\LS_ConsolePrint.asm" 
#import "Include\LS_Interrupt.asm"
#import "Include\LS_System.asm"
#import "Include\LS_Keyboard.asm"
#import "Include\LS_Screen.asm"
#import "Include\LS_Random.asm"
#import "Include\LS_GRID.asm"
#import "Include\LS_MAZE.asm"

//-----------------------SUBS-------------------------------
subs:	* = subs "Subroutines"

//------ INTERRUPT ----
irqcode:
{
	lda modeflag
	beq mode1
	jmp mode2

mode1:
	lda #$01
	sta modeflag
	lda #LIGHTBLUE
	sta BORDER
	lda #startRaster
	sta RASTER_COUNTER
	AcknowledgeInterrupt()
	jmp IRQOUT

mode2:
	lda #$00
	sta modeflag
	lda #BLUE
	sta BORDER
	lda #endRaster
	sta RASTER_COUNTER
	AcknowledgeInterrupt()
	ExitInterrupt()
}


//-----------------------TEXT-------------------------------

text: 		* = text "Text"

		
//-----------------------DATA-------------------------------

data: 		* = data "Data"
modeflag:		.byte 0
startX:			.byte 0
startY:			.byte 0

//--------------------MACROS--------------------------------

