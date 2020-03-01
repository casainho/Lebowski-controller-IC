.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************
.macro write_motor_sin
	 mov ampli_real, w0
    add ampli_prop, wreg
    btsc SR, #OV
    mov ampli_real, w0
    mov w0, w11
                                            ;ampli_imag mainly positive, overflow always towards positive end
    mov ampli_imag, w0
    add ampli_imag_prop, wreg
    btsc SR, #OV
    mov ampli_imag, w0
    mov w0, w12             
											;get current position in sin array [w13]
    mov phi_motor, w0
    add phi_prop, wreg
    lsr w0, #7, w13
    bclr w13, #0
    bset w13, #11
                                            ;w8 = w11*[w13+90] - w12*[w13]
                                            ;w9 = w11*[w13] + w12*[w13+90]
    mul.ss w12, [w13], w0
    neg w1, w8
    mul.ss w11, [w13], w0
    mov w1, w9

    add #128, w13
    bclr w13, #9

    mul.ss w11, [w13], w0
    add w1, w8, w8
    mul.ss w12, [w13], w0
    add w1, w9, w9
.endm
;*****************************************************************


	nop
	nop
	nop

	call fill_pwm_and_sin_arrays

	clr phi_motor
	clr phi_prop
	
	mov #6667, w4
	mov #-3333, w5
	mov #-3333, w6
	
	mov phi_motor, w0
    call demod
	
	mov #8000, w0
	mov w0, ampli_real
	mov w0, ampli_imag
	clr ampli_prop
	clr ampli_imag_prop
	
	write_motor_sin
	
	mov #6000, w0
	mov w0, ampli_imag_dr2hl
	bclr flags1, #reverse
											;determine phi_offset and perform initial phase step
	call phase_step_dr23hl

;now we are in drive 23
	
	mov phi_motor, w0
	add phi_offset, wreg
    call demod
	
	nop
	
	write_motor_sin

	
-	nop
	nop
	nop
	
	
	

.end

