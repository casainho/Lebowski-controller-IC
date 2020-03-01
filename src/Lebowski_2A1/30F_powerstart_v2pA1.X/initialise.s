.include "p30F4011.inc"
.include "defines.inc"

.text

;**********************************************

.global initialise
initialise:
						
;---------------------------------------------- initialise

    call init_interrupts
    call init_232
    call clear_variables
    call restore_from_progmem
	call calc_ram_variables
	call fill_pwm_and_sin_arrays
	call initialise_angle_amplitude_accurate
	call timers_open
	call PWM_open
    call ADC_open
    call reset_filters
    call LEDs_open
    call halls_open
    call temp_open
	call reset_collect_imp_data
	call store_imp_data
	call initialise_sine_walk
													;some things only initialise when in motor mode
    btsc flags1, #motor_mode
	call ini_motor_mode
													;make sure there are 7 or less temp sensors
    mov number_temp_sensors, w0
    mov #0xFFF8, w1
    and w0, w1, w1
    btss SR, #Z
    clr w0
    mov w0, number_temp_sensors
                                                    ;initialise temp_red_i_max_phase, as this is always used
													;in the throttle routine, also when there are no temp sensors
	mov i_max_phase, w0
	mov w0, temp_red_i_max_phase
                                                    ;initialise for activity indication
    bclr TRISD, #2
    bclr LATD, #2

    return

;***********************************************

ini_motor_mode:
													;if not all menus completed, endlessly blink error
	mov menus_completed, w0
	mov #mc_mask, w1
	and w0, w1, w0
	btss SR, #Z
	goto LED_menu_error
													;switch off hall assisted sensorless when not in hall mode
	btss flags_rom, #hall_mode
	bclr flags_rom2, #use_hall_assisted_sl
                                                    ;open throttle only when in motor mode (ivm CAN interrupts)
    call throttle_open
													;clear all motor measurement bits when not allow_rom_write
	btsc flags_rom, #allow_rom_write
	bra imm_end
	
	bclr flags_rom, #calib_halls
imm_end:
	return
	
;***********************************************

.global reset_filters
reset_filters:

    clr filter_I
    clr filter_I+2

    clr filter_Q
    clr filter_Q+2
	
    clr filter_I_error
    clr filter_I_error+2
	
    clr filter_spd
    clr filter_spd+2
	
    clr filter_w8
    clr filter_w8+2
	
    clr filter_w9
    clr filter_w9+2
	
    clr filter_wir
    clr filter_wir+2
	
    mov #filter_hallX, w0
    repeat #15
    clr [w0++]
    mov #filter_hallY, w0
    repeat #15
    clr [w0++]
	
    clr [w0++]
    mov #filt_spd_ctrl, w0
    repeat #2
    clr [w0++]

    mov #49152, w0
    mov w0, filter_inv_vbat
    clr filter_inv_vbat+2
	
	clr filter_vbat
	clr filter_vbat+2

	clr filter_accel
	clr filter_accel+2
	
    return

;***********************************************

.global clear_variables
clear_variables:

    clr phi_motor
    clr phi_motor+2
    clr phi_hf_motor
    clr phi_int
    clr phi_int+2
    clr phi_prop
    clr phi_prop+2
    clr phi_motor_magbased
    clr phi_motor_magbased+2
	clr phi_hf_offset
	clr phi_offset
	clr phi_step
	clr phi_step_int
	clr phi_int_prev
	clr phi_int_prev+2

	clr count_tot
	clr count_tot+2
	
	clr pll_phi
	clr pll_phi+2
	clr pll_int
	clr pll_int+2

    clr ampli_real
    clr ampli_real+2
    clr ampli_imag
    clr ampli_imag+2
	clr ampli_imag_prop
    clr ampli_prop
    clr ampli_imag_prop
    clr ampli_hf_motor
	
	clr fieldweak

    clr wanted_i_real
	clr wir_thr
    clr wanted_i_imag
	clr sine_i_imag
	clr wanted_phi_int
	clr phi_motor_prev
	clr post_dr1_ramp
	clr post_dr1_ramp+2
	
	clr pred_i_real
	clr pred_i_real+2
	clr pred_i_imag
	clr pred_i_imag+2

    mov #512, w0
    mov w0, adc_current_prev
    mov w0, adc_current_prev+2
    mov w0, adc_current_prev+4
    
    mov #32768, w0
    mov w0, adc_current_offset_lsbs
    mov w0, adc_current_offset_lsbs+2
    mov w0, adc_current_offset_lsbs+4

    clr supply_voltage
    mov #43691, w0
    mov w0, filter_inv_vbat

    bclr flags1, #tx_allowed
    bclr flags1, #ADCs_to_current_sensors
    bclr flags1, #over_i_imag
    bclr flags1, #over_erpm
    bclr flags1, #over_i_total
    bclr flags1, #reverse
    bclr flags1, #reverse_request
	bclr flags1, #clipping
	bclr flags2, #direction_phase_loop
	bclr flags2, #direction_ampli_loop
	
	clr flags2
	
    mov #temp_data, w13
    repeat #7
    clr [w13++]
	clr temp_data_rxed
	
    return
    


.end

