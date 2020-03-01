.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"

.text

;Some variables stored in rom are the result of various settings.
;To be sure these variables are correct they are calculated upon
;entering the ROM menu.

.global calc_rom_variables
calc_rom_variables:
	
	call unset_calib_bits
	call calc_hall_pll_coeffs
	
	return
	
;*****************************************************************	
	
;Some variables stored in ram for motor use are calculated on startup

.global calc_ram_variables
calc_ram_variables:
	
	call calc_impedance_based_coeffs
	call calc_ampli_rampdown
	call calc_post_dr1_incr
	
	btsc flags_rom2, #use_hvc_lvc
	call calc_hvc_lvc_rampdown
	
	btsc flags_rom2, #limit_accel
	call calc_accel_ramp
	
	return
	
;*****************************************************************		
	
.global calc_rom_variables_online
calc_rom_variables_online:
											;process hall calibration if necessary, build when calib selected
;	btsc flags_rom, #calib_halls
;	call build_hall_array
                                            ;turn off the bit that allow online write
;    bclr flags_rom, #allow_rom_write
    bclr flags_rom, #calib_halls								
	
	return
	
;*****************************************************************
calc_post_dr1_incr:
											;post_dr1_incr = 8.95 * mlc / post_dr1_time[4.12]
	mov #9, w0
	mul main_loop_count
											;w3:w2 = 9 * mlc
	mov post_dr1_time, w4
	
	repeat #17
	div.ud w2, w4
	mov w0, post_dr1_incr
	
	clr w0
	repeat #17
	div.ud w0, w4
	mov w0, post_dr1_incr+2
	
	return
	
;*****************************************************************
	
unset_calib_bits:										
	
;---------------------------------------------- unset calib bits when mode not matching
													;unset hall calib when not in hall mode
	btss flags_rom, #hall_mode										
	bclr flags_rom, #calib_halls											
;---------------------------------------------- unset calib bits when allow_rom_write not set
;	btsc flags_rom, #allow_rom_write
;	return
													;unset all bits
;	bclr flags_rom, #calib_halls
;---------------------------------------------- end
	return
	
;*****************************************************************

calc_hall_pll_coeffs:
;--------------------------------------------- calc a0
												;a0 = mlc * pll_bw / 73
	mov pll_bw, w0
	mul main_loop_count
	mov #73, w4
	repeat #17
	div.ud w2, w4
	mov w0, pll_coefs
	
;--------------------------------------------- calc a1
												;a1 = 2^8 * a0 / damp^2
	mov #256, w1
	mul.uu w0, w1, w4
	
	mov pll_damp, w0
	mul.uu w0, w0, w2
	
	cp0 w2
	bra z, chpc_end
	
	repeat #17
	div.ud w4, w2
	
	mov w0, pll_coefs+2
	
;--------------------------------------------- end
chpc_end:	
	return
		
;*****************************************************************
	
calc_ampli_rampdown:
;--------------------------------------------- ampli_rampdown = 2^16 / (ampli_upper_limit-ampli_lower_limit )
	mov ampli_upper_limit, w2
	mov ampli_lower_limit, w1
	sub w2, w1, w2
													;prevent div_by_0
	btsc SR, #Z
	mov #700, w2
	
	btsc w2, #15
	neg w2, w2
	
	mov #1, w1
	clr w0
	repeat #17
	div.ud w0, w2
	
	inc w0, w0
	mov w0, ampli_rampdown
;--------------------------------------------- end
	return
	
;*****************************************************************
	
calc_hvc_lvc_rampdown:
;--------------------------------------------- hvc_ramp = 2^16 / |hvc_cutoff - hvc_start|
	mov hvc_cutoff, w2
	mov hvc_start, w1
	sub w2, w1, w2
													;prevent div_by_0
	btsc SR, #Z
	mov #700, w2
	
	btsc w2, #15
	neg w2, w2
	
	mov #1, w1
	clr w0
	repeat #17
	div.ud w0, w2
	
	inc w0, w0
	mov w0, hvc_ramp
;--------------------------------------------- lvc_ramp = 2^16 / |lvc_cutoff - lvc_start|
	mov lvc_cutoff, w2
	mov lvc_start, w1
	sub w2, w1, w2
													;prevent div_by_0
	btsc SR, #Z
	mov #700, w2
	
	btsc w2, #15
	neg w2, w2
	
	mov #1, w1
	clr w0
	repeat #17
	div.ud w0, w2
	
	inc w0, w0
	mov w0, lvc_ramp
;--------------------------------------------- end
	return
	
;*****************************************************************
	
calc_accel_ramp:
;--------------------------------------------- accel_ramp = 2^16 / |max_accel - max_accel+2|
	mov max_accel, w2
	mov max_accel+2, w1
	sub w2, w1, w2
													;prevent div_by_0
	btsc SR, #Z
	mov #700, w2
	
	btsc w2, #15
	neg w2, w2
	
	mov #1, w1
	clr w0
	repeat #17
	div.ud w0, w2
	
	inc w0, w0
	mov w0, accel_ramp

;--------------------------------------------- end
	return
	
;*****************************************************************

	
.end
