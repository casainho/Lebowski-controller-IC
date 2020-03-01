.include "p30F4011.inc"
.include "defines.inc"

.text

.global process_all_variables
process_all_variables:
	
    mov #post_dr1_time, w1
    mov #1, w0
    call w14	
	
    mov #menus_completed, w1
    mov #1, w0
    call w14	
	
    mov #Kv, w1
    mov #2, w0
    call w14	
	
    mov #hall_stat, w1
    mov #10, w0
    call w14
	
    mov #hall_offset, w1
    mov #2, w0
    call w14
	
    mov #data_speed_limit, w1
    mov #1, w0
    call w14
	
    mov #data_current_limit_R, w1
    mov #1, w0
    call w14
	
    mov #data_current_limit_L, w1
    mov #1, w0
    call w14
	
    mov #data_collect_countdown_R, w1
    mov #1, w0
    call w14
	
    mov #data_collect_countdown_L, w1
    mov #1, w0
    call w14
	
    mov #data_filt_exponent, w1
    mov #1, w0
    call w14
	
    mov #imag_impedance, w1
    mov #2, w0
    call w14
	
	mov #real_impedance, w1
    mov #2, w0
    call w14

	mov #inv_vbat0, w1
    mov #1, w0
    call w14
	
	mov #vbat0, w1
    mov #1, w0
    call w14
	
	mov #accel_filt_coef, w1
    mov #1, w0
    call w14
	
	mov #max_accel, w1
    mov #2, w0
    call w14
	
	mov #phi_int_max_erpm, w1
    mov #2, w0
    call w14

    mov #max_erpm_rampdown, w1
    mov #2, w0
    call w14
	
	mov #phi_int_start_regen, w1
    mov #1, w0
    call w14

    mov #regen_rampup, w1
    mov #1, w0
    call w14
	
	mov #hvc_cutoff, w1
    mov #1, w0
    call w14
	
	mov #hvc_start, w1
    mov #1, w0
    call w14
	
	mov #lvc_cutoff, w1
    mov #1, w0
    call w14
	
	mov #lvc_start, w1
    mov #1, w0
    call w14
	
	mov #volt_scale, w1
    mov #1, w0
    call w14
	
	mov #vbat_filt_coeff, w1
    mov #1, w0
    call w14
	
	mov #ampli_upper_limit, w1
    mov #1, w0
    call w14
	
	mov #ampli_lower_limit, w1
    mov #1, w0
    call w14
	
	mov #phi_step_max, w1
    mov #1, w0
    call w14

	mov #ampli_fw, w1
    mov #1, w0
    call w14	

	mov #plic_2, w1
    mov #10, w0
    call w14
	
	mov #plic_3, w1
    mov #10, w0
    call w14

    mov #pll_coefs, w1
    mov #2, w0
    call w14

    mov #pll_bw, w1
    mov #1, w0
    call w14

    mov #pll_damp, w1
    mov #1, w0
    call w14

    mov #cycles_try_recov, w1
    mov #1, w0
    call w14

    mov #hall_array, w1
    mov #8, w0
    call w14

    mov #phi_int_max_erpm_shutdown, w1
    mov #1, w0
    call w14

    mov #phi_int_2to3, w1
    mov #1, w0
    call w14

    mov #phi_int_3to2, w1
    mov #1, w0
    call w14

    mov #phi_int_direction_change, w1
    mov #1, w0
    call w14

    mov #phi_int_hall_measure, w1
    mov #1, w0
    call w14

    mov #i_filter_offset, w1
    mov #1, w0
    call w14

    mov #i_force_regen, w1
    mov #1, w0
    call w14

    mov #i_error_max_fixed, w1
    mov #1, w0
    call w14

    mov #i_error_max_prop, w1
    mov #1, w0
    call w14

    mov #adc_current_offset, w1
    mov #3, w0
    call w14

    mov #pwm_period, w1
    mov #1, w0
    call w14

    mov #pwm_period_rec, w1
    mov #1, w0
    call w14

    mov #pwm_deadtime, w1
    mov #1, w0
    call w14

    mov #main_loop_count, w1
    mov #1, w0
    call w14

    mov #monitoring_value, w1
    mov #1, w0
    call w14

    mov #flags_rom, w1
    mov #1, w0
    call w14

    mov #flags_rom2, w1
    mov #1, w0
    call w14

    mov #battery_voltage, w1
    mov #1, w0
    call w14

    mov #thr_coeff_1, w1
    mov #3, w0
    call w14

    mov #thr_coeff_2, w1
    mov #3, w0
    call w14

    mov #thr1_offset, w1
    mov #1, w0
    call w14

    mov #thr1_range, w1
    mov #1, w0
    call w14

    mov #thr2_offset, w1
    mov #1, w0
    call w14

    mov #thr2_range, w1
    mov #1, w0
    call w14

    mov #i_max_phase, w1
    mov #1, w0
    call w14

    mov #i_min_recov, w1
    mov #1, w0
    call w14

    mov #i_max_bat_motoruse, w1
    mov #1, w0
    call w14

    mov #i_max_bat_regenuse, w1
    mov #1, w0
    call w14

    mov #dr0_XX_msec, w1
    mov #1, w0
    call w14

    mov #dr0_pulse_duration, w1
    mov #1, w0
    call w14

    mov #motor_standstill_voltage, w1
    mov #1, w0
    call w14

    mov #can_txsid, w1
    mov #1, w0
    call w14

    mov #can_rxsid, w1
    mov #1, w0
    call w14

    mov #can_cfg1, w1
    mov #1, w0
    call w14

    mov #can_cfg2, w1
    mov #1, w0
    call w14
	
    mov #plic_1, w1
    mov #10, w0
    call w14

    mov #alic_3, w1
    mov #6, w0
    call w14

    mov #alic_1, w1
    mov #6, w0
    call w14

    mov #transimpedance, w1
    mov #1, w0
    call w14

    mov #phi_int_for_impedance_measurement, w1
    mov #1, w0
    call w14

    mov #i_inductor_measurement, w1
    mov #1, w0
    call w14

    mov #fil2ord_percentage, w1
    mov #1, w0
    call w14

    mov #fil2ord_speed_recovery, w1
    mov #1, w0
    call w14

    mov #fil2ord_i_error, w1
    mov #1, w0
    call w14

    mov #fil2ord_dr2_motor_speed, w1
    mov #1, w0
    call w14
    
    mov #phi_int_wiggle, w1
    mov #1, w0
    call w14
    
    mov #ampli_wiggle, w1
    mov #1, w0
    call w14

    mov #cycles_2to3, w1
    mov #1, w0
    call w14

    mov #pulse_perc_to_reach, w1
    mov #1, w0
    call w14

    mov #over_i_total_prop, w1
    mov #1, w0
    call w14

    mov #over_i_total_fixed, w1
    mov #1, w0
    call w14

    mov #fil2ord_i_meas, w1
    mov #1, w0
    call w14

    mov #temp_ids, w1
    mov #32, w0
    call w14

    mov #temp_limit, w1
    mov #8, w0
    call w14

    mov #temp_current_red, w1
    mov #8, w0
    call w14

    mov #number_temp_sensors, w1
    mov #1, w0
    call w14
	
    mov #max_fieldweak_ratio, w1
    mov #1, w0
    call w14

    mov #fwlic, w1
    mov #1, w0
    call w14
 
    mov #stored_status, w1
    mov #72, w0
    call w14
	
	mov #data_collected, w1
	mov #20, w0
	call w14
                                                ;end by writing 32 dummy words to make sure last page is committed to program memory
	mov #data_array_sin, w1
	mov #32, w0
	call w14

    return

;*****************************************************************


.end


