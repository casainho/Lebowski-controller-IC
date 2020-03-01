.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"
.include "fp_macros.mac"

.text


.global store_status
;
;status is written at start of drive_1
;
store_status:
;-------------------------------------- move all previous status reports one position down
	mov #stored_status+106, w13				;3*36-2
	mov #stored_status+142, w12				;4*36-2
	
	repeat #53								;3*(36/2)-1
	mov [w13--], [w12--]
	
;-------------------------------------- stored_status+0, ampli_sf plus conkout and LED bits
	clr w0
	
	btsc LATC, #15
	bset w0, #cs_led0
	
	btsc LATC, #13
	bset w0, #cs_led1
	
	btsc LATC, #14
	bset w0, #cs_led2
	
	btsc LATE, #8
	bset w0, #cs_led3
	
	btsc flags1, #over_i_total
	bset w0, #cs_over_i_total
	
	btsc flags1, #over_i_imag
	bset w0, #cs_over_i_imag
	
	btsc flags1, #over_erpm
	bset w0, #cs_over_erpm
	
	btsc flags1, #clipping
	bset w0, #cs_clipping
	
	mov w0, stored_status
;-------------------------------------- clear unused variables before saving, to avoid confusion
	btsc stored_status, #cs_led0
	bra in_dr_0
	btsc stored_status, #cs_led1
	bra in_dr_1
	btsc stored_status, #cs_led2
	bra in_dr_2
	btsc stored_status, #cs_led3
	bra in_dr_3
	
	bra cont_with_store
	
in_dr_0:
	clr phi_int
	clr ampli_real
	clr ampli_imag
	clr wanted_i_real
	clr wanted_i_imag
	clr filter_I_error
	clr filter_w8
	clr filter_w9
	bra cont_with_store
	
in_dr_1:
	clr filter_I_error
	clr filter_w8
	clr filter_w9	
	bra cont_with_store
	
in_dr_2:
	btsc stored_status, #cs_led3
	bra in_dr_23

	bra cont_with_store

in_dr_23:
											;clear unobserved error bits
	bclr stored_status, #cs_over_i_imag
	bra cont_with_store
	
in_dr_3:
	clr pll_int
	bclr stored_status, #cs_over_i_total
	
;-------------------------------------- stored_status + 2: count_last_drive_mode
cont_with_store:
	mov count_ldm, w0
	mov w0, stored_status+2
	mov count_ldm+2, w0
	mov w0, stored_status+4
;-------------------------------------- stored_status + 6: throttle	
	mov throttle, w0
	mov w0, stored_status+6
;-------------------------------------- stored_status + 8: filter_I_error
	mov filter_I_error, w0
	mov w0, stored_status+8
;-------------------------------------- stored_status +10: phi_int
	mov phi_int, w0
	mov w0, stored_status+10
;-------------------------------------- stored_status +12: filter_w8
	mov filter_w8, w0
	mov w0, stored_status+12
;-------------------------------------- stored_status +14: ampli_real 
	mov ampli_real, w0
	mov w0, stored_status+14
;-------------------------------------- stored_status +16: ampli_imag 
	mov ampli_imag, w0
	mov w0, stored_status+16
;-------------------------------------- stored_status +18: wanted_i_real
	mov wanted_i_real, w0
	mov w0, stored_status+18
;-------------------------------------- stored_status +20: wanted_i_imag
	mov wanted_i_imag, w0
	add sine_i_imag, wreg
	mov w0, stored_status+20
;-------------------------------------- stored_status +22: filter_w9
	mov filter_w9, w0
	mov w0, stored_status+22
;-------------------------------------- stored_status +24: imag_impedance
	mov #imag_impedance, w12
	mov #stored_status+24, w13
	reg_copy
;-------------------------------------- stored_status +28: real_impedance
	mov #real_impedance, w12
	mov #stored_status+28, w13
	reg_copy
;-------------------------------------- stored_status +32: total on time
	mov count_tot, w0
	mov w0, stored_status+32
	mov count_tot+2, w0
	mov w0, stored_status+34
;-------------------------------------- end
    return
	
;*****************************************************************
.global print_status
;
;w13: points to start of status array
;
print_status:
;-------------------------------------- print error bits
	print_txt txt_status
	
	btss [w13], #cs_clipping
	bra 1f
	print_txt txt_clipping
1:
	btss [w13], #cs_over_i_total
	bra 1f
	print_txt txt_error_itotal
1:
	btss [w13], #cs_over_i_imag
	bra 1f
	print_txt txt_error_iimag
1:
	btss [w13], #cs_over_erpm
	bra 1f
	print_txt txt_error_erpm
1:
;-------------------------------------- print LED status
	print_txt txt_leds
	
	mov #'0', w0
	btss [w13], #cs_led0
	mov #'.', w0
	call tx_char_232
	
	mov #'1', w0
	btss [w13], #cs_led1
	mov #'.', w0
	call tx_char_232
	
	mov #'2', w0
	btss [w13], #cs_led2
	mov #'.', w0
	call tx_char_232
	
	mov #'3', w0
	btss [w13], #cs_led3
	mov #'.', w0
	call tx_char_232
