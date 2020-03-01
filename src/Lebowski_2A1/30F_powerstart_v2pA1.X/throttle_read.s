.include "p30F4011.inc"
.include "defines.inc"

;*****************************************************************
; macros to de-clutter throttle_read
;*****************************************************************
.macro apply_hvc_limiting
											;exit if below hvc_start
	mov filter_vbat, w0
	subr hvc_start, wreg
	bra ltu, 8f
											;calc y = 1 - (filter_vbat - hvc_start) * hvc_ramp
	mul hvc_ramp
	com w2, w2
											;clear bat current (w1) if overflow
	cp0 w3
	btss SR, #Z
	clr w1
											;calc current: w1 = 2^-16 * w1 * w2
	mul.uu w1, w2, w0
8:	
.endm
;*****************************************************************
.macro apply_lvc_limiting
											;exit if above lvc_start
	mov filter_vbat, w0
	sub lvc_start, wreg
	bra ltu, 8f
											;calc y = 1 - (lvc_start - filter_vbat) * lvc_ramp
	mul lvc_ramp
	com w2, w2
											;clear bat current (w1) if overflow
	cp0 w3
	btss SR, #Z
	clr w1
											;calc current: w1 = 2^-16 * w1 * w2
	mul.uu w1, w2, w0
8:	
.endm
;*****************************************************************

.text
.global throttle_read
;does not corrupt w4, w5 and w6
throttle_read:
;*****************************************************************
;* initialise, skip if no analog throttle
;*****************************************************************
;-------------------------------------- initialise
                                            ;reset TMR4 overflow
    bclr IFS1, #5
                                            ;do we actually have analog throttle on this chip ?
    btss flags_rom, #analog_throttle
    return

;*****************************************************************
;* read analog channels and reverse_request pin
;*****************************************************************
;-------------------------------------- perform voltage measurements, determine throttle_raw1 and throttle_raw2
                                            ;if present, read AN7 (throttle_raw1), else make 0
    clr throttle_raw1
    btss flags_rom, #throttle_AN7
    bra thre_skip7
                                            ;configure ch0 to AN7, convert only ch0
    bclr ADCHS, #3
    bset ADCHS, #2
    bset ADCHS, #1
    bset ADCHS, #0
    bclr ADCON2, #9

    repeat #5
    nop
    bclr ADCON1, #1
    repeat #5
    nop
thre_wait_adc7:
    btss ADCON1, #0
    bra thre_wait_adc7
    mov ADCBUF0, w0
                                            ;substract offset, make 0 for lower than offset
    subr thr1_offset, wreg
                                            ;must be !negative at this point
    bra n, thre_skip7                       ;throttle_raw1 already is 0
                                            ;make 1 for over range
    mov thr1_range, w2
    cpslt w0, w2
    setm throttle_raw1
    cpslt w0, w2
    bra thre_skip7
                                            ;divide by range
    mov w0, w1
    clr w0
;   mov thr1_range, w2
    repeat #17
    div.ud w0, w2
                                            ;store
    mov w0, throttle_raw1

thre_skip7:
                                            ;if present, read AN8 (throttle_raw2), else make 0
    clr throttle_raw2
    btss flags_rom, #throttle_AN8
    bra thre_skip8
                                            ;configure ch0 to AN8, convert only ch0
    bset ADCHS, #3
    bclr ADCHS, #2
    bclr ADCHS, #1
    bclr ADCHS, #0
    bclr ADCON2, #9

    repeat #5
    nop
    bclr ADCON1, #1
    repeat #5
    nop
thre_wait_adc8:
    btss ADCON1, #0
    bra thre_wait_adc8
    mov ADCBUF0, w0
                                            ;substract offset, make 0 for lower than offset
    subr thr2_offset, wreg
                                            ;must be !negative at this point
    bra n, thre_skip8                       ;throttle_raw1 already is 0
                                            ;make 1 for over range
    mov thr2_range, w2
    cpslt w0, w2
    setm throttle_raw2
    cpslt w0, w2
    bra thre_skip8
                                            ;divide by range
    mov w0, w1
    clr w0
;   mov thr2_range, w2
    repeat #17
    div.ud w0, w2
                                            ;store
    mov w0, throttle_raw2

thre_skip8:
;-------------------------------------- restore ADC settings to current/voltage measurement

    bclr ADCHS, #3
    bset ADCON2, #9
    mov #tbloffset(ADC_current), w0
    btss flags1, #ADCs_to_current_sensors
    mov #tbloffset(ADC_voltage), w0
    call w0

;-------------------------------------- read direction pin and update reverse_request flag

    bclr flags1, #reverse_request
    btsc PORTF, #6
    bset flags1, #reverse_request

