.include "p30F4011.inc"
.include "defines.inc"
.include "temp_macros.s"

.text

;*****************************************************************

.global main_tb
main_tb:
						
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise

;---------------------------------------------- main loop
mlp:
                                                    ;wait for 40 kHz operation
    bclr LATD, #2
    btss IFS0, #3
    bra mlp
    bclr IFS0, #3
                                                    ;indicate when busy
    bset LATD, #2

    mov temp_readout, w14
    call w14

    bra mlp


;***********************************************

;---------------------------------------------- temp routine
.global tb_temp_reset
tb_temp_reset:

    reset_temp_sensors

    bra tb_temp_reset

.end

