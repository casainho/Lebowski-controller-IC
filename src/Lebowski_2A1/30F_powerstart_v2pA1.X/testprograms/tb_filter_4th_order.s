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
                                                    ;initialise filter array
    mov #filter_A, w11
    repeat #7
    clr [w11++]

;---------------------------------------------- loop 
mlp:
;---------------------------------------------- calculate filter response

    mov #1000, w1
    mov #filter_A, w11

    call filter_4th_order

;---------------------------------------------- transmit filter output

    mov filter_A+12, w0
    btg w0, #15
    call tx_word_232

;---------------------------------------------- loop

    bra mlp

;---------------------------------------------- end

.end

