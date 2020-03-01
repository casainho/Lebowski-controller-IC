.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"

.text
.global menu_recov
menu_recov:
    call clr_scr_232
;------------------------------------------------------
;a) autocomplete
;------------------------------------------------------
mr_msg_a:
    mov #tblpage(rec_mes_a), w0
    mov #tbloffset(rec_mes_a), w1
    call tx_str_232

    bra mr_msg_b

mr_opt_a:
;------------------------------------------------------ phase coefficients, drive_1
                                                            ;3, 120, 0
    mov #3, w0
    mov w0, plic_1
    mov #0, w0
    mov w0, plic_1+2
    mov #120, w0
    mov w0, plic_1+4
    mov #0, w0
    mov w0, plic_1+6
    mov #0, w0
    mov w0, plic_1+8
                                                            ;make negative phase loop coeffs
    mov plic_1+0, w0
    mov plic_1+2, w1
    com w0, w0
    neg w1, w1
    addc #0, w0
    mov w0, plic_1+10
    mov w1, plic_1+12

    mov plic_1+4, w0
    mov plic_1+6, w1
    com w0, w0
    neg w1, w1
    addc #0, w0
    mov w0, plic_1+14
    mov w1, plic_1+16

    mov plic_1+8, w0
    neg w0, w0
    mov w0, plic_1+18
;------------------------------------------------------ amplitude coefficients, drive_1
                                                            ;12, 240
    mov #240, w0
    mov w0, alic_1+4
    
    mov #12, w0
    mov w0, alic_1+0
    mov #0, w0
    mov w0, alic_1+2
                                                            ;generate negative coefficients
    mov alic_1+4, w0
    neg w0, w0
    mov w0, alic_1+10

    mov alic_1+0, w0
    mov alic_1+2, w1
    com w0, w0
    neg w1, w1
    addc #0, w0
    mov w0, alic_1+6
    mov w1, alic_1+8

;------------------------------------------------------ set pulse when below current at 5% of i_max_phase

    mov #3277, w0
    mul i_max_phase
    mov w3, i_min_recov

;------------------------------------------------------ try recov for half a second
    mov #500, w0
    mov #30000, w1
    mul.uu w0, w1, w0
    mov main_loop_count, w2
    repeat #17
    div.ud w0, w2
    mov w0, cycles_try_recov

;------------------------------------------------------ set pwm_period_rec to 80% of sample period

    mov #52429, w0
    mul main_loop_count
    mov w3, pwm_period_rec

;------------------------------------------------------ perform all checks

    bset, flags_rom, #perform_throttle_check
    bset, flags_rom, #perform_voltage_test

;------------------------------------------------------ percentage filter, set 50% time to 30msec
                                                        ;w11 = 140*mlc/t[10.6]
    mov #1920, w4
    mov #140, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4
    mov w0, fil2ord_percentage

;------------------------------------------------------ speed filter, set 50% time to 7msec
                                                        ;w11 = 140*mlc/t[10.6]
    mov #448, w4
    mov #140, w0
    mul main_loop_count
    repeat #17
    div.ud w2, w4
    mov w0, fil2ord_speed_recovery

;------------------------------------------------------ percentage to reach:95%

    mov #950, w0
    mov w0, pulse_perc_to_reach
	
;------------------------------------------------------ 0.1 seconds to ramp up throttle
															;in [4.12]
	mov #410, w0
	mov w0, post_dr1_time

	bclr menus_completed, #mc_recovery
	
    bra menu_recov

;------------------------------------------------------
;b) 1st order:
;------------------------------------------------------
mr_msg_b:
    mov #tblpage(rec_mes_b), w0
    mov #tbloffset(rec_mes_b), w1
    call tx_str_232
    
    mov plic_1+8, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mr_msg_c

mr_opt_b:

    mov #5, w0
    call get_number
    mov w0, plic_1+8
    neg w0, w0
    mov w0, plic_1+18

    bra menu_recov

