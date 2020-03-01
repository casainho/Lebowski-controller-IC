.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"
.include "fp_macros.mac"

.text
.global menu_halls
menu_halls:
    call clr_scr_232
    
;------------------------------------------------------
; display hall array contents
;------------------------------------------------------
	mov #hall_array, w13
	clr w12
                                                    ;loop 8 times
mh_loop:
                                                    ;print "\ncode:"
	mov #tblpage(hal_mes_code), w0
	mov #tbloffset(hal_mes_code), w1
	call tx_str_232
                                                    ;print number
	mov w12, w0						
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
                                                    ;print ", angle:"
	mov #tblpage(hal_mes_angle), w0
	mov #tbloffset(hal_mes_angle), w1
	call tx_str_232
                                                    ;print angle in 0-359 range
	mov #0xFF00, w0
	and w0, [w13], w0
	mov #360, w1
	mul.uu w0, w1, w0
	mov w1, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
                                                    ;print " deg, confidence:"
	mov #tblpage(hal_mes_deg), w0
	mov #tbloffset(hal_mes_deg), w1
	call tx_str_232
	mov #tblpage(hal_mes_conf), w0
	mov #tbloffset(hal_mes_conf), w1
	call tx_str_232
                                                    ;print top 3 bits of amplitude as confidence number
	mov #0x00FF, w0
	and w0, [w13], w0
	lsr w0, #3, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
                                                    ;print ", used:"
	mov #tblpage(hal_mes_used), w0
	mov #tbloffset(hal_mes_used), w1
	call tx_str_232
                                                    ;print yes or no based on LSB bit
	mov #tblpage(hal_mes_yes), w0
	mov #tbloffset(hal_mes_yes), w1
	btss [w13], #0
	mov #tblpage(hal_mes_no), w0
	btss [w13], #0
	mov #tbloffset(hal_mes_no), w1
	call tx_str_232
                                                    ;next loop iteration
	inc2 w13, w13
	inc w12, w12
	cp w12, #8
	bra nz, mh_loop
	
;------------------------------------------------------
;a) autocomplete
;------------------------------------------------------
    mov #tblpage(hal_mes_a), w0
    mov #tbloffset(hal_mes_a), w1
    call tx_str_232

    bra mh_msg_b

mh_opt_a:
													;set hall measure to lowest ( 5 k-erpm, half of phi_int_max_erpm)
	mov #5, w0
	clr w1
	                                                    ;convert to 8.8 format, times mlc, divide by 27.466 (7031 in 8.8)
    sl w0, #8, w0
    lsr w1, #8, w1
    ior w0, w1, w0

    mov main_loop_count, w1
    mul.uu w0, w1, w0
    mov #7031, w2
    repeat #17
    div.ud w0, w2
														;lowest of half phi_int_max_erpm and 5k
	mov phi_int_max_erpm, w1
	lsr w1, w1
	cpslt w0, w1 
	mov w1, w0
	
    mov w0, phi_int_hall_measure				
														;PLL: 100 Hz, damp = 0.7 [11.5]
	mov #100, w0
	mov w0, pll_bw
	mov #23, w0
	mov w0, pll_damp
														;clear hall offset
	clr hall_offset
	clr hall_offset+2	
														;hall assisted sensorless off
	bclr flags_rom2, #use_hall_assisted_sl

	bra menu_halls
;------------------------------------------------------
;b) toggle hall usage
;------------------------------------------------------
mh_msg_b:

    mov #tblpage(hal_mes_b), w0
    mov #tbloffset(hal_mes_b), w1
    call tx_str_232

    bra mh_msg_c

mh_opt_b:

    mov #tblpage(hal_mes_b1), w0
    mov #tbloffset(hal_mes_b1), w1
    call tx_str_232

	mov #3, w0
	call get_number

	mov #0x0007, w1
	and w0, w1, w0
	mov #hall_array, w13
	add w0, w13, w13
	add w0, w13, w13

	btg [w13], #0

    bra menu_halls

