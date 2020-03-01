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
    mov #notch_array, w0
    repeat #20
    clr [w0++]


;---------------------------------------------- loop 
mlp:
	                                                    ;wait for any key
	call rx_char_232

;---------------------------------------------- calculate filter response

    mov #3000, w6
	clr w4
	clr w5
    call filter_notches

;---------------------------------------------- transmit filter output

    mov w6, w0
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

