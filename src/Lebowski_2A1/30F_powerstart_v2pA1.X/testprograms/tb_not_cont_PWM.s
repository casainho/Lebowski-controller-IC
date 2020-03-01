.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main_tb
main_tb:						
						
;---------------------------------------------- initialise
                                                    ;global initialise
    call initialise
    bclr PTCON, #15

;---------------------------------------------- set PWM registers for single event mode

                                                    ;pwm time base off for now, postscale 1:1, prescale 1:1, single event
	mov #0b0000000000000001, w0
	mov w0, PTCON
                                                    ;use double pwm_period as single ramp instead of double
	mov pwm_period, w0
    sl w0, w0
	mov w0, PTPER

                                                    ;initialise dutycycle
	mov pwm_period, w0
    add pwm_period, wreg
    add pwm_period, wreg
	mov w0, PDC1
	mov w0, PDC2
	mov w0, PDC3


;---------------------------------------------- pulse once every millisecond
    mov #40, w0
    mov w0, counter
tb1:
                                                    ;wait for 40 kHz operation
    btss IFS0, #3
    bra tb1
    bclr IFS0, #3
;---------------------------------------------- dec counter, pulse when 0
    dec counter
    bra nz, tb1

    mov #40, w0
    mov w0, counter

    bset PTCON, #15
;---------------------------------------------- loop
    bra tb1









.end