;------------------------------------------------------
;c) calibrate hall positions
;------------------------------------------------------
mh_msg_c:

    mov #tblpage(hal_mes_c), w0
    mov #tbloffset(hal_mes_c), w1
    call tx_str_232

	mov #tblpage(hal_mes_yes), w0
	mov #tbloffset(hal_mes_yes), w1
	btss flags_rom, #calib_halls
	mov #tblpage(hal_mes_no), w0
	btss flags_rom, #calib_halls
	mov #tbloffset(hal_mes_no), w1
	call tx_str_232

    bra mh_msg_d

mh_opt_c:

	btg flags_rom, #calib_halls

	bra menu_halls
	
;------------------------------------------------------
;d) erpm for hall calibration:
;------------------------------------------------------
mh_msg_d:
    mov #tblpage(hal_mes_d), w0
    mov #tbloffset(hal_mes_d), w1
    call tx_str_232
                                                        ;erpm = (pime / 65536) * (30e6/mlc) * 60 =>
                                                        ;erpm = 27466 * phi_int_ / mlc
    mov phi_int_hall_measure, w0
    mov #7031, w1                                           ;w1 = 27.466 in 8.8 -> 	7031
    mul.uu w0, w1, w0
    mov main_loop_count, w2
    repeat #17
    div.ud w0, w2
                                                            ;now w0: answer in 8.8 format
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

    mov #tblpage(hal_mes_d1), w0
    mov #tbloffset(hal_mes_d1), w1
    call tx_str_232

    bra mh_msg_e

mh_opt_d:

    mov #10, w0
    call get_signed_decimal_number
                                                            ;convert to 8.8 format, times mlc, divide by 27.466 (7031 in 8.8)
    sl w0, #8, w0
    lsr w1, #8, w1
    ior w0, w1, w0

    mov main_loop_count, w1
    mul.uu w0, w1, w0
    mov #7031, w2
    repeat #17
    div.ud w0, w2

    mov w0, phi_int_hall_measure

    bra menu_halls	
;------------------------------------------------------
;e) PLL bandwidth
;------------------------------------------------------
mh_msg_e:
	print_txt hal_mes_e
	
	mov pll_bw, w0
	print_udec
	
	print_txt hal_mes_e1
	
    bra mh_msg_f
	
mh_opt_e:
	
	mov #5, w0
    call get_number
	
	mov w0, pll_bw
	
    bra menu_halls

;------------------------------------------------------
;f) PLL damping factor
;------------------------------------------------------
mh_msg_f:
	print_txt hal_mes_f
															;pll_damp = [11.5]
	mov pll_damp, w0
	lsr w0, #5, w0
	print_udec
	mov pll_damp, w0
	sl w0, #11, w0
	print_frac 2
	
    bra mh_msg_g
	
mh_opt_f:
	
	mov #10, w0
    call get_signed_decimal_number
                                                            ;convert to 11.5 format
    sl w0, #5, w0
    lsr w1, #11, w1
    ior w0, w1, w0
															;limit to 8 bits
	mov #0x00FF, w1
	and w0, w1, w0
	
	mov w0, pll_damp

    bra menu_halls
	
;------------------------------------------------------
;g) hall offset, forward:
;------------------------------------------------------
mh_msg_g:
	print_txt hal_mes_g
															
	mov hall_offset, w0
	print_sign
	mov #360, w1
	mul.us w1, w0, w2
	
	push w2
	mov w3, w0
	print_udec
	pop w0
	print_frac 2
	
	print_txt hal_mes_deg
	
    bra mh_msg_h
	
mh_opt_g:
	
	mov #10, w0
    call get_signed_decimal_number
	
	exch w0, w1
	mov #360, w2
	repeat #17
	div.sd w0, w2
	
	mov w0, hall_offset

    bra menu_halls
	
