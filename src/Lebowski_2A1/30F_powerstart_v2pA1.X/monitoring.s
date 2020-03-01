.include "p30F4011.inc"
.include "defines.inc"

.text
.global monitoring
monitoring:
;------------------------------ check for new command, store variable address if new
                                    ;rx-ed anything ?
    btss U2STA, #0
    bra moni_read_var               ;if no: skip to read
                                    ;if yes, get character
    mov U2RXREG, w0
	
	nop
	nop
	
    ze w0, w0

;------------------------------ check that new command is in 0-9 range, else disable TX

    mov #'u'+1, w1
    cpslt w0, w1
    bra moni_disable_end

    mov #'a'-1, w1
    cpsgt w0, w1
    bra moni_disable_end

;------------------------------ in range, calculate variable address
                                    ;allow tx
    bset flags1, #tx_allowed
                                    ;get delta with 'a'
    mov #'a', w1
    sub w0, w1, w0
                                    ;times 4
    sl w0, #2, w0
                                    ;add to array offset
    mov #tblpage(variable_array), w1
    mov w1, TBLPAG
    mov #tbloffset(variable_array), w1
    add w0, w1, w1
                                    ;get RAM address variable
    tblrdl [w1], w2
    mov w2, tx_var_address

;------------------------------ transmit variable	
moni_read_var:
                                    ;only TX when allowed
    btss flags1, #tx_allowed
    return
                                    ;read value and TX
    mov tx_var_address, w2
    mov [w2], w0
    btg w0, #15
    call tx_word_232
	
    return

;------------------------------ disable TX when RX-ed outside of 0-9

moni_disable_end:

    bclr flags1, #tx_allowed
    return



.align 2
variable_array:	
        .word   phi_motor,				;a
        .word   phi_int,                ;b
        .word   filter_w8,              ;c
        .word   wanted_i_real,          ;d
        .word   ampli_real,             ;e
        .word   throttle_raw1,          ;f
        .word   throttle_raw2,          ;g
        .word   throttle,               ;h
        .word   adc_current_offset,     ;i
        .word   adc_current_offset+2,   ;j
        .word   adc_current_offset+4,   ;k
        .word   temp_data,				;l
        .word   temp_data+2,            ;m
        .word   temp_data+4,			;n
        .word   temp_data+6,            ;o
        .word   temp_data+8,            ;p
        .word   temp_data+10,           ;q
        .word   temp_data+12,           ;r
        .word   temp_data+14,           ;s
        .word   temp_red_i_max_phase,   ;t
		.word	filter_w9,				;u
		
		.word	dummy1,					;v
		.word	flags2,					;w
		.word	filter_Q,				;x
		.word	meas_L,					;y
		.word   meas_R,					;z



.end
