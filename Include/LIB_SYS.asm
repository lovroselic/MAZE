#importonce
//------------------SYSTEM------------------
.const 	IRQVEC  	= $0314
.const 	CIA_ICR 	= $dc0d
.const 	CIA2_ICR 	= $dd0d
.const 	SCREEN 		= $0400
.const	CUR_COLOR 	= $0286
.const	CHRGET		= $0073

//--------------ZERO PAGE------------------------------
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
//--------------- LS constants ----------------------------
.const 	maxCOL 		= 40
.const 	maxROW 		= 25