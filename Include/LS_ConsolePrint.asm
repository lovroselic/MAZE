#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_ConsolePrint.asm
v0.03

dependencies:
	standard includes
memory:
	none

*****************************************************************/
//-----------------------CONST-----------------------------------

//--- SUBS -------------------------------------------------------

printSequence:
{
			jsr CHROUT
			dex
			bne printSequence
			rts
}
printString:
{
			stx ZP1			//lo
			sty	ZP2			//hi
next:		ldy #$00
			lda (ZP1),y		//load character
			cmp #$00
			beq	out			//null terminator
			jsr CHROUT
			clc
			inc	ZP1
			bne	next
			inc ZP2
			jmp next
out:		rts
}	
lenString:
{
			stx ZP1			//lo
			sty	ZP2			//hi
			ldy #$00		
			sty ZP3			//counter
next:		lda (ZP1),y		//load character
			cmp #$00
			beq	out			//null terminator
			iny
			jmp next
out:		tya
			rts
}

//--- MACRO ---------------------------------------------------------
.macro ConsoleX(){
/*
arguments: none
return: none
*/
		lda #00
		jsr PRINT_INT
		EndLine()
} 
.macro ConsoleY(){
/*
arguments: none
return: none
*/
		tya
		tax
		lda #00
		jsr PRINT_INT
		EndLine()
}
.macro ConsoleA(){
/*
arguments: none
return: none
*/
		tax
		lda #00
		jsr PRINT_INT
		//EndLine()
}
.macro PrintSequence(char,repeat){
/*
arguments: character code, number of repeats
assume: 255 is max
*/
		lda #char
		ldx #repeat
		jsr printSequence
}
.macro Console16(x){
/*
arguments: pointer to number (16 bit) A: HI, X: lo
return: none
*/
		lda x+1
		ldx x
		jsr PRINT_INT
} 
.macro Console8(x){
/*
arguments: pointer to number (8 bit) A: HI, X: lo
return: none
*/
		lda #00
		ldx x
		jsr PRINT_INT
} 
.macro Comma(){
		lda #CHR_Comma
		jsr CHROUT
}
.macro EndLine(){
		lda #CHR_Return
		jsr CHROUT
}
.macro LenText(text){
/*
arguments: null terminated pointer to text
return: A: string length
assume: 255 is max
*/
		ldy #>text
		ldx #<text
		jsr lenString
}
.macro PrintText(text){
/*
arguments: null terminated pointer to text
return: none
*/
		ldy #>text
		ldx #<text
		jsr printString
}
.macro PrintCentered(text){
/*
arguments: null terminated pointer to text
return: none
*/
		LenText(text)				//len is in A
		sta	ZP1						//cached
		lda #maxCOL
		sec
		sbc ZP1
		bcc	skip					//its too long
		clc
		ror 						// div 2
		sta	CUR_X
		jsr CALC_CURSOR
skip:	PrintText(text)
}
.macro Console32(x){
/*
arguments: pointer to memory
return: none
*/
		lda #0
		ldx x
		jsr PRINT_INT
		lda #44
		jsr CHROUT
		lda #0
		ldx x+1
		jsr PRINT_INT
		lda #44
		jsr CHROUT
		lda #0
		ldx x+2
		jsr PRINT_INT
		lda #44
		jsr CHROUT
		lda #0
		ldx x+3
		jsr PRINT_INT
		EndLine()
}
.macro CenterSequence(char, len){
		lda #maxCOL
		sec
		sbc	#len
		clc
		ror
		sta CUR_X
		jsr CALC_CURSOR
		PrintSequence(char, len)
}

//-- LS_ConsolePrint.asm END -------------------------------------
//----------------------------------------------------------------	