;------------------------------------------------------
;h) hall offset, reverse:
;------------------------------------------------------
mh_msg_h:
	print_txt hal_mes_h
															
	mov hall_offset+2, w0
	print_sign
	mov #360, w1
	mul.us w1, w0, w2
	
	push w2
	mov w3, w0
	print_udec
	pop w0
	print_frac 2
	
	print_txt hal_mes_deg
	
    bra mh_msg_i
	
mh_opt_h:
	
	mov #10, w0
    call get_signed_decimal_number
	
	exch w0, w1
	mov #360, w2
	repeat #17
	div.sd w0, w2
	
	mov w0, hall_offset+2

    bra menu_halls
	
;------------------------------------------------------
;i) hall assisted sensorless
;------------------------------------------------------
mh_msg_i:

    mov #tblpage(hal_mes_i), w0
    mov #tbloffset(hal_mes_i), w1
    call tx_str_232

	mov #tblpage(hal_mes_yes), w0
	mov #tbloffset(hal_mes_yes), w1
	btss flags_rom2, #use_hall_assisted_sl
	mov #tblpage(hal_mes_no), w0
	btss flags_rom2, #use_hall_assisted_sl
	mov #tbloffset(hal_mes_no), w1
	call tx_str_232

    bra mh_msg_z

mh_opt_i:

	btg flags_rom2, #use_hall_assisted_sl

	bra menu_halls	
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
mh_msg_z:
    mov #tblpage(hal_mes_z), w0
    mov #tbloffset(hal_mes_z), w1
    call tx_str_232

    bra mh_msg_choise
mh_opt_z:
    return

;------------------------------------------------------
mh_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, mh_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, mh_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, mh_opt_c
    mov #'d', w1
    cp w0, w1
    bra z, mh_opt_d
    mov #'e', w1
    cp w0, w1
    bra z, mh_opt_e
    mov #'f', w1
    cp w0, w1
    bra z, mh_opt_f
    mov #'g', w1
    cp w0, w1
    bra z, mh_opt_g
    mov #'h', w1
    cp w0, w1
    bra z, mh_opt_h
    mov #'i', w1
    cp w0, w1
    bra z, mh_opt_i
	mov #'z', w1
    cp w0, w1
    bra z, mh_opt_z
	mov #'0', w1
    cp w0, w1
    bra z, mh_opt_0
	mov #'#', w1
    cp w0, w1
    bra z, mh_opt_st

    bra menu_halls

;**********************************************************

hal_mes_a:
	.pascii "\n\na) autocomplete\n\0"
hal_mes_b:
    .pascii "\nb) toggle hall usage\0"
hal_mes_b1:
    .pascii "\n enter code to toggle \n\0"
hal_mes_c:
    .pascii "\nc) calibrate hall mode: \0"
hal_mes_d:
    .pascii "\nd) erpm for hall calibration: \0"
hal_mes_d1:
    .pascii " k-erpm\0"	
hal_mes_e:
	.pascii "\ne) PLL bandwidth: \0"
hal_mes_e1:
	.pascii " Hz\0"
hal_mes_f:
	.pascii "\nf) PLL damping factor: \0"
hal_mes_g:
	.pascii "\ng) hall offset, forward: \0"
hal_mes_h:
	.pascii "\nh) hall offset, reverse: \0"
hal_mes_i:
	.pascii "\ni) hall assisted sensorless: \0"
hal_mes_z:
    .pascii "\n\n0) reset hall statistics\n#) display hall statistics\nz) return to main menu"
    .pascii "\n\n\0"
hal_mes_code:
	.pascii "\n code: \0"
hal_mes_angle:
	.pascii ", angle: \0"
hal_mes_deg:
	.pascii " deg\0"
hal_mes_conf:
	.pascii ", confidence: \0"
hal_mes_used:
	.pascii ", used: \0"
hal_mes_yes:
	.pascii "yes\0"
hal_mes_no:
	.pascii "no\0"

	
;**********************************************************	
	
mh_opt_0:
	print_txt hall_stat_reset
	
	mov #hall_stat, w13
	repeat #9
	clr [w13++]
	
	call rx_char_232
	
	bra menu_halls
	