;-------------------------------------- TX throttle_raw's over CAN if this option is set

    btsc flags_rom, #tx_throttle
    call CAN_tx_throttle

;*****************************************************************
;* calculate wanted_i_real
;*****************************************************************
;-------------------------------------- compute polynomals, calculate effective throttle setting, also called from CAN_rx
.global throttle_rawx_to_wanted_i_real

;only use w0-w3 and w10-w13 !!!! as this is also called from CAN_rx interrupt !

throttle_rawx_to_wanted_i_real:

    clr throttle

    mov #thr_coeff_1+4, w13
    mov #throttle_raw1, w12
    call raw_to_throttle

    mov #thr_coeff_2+4, w13
    mov #throttle_raw2, w12
    call raw_to_throttle

    mov throttle, w1
                                            ;not larger than +0.996
    mov #0x0FF0, w0
    cpslt w1, w0
    mov #0x0FF0, w1
                                            ;not smaller than -0.996
    mov #0xF00F, w0
    cpsgt w1, w0
    mov #0xF00F, w1

    sl w1, #3, w1
    mov w1, throttle

;-------------------------------------- calculate wanted_i_real

    mov i_max_phase, w1
    mov throttle, w0
    mul.su w0, w1, w0
    sl w0, w0
    rlc w1, w0                              
                                            ;w0 = wanted_i_real (Q15) as calculated from throttle setting
    mov w0, wanted_i_real
;*****************************************************************
;* process reverse request, force regen if appropriate
;*****************************************************************
    mov phi_int, w0
    mov phi_int_direction_change, w1

    btsc flags1, #reverse
    bra thre_run_reverse
;-------------------------------------- running forward, if rpm's < erpms_direction_change, make reverse_bit = reverse_request
thre_run_forward:
    cp w0, w1
    bra ge, thre_no_accept

    bra thre_yes_accept
;-------------------------------------- running backward, if rpm's > -erpms_direction_change, make reverse_bit = reverse_request
thre_run_reverse:
    neg w1, w1
    cp w0, w1
    bra le, thre_no_accept

thre_yes_accept:

    bclr flags1, #reverse
    btsc flags1, #reverse_request
    bset flags1, #reverse

thre_no_accept:
;-------------------------------------- skip if reverse bit = reverse_request bit
    clr w1
    bset w1, #reverse
    bset w1, #reverse_request
    mov flags1, w2
    and w1, w2, w2
                                            ;Z if both bits clear
    bra z, thre_skip_force_regen
                                            ;w1=w2 if both bits set
    cp w1, w2
    bra z, thre_skip_force_regen
;-------------------------------------- make wanted_i_real the lowest of wanted_i_real or the (negative) force regen current
thre_force_regen:
    mov wanted_i_real, w1
    neg i_force_regen, wreg
    cpslt w1, w0
    mov w0, wanted_i_real

thre_skip_force_regen:

;*****************************************************************
;* check allowed battery current is not violated, limit current
;*****************************************************************
;only use w0-w3 and w10-w13 !!!! as this is also called from CAN_rx interrupt !						
	
	btsc wanted_i_real, #15
    bra thre_regen
;-------------------------------------- for wanted_i_real positive (power), calc allowed current based on i_max_bat_motoruse
thre_power:
	mov i_max_bat_motoruse, w1
	
	btss flags_rom2, #use_hvc_lvc
	bra 9f
	apply_lvc_limiting
9:
											;i_real_max = (1/ampli_real) * (38102*I_bat - ampli_imag * wanted_i_imag)
											;w1:w0 = 38102*I_bat
	mov #38102, w0
	mul.uu w1, w0, w0
											;w3:w2 = ampli_imag * wanted_i_imag
	mov ampli_imag, w2
	mov wanted_i_imag, w3
	mul.ss w2, w3, w2
											;w1:w0 = (38102*I_bat - ampli_imag * wanted_i_imag), clear on negative
	sub w0, w2, w0
	subb w1, w3, w1
											
	bra nn, 1f
	clr w0
	clr w1
1:
											;divide by |ampli_real|,prevent div_0
	mov ampli_real, w2
	btsc w2, #15
	neg w2, w2
	bset w2, #0
	repeat #17
	div.sd w0, w2
											;max out on overflow
	mov w0, w13
	btsc SR, #OV
	mov #0x7FF0, w13
;-------------------------------------- replace wanted_i_real when too high
    mov wanted_i_real, w0
											;compare with w13, the max phase current based on battery current
    cpsgt w13, w0
    mov w13, wanted_i_real

    bra thre_temp_cur_limit
;-------------------------------------- for wanted_i_real negative (regen), calc allowed current based on i_max_bat_regenuse
thre_regen:
	
	mov i_max_bat_regenuse, w1
	
	btss flags_rom2, #use_hvc_lvc
	bra 9f
	apply_hvc_limiting
