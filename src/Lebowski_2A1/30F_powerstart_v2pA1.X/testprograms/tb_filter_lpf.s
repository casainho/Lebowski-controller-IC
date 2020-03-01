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
    mov #lpf_array, w0
    repeat #7
    clr [w0++]

	mov #3277, w0
	mov w0, lpf_alpha

;---------------------------------------------- loop 
mlp:
	                                                    ;wait for any key
	call rx_char_232

;---------------------------------------------- calculate filter response

    mov #1000, w8
    mov #100, w9
    call filter_lpf

;---------------------------------------------- transmit filter output

    mov w8, w0
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

