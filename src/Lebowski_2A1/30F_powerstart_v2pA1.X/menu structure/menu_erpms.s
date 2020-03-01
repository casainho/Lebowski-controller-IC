.include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_erpms
menu_erpms:
    call clr_scr_232
;------------------------------------------------------
;a) erpm limiter (forward) rampdown start, end:
;------------------------------------------------------
    mov #tblpage(erpms_mes_a), w0
    mov #tbloffset(erpms_mes_a), w1
    call tx_str_232

	mov phi_int_max_erpm, w0
	call print_kerpm
	
    mov #tblpage(erpms_mes_comma), w0
    mov #tbloffset(erpms_mes_comma), w1
    call tx_str_232
															;erpm_range = 2^16 / max_erpm_rampdown
	mov #1, w1
	clr w0
	mov max_erpm_rampdown, w2
	cp0 w2
	btsc SR, #Z
	setm w2
	repeat #17
	div.ud w0, w2
															;add lower limmit
	add phi_int_max_erpm, wreg
															;erpm in w0
	call print_kerpm														
															
    mov #tblpage(erpms_mes_kerpm), w0
    mov #tbloffset(erpms_mes_kerpm), w1
    call tx_str_232

    bra me_msg_b

me_opt_a:

    call input_kerpm
    mov w0, phi_int_max_erpm
	
	call input_kerpm
	subr phi_int_max_erpm, wreg
															;invert w0, 2^16 / w0
    mov w0, w2
	mov #1, w1
	clr w0
	cp0 w2
	btsc SR, #Z
	mov #1, w2
	repeat #17
	div.ud w0, w2
	mov w0, max_erpm_rampdown
															;determine shutdown erpm
	mov phi_int_max_erpm, w0
	mov phi_int_max_erpm+2, w1
	cpsgt w0, w1
	mov w1, w0					    
							    
    mov w0, phi_int_max_erpm_shutdown
    mov #40000, w1
    mul.uu w0, w1, w0
    mov w1, w0
    add phi_int_max_erpm_shutdown

    bra menu_erpms

;------------------------------------------------------
;b)  erpm limiter (reverse) rampdown start, end:
;------------------------------------------------------
me_msg_b:
    mov #tblpage(erpms_mes_b), w0
    mov #tbloffset(erpms_mes_b), w1
    call tx_str_232
	
    mov phi_int_max_erpm+2, w0
    call print_kerpm

    mov #tblpage(erpms_mes_comma), w0
    mov #tbloffset(erpms_mes_comma), w1
    call tx_str_232
															;erpm_range = 1 / max_erpm_rampdown
	mov #1, w1
	clr w0
	mov max_erpm_rampdown+2, w2
	cp0 w2
	btsc SR, #Z
	setm w2
	repeat #17
	div.ud w0, w2
															;add lower limmit
	add phi_int_max_erpm+2, wreg
															;erpm in w0
    call print_kerpm

    mov #tblpage(erpms_mes_kerpm), w0
    mov #tbloffset(erpms_mes_kerpm), w1
    call tx_str_232

    bra me_msg_c

me_opt_b:
															;reverse max erpm
    call input_kerpm
    mov w0, phi_int_max_erpm+2
															;and rampdown
    call input_kerpm

	subr phi_int_max_erpm+2, wreg
    mov w0, w2
	mov #1, w1
	clr w0
	cp0 w2
	btsc SR, #Z
	mov #1, w2
	repeat #17
	div.ud w0, w2
	mov w0, max_erpm_rampdown+2
															;determine shutdown erpm
	mov phi_int_max_erpm, w0
	mov phi_int_max_erpm+2, w1
	cpsgt w0, w1
	mov w1, w0					    
							    
    mov w0, phi_int_max_erpm_shutdown
    mov #40000, w1
    mul.uu w0, w1, w0
    mov w1, w0
    add phi_int_max_erpm_shutdown

    bra menu_erpms

;------------------------------------------------------
;c) regen rampup start, end:
;------------------------------------------------------
me_msg_c:
    mov #tblpage(erpms_mes_c), w0
    mov #tbloffset(erpms_mes_c), w1
    call tx_str_232
                                                            ;erpm = phi_int_ * 27466 / main_loop_count
    mov phi_int_start_regen, w0
    mov #27466, w1
    mul.uu w0, w1, w0
    mov main_loop_count, w2
    repeat #17
    div.ud w0, w2
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(erpms_mes_comma), w0
    mov #tbloffset(erpms_mes_comma), w1
    call tx_str_232
															;erpm_range = 2^16 / max_erpm_rampdown
	mov #1, w1
	clr w0
	mov regen_rampup, w2
	cp0 w2
	btsc SR, #Z
	setm w2
	repeat #17
	div.ud w0, w2
	add phi_int_start_regen, wreg

    mov #27466, w1
    mul.uu w0, w1, w0
    mov main_loop_count, w2
    repeat #17
    div.ud w0, w2

    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(erpms_mes_erpm), w0
    mov #tbloffset(erpms_mes_erpm), w1
    call tx_str_232

    bra me_msg_d

