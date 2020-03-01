.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global fill_pwm_and_sin_arrays
fill_pwm_and_sin_arrays:						
;-------------------------------------- fill both arrays with sin(x)

	mov #data_array_sin+2, w10			;address for 0-90 degrees
	mov #data_array_sin+254, w11		;address for 180-90 degrees
	mov #data_array_sin+258, w12		;address for 180-270 degrees
	mov #data_array_sin+510, w13		;address for 360-270 degrees
								
										;set 0 and 180 degrees to 0
	clr data_array_sin
	clr data_array_sin+256
										;set 90 degrees to 32767
	mov #32767, w0
	mov w0, data_array_sin+128
										;set 270 degrees to -32767
	mov #-32767, w0
	mov w0, data_array_sin+384
;-------------------------------------- initialise ROM table read
	mov #tblpage(sine_table), w9
    mov w9, TBLPAG
    mov #tbloffset(sine_table), w9

;-------------------------------------- loop and fill RAM table
	do #62, fill_lp
	
	tblrdl [w9], w0
	
	add #4, w9
	
	mov w0, [w10++]
	mov w0, [w11--]
	neg w0, w0
	mov w0, [w12++]
fill_lp:
	mov w0, [w13--]
;-------------------------------------- end

    return

;*****************************************************************

.align 2
sine_table:
		.word	804,			;1-7
		.word	1608,
		.word	2410,
		.word	3212,
		.word	4011,
		.word	4808,
		.word	5602,
		
		.word	6393,			;8-15
		.word	7179,
		.word	7962,
		.word	8739,
		.word	9512,
		.word	10278,
		.word	11039,
		.word	11793,
		
		.word	12539,			;16-23
		.word	13279,
		.word	14010,
		.word	14732,
		.word	15446,
		.word	16151,
		.word	16846,
		.word	17530,
		
		.word	18204,			;24-31
		.word	18868,
		.word	19519,
		.word	20159,
		.word	20787,
		.word	21403,
		.word	22005,
		.word	22594,
		
		.word	23170,			;32-39
		.word	23731,
		.word	24279,
		.word	24811,
		.word	25329,
		.word	25832,
		.word	26319,
		.word	26790,
		
		.word	27245,			;40-47
		.word	27683,
		.word	28105,
		.word	28510,
		.word	28898,
		.word	29268,
		.word	29621,
		.word	29956,
		
		.word	30273,			;48-55
		.word	30571,
		.word	30852,
		.word	31113,
		.word	31356,
		.word	31580,
		.word	31785,
		.word	31971,
		
		.word	32137,			;56-63
		.word	32285,
		.word	32412,
		.word	32521,
		.word	32609,
		.word	32678,
		.word	32728,
		.word	32757,
		





.end

