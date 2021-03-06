#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_Random.asm
v0.05

dependencies:
	standard includes
memory:
	dataRND: 5byte
*****************************************************************/
/*****************************************************************/

// imports required
#import "LIB_SYS.asm"
#import "LIB_Basic.asm"
#import "LIB_Kernel.asm"
#import "LIB_SID.asm"
//-----------------------CONST-----------------------------------

//--- SUBS -------------------------------------------------------

rnd_XY:
{
/**

start inclusive in (ZP1)
end inclusive in (ZP3)
output: random number (0, 32767) in WINT; 

*/						
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
			jsr GIVAYF 					//A(h),Y(L) - FAC
			ldx #<flt
			ldy #>flt
			jsr MOVMF					//store FAC to flt		
			lda #$00					//RND(0)
			jsr RND						//$E09A
										//multiply by ++end - start
			lda #<flt
			ldy #>flt
			jsr FMULT					//Multiplies a number from RAM (A,y) and FAC	
			jsr FAINT					//to integer
			jsr AYINT					//fac to signed int HI $64 LO $65
			lda $65						//FAC mantissa lo
			clc
			adc ZP1						//add number to start	
			sta WINT
			lda $64						//FAC mantissa hi
			adc ZP2
			sta WINT+1
over:
			rts			
}

/*****************************************************************/

rnd_X:
{
/**

end inclusive in (ZP3)
output: random number (0, 255) in WINT; 

*/						
										//++end 
			inc ZP3
			bne toFloat
			inc ZP4	
toFloat:
			ldy ZP3
			lda ZP4
			jsr GIVAYF 					//A(h),Y(L) - FAC
			ldx #<flt
			ldy #>flt
			jsr MOVMF					//store FAC to flt		
			lda #$00					//get actual RND(0)
			jsr RND						//$E09A
										//multiply by ++end
			lda #<flt
			ldy #>flt
			jsr FMULT					//Multiplies a number from RAM (A,y) and FAC	
			jsr FAINT					//to integer
			jsr AYINT					//fac to signed int HI $64 LO $65
			lda $65						//FAC mantissa lo
			sta WINT					
			rts			
}

/*****************************************************************/
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

/*****************************************************************/

.macro Random4(){
/*
result: A (0,3)
*/
		lda #0
		jsr RND
		lda RND2
		and #%00000011	
}

/*****************************************************************/

.macro RandomNumber(start, end){
/*
limits: 0 - 32767
arguments: 
	start -> ZP1, lower inclusive
	end -> ZP3, upper inclusive
	changes: x,y,a
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

/*****************************************************************/

.macro RandomX(X){
/**
limits: 0 - 255
from 0 (inclusive), to value in X (inclusive)
arguments: 
	start -> ZP1, lower inclusive -> 0
	end -> ZP3, upper inclusive
	changes: x,y,a
return: WINT: 16-bit int
*/

		lda X	
		sta ZP3
		lda #0
		sta ZP4
		jsr rnd_X
}

/*****************************************************************/

.macro SetSIDforRandom(){
		lda #$ff
		sta FV3LO
		sta FV3HI
		lda #$80
		sta CTRLREG_V3
}

/*****************************************************************/

//----------------------------------------------------------------	