me_opt_c:
                                                            ;get new e-rpm limit
    mov #4, w0
    call get_number
                                                            ;phi_int_ = e-rpm * main_loop_count / 27466
    mov main_loop_count, w1
    mul.uu w0, w1, w0
    mov #27466, w2
    repeat #17
    div.ud w0, w2

    mov w0, phi_int_start_regen

    mov #4, w0
    call get_number
    mov main_loop_count, w1
    mul.uu w0, w1, w0
    mov #27466, w2
    repeat #17
    div.ud w0, w2
	subr phi_int_start_regen, wreg
	mov w0, w2
																;erpm_range = 2^16 / max_erpm_rampdown
	mov #1, w1
	clr w0
	cp0 w2
	btsc SR, #Z
	setm w2
	repeat #17
	div.ud w0, w2

	mov w0, regen_rampup
	
    bra menu_erpms
;------------------------------------------------------
;d) accept direction change below
;------------------------------------------------------
me_msg_d:
    mov #tblpage(erpms_mes_d), w0
    mov #tbloffset(erpms_mes_d), w1
    call tx_str_232
                                                            ;erpm = phi_int_2to3 * 27466 / main_loop_count
    mov phi_int_direction_change, w0
    mov #27466, w1
    mul.uu w0, w1, w0
    mov main_loop_count, w2
    repeat #17
    div.ud w0, w2

    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(erpms_mes_erpm), w0
    mov #tbloffset(erpms_mes_erpm), w1
    call tx_str_232

    bra me_msg_e

me_opt_d:
                                                            ;get new e-rpm limit
    mov #4, w0
    call get_number
                                                            ;phi_int_2to3 = e-rpm * main_loop_count / 27466
    mov main_loop_count, w1
    mul.uu w0, w1, w0
    mov #27466, w2
    repeat #17
    div.ud w0, w2

    mov w0, phi_int_direction_change

    bra menu_erpms

;------------------------------------------------------
;e) erpm dr3 back to dr2:
;------------------------------------------------------
me_msg_e:
    mov #tblpage(erpms_mes_e), w0
    mov #tbloffset(erpms_mes_e), w1
    call tx_str_232
                                                            ;erpm = phi_int_2to23 * 27466 / main_loop_count
    mov phi_int_3to2, w0
    mov #27466, w1
    mul.uu w0, w1, w0
    mov main_loop_count, w2
    repeat #17
    div.ud w0, w2

    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(erpms_mes_erpm), w0
    mov #tbloffset(erpms_mes_erpm), w1
    call tx_str_232

    bra me_msg_f

me_opt_e:
                                                            ;get new e-rpm limit
    mov #4, w0
    call get_number
                                                            ;phi_int_3to2 = e-rpm * main_loop_count / 27466
    mov main_loop_count, w1
    mul.uu w0, w1, w0
    mov #27466, w2
    repeat #17
    div.ud w0, w2
															;must be lower than phi_int_2to3
	mov phi_int_2to3, w1
	cp w0, w1
	bra ltu, 1f
	dec w1, w0
1:	
    mov w0, phi_int_3to2

    bra menu_erpms
	
;------------------------------------------------------
;f) erpm dr2 jump to dr3
;------------------------------------------------------
me_msg_f:
    mov #tblpage(erpms_mes_f), w0
    mov #tbloffset(erpms_mes_f), w1
    call tx_str_232
                                                            ;erpm = phi_int_2to3 * 27466 / main_loop_count
    mov phi_int_2to3, w0
    mov #27466, w1
    mul.uu w0, w1, w0
    mov main_loop_count, w2
    repeat #17
    div.ud w0, w2

    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(erpms_mes_erpm), w0
    mov #tbloffset(erpms_mes_erpm), w1
    call tx_str_232

    bra me_msg_g

me_opt_f:
                                                            ;get new e-rpm limit
    mov #5, w0
    call get_number
                                                            ;phi_int_2to3 = e-rpm * main_loop_count / 27466
    mov main_loop_count, w1
    mul.uu w0, w1, w0
    mov #27466, w2
    repeat #17
    div.ud w0, w2
															;must be higher than phi_int_3to2
	mov phi_int_3to2, w1
	cp w0, w1
	bra gtu, 1f
	inc w1, w0
	
1:	
    mov w0, phi_int_2to3

    bra menu_erpms
	
;------------------------------------------------------
;g) use accelleration limiting:
;------------------------------------------------------
me_msg_g:
    mov #tblpage(erpms_mes_g), w0
    mov #tbloffset(erpms_mes_g), w1
    call tx_str_232
	
	mov #tblpage(erpms_mes_yes), w0
    mov #tbloffset(erpms_mes_yes), w1
    btss flags_rom2, #limit_accel
    mov #tblpage(erpms_mes_no), w0
    btss flags_rom2, #limit_accel
    mov #tbloffset(erpms_mes_no), w1
    call tx_str_232
	
	btss flags_rom2, #limit_accel
	bra me_msg_z
	bra me_msg_h