hall_stat_reset:
	.pascii "\n\n hall statistics data reset\n\n\0"
	
;**********************************************************	
	
mh_opt_st:							
;----------------------------------	print forward
	print_txt hs_1f
	
	mov hall_stat, w0
	print_udec
	
	cp0 hall_stat
	bra z, 1f
	
	print_txt hs_2
													;deg = (hallstat+2 / N) * (360/65536)
	signed_to_fp hall_stat regA
	mov #regA, w13
	call fp_oneover
	
	mov #hall_stat+2, w12
	call fp_mult
	mov #-22, w0
	mov w0, regB
													;print negative value so we can add to offset (easier for user)
	mov #-23040, w0
	mov w0, regB+2
	mov #regB, w12
	call fp_mult
	
	call fp_print
	
	print_txt hs_3
													;regA = regB = 1/N
	signed_to_fp hall_stat regA
	mov #regA, w13
	call fp_oneover
	mov #regA, w12
	mov #regB, w13
	reg_copy
													;regA = - (Ex/N)^2
	mov #regA, w13
	mov #hall_stat+2, w12
	call fp_mult
	mov #regA, w12
	call fp_mult
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]
													;regB = Ex^2/N
	mov #regB, w13
	mov #hall_stat+6, w12
	call fp_mult
													;regB = Ex^2/N - (Ex/N)^2
	mov #regA, w12
	call fp_add
													;regB = sqrt ( Ex2/N - (Ex/N)^2 )
	call fp_sqrt
													;regB = (360/65536) * sqrt ( Ex2/N - (Ex/N)^2 )
	mov #-22, w0
	mov w0, regA
	mov #23040, w0
	mov w0, regA+2
	mov #regA, w12
	call fp_mult
													;print regB, the std-dev
	call fp_print
	print_txt hs_4
1:
;----------------------------------	print reverse
			
	print_txt hs_1r
	
	mov hall_stat+10, w0
	print_udec
	
	cp0 hall_stat+10
	bra z, 1f
	
	print_txt hs_2
													;deg = (hallstat+2 / N) * (360/65536)
	signed_to_fp hall_stat+10 regA
	mov #regA, w13
	call fp_oneover
	
	mov #hall_stat+12, w12
	call fp_mult
	mov #-22, w0
	mov w0, regB
													;print negative value so we can add to offset (easier for user)
	mov #-23040, w0
	mov w0, regB+2
	mov #regB, w12
	call fp_mult
	
	call fp_print
	
	print_txt hs_3
													;regA = regB = 1/N
	signed_to_fp hall_stat+10 regA
	mov #regA, w13
	call fp_oneover
	mov #regA, w12
	mov #regB, w13
	reg_copy
													;regA = - (Ex/N)^2
	mov #regA, w13
	mov #hall_stat+12, w12
	call fp_mult
	mov #regA, w12
	call fp_mult
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]
													;regB = Ex^2/N
	mov #regB, w13
	mov #hall_stat+16, w12
	call fp_mult
													;regB = Ex^2/N - (Ex/N)^2
	mov #regA, w12
	call fp_add
													;regB = sqrt ( Ex2/N - (Ex/N)^2 )
	call fp_sqrt
													;regB = (360/65536) * sqrt ( Ex2/N - (Ex/N)^2 )
	mov #-22, w0
	mov w0, regA
	mov #23040, w0
	mov w0, regA+2
	mov #regA, w12
	call fp_mult
													;print regB, the std-dev
	call fp_print
	print_txt hs_4
;----------------------------------	wait for key, end
1:		
	print_CR
	call rx_char_232
	
	bra menu_halls
	
	

hs_1f:.pascii	"\n\n forward\ncount: \0"	
hs_1r:.pascii	"\n\n reverse\ncount: \0"
hs_2:.pascii	"\naverage: \0"	
hs_3:.pascii	" deg\nstd-dev: \0"	
hs_4:.pascii	" deg\0"
	

	
.end

