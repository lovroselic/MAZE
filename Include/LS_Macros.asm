/*
Collection of macros
used by GMN, RND

v0.02
*/


.macro InputInteger(n){
/*
arguments: y: number of places
return: none
*/
		ldy #n
		jsr getNumber
}
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
		EndLine()
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
		sta	STR_len					//cached
		lda #maxCOL
		sec
		sbc STR_len
		bcc	skip					//its too long
		clc
		ror 						// div 2
		sta	CUR_X
		jsr CALC_CURSOR
skip:	PrintText(text)

}
.macro ExitInterrupt(){
		pla
		tay
		pla
		tax
		pla
		rti
}
.macro AcknowledgeInterrupt(){
		asl INTERRUPT_REQUEST_REGISTER
}
.macro SetIrqVector(address){
		lda #<address
		sta IRQVEC
		lda #>address
		sta	IRQVEC+1
}
.macro TurnOffCiaInterrupt(){
		lda #$7f
		sta CIA_ICR
		sta CIA2_ICR
		lda CIA_ICR
		lda CIA2_ICR
}
.macro EnableRasterInterrupt(){
		lda INTERRUPT_MASK_REGISTER	
		ora #$01
		sta INTERRUPT_MASK_REGISTER
}
.macro Clear_RST8(){
		lda CONTROL_REGISTER1
		and #$7f
		sta CONTROL_REGISTER1
}
.macro Set_RST8(){
		lda CONTROL_REGISTER1	
		ora #$80
		sta CONTROL_REGISTER1
}
.macro SetSIDforRandom(){
		lda #$ff
		sta FV3LO
		sta FV3HI
		lda #$80
		sta CTRLREG_V3
}
.macro Console32(x){
//??
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