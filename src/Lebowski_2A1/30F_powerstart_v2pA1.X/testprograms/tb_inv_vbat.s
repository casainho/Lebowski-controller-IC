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
    call reset_filters


    mov #1000, w0
    mov w0, counter
;---------------------------------------------- loop value 1

mlp1:
    clr supply_voltage
    call inverse_vbat

    mov filter_inv_vbat, w0
    call tx_word_232

    dec counter
    bra nz, mlp1

;---------------------------------------------- loop value 2
    mov #1000, w0
    mov w0, counter
mlp2:
    mov #1020, w0
    mov w0, supply_voltage
    call inverse_vbat

    mov filter_inv_vbat, w0
    call tx_word_232

    dec counter
    bra nz,mlp2

;---------------------------------------------- loop value 3

    mov #3000, w0
    mov w0, counter
mlp3:
    mov #520, w0
    mov w0, supply_voltage
    call inverse_vbat

    mov filter_inv_vbat, w0
    call tx_word_232

    dec counter
    bra nz,mlp3

;---------------------------------------------- loop value 4

    mov #1000, w0
    mov w0, counter
mlp4:
    mov #900, w0
    mov w0, supply_voltage
    call inverse_vbat

    mov filter_inv_vbat, w0
    call tx_word_232

    dec counter
    bra nz,mlp4

;---------------------------------------------- loop value 5

    mov #1000, w0
    mov w0, counter
mlp5:
    mov #600, w0
    mov w0, supply_voltage
    call inverse_vbat

    mov filter_inv_vbat, w0
    call tx_word_232

    dec counter
    bra nz,mlp5

;---------------------------------------------- end

hangloop:
    call tx_word_232

    bra hangloop

.end