;------------------------------------------------------
;c) 2nd order:
;------------------------------------------------------
mr_msg_c:
    mov #tblpage(rec_mes_c), w0
    mov #tbloffset(rec_mes_c), w1
    call tx_str_232
    
    mov plic_1+4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov plic_1+6, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mr_msg_d

mr_opt_c:
    mov #10, w0
    call get_signed_decimal_number
                                                            ;don't accept negative values
    btsc w0, #15
    bra menu_loop_coeffs

    mov w0, plic_1+4
    mov w1, plic_1+6

    com w0, w0
    neg w1, w1
    addc #0, w0

    mov w0, plic_1+14
    mov w1, plic_1+16

    bra menu_recov

;------------------------------------------------------
;d) 3rd order:
;------------------------------------------------------
mr_msg_d:
    mov #tblpage(rec_mes_d), w0
    mov #tbloffset(rec_mes_d), w1
    call tx_str_232
    
    mov plic_1+0, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov plic_1+2, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mr_msg_e

mr_opt_d:
    mov #10, w0
    call get_signed_decimal_number
                                                            ;don't accept negative values
    btsc w0, #15
    bra menu_loop_coeffs

    mov w0, plic_1+0
    mov w1, plic_1+2

    com w0, w0
    neg w1, w1
    addc #0, w0

    mov w0, plic_1+10
    mov w1, plic_1+12

    bra menu_recov

;------------------------------------------------------
;e) 1st order:
;------------------------------------------------------
mr_msg_e:
    mov #tblpage(rec_mes_e), w0
    mov #tbloffset(rec_mes_e), w1
    call tx_str_232
    
    mov alic_1+4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mr_msg_f

mr_opt_e:
    mov #5, w0
    call get_number
    mov w0, alic_1+4
    neg w0, w0
    mov w0, alic_1+10

    bra menu_recov

;------------------------------------------------------
;f) 2nd order:
;------------------------------------------------------
mr_msg_f:
    mov #tblpage(rec_mes_f), w0
    mov #tbloffset(rec_mes_f), w1
    call tx_str_232
    
    mov alic_1+0, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov alic_1+2, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mr_msg_g

mr_opt_f:
    mov #10, w0
    call get_signed_decimal_number
                                                            ;don't accept negative values
    btsc w0, #15
    bra menu_loop_coeffs

    mov w0, alic_1+0
    mov w1, alic_1+2

    com w0, w0
    neg w1, w1
    addc #0, w0

    mov w0, alic_1+6
    mov w1, alic_1+8

    bra menu_recov

;------------------------------------------------------
;g) pulse when current drops below:
;------------------------------------------------------
mr_msg_g:
    mov #tblpage(rec_mes_g), w0
    mov #tbloffset(rec_mes_g), w1
    call tx_str_232
                                                        ;display maximum motor phase current
    mov i_min_recov, w0
    call display_current

    mov #tblpage(rec_mes_g1), w0
    mov #tbloffset(rec_mes_g1), w1
    call tx_str_232

    bra mr_msg_h

mr_opt_g:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
    mov w0, i_min_recov

    bra menu_recov

;------------------------------------------------------
;h) pulse width:
;------------------------------------------------------
mr_msg_h:
    mov #tblpage(rec_mes_h), w0
    mov #tbloffset(rec_mes_h), w1
    call tx_str_232
                                                            ;time[usec] = 0.033 * pwm_period_rec
    mov #2163, w0
    mul pwm_period_rec
    mov w3, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(rec_mes_h1), w0
    mov #tbloffset(rec_mes_h1), w1
    call tx_str_232

    bra mr_msg_i

mr_opt_h:
    mov #5, w0
    call get_number
                                                            ;pwm_period_rec = 30 * time[usec]
    mov #30, w1
    mul.uu w0, w1, w0
    mov w0, pwm_period_rec

    bra menu_recov

