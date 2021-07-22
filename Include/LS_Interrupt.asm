#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_Interrupt.asm
v0.01

dependencies:
	standard includes
memory:
	none

*****************************************************************/

//--- SUBS -------------------------------------------------------

//--- MACRO ---------------------------------------------------------

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