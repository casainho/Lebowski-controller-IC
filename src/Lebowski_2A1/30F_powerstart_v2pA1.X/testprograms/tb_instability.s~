.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main
main:						
						
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise
                                                    ;wait for any key
	call rx_char_232

    mov #1000, w8

;---------------------------------------------- loop 
mlp:
;---------------------------------------------- calculate filter response


    mov #notch_2hf_I, w13
    call notch_2hf

    mov #notch_hf_I, w13
    call notch_hf

;---------------------------------------------- transmit filter output

    mov w8, w0
    btg w0, #15
    call tx_word_232

;---------------------------------------------- loop

    clr w8

    bra mlp

;---------------------------------------------- end

.end

