#importonce
//-----------------------Character ASCII Set Constants-----------------------------------
.const	CHR_White                   = 5
.const	CHR_DisableCommodoreKey     = 8
.const 	CHR_EnableCommodoreKey      = 9
.const 	CHR_Return                  = 13
.const	CHR_SwitchToLowerCase       = 14
.const	CHR_CursorUp                = 17
.const	CHR_ReverseOn               = 18
.const	CHR_Home                    = 19
.const	CHR_Backspace	            = 20
.const	CHR_Red                     = 28
.const	CHR_CursorRight             = 29
.const	CHR_Green                   = 30
.const	CHR_Blue                    = 31
.const	CHR_Space                   = 32
.const	CHR_Block                   = $E0
.const	CHR_ShiftReturn             = 141
.const	CHR_SwitchToUpperCase       = 142
.const	CHR_Black                   = 144
.const	CHR_CursorDown              = 145
.const	CHR_ReverseOff              = 146
.const	CHR_ClearScreen             = 147
.const	CHR_Insert                  = 148
.const	CHR_Purple                  = 156
.const	CHR_CursorLeft              = 157
.const	CHR_Yellow                  = 158
.const	CHR_Cyan                    = 159
.const	CHR_ShiftSpace              = 16
.const 	CHR_Y						= $59
.const	CHR_N						= $4E
.const 	CHR_Comma					= 44

//-----------------------COLOURS-----------------------------------
// https://www.c64-wiki.com/wiki/Color

.const	BLACK 		= 0
.const 	WHITE		= 1
.const	RED 		= 2
.const	CYAN		= 3
.const	PURPLE		= 4
.const	GREEN		= 5
.const	BLUE		= 6
.const	YELLOW		= 7
.const	ORANGE		= 8
.const	BROWN		= 9
.const	LIGHTRED	= 10
.const	DARKGREY	= 11
.const	GREY		= 12
.const	LIGHTGREEN	= 13
.const	LIGHTBLUE	= 14
.const	LIGHTGREY 	= 15