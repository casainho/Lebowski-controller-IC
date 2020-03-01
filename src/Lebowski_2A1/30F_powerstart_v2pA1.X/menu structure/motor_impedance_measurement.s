
.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************
.global motor_impedance_measurement
motor_impedance_measurement:
;---------------------------------------------- double PWM deadtime
	bset pwm_deadtime, #6
;---------------------------------------------- perform measurement, stack ampli_real
	call impedance_measurement
	push ampli_real
;---------------------------------------------- restore PWM deadtime to original
	bclr pwm_deadtime, #6
;---------------------------------------------- perform measurement, stack ampli_real
	call impedance_measurement
;---------------------------------------------- recover stored ampli_real		
	pop w0
													;ampli_real_corrected = ampli_real - (w0 - ampli_real)
	subr ampli_real, wreg
	sub ampli_real
;---------------------------------------------- detect overflow
	bclr flags_rom2, #FOC_overflow
													;ampli_real must be in 0x0000 to 0x3FFF range
	mov #0xE000, w0
	and ampli_real, wreg
	btss SR, #Z
	bset flags_rom2, #FOC_overflow
													;ampli_imag must be in 0x0000 to 0x3FFF range
	mov #0xE000, w0
	and ampli_imag, wreg
	btss SR, #Z
	bset flags_rom2, #FOC_overflow
													;end when overflow occurred
	btsc flags_rom2, #FOC_overflow
	bra mim_end
;---------------------------------------------- reverse determine imag_impedance (so based on original deadtime)
	mov filter_inv_vbat, w0
	mov w0, inv_vbat0
	mov battery_voltage, w0
	mov w0, vbat0

	call reverse_determine_imag_impedance
;---------------------------------------------- reverse determine real_impedance
	call reverse_determine_real_impedance
;---------------------------------------------- end
mim_end:
	return
		
	
impedance_measurement:
;*****************************************************************
;* initialise
;*****************************************************************
    call reset_filters
	call timers_open
	call PWM_open
    call ADC_open
    call fill_pwm_and_sin_arrays
    call clear_variables
                                                   ;turn on PWM
	bset PTCON, #15
                                                    ;switch ADCs over to current measurement, wait a bit before 1st measurement
    call ADC_current

    mov phi_int_for_impedance_measurement, w0
    mov w0, phi_int

    clr counter

;*****************************************************************
;* make measurement, determine ampli_real and ampli_imag 
;*****************************************************************

;call tx_char_232                                       ;for variable view tx

mim_lp1:
    btss IFS0, #3
    bra mim_lp1
    bclr IFS0, #3
;---------------------------------------------- get measured currents
    bclr ADCON1, #1
    nop
    nop
    nop
    nop
    nop
    call ADC_read_current
;---------------------------------------------- filter 1/V_battery as we need this for the imag_impedance calculation later
    call inverse_vbat
;---------------------------------------------- demodulate USING CORRECT PHASE
    mov phi_motor, w0
    call demod
;---------------------------------------------- for stability a *j (rotate forward over 90 deg) is implemented in the feedback    
;---------------------------------------------- control i_real, ramp up
;---------------------------------------------- *j => i_real controls ampli_imag
    mov i_inductor_measurement, w1
    mov #3, w0
    mul counter
                                                    ;as long as w3=0, w2 contains ramp up factor, w1 = w1*w2
                                                    ;if w3 <> 0, skip the mult of w1 and w2, keep w1
    cp0 w3
    btsc SR, #Z
    mul.uu w1, w2, w0
                                                    ;now wanted current in w1
                                                    ;first integrator part
    mov #1, w0
    cpslt w8, w1
    neg w0, w0

    add ampli_imag
                                                    ;undo add on overflow
	btsc SR, #OV
	sub ampli_imag						    
    						
    push ampli_imag
                                                    ;then proportional part
    mov #20, w0
    cpslt w8, w1
    neg w0, w0
    add ampli_imag
                                                     ;undo add on overflow
	btsc SR, #OV
	sub ampli_imag						                                                      
   							
;---------------------------------------------- control i_imag
;---------------------------------------------- *j => i_imag controls -ampli_real
    clr w1
                                                    ;first integrator part
    mov #-1, w0
    cpslt w9, w1
    neg w0, w0

    add ampli_real
                                                    ;undo add on overflow
	btsc SR, #OV
	sub ampli_real					    
    
    push ampli_real
                                                    ;then proportional part
    mov #-20, w0
    cpslt w9, w1
    neg w0, w0
    add ampli_real
                                                    ;undo add on overflow
	btsc SR, #OV
	sub ampli_real					    
;---------------------------------------------- update motor phase, write to motor
    mov phi_int, w0
    add phi_motor
    call write_motor_sinus
;---------------------------------------------- recover ampli_real, ampli_imag to remove the proportional part
    pop ampli_real
    pop ampli_imag
;---------------------------------------------- end when counter has reached 65536
    inc counter
    bra nz, mim_lp1
;---------------------------------------------- turn off PWM

	bclr PTCON, #15
;---------------------------------------------- turn off PWM
	return
	

.end