me_opt_g:
	
	btg flags_rom2, #limit_accel
	
	bra menu_erpms
	
;------------------------------------------------------
;h) max accelleration:
;------------------------------------------------------
me_msg_h:
    mov #tblpage(erpms_mes_h), w0
    mov #tbloffset(erpms_mes_h), w1
    call tx_str_232	
															;kerpm/sec[8.8] = max_accel * 3.22e6 / (mlc^2)
	mov #49, w1
	mov #7387, w0
	mov main_loop_count, w2
	repeat #17
	div.ud w0, w2
	mov max_accel, w1
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
	
    mov #tblpage(erpms_mes_comma), w0
    mov #tbloffset(erpms_mes_comma), w1
    call tx_str_232	
															;kerpm/sec[8.8] = max_accel+2 * 3.22e6 / (mlc^2)
	mov #49, w1
	mov #7387, w0
	mov main_loop_count, w2
	repeat #17
	div.ud w0, w2
	mov max_accel+2, w1
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
	
    mov #tblpage(erpms_mes_h1), w0
    mov #tbloffset(erpms_mes_h1), w1
    call tx_str_232	
	
	bra me_msg_z

me_opt_h:
	mov #10, w0
    call get_signed_decimal_number
                                                            ;convert to 8.8 format
    sl w0, #8, w0
    lsr w1, #8, w1
    ior w0, w1, w0
															;max_accel = kerpm/sec[8.8] * mlc^2 / 3.22e6  (which is 1794 ^ 2) 
	mov main_loop_count, w1
	mul.uu w0, w1, w0
	mov #1784, w2
	repeat #17
	div.ud w0, w2
	mov main_loop_count, w1
	mul.uu w0, w1, w0
	mov #1784, w2
	repeat #17
	div.ud w0, w2

	mov w0, max_accel
	
	mov #10, w0
    call get_signed_decimal_number
    sl w0, #8, w0
    lsr w1, #8, w1
    ior w0, w1, w0
	mov main_loop_count, w1
	mul.uu w0, w1, w0
	mov #1784, w2
	repeat #17
	div.ud w0, w2
	mov main_loop_count, w1
	mul.uu w0, w1, w0
	mov #1784, w2
	repeat #17
	div.ud w0, w2
	mov w0, max_accel+2
	
	bra menu_erpms	
	
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
me_msg_z:
    mov #tblpage(erpms_mes_z), w0
    mov #tbloffset(erpms_mes_z), w1
    call tx_str_232

    bra me_msg_choise
me_opt_z:
	bclr menus_completed, #mc_erpms
    return

;------------------------------------------------------
me_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, me_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, me_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, me_opt_c
    mov #'d', w1
    cp w0, w1
    bra z, me_opt_d
    mov #'e', w1
    cp w0, w1
    bra z, me_opt_e
    mov #'f', w1
    cp w0, w1
    bra z, me_opt_f
    mov #'g', w1
    cp w0, w1
    bra z, me_opt_g
	mov #'h', w1
    cp w0, w1
    bra z, me_opt_h
    mov #'z', w1
    cp w0, w1
    bra z, me_opt_z

    bra menu_erpms

;**********************************************************
.global print_kerpm
print_kerpm:
	                                                        ;erpm = (w0 / 65536) * (30e6/mlc) * 60 =>
															;erpm = 27466 * w0 / mlc
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

	return

;**********************************************************
.global input_kerpm
input_kerpm:
                                                            ;convert to 8.8 format, times mlc, divide by 27.466 (7031 in 8.8)
    mov #10, w0
    call get_signed_decimal_number
    sl w0, #8, w0
    lsr w1, #8, w1
    ior w0, w1, w0
    mov main_loop_count, w1
    mul.uu w0, w1, w0
    mov #7031, w2
    repeat #17
    div.ud w0, w2

	return

;**********************************************************

erpms_mes_a:
    .pascii "\na) erpm limiter (forward) rampdown start, end: \0"
erpms_mes_b:
    .pascii "\nb) erpm limiter (reverse) rampdown start, end: \0"
erpms_mes_c:
    .pascii "\nc) regen rampup start, end: \0"
erpms_mes_d:
    .pascii "\nd) accept direction change below: \0"
erpms_mes_e:
    .pascii "\ne) erpm dr3 back to dr2: \0"
erpms_mes_f:
    .pascii "\nf) erpm dr2 jump to dr3: \0"
erpms_mes_g:
	.pascii "\n\ng) use acceleration limiter: \0"
erpms_mes_h:
	.pascii "\nh) acceleration limiter start, end: \0"
erpms_mes_h1:
	.pascii " kerpm/sec\0"
erpms_mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"
erpms_mes_kerpm:
    .pascii " k-erpm\0"
erpms_mes_erpm:
    .pascii " erpm\0"
erpms_mes_comma:
    .pascii ", \0"
erpms_mes_yes:
	.pascii "yes\0"
erpms_mes_no:
	.pascii "no\0"


.end

