.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global write_motor_sinus
;corrupted variables
;w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13
write_motor_sinus:
;*****************************************************************
;* calculate phase A both real and imaginary part
;*****************************************************************
;--------------------------------------- calculate re, im position (w8, w9 for re, im)
                                            ;get amplitudes (w11, w12 for re, im amplitude)
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
	

                                            ;w8, w9 now contain the (re and im) of the power vector for phase A
;*****************************************************************
;* compensate for delay in phase control loop
;*****************************************************************
;--------------------------------------- calculate this cycles step compensation
                                            ;accumulate all phase steps to phi_step_int
    mov phi_step, w0
    add phi_prop, wreg
    subr phi_prop+2, wreg

    add phi_step_int
                                            ;step_int > max: use max
	mov phi_step_max, w0
	mov phi_step_int, w1
	cpslt w1, w0
	bra 1f					
                                            ;step_int < -max: use -max
	neg w0, w0
	cpsgt w1, w0
	bra 1f
                                            ;else use step_int (with already correct sign)
	mov w1, w0
1:	
											;subtract from phi_step_int (so it will sigma delta to 0)			
    sub phi_step_int							
;--------------------------------------- calculate signal to be added to w8, w9 for cancellation of delay in phase control loop
                                            ;add_to_vmotor = j * 2^-14 * phi_added_2nd *   2^-2*2*pi/aLR  * predicted_I_motor(z-1);    aLR = R/(fs*L)
                                            ;add_to_vmotor = j * 2^-14 * phi_added_2nd * phase_comp_coeff * predicted_I_motor(z-1);    aLR = R/(fs*L)      
    mov phase_comp_coeff, w1
    mul.us w1, w0, w2
											;limit on overflow
	btsc w3, #15
	bra result_neg
result_pos:
	mov #0x7FF0, w1
	cp0 w3
	bra nz, 1f
	btss w2, #15
	mov w2, w1
	bra 1f
result_neg:
	mov #0x8010, w1
	com w3, w3
	bra nz, 1f
	btsc w2, #15
	mov w2, w1
1:				
	
    mov pred_i_real, w0
    mul.ss w0, w1, w4
                                            ;w5:w4 = xxUU.UUUU.UUUU.UUUU : UUyy.yyyy.yyyy.yyyy , forget about the 2 LSB's in the answer from w4.
    sl w5, #2, w5
                                            ;implement *j by adding real part of mult to imag motor voltage (w9)
    add w9, w5, w9

    mov pred_i_imag, w0
    mul.ss w0, w1, w4
    sl w5, #2, w5
	
                                            ;implement *j by subtracting imag part of mult from real motor voltage (w8)   
    sub w8, w5, w8

;--------------------------------------- filter w8, w9 with motor time constant to keep track of motor current (as caused by controller output).
											;predicted_I_motor(z) = predicted_I_motor(z-1) +           aLR            * (v_motor(z) - predicted_I_motor(z-1)); aLR = R/(fs*L)
											;predicted_I_motor(z) = predicted_I_motor(z-1) + 2^-16 * motor_filt_coeff * (v_motor(z) - predicted_I_motor(z-1)); aLR = R/(fs*L)
    mov motor_filt_coeff, w0

    mov #pred_i_real, w13
    sub w8, [w13], w1
    mul.us w0, w1, w2
    add w2, [++w13], [w13]
    addc w3, [--w13], [w13]
    
    mov #pred_i_imag, w13
    sub w9, [w13], w1
    mul.us w0, w1, w2
    add w2, [++w13], [w13]
    addc w3, [--w13], [w13]

;*****************************************************************
;* add hf tones to w8, w9, if used
;*****************************************************************	
                                            ;now, if ampli_hf=0 we're finished
    cp0 ampli_hf_motor
    bra z, skip_hf
                                            ;get array position for phase A
    mov phi_hf_motor, w13
	lsr w13, #7, w13
	bclr w13, #0
	bset w13, #11
                                            ;w11: amplitude hf / 2^ampli_sf
    mov ampli_hf_motor, w11
                                            ;w8 += w11*[w13]
                                            ;w9 += w11*[w13+90]
    mul.us w11, [w13], w0
    add w1, w8, w8
    add #128, w13
    bclr w13, #9
    mul.us w11, [w13], w0
    add w1, w9, w9