;------------------------------------------------------
;i) pulse % for exit:
;------------------------------------------------------
mr_msg_i:
    mov #tblpage(rec_mes_i), w0
    mov #tbloffset(rec_mes_i), w1
    call tx_str_232

    mov #6554, w0
    mul pulse_perc_to_reach
    mov w3, w0

    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mr_msg_j

mr_opt_i:
    mov #5, w0
    call get_number
                                                            ;pulse_perc_to_reach = 10 * input %
    mov #10, w1
    mul.uu w0, w1, w0
    mov w0, pulse_perc_to_reach

    bra menu_recov
    
;------------------------------------------------------
;j) pulse % filter 50% step response time:
;------------------------------------------------------
mr_msg_j:
    mov #tblpage(rec_mes_j), w0
    mov #tbloffset(rec_mes_j), w1
    call tx_str_232
                                                        ;t[10.6] = 140*mlc / w11
    mov #140, w0
    mul main_loop_count
    mov fil2ord_percentage, w4
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

    mov #tblpage(rec_mes_msec), w0
    mov #tbloffset(rec_mes_msec), w1
    call tx_str_232

    bra mr_msg_k

mr_opt_j:
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

    mov w0, fil2ord_percentage

    bra menu_recov

;------------------------------------------------------
;k) speed filter 50% step response time:
;------------------------------------------------------
mr_msg_k:
    mov #tblpage(rec_mes_k), w0
    mov #tbloffset(rec_mes_k), w1
    call tx_str_232
                                                        ;t[10.6] = 140*mlc / w11
    mov #140, w0
    mul main_loop_count
    mov fil2ord_speed_recovery, w4
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

    mov #tblpage(rec_mes_msec), w0
    mov #tbloffset(rec_mes_msec), w1
    call tx_str_232

    bra mr_msg_l

mr_opt_k:
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

    mov w0, fil2ord_speed_recovery

    bra menu_recov

;------------------------------------------------------
;l) try restart for:
;------------------------------------------------------
mr_msg_l:
    mov #tblpage(rec_mes_l), w0
    mov #tbloffset(rec_mes_l), w1
    call tx_str_232
                                                            ;t[msec] = cycles*mlc/30000
    mov cycles_try_recov, w0
    mul main_loop_count
    mov #30000, w4
    repeat #17
    div.ud w2, w4

    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(rec_mes_msec), w0
    mov #tbloffset(rec_mes_msec), w1
    call tx_str_232

    bra mr_msg_m

mr_opt_l:
    mov #5, w0
    call get_number

    mov #30000, w1
    mul.uu w0, w1, w0
    mov main_loop_count, w2
    repeat #17
    div.ud w0, w2

    mov w0, cycles_try_recov

    bra menu_recov

;------------------------------------------------------
;m) check for spinning motor, drive_0:
;------------------------------------------------------
mr_msg_m:
    mov #tblpage(rec_mes_m), w0
    mov #tbloffset(rec_mes_m), w1
    call tx_str_232

    mov #tblpage(rec_mes_en), w0
    mov #tbloffset(rec_mes_en), w1
    btss, flags_rom, #perform_voltage_test
    mov #tblpage(rec_mes_dis), w0
    btss, flags_rom, #perform_voltage_test
    mov #tbloffset(rec_mes_dis), w1
    call tx_str_232

    bra mr_msg_n

mr_opt_m:
    btg flags_rom, #perform_voltage_test

    bra menu_recov

;------------------------------------------------------
;n) check for throttle closed, drive_0:
;------------------------------------------------------
mr_msg_n:
    mov #tblpage(rec_mes_n), w0
    mov #tbloffset(rec_mes_n), w1
    call tx_str_232

    mov #tblpage(rec_mes_en), w0
    mov #tbloffset(rec_mes_en), w1
    btss, flags_rom, #perform_throttle_check
    mov #tblpage(rec_mes_dis), w0
    btss, flags_rom, #perform_throttle_check
    mov #tbloffset(rec_mes_dis), w1
    call tx_str_232

    bra mr_msg_o

