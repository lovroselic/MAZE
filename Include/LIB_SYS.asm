#importonce
//------------------SYSTEM------------------
.const 	IRQVEC  	= $0314
.const 	CIA_ICR 	= $dc0d
.const 	CIA2_ICR 	= $dd0d
.const 	SCREEN 		= $0400
.label  COLORRAM    = $D800
.const	CUR_COLOR 	= $0286
.const	CHRGET		= $0073

// IRQ Registers
.label VICIRQ       = $D019
.label IRQMSK       = $D01A

// CIA #1 Registers (Generates IRQ's)
.label CIAPRA       = $DC00
.label CIAPRB       = $DC01
.label CIAICR       = $DC0D

// CIA #2 Registers (Generates NMI's)
.label CI2PRA       = $DD00
.label CI2PRB       = $DD01
.label CI2ICR       = $DD0D

// Timer Registers
.label TIMALO       = $DC04
.label TIMBHI       = $DC07

// Interrupt Vectors
.label IRQRAMVECTOR = $0314
.label IRQROMVECTOR = $FFFE
.label NMIRAMVECTOR = $0318
.label NMIROMVECTOR = $FFFA

// Interrupt Routines
.label IRQROMROUTINE = $EA31

//--------------ZERO PAGE------------------------------
.const  ZP0         = $02
.const 	ZP1 		= $FB
.const 	ZP2 		= $FC
.const 	ZP3 		= $FD
.const 	ZP4 		= $FE
.const 	CUR_X 		= $D3
.const	CUR_Y 		= $D6
.const 	FAC 		= $61
.const	ARG 		= $69
.const	RND1 		= $63		//shortcut to FAC mantissa
.const	RND2 		= $64		//shortcut to FAC mantissa
.const	TXTPTR 		= $7a
.const	NDX 		= $C6		//no of chars in buffer
.const	LSTX 		= $C5		//last char in buffer
.const 	TI 			= $A0		//sys timer
.const 	WINT		= $14		//line pointer, FAC to W stores int here

//--------------ZERO PAGE ABUSED, USED BY BASIC ------------------------------
.const  TEMPX       = $3F       //DATLIN
.const  TEMPY       = $40       //DATLIN
.const  TEMPA1      = $41       //DATPTR
.const  TEMPA2      = $42       //DATPTR
.const  BV1         = $43       //INPPTR
.const  BV2         = $44       //INPPTR
.const  BV3         = $45       //VARNAM
.const  BV4         = $46       //VARNAM
.const  BV5         = $4B       //OPPTR 
.const  BV6         = $4C       //OPPTR 
.const  VAR_A       = $47       //VARPNT
.const  VAR_B       = $48       //VARPNT
.const  VAR_C       = $49       //FORPNT
.const  VAR_D       = $4A       //FORPNT
.const  BV9         = $4E       //DEFPNT 
.const  BV10        = $4F       //DEFPNT 
.const  TEMPX2      = $4D       //OPMASK
.const  TEMPY2      = $53       //FOUR6
.const  BV7         = $4E       //DEFPNT 
.const  BV8         = $4F       //DEFPNT 
//--------------- LS constants ----------------------------
.const 	maxCOL 		= 40
.const 	maxROW 		= 25