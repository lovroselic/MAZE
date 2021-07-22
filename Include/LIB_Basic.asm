#importonce

/*
	FP arithmetic: https://codebase64.org/doku.php?id=base:kernal_floating_point_mathematics#movement
*/

//----------------------------BASIC--------------------------------

.const	PRINT_INT	= $BDCD		//prints integer 
.const 	GETLINE		= $A560		//input line
.const	EVALNUM		= $B79E
.const 	FOUT		= $BDDD		//Convert number in FAC to a zero-terminated string (starting at $0100, address in A, Y ). Direct output of FAC also via $AABC 
.const 	FMULT		= $BA28		//Multiplies a number from RAM and FAC (clobbers ARG, A=Addr.LB, Y=Addr.HB)
.const	MOVMF		= $BBD4		//FAC -> memory (5 bytes)
.const 	MOVFA		= $BC0F		//MOVFA; Copy a number currently in FAC, over into ARG 
.const 	FAINT		= $BCCC		//FAC to INT
.const 	INTFAC 		= $BC3C		//A -> FAC
.const 	MOVAF 		= $bbfc 	// Stores ARG in FAC. 
.const 	QINT		= $BC9B		/*This routine converts the value in FAC1 into a four-byte signed integer in 98- 101 ($62-$65), with the most significant byte first.*/
.const	GETADR		= $B7F7		/* Converts FAC in 2-byte integer (scope 0 ... 65535) to $14, $15 and Y-Reg/accu  */
.const	AYINT		= $B1BF		//fac to signed int HI $64 LO $65 
.const	AYINT2		= $B1AA		//fac to signed int HI $64 (A) LO $65 (Y) 
.const 	SWFAC		= $BC44		//signed W $62,63 Hi, LO to FAC
.const	GIVAYF		= $B391		//Convert 16-Bit Signed Integer to Floating Point A(HI), Y(Lo)