skip_hf:
;*****************************************************************
;* calc Va_raw for impedance determination
;*****************************************************************	
;--------------------------------------- not necessary when clipping (w8, w9 = 16384
	mul.ss w8, w8, w0
	mul.ss w9, w9, w2
	add w1, w3, w1
	
	mov #4094, w0
	cpsgt w1, w0
	bra 1f
											;no data sampling, no sine_i_imag when clipping / overflow
	bclr flags1, #valid_data_imp_meas
	bclr flags1, #allow_sine_iimag
1:						
;--------------------------------------- rotate w8+jw9 over exp(-j*phi_motor)
											;get demod position in sin array [w13]
    mov phi_motor, w0
    lsr w0, #7, w13
    bclr w13, #0
    bset w13, #11
											;Va_raw = w2 = w8 * cos + w9 * sin
	mul.ss w9, [w13], w2
	add #128, w13
    bclr w13, #9
	mul.ss 	w8, [w13], w0
	add w1, w3, w2
											;compensate for sine arraybeing Q15
	sl w2, #2, w2
	mov w2, Va_raw
skip_varaw:	
;*****************************************************************
;* calculate phases B and C by rotating phase A
;*****************************************************************
;--------------------------------------- dont rotate for phase A, to w4
    mov w8, w4
;--------------------------------------- rotate +120 for phase B, add to w5 and rotate -120 for phase C, add to w6
                                            ;w5 = -0.5*w8 - 0.866*w9
                                            ;w6 = -0.5*w8 + 0.866*w9
    asr w8, w1
    neg w1, w5
    neg w1, w6

    mov #56756, w0
    mul.su w9, w0, w0

    sub w5, w1, w5
    add w6, w1, w6
;*****************************************************************
;* apply moving midpoint
;*****************************************************************
;---------------------------------------moving midpoint
                                            ;w4, w5, w6 += - (max(w4,w5,w6) + min(w4,w5,w5)) , or
                                            ;w4, w5, w6 += (mid(w4,w5,w6))/2 as w4+w5+w6 = 0
    asr w4, w10
    asr w5, w11
    asr w6, w12
                                            ;bubble sort, afterwards w12=max, w11=mid and w10=min
    cpsgt w11, w10
    exch w10, w11
    cpsgt w12, w11
    exch w11, w12
    cpsgt w11, w10
    exch w10, w11
                                            ;add w11 to w4,w5,w6
    add w4, w11, w4
    add w5, w11, w5
    add w6, w11, w6

;*****************************************************************
;* calc PWM outputs
;*****************************************************************
;--------------------------------------- mult with (4/.866)*pwm_period as so far because of Q.15 * Q.15 we're in -.25 .. .25 range
                                            ;use PTPER instead of pwm_period as this convers both continuous and discontinuous cases
											;w4,5,6 are actually a bit larger than -0.25 .. 0.25  as they contain the sum of a 0.25*sine and 0.25*cosine contribution.
    mov PTPER, w12
											;multiply with 2^(2), this will compensate for w4,5,6 being -0.25 .. 0.25
	sl w12, #2, w11
                                            ;1/0.866 = 1.1547, therefore w11+= 0.1547*w11
    mov #10140, w0
    mul.uu w0, w11, w0
    add w11, w1, w11
                                            ;convert phase A
    mul.us w11, w4, w0
    add class_d_remainder
    addc w1, #0, w4
                                            ;convert phase B
    mul.us w11, w5, w0
    add class_d_remainder+2
    addc w1, #0, w5
                                            ;convert phase C
    mul.us w11, w6, w0
    add class_d_remainder+4
    addc w1, #0, w6

;--------------------------------------- limit outputs
                                            ;if w4 > pwm_period, then w4 = pwm_period
    cpslt w4, w12
    mov w12, w4
                                           	;if -w4 > pwm_period, then -w4 = pwm_period
    neg w4, w4
    cpslt w4, w12
    mov w12, w4
                                            ;add to pwm_period for correct offset, and write to PDC register
 	sub w12, w4, w4                         ;sub replaces neg and add


    cpslt w5, w12
    mov w12, w5
    neg w5, w5
    cpslt w5, w12
    mov w12, w5
 	sub w12, w5, w5

    cpslt w6, w12
    mov w12, w6
    neg w6, w6
    cpslt w6, w12
    mov w12, w6
 	sub w12, w6, w6

;---------------------------------------- write outputs

	mov w4, PDC1
	mov w5, PDC2
	mov w6, PDC3

;---------------------------------------- end

	return




.end

