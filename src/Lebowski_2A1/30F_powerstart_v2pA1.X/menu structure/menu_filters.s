.include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_filters
menu_filters:
    call clr_scr_232
;------------------------------------------------------
;a) autocomplete
;------------------------------------------------------
    mov #tblpage(fil_mes_a), w0
    mov #tbloffset(fil_mes_a), w1
    call tx_str_232

    bra mf_msg_b

mf_opt_a:		
                                                        ;fil2ord_i_error, equivalent of 5 msec (5 in 6.10 = 5120)
    mov #5120, w4
    mov #2237, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4
    bclr w0, #15
    mov #16384, w1
    cpslt w0, w1
    mov w1, w0
    mov w0, fil2ord_i_error
                                                        ;fil2ord_dr2_motor_speed, equivalent of 200 msec (=12800 in [10.6])
    mov #12800, w4
														;or 50 msec (3200) for hall mode
	btsc flags_rom, #hall_mode
	mov #3200, w4
	
    mov #140, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4
    mov w0, fil2ord_dr2_motor_speed
														;i_total filter, set 50% time to 20msec
                                                        ;w11 = 140*mlc/t[10.6]
    mov #1280, w4
    mov #140, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4
	mov w0, fil2ord_i_meas
														;0.1 second [8.8] vbat filtering
	mov #26, w4
	mov #143, w0
	mul main_loop_count
	repeat #17
	div.ud w2, w4
	mov w0, vbat_filt_coeff
														;200 msec [10.6] accelleration filter 
	mov #12800, w4
    mov #2237, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4
    mov w0, accel_filt_coef
	
	bclr menus_completed, #mc_filters
	
    bra menu_filters
	
;------------------------------------------------------
;b) drive 2 speed filter 50% step response time
;------------------------------------------------------
mf_msg_b:
    mov #tblpage(fil_mes_b), w0
    mov #tbloffset(fil_mes_b), w1
    call tx_str_232
                                                        ;t[10.6] = 140*mlc / w11
    mov #140, w0
    mul main_loop_count
    mov fil2ord_dr2_motor_speed, w4
    repeat #17
    div.ud w2, w4

    push w0
    lsr w0, #6, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    pop w0
    sl w0, #10, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+2
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(fil_mes_msec), w0
    mov #tbloffset(fil_mes_msec), w1
    call tx_str_232

    bra mf_msg_c

mf_opt_b:
    mov #10, w0
    call get_signed_decimal_number
                                                        ;w11 = 140*mlc/t[10.6]
    sl w0, #6, w0
    lsr w1, #10, w1
    ior w0, w1, w4
    
    mov #140, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4

    bclr w0, #15
    mov #16384, w1
    cpslt w0, w1
    mov w1, w0

    mov w0, fil2ord_dr2_motor_speed

    bra menu_filters
	
;------------------------------------------------------
;c) dr2, dr23: error current 50% step response time
;------------------------------------------------------
mf_msg_c:
    mov #tblpage(fil_mes_c), w0
    mov #tbloffset(fil_mes_c), w1
    call tx_str_232
                                                        ;t[10.6] = 140*mlc / w11
    mov #140, w0
    mul main_loop_count
    mov fil2ord_i_meas, w4
    repeat #17
    div.ud w2, w4

    push w0
    lsr w0, #6, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    pop w0
    sl w0, #10, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+2
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(fil_mes_msec), w0
    mov #tbloffset(fil_mes_msec), w1
    call tx_str_232

    bra mf_msg_d

mf_opt_c:
    mov #10, w0
    call get_signed_decimal_number
                                                        ;w11 = 140*mlc/t[10.6]
    sl w0, #6, w0
    lsr w1, #10, w1
    ior w0, w1, w4

    mov #140, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4

    bclr w0, #15
    mov #16384, w1
    cpslt w0, w1
    mov w1, w0

    mov w0, fil2ord_i_meas

    bra menu_filters