9:						
											;i_real_max = (1/ampli_real) * (38102*I_bat)
											;w1:w0 = 38102*I_bat
	mov #38102, w2
	mul.uu w1, w2, w0
											;divide by |ampli_real|, prevent div_0
	mov ampli_real, w2
	btsc w2, #15
	neg w2, w2
	bset w2, #0
	repeat #17
	div.sd w0, w2	
											;max out on overflow
	mov w0, w13
	btsc SR, #OV
	mov #0x7FF0, w13
                                            ;make negative for regen
    neg w13, w13
;-------------------------------------- replace wanted_i_real when too low
    mov wanted_i_real, w0
											;compare with minimum phase current due to battery current
    cpsgt w0, w13
    mov w13, wanted_i_real

;*****************************************************************
;* check allowed battery current w.r.t. temperature and field weakening reduced i_max_phase
;*****************************************************************
;only use w0-w3 and w10-w13
	
thre_temp_cur_limit:
	mov i_max_phase, w13
	btsc flags_rom, #use_temp_sensors
	mov temp_red_i_max_phase, w13
	
	mov wanted_i_imag, w12
	asr w12, w12								;div 2 to compensate for sin array being Q15
	mov #data_array_sin+64, w10
											;pythagoras subtract wanted_i_imag from temp_red_i_max_phase
											;determine theta such that wanted_i_imag = temp_red_i_max_phase * sin(theta)
												;new array position (for first one already done by loading w10 with +64)
	mul.ss w13, [w10], w0						;w1 = temp_red_i_max_phase * 0.5 sin(theta)
	cpslt w1, w12								;w1 < wanted_i_imag ?			
	sub #64, w10								;if true keep update, else subtract update

	add #32, w10							
	mul.ss w13, [w10], w0						
	cpslt w1, w12									
	sub #32, w10														
	
	add #16, w10							
	mul.ss w13, [w10], w0						
	cpslt w1, w12									
	sub #16, w10														
	
	add #8, w10							
	mul.ss w13, [w10], w0						
	cpslt w1, w12									
	sub #8, w10														
	
	add #4, w10							
	mul.ss w13, [w10], w0						
	cpslt w1, w12									
	sub #4, w10														
	
	add #2, w10							
	mul.ss w13, [w10], w0						
	cpslt w1, w12									
	sub #2, w10														
												;now [w10] = 0.5 sin(theta), move w10 to 0.5 cos(theta)
	add #128, w10
											;limit current to temp_red_i_max_phase * cos(theta)
	mul.ss w13, [w10], w0
	sl w1, w13									;compensate for 0.5

											;phase current not higher than allowed
    mov wanted_i_real, w0
    cpslt w0, w13
    mov w13, wanted_i_real
											;and not lower than allowed
	neg w13, w13
	cpsgt w0, w13
	mov w13, wanted_i_real
	
;*****************************************************************
;* take care of watchdog timer
;*****************************************************************

    clrwdt
											;also tell temp sensor readout to start the next measurement cycle
    bclr flags1, #temp_sensor_cycle

;*****************************************************************
;* check for eeprom parameter write
;*****************************************************************
;-------------------------------------- check for ROM write (only in motor mode)

    btsc PORTD, #3
    bra tw_end

    btss flags_rom, #allow_rom_write
    bra tw_end

    btss flags1, #motor_mode
    bra tw_end
											;perform throttle ramp before storing data
	mov wanted_i_real, w0
	mov w0, wir_thr
	call throttle_ramp
	
    goto online_store_in_progmem

;*****************************************************************
;* end
;*****************************************************************
tw_end:
											;generate copy of wanted_i_real for throttle ramping routine
	mov wanted_i_real, w0
	mov w0, wir_thr

    return

;*****************************************************************

.global raw_to_throttle

;w13: contains address of thr_coeff_x+4
;w12: throttle_rawx address
;output is added to throttle

raw_to_throttle:
;-------------------------------------- initialise

    clr w11                                 ;w11: 1/8 * throttle for this throttle_rawx

;-------------------------------------- calculate throttle contribution
                                            ;w11 = c3
    add w11, [w13--], w11
                                            ;w11 *= [w12]
    mul.su w11, [w12], w10
                                            ;w11 += c2
    add w11, [w13--], w11
                                            ;w11 *= [w12]
    mul.su w11, [w12], w10
                                            ;w11 += c1
    add w11, [w13--], w11
                                            ;w11 *= [w12]
    mul.su w11, [w12], w10

;-------------------------------------- add to throttle, DO NOT SCALE YET !

    mov w11, w0
    add throttle

    return



	
	
.end




