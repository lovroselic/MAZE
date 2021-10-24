/*
	MAZE demo
	in progress

https://www.pagetable.com/c64ref/c64disasm/
http://unusedino.de/ec64/technical/project64/mapping_c64.html
https://www.c64-wiki.com/wiki/Zeropage
http://www.c64os.com/post/6502instructions
https://oldskoolcoder.co.uk/the-vic-ii-addressing-system/
https://www.georg-rottensteiner.de/c64/projectj/step2/step2.html
https://codebase64.org/doku.php?id=base:vicii_memory_organizing

*/
//java -jar kickass.jar MAZE.asm

.const VER	= "0.09.08"
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
/*****************************************************************/

		* = $0810 "Main"

setup:
		jsr COPY_CHAR_ROM_TO_RAM
		jsr set_bricks
		FillColor(LIGHTGREY)
		lda #BLACK
		sta BACKGROUND


interrupt:							//interupt
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
		cld
init:
		MAZE_BIAS(2)
		INIT_MAZE(SCREEN)
		jsr ROOMS
		jsr SET_START
		jsr MAZE
		jsr CONNECT_ROOMS

		// while DE > 0, repeat:
			jsr CONNECT_DEAD_ENDS
.break
			//jsr POLISH_DEAD_END
		
end:
		WaitAnyKey()
		jmp init
		rts


//-----------------------SUBS-------------------------------

imports:	* = imports "Imports"

//------ IMPORTS ----

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
	lda #BLACK
	sta BORDER
	lda #startRaster
	sta RASTER_COUNTER
	AcknowledgeInterrupt()
	jmp IRQOUT

mode2:
	lda #$00
	sta modeflag
	lda #LIGHTGREY
	sta BORDER
	lda #endRaster
	sta RASTER_COUNTER
	AcknowledgeInterrupt()
	ExitInterrupt()
}

/*****************************************************************/
set_bricks:
{
			.var char_offset = $3000 + 0 * 8		//@ screencode = 0
			ldx #00
copy:		lda brick_data,x
			sta char_offset,x
			inx
			cpx #08
			bne copy
			rts
}


//-----------------------TEXT-------------------------------

text: 		* = text "Text"

		
//-----------------------DATA-------------------------------

data: 		* = data "Data"
modeflag:		.byte 0
startX:			.byte 0
startY:			.byte 0
//brick_data: 	.byte $ee,$00,$77,$00,$dd,$00,$bb,$00
brick_data: 	.byte $dd,$c1,$38,$bb,$bb,$83,$1c,$dd
//--------------------MACROS--------------------------------

