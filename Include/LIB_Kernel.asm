#importonce
//----------------------------KERNEL--------------------------------

.const	CLSCR 			= $E544			//clear screen
.const	CHROUT 			= $FFD2			//prints character
.const 	CHRIN 			= $FFCF
.const	CALC_CURSOR 	= $E56C			//Calculate cursor position, set screen and color RAM pointer, from CUR_X, CUR_Y
.const 	SET_CURSOR		= $E50A			//Set cursor; Specify values ​​in X, Y (row, column)
.const  BRING_CURSOR	= $E513			//Bring cursor to X, Y
.const 	RND				= $E09A
.const	GETIN			= $FFE4			//get a acharacter
.const 	IRQOUT 			= $EA31			