mr_opt_n:
    btg flags_rom, #perform_throttle_check

    bra menu_recov
;------------------------------------------------------
;o) post drive 1 throttle ramp time : 
;------------------------------------------------------
mr_msg_o:
	print_txt rec_mes_o
													;post_dr1_time = [4.12] seconds
	mov post_dr1_time, w0
	lsr w0, #12, w0
	print_udec
	mov post_dr1_time, w0
	sl w0, #4, w0
	print_frac 3
	
	print_txt rec_mes_sec
	
	bra mr_msg_z
mr_opt_o:
	mov #10, w0
    call get_signed_decimal_number
													;post_dr1_time = [4.12] seconds
	sl w0, #12, w0
	lsr w1, #4, w1
	ior w0, w1, w0
	btsc SR, #Z
	mov #410, w0
	mov w0, post_dr1_time
	
	bra menu_recov
	
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
mr_msg_z:
    mov #tblpage(rec_mes_z), w0
    mov #tbloffset(rec_mes_z), w1
    call tx_str_232

    bra mr_msg_choise
mr_opt_z:
    return

;------------------------------------------------------
mr_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, mr_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, mr_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, mr_opt_c
    mov #'d', w1
    cp w0, w1
    bra z, mr_opt_d
    mov #'e', w1
    cp w0, w1
    bra z, mr_opt_e
    mov #'f', w1
    cp w0, w1
    bra z, mr_opt_f
    mov #'g', w1
    cp w0, w1
    bra z, mr_opt_g
    mov #'h', w1
    cp w0, w1
    bra z, mr_opt_h
    mov #'i', w1
    cp w0, w1
    bra z, mr_opt_i
    mov #'j', w1
    cp w0, w1
    bra z, mr_opt_j
    mov #'k', w1
    cp w0, w1
    bra z, mr_opt_k
    mov #'l', w1
    cp w0, w1
    bra z, mr_opt_l
    mov #'m', w1
    cp w0, w1
    bra z, mr_opt_m
    mov #'n', w1
    cp w0, w1
    bra z, mr_opt_n
    mov #'o', w1
    cp w0, w1
    bra z, mr_opt_o
    mov #'z', w1
    cp w0, w1
    bra z, mr_opt_z

    bra menu_recov

;**********************************************************

rec_mes_a:
    .pascii "\na) autocomplete\n\0"
rec_mes_b:
    .pascii "\n  phase control loop, recovery"
    .pascii "\nb) 1st order: \0"
rec_mes_c:
    .pascii "\nc) 2nd order: \0"
rec_mes_d:
    .pascii "\nd) 3rd order: \0"
rec_mes_e:
    .pascii "\n  amplitude control loop, recovery"
    .pascii "\ne) 1st order: \0"
rec_mes_f:
    .pascii "\nf) 2nd order: \0"
rec_mes_g:
    .pascii "\ng) pulse when current drops below: \0"
rec_mes_g1:
    .pascii " A\0"
rec_mes_h:
    .pascii "\nh) pulse width: \0"
rec_mes_h1:
    .pascii " usec\0"
rec_mes_i:
    .pascii "\ni) pulse % for exit: \0"
rec_mes_j:
    .pascii "\nj) pulse % filter 50% step response time: \0"
rec_mes_k:
    .pascii "\nk) speed filter 50% step response time: \0"   
rec_mes_l:
    .pascii "\nl) try restart for: \0"
rec_mes_m:
    .pascii "\nm) check for spinning motor, drive_0: \0"
rec_mes_n:
    .pascii "\nn) check for throttle closed, drive_0: \0"
rec_mes_o:
    .pascii "\no) post recovery throttle ramp : \0"
rec_mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"
rec_mes_en:
    .pascii "enabled\0"
rec_mes_dis:
    .pascii "disabled\0"
rec_mes_msec:
	.pascii " msec\0"
rec_mes_sec:
	.pascii	" sec\0"



.end

