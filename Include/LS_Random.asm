#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_Random.asm
v0.01

dependencies:
	standard includes
memory:
	dataRND: 5byte
*****************************************************************/
//-----------------------CONST-----------------------------------

//--- SUBS -------------------------------------------------------

rnd_XY:
{			
//output: random number (0, 32767) in WINT; 


			//reseed, to avoid repeated sequence
			lda #00
			jsr RND
			
			//++end 
			inc ZP3
			bne skip1
			inc ZP4
skip1:
			//- start
			lda ZP3
			sec
			sbc ZP1
			sta ZP3
			lda ZP4
			sbc ZP2
			sta ZP4			
toFloat:
			ldy ZP3
			lda ZP4
			jsr GIVAYF //A(h),Y(L) - FAC
			
			ldx #<flt
			ldy #>flt
			jsr MOVMF	//store FAC to flt
				
			//get actual RND(1)
			lda #$7f
			jsr RND
			
			//multiply by ++end - start
			lda #<flt
			ldy #>flt
			jsr FMULT
			
			//to integer
			jsr FAINT
			
			//FAC to int;
			jsr AYINT
			lda $65			
			clc
			adc ZP1
			sta WINT
			lda $64
			adc ZP2
			sta WINT+1
over:
			rts
			
}
//-----------------------DATA-------------------------------
dataRND: 		* = dataRND "Data RND"

flt:			.byte 0,0,0,0,0

//-----------------------MACROS-----------------------------
.macro Random2(){
/*
result: A (0,1)
*/
		lda #0
		jsr RND
		lda RND2
		and #%00000001	
}
.macro Random4(){
/*
result: A (0,1)
*/
		lda #0
		jsr RND
		lda RND2
		and #%00000011	
}
.macro RandomNumber(start, end){
/*
limits: 0 - 32767
arguments: 
	start -> ZP1, lower inclusive
	end -> ZP3, upper inclusive
return: WINT: 16-bit int
*/
		lda #<end	
		sta ZP3
		lda #>end
		sta ZP4
		lda #<start
		sta ZP1
		lda #>start
		sta ZP2
		jsr rnd_XY
}

.macro SetSIDforRandom(){
		lda #$ff
		sta FV3LO
		sta FV3HI
		lda #$80
		sta CTRLREG_V3
}
//----------------------------------------------------------------	