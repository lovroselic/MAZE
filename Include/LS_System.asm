#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_System.asm
v0.06

dependencies:
	standard includes
memory:
	none

*****************************************************************/
#import "LIB_SYS.asm"
#import "LIB_Basic.asm"
#import "LIB_VIC.asm"
//-----------------------CONST-----------------------------------

//--- SUBS -------------------------------------------------------

SPLICE:
{

													//length in VAR_B
													//data size in VAR_C
													//array start in (BV1)
			dec VAR_B								//array length - 1, last index
			ldy VAR_A								//index
	loop:	cpy VAR_B								//stop if index
			bpl out 								//equal or greater than last index

			ldx #0									//number of properties (data_size), start from 0
													//from i+1
		each:											//for each property in data_size
				iny		
				sty TEMPY
														//recalc y as offset
				lda	VAR_C 								//data size
														//y has right value
				jsr MUL_Y_A
														//y <- y*datasize, a = hi byte
				sty ZP0
				txa
				clc
				adc ZP0
				tay

				lda (BV1),y
				sta TEMPA1
														//to i
				ldy TEMPY
				dey
				sty TEMPY
														//recalc y as offset
				lda	VAR_C 								//data size
														//y has right value
				jsr MUL_Y_A
														//y <- y*datasize, a = hi byte
				sty ZP0
				txa
				clc
				adc ZP0
				tay

				lda TEMPA1
				sta (BV1),y
				ldy TEMPY

				inx
				cpx VAR_C								//all props? less than VAR_C ?
				bcc each

			iny
			jmp loop
	out: 	rts

}

/*****************************************************************/

MUL_Y_A:
{

/**
	acc: multiplier
	Y: muplitplicant
	uses: ZP0
	return: product in  acc(hi) and y(lo)
*/

multiply:	cpy #00
			beq end
			dey
			sty mod+1
			lsr
			sta ZP0
			lda #00
			ldy #$08
loop:		bcc skip
mod:		adc #0
skip:		ror
			ror ZP0
			dey
			bne loop
			ldy ZP0
			rts
end:		tya
			rts
}

/*****************************************************************/


COPY_CHAR_ROM_TO_RAM:
/** 
copy char ROM to RAM 
RAM defalut: $3000
modify ram+1 to change
*/
{
			
			sei

			lda $01			//make ROM visible
			and #$FB
			sta $01 

			lda #00
			sta $5f			//block start
			sta $5a			//block end
			sta $58			//destination end

			ldy #$d0
			sty $60			//block start
			ldy #$e0		
			sty $5b			//block end
ram:		ldy #$40
			sty $59			//destination end

			jsr MOVE_BYTES

			lda $01			//hide rom
			ora #$04
			sta $01
			cli
			
							//set charmem
			lda VMCSB
			and #%11110000
			ora #%00001100	//$3000
			sta VMCSB
			rts
}


/*****************************************************************/

//--- MACRO ------------------------------------------------------
.macro StringToInt8(pointer)
{

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

/*****************************************************************/

.macro MOV8(X, Y)
{

/*
arguments: X origin, Y destination
*/
			lda X
			sta Y
}

/*****************************************************************/

.macro MOV16(X, Y)
{

/*
arguments: X origin, Y destination
*/
			lda X
			sta Y
			lda X + 1
			sta Y + 1
}

/*****************************************************************/

.macro CLEAR16(X)
{

/*
arguments: X 16 bit address to be set to 0
*/
			lda #0
			sta X
			sta X+1
}

/*****************************************************************/

.macro ASL16(X)
{

/*
arguments: X 16 bit address, value shifted left

*/
			asl X
			rol X+1	
}

/*****************************************************************/

.macro ADD16(X,Y)
{

/*
arguments: X,Y 16 bit addresses; add value of Y to X
result in X
16 bit overflow ignored, but carry is set
*/	
		
		lda X
		clc
		adc Y
		sta X
		bcc skip
		inc X+1
skip:	
		lda X+1
		clc
		adc Y+1
		sta X+1	
}

/*****************************************************************/

.macro ADD_C_16(X, C){
/**
add constant to address in X
arguments: 
	X 16 bit address, zero page!!!!
	C constant, 8 bit
result in X
*/
		
		lda X
		clc
		adc #C
		sta X
		bcc out+2
out:	inc X+1
}

/*****************************************************************/

.macro SUB_C_16(X,C){
/**
subtract  constant to address in X
arguments: 
	X 16 bit address, zero page!!!!
	C constant, 8 bit
result in X
*/

		lda X
		sec
		sbc #C
		sta X
		bcs out+2
out:	dec X+1
}

/*****************************************************************/

.macro ADD8to16(X,y)
{

/*
arguments: 	X 16 bit address; 
			y B bit
add value of y to X
result in X
16 bit overflow ignored, but carry is set
*/		
		lda X
		clc
		adc y	
		sta X
		bcc out+2
out:	inc X+1
}

/*****************************************************************/

.macro SET_ADDR(addr,X)
{

/*
arguments: 
	addr  	address
	X 		storage location (pointer)	
*/
		lda #<addr
		sta X
		lda #>addr
		sta X+1
}

/*****************************************************************/

.macro SPLICE_ARRAY(which, data_size)
{

/*
arguments: 
	which: pointer to array -> BV1
	data_size: VAR_C
implied:
	index: where to remove one element VAR_A
	length of array: VAR_B
destroys: a,y,x
*/
		SET_ADDR(which, BV1)
		lda #data_size
		sta VAR_C
		jsr SPLICE

}

/*****************************************************************/

.macro MEM_COPY(source, destination, length)
{
/**

arguments:
	source from
	destination to
	length: bytes <= 255
destroys: y,a
uses: BV7,BV9

*/

			SET_ADDR(source, BV7)					
			SET_ADDR(destination, BV9)				
			ldy #length											
			dey
	copy:	lda (BV7),y
			sta (BV9),y
			dey
			bpl copy
	
}

/*****************************************************************/

//-----------------------DATA-------------------------------
SYS_data: 		* = SYS_data "SYSTEM_data"

//----------------------------------------------------------------	