;-------------------------------------- print total on time in last drive mode
	print_txt txt_time_on

	mov #32, w4
	
	call print_time
;-------------------------------------- print time spent in last drive mode
	print_txt txt_time_spent

	mov #2, w4
	
	call print_time
;-------------------------------------- print throttle, wanted_i_real, wanted_i_imag
											;throttle
	print_txt txt_throttle
	
	mov #200, w0
	mov [w13+6], w1
	mul.us w0, w1, w0
	mov w1, w0
	
	print_sdec
	print_txt txt_perc
											;wanted_i_real
	print_txt txt_wanted_i_real
	mov [w13+18], w0
	print_sign
    call display_current
	print_txt txt_amp
											;wanted_i_imag
	print_txt txt_wanted_i_imag
	mov [w13+20], w0
	print_sign
    call display_current
	print_txt txt_amp
	
;-------------------------------------- print filter_i_error, filter_I, filter_Q, filter_w8, filter_w9

											;filter_w8
	print_txt txt_filter_w8
	mov [w13+12], w0
	print_sign
    call display_current
	print_txt txt_amp
											;filter_w9
	print_txt txt_filter_w9
	mov [w13+22], w0
	print_sign
    call display_current
	print_txt txt_amp
											;filter_i_error
	print_txt txt_filter_i_error
	mov [w13+8], w0
	print_sign
    call display_current
	print_txt txt_amp
	
;-------------------------------------- print ampli_real, ampli_imag
											;ampli_real
	print_txt txt_ampli_real
	mov #200, w0
	mov [w13+14], w1
	mul.us w0, w1, w0
	mov w1, w0
	print_sdec
	print_txt txt_perc
											;ampli_imag
	print_txt txt_ampli_imag
	mov #200, w0
	mov [w13+16], w1
	mul.us w0, w1, w0
	mov w1, w0
	print_sdec
	print_txt txt_perc

;-------------------------------------- print phi_int, pll_int, filt_fast_accel
											;phi_int
	print_txt txt_phi_int                                                       
    mov [w13+10], w0
	print_sign
											;copied from erpm menu
    mov #7031, w1                                           
    mul.uu w0, w1, w0
    mov main_loop_count, w2
    repeat #17
    div.ud w0, w2
    mov w0, w2
    lsr w0, #8, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    sl w2, #8, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+3
    mov #str_buf, w0
    call tx_ram_str_232

	print_txt txt_kerpm
;-------------------------------------- print impedance
											;inductor
	print_txt txt_L
	mov #24, w11	
	add w13, w11, w11
	call print_readable_L
	print_txt txt_uH
											;resistance
	print_txt txt_R
	mov #28, w11
	add w13, w11, w11
	call print_readable_R
	print_txt txt_Ohm
	
;-------------------------------------- end
    return				
	
print_time:
												;calculate f_sample in Hz (30e6 / mlc)
	mov #457, w1
	mov #50048, w0
	mov main_loop_count, w2
	repeat #17
	div.ud w0, w2
	mov w0, w2
											;time[sec] = count_here / f_sample
	mov [w13+w4], w0
	inc2 w4, w4
	mov [w13+w4], w1
	repeat #17
	div.ud w0, w2
	
	push w2
	push w1
	print_udec
	pop w1
	pop w2
											;decimal part = 65536*remainder / w2
	clr w0
	repeat #17
	div.ud w0, w2
	
	print_frac 3
	
	print_txt txt_sec
	
	return
	

txt_L:
	.pascii "\nL:                         \0"
txt_uH:
	.pascii " uH\0"
txt_R:
	.pascii "\nR:                         \0"
txt_Ohm:
	.pascii " mOhm\0"
txt_status:
	.pascii	"\nstatus bits:               \0"
txt_stab_coefs:
	.pascii  "safety_coefs \0"
txt_clipping:
	.pascii  "clipping \0"
txt_error_iimag:
	.pascii  "over_i_error \0"
txt_error_itotal:
	.pascii	"over_i_total or over_i_error \0"
txt_error_erpm:
	.pascii	"over_erpm \0"
txt_leds:
	.pascii	"\ndrive LEDS:                \0"
txt_time_on:
	.pascii	"\ntotal on time:             \0"
txt_time_spent:
	.pascii	"\ntime in drive mode:        \0"
txt_sec:
	.pascii	" sec\0"
txt_throttle:
	.pascii	"\nthrottle:                  \0"
txt_perc:
	.pascii	" %\0"
txt_wanted_i_real:
	.pascii	"\nwanted_i_torque:           \0"
txt_amp:
	.pascii	" A\0"
txt_wanted_i_imag:
	.pascii	"\nwanted_i_fieldweak:        \0"
txt_filter_w8:
	.pascii	"\nmeasured_i_torque:         \0"
txt_filter_w9:
	.pascii	"\nmeasured_i_fieldweak:      \0"
txt_filter_i_error:
	.pascii	"\nmeasured_i_error:          \0"
txt_ampli_real:
	.pascii	"\nVout_real:                 \0"
txt_ampli_imag:
	.pascii	"\nVout_imag:                 \0"
txt_phi_int:
	.pascii "\nspeed:                     \0"
txt_kerpm:
	.pascii	" k-erpm\0"

	
	
.end