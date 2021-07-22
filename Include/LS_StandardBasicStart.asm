#importonce
//----------------------------------------------------------------			
/*****************************************************************
LS_StandardBasicStart.asm
v1.00

dependencies:
	not
memory:
	reservation

*****************************************************************/

basicStart:
		* = $0801 "Header"
		.word bend
		.byte $0d, $00			//;line number
		.byte $9E				//;SYS
		.byte $20				//;space
		.byte $32,$30,$36,$34	//;start 2064
		.byte $00				//;end of line
bend:	.byte $00, $00			//;end of basic program
//----------------------------------------------------------------
