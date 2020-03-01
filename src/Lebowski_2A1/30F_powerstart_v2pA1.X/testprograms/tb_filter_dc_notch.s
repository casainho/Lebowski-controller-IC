.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main
main:						
						
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise
                                                    ;initialise filter array
    mov #dc_notch_array, w0
    repeat #5
    clr [w0++]

	mov #7000, w0
	mov w0, notch_alpha

;---------------------------------------------- loop 
mlp:
	                                                    ;wait for any key
	call rx_char_232

;---------------------------------------------- calculate filter response

    mov #1000, w4
    call filter_dc_notch

;---------------------------------------------- transmit filter output

    mov w4, w0
    mov #str_buf, w1
    call word_to_sdec_str
    mov #str_buf, w0
    call tx_ram_str_232
	
	mov #'\n', w0
	call tx_char_232


;---------------------------------------------- loop

	bra mlp

;---------------------------------------------- end

.end