;------------------------------------------------------
;d) error current 50% step response time
;------------------------------------------------------
mf_msg_d:
    mov #tblpage(fil_mes_d), w0
    mov #tbloffset(fil_mes_d), w1
    call tx_str_232
                                                        ;t[6.10] = 2237*mlc / w11
    mov #2237, w0
    mul main_loop_count
    mov fil2ord_i_error, w4
    repeat #17
    div.ud w2, w4

    push w0
    lsr w0, #10, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    pop w0
    sl w0, #6, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+3
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(fil_mes_msec), w0
    mov #tbloffset(fil_mes_msec), w1
    call tx_str_232

    bra mf_msg_e

mf_opt_d:
    mov #10, w0
    call get_signed_decimal_number
                                                        ;w11 = 2237*mlc/t[6.10]
    sl w0, #10, w0
    lsr w1, #6, w1
    ior w0, w1, w4
    
    mov #2237, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4

    bclr w0, #15
    mov #16384, w1
    cpslt w0, w1
    mov w1, w0

    mov w0, fil2ord_i_error

    bra menu_filters
	
;------------------------------------------------------
;e) battery voltage filtering time constant: 
;------------------------------------------------------
mf_msg_e:
    mov #tblpage(fil_mes_e), w0
    mov #tbloffset(fil_mes_e), w1
    call tx_str_232
												;tau[8.8] = 143 * mlc / filt_coeff
	mov #143, w0
	mul main_loop_count
	mov vbat_filt_coeff, w4
	repeat #17
	div.ud w2, w4
	
	push w0
    lsr w0, #8, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    pop w0
    sl w0, #8, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+3
    mov #str_buf, w0
    call tx_ram_str_232
	
    mov #tblpage(fil_mes_e1), w0
    mov #tbloffset(fil_mes_e1), w1
    call tx_str_232
	
    bra mf_msg_f	
mf_opt_e:
    mov #10, w0
    call get_signed_decimal_number
												;filt_coeff = 143 * mlc / tau[8.8]	
	sl w0, #8, w0
    lsr w1, #8, w1
    ior w0, w1, w4

	mov #143, w0
	mul main_loop_count
	repeat #17
	div.ud w2, w4
	
	mov w0, vbat_filt_coeff
	
    bra menu_filters
	
;------------------------------------------------------
;f) accelleration filter time constant:
;------------------------------------------------------
mf_msg_f:
    mov #tblpage(fil_mes_f), w0
    mov #tbloffset(fil_mes_f), w1
    call tx_str_232
	                                                        ;t[10.6] = 2237*mlc / beta
    mov #2237, w0
    mul main_loop_count
    mov accel_filt_coef, w4
    repeat #17
    div.ud w2, w4

    push w0
    lsr w0, #6, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    pop w0
    sl w0, #10, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+3
    mov #str_buf, w0
    call tx_ram_str_232
	
    mov #tblpage(fil_mes_msec), w0
    mov #tbloffset(fil_mes_msec), w1
    call tx_str_232
	
    bra mf_msg_z

mf_opt_f:
	
    mov #10, w0
    call get_signed_decimal_number
                                                        ;beta = 2237*mlc/t[10.6]
    sl w0, #6, w0
    lsr w1, #10, w1
    ior w0, w1, w4

    mov #2237, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4

;    bclr w0, #15
;    mov #16384, w1
;    cpslt w0, w1
;    mov w1, w0

    mov w0, accel_filt_coef

    bra menu_filters
	
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
mf_msg_z:
    mov #tblpage(fil_mes_z), w0
    mov #tbloffset(fil_mes_z), w1
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
    mov #'e', w1
    cp w0, w1
    bra z, mf_opt_e
    mov #'f', w1
    cp w0, w1
    bra z, mf_opt_f
    mov #'z', w1
    cp w0, w1
    bra z, mf_opt_z

    bra menu_filters

;**********************************************************

fil_mes_a:
    .pascii "\na) autocomplete\n\0"
fil_mes_b:
    .pascii "\nb) dr2: speed filter 50% step response time: \0"
fil_mes_c:
    .pascii "\nc) dr2, dr23: error current 50% step response time: \0"
fil_mes_d:
    .pascii "\nd) dr3: error current 50% step response time: \0"
fil_mes_e:
    .pascii "\ne) battery voltage filtering time constant: \0"
fil_mes_e1:
    .pascii " sec\0"
fil_mes_f:
    .pascii "\nf) acceleration filter time constant: \0"
	
fil_mes_msec:
    .pascii " msec\0"
fil_mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"



.end

