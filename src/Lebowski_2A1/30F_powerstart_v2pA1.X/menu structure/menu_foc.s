.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"

.text
.global menu_foc
menu_foc:

    call clr_scr_232
;------------------------------------------------------
;a) autocomplete
;------------------------------------------------------
    mov #tblpage(foc_mes_a), w0
    mov #tbloffset(foc_mes_a), w1
    call tx_str_232

    bra mf_msg_b

mf_opt_a:
                                                        ;measurement current = 1/2 max phase current
    mov i_max_phase, w0
    lsr w0, #1, w0
    mov w0, i_inductor_measurement
														;set to 12 k-erpm
	mov #12, w0
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

    mov w0, phi_int_for_impedance_measurement
		
    bra menu_foc

;------------------------------------------------------
;b) FOC measurement current:
;------------------------------------------------------
mf_msg_b:
    mov #tblpage(foc_mes_b), w0
    mov #tbloffset(foc_mes_b), w1
    call tx_str_232

    mov i_inductor_measurement, w0
    call display_current

    mov #tblpage(foc_mes_amp), w0
    mov #tbloffset(foc_mes_amp), w1
    call tx_str_232

    bra mf_msg_c

mf_opt_b:

    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb

    mov w0, i_inductor_measurement

    bra menu_foc

;------------------------------------------------------
;c) FOC measurement erpm
;------------------------------------------------------
mf_msg_c:
    mov #tblpage(foc_mes_c), w0
    mov #tbloffset(foc_mes_c), w1
    call tx_str_232

	mov phi_int_for_impedance_measurement, w0
    call print_kerpm

    mov #tblpage(foc_mes_c1), w0
    mov #tbloffset(foc_mes_c1), w1
    call tx_str_232

    bra mf_msg_d

mf_opt_c:

    call input_kerpm

    mov w0, phi_int_for_impedance_measurement

    bra menu_foc

;------------------------------------------------------
;d) perform impedance measurement
;------------------------------------------------------
mf_msg_d:
    mov #tblpage(foc_mes_d), w0
    mov #tbloffset(foc_mes_d), w1
    call tx_str_232

    bra mf_msg_L

mf_opt_d:

    call motor_impedance_measurement

	bclr menus_completed, #mc_foc
	
    bra menu_foc
	
	
;------------------------------------------------------
;L) inductance:
;------------------------------------------------------
mf_msg_L:

    print_txt foc_mes_l
 
	mov #imag_impedance, w11
	call print_readable_L

    print_txt foc_mes_l1
	
    bra mf_msg_R

mf_opt_L:
										;measurement must have been run first as we need vbat0 and invvbat 0
	btss menus_completed, #mc_foc	
	call input_L

    bra menu_foc

;------------------------------------------------------
;R) resistance:
;------------------------------------------------------
mf_msg_R:

    print_txt foc_mes_r
 
	mov #real_impedance, w11
	call print_readable_R

    print_txt foc_mes_r1
	
    bra mf_msg_v

mf_opt_R:
										;measurement must have been run first as we need vbat0 and invvbat 0
	btss menus_completed, #mc_foc	
	call input_R

    bra menu_foc
	
	
;------------------------------------------------------
; overflow ?
;------------------------------------------------------
mf_msg_v:
	btss flags_rom2, #FOC_overflow
	bra mf_msg_z
	
	mov #tblpage(foc_mes_v), w0
    mov #tbloffset(foc_mes_v), w1
    call tx_str_232
	
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
mf_msg_z:
    mov #tblpage(foc_mes_z), w0
    mov #tbloffset(foc_mes_z), w1
    call tx_str_232

    bra mf_msg_choise
mf_opt_z:
    return
;------------------------------------------------------
mf_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, mf_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, mf_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, mf_opt_c
    mov #'d', w1
    cp w0, w1
    bra z, mf_opt_d
    mov #'L', w1
    cp w0, w1
    bra z, mf_opt_L
    mov #'R', w1
    cp w0, w1
    bra z, mf_opt_R
    mov #'z', w1
    cp w0, w1
    bra z, mf_opt_z

    bra menu_foc

;**********************************************************

foc_mes_a:
    .pascii "\na) autocomplete\n\0"
foc_mes_b:
    .pascii "\nb) FOC measurement current: \0"
foc_mes_amp:
    .pascii " A\0"
foc_mes_c:
    .pascii "\nc) FOC measurement erpm: \0"
foc_mes_c1:
    .pascii " k-erpm\0"
foc_mes_d:
    .pascii "\nd) perform impedance measurement\0"
foc_mes_v:
	.pascii "\n\n  # Overflow during impedance measurement #\n\0"
foc_mes_l:
    .pascii "\n\nL) inductance: \0"
foc_mes_l1:
    .pascii " uH\0"
foc_mes_r:
    .pascii "\nR) resistance: \0"
foc_mes_r1:
    .pascii " mOhm\0"
foc_mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"


.end
