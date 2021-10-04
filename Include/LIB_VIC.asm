#importonce
//------------------------VIC-------------------
.const 	BORDER = $d020
.const 	BACKGROUND = $d021
.const 	CONTROL_REGISTER1 = $d011
.const 	RASTER_COUNTER = $d012
.const 	INTERRUPT_REQUEST_REGISTER = $d019
.const 	INTERRUPT_MASK_REGISTER = $d01a

// VIC-II Registers
.label SP0X         = $D000
.label SP0Y         = $D001
.label MSIGX        = $D010
.label SCROLY       = $D011
.label RASTER       = $D012
.label SPENA        = $D015
.label SCROLX       = $D016
.label VMCSB        = $D018
.label SPMC         = $D01C
.label SPSPCL       = $D01E
.label EXTCOL       = $D020
.label BGCOL0       = $D021
.label BGCOL1       = $D022
.label BGCOL2       = $D023
.label BGCOL3       = $D024
.label SPMC0        = $D025
.label SPMC1        = $D026
.label SP0COL       = $D027