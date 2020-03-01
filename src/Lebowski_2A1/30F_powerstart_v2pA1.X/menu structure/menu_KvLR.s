.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"

.text
.global menu_KvLR
menu_KvLR:
	
	btsc menus_completed, #mc_KvLR
	bclr flags_rom2, #use_KvLR
	
menu_top:
    call clr_scr_232
;------------------------------------------------------
;a) use online Kv, L and R measurement
;------------------------------------------------------
    print_txt mes_a
	
	mov #tblpage(mes_yes), w0
    mov #tbloffset(mes_yes), w1
    btss flags_rom2, #use_KvLR
    mov #tblpage(mes_no), w0
    btss flags_rom2, #use_KvLR
    mov #tbloffset(mes_no), w1
    call tx_str_232

	btsc flags_rom2, #use_KvLR
    bra item_b
	
	bra item_z

select_a:

	btg flags_rom2, #use_KvLR
	
    bra menu_top

;------------------------------------------------------
;b) autocomplete
;------------------------------------------------------
item_b:
    
	print_txt mes_b

    bra item_c

select_b:
	mov #14, w0
	mov w0, data_filt_exponent
	mov #1024, w0
	mov w0, data_collect_countdown_R
	mov w0, data_collect_countdown_L
														;clr all 11 (* 3) data collection words
	mov #data_collected, w13
	repeat #20
	clr [w13++]
														;data_current_limit to 20% of i_max_phase
	mov i_max_phase, w0
	mov #13107, w1
	mul.uu w0, w1, w0
	mov w1, data_current_limit_R
														;and 5% for L
	mov i_max_phase, w0
	mov #3277, w1
	mul.uu w0, w1, w0
	mov w1, data_current_limit_L
														;use current injection
	bset flags_rom, #use_sine_iimag
														;data speed limit at 6k-erpm
	mov #6, w0
	clr w1
    sl w0, #8, w0
    lsr w1, #8, w1
    ior w0, w1, w0
    mov main_loop_count, w1
    mul.uu w0, w1, w0
    mov #7031, w2
    repeat #17
    div.ud w0, w2
    mov w0, data_speed_limit
						
;	bset flags_rom2, #check_KvLR
;	mov #4, w0
;	mov w0, match_KvLR

    bra menu_top

;------------------------------------------------------
;c) #data points for online impedance measurement
;------------------------------------------------------
item_c:
    print_txt mes_c

	mov data_filt_exponent, w1
	mov #1, w0
	sl w0, w1, w0
	print_udec
	
    bra item_d

select_c:

	mov #5, w0
    call get_number

	lsr w0, w0
	fbcl w0, w3
	neg w3, w1
	sl w0, w1, w0
	btsc w0, #13
	dec w1, w1
	
	subr w1, #15, w1
	
	mov w1, data_filt_exponent
	
    bra menu_top

;------------------------------------------------------
;d) reset data collection
;------------------------------------------------------
item_d:
    print_txt mes_d
	
    bra item_e

select_d:

	mov #1024, w0
	mov w0, data_collect_countdown_R
	mov w0, data_collect_countdown_L
												;clr all 11 (* 3) data words
	mov #data_collected, w13
	repeat #20
	clr [w13++]
	
    bra menu_top

;------------------------------------------------------
;e) current limit data collection, R
;------------------------------------------------------
item_e:
    print_txt mes_e
	
	mov data_current_limit_R, w0
    call display_current

    print_txt mes_amp
	
    bra item_f

select_e:
	
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb

	mov w0, data_current_limit_R
	
    bra menu_top

;------------------------------------------------------
;f) current limit data collection, L
;------------------------------------------------------
item_f:
    print_txt mes_f
	
	mov data_current_limit_L, w0
    call display_current

    print_txt mes_amp
	
    bra item_g

select_f:
	
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb

	mov w0, data_current_limit_L
	
    bra menu_top

;------------------------------------------------------
;g) speed lower limit data collection:
;------------------------------------------------------
item_g:
    print_txt mes_g
	
	mov data_speed_limit, w0
	call print_kerpm
	
    print_txt mes_kerpm
	
    bra item_h

select_g:
	
	call input_kerpm

	mov w0, data_speed_limit
	
    bra menu_top

;------------------------------------------------------
;h) inject extra current
;------------------------------------------------------
item_h:
    print_txt mes_h
	
    mov #tblpage(mes_yes), w0
    mov #tbloffset(mes_yes), w1
    btss flags_rom, #use_sine_iimag
    mov #tblpage(mes_no), w0
    btss flags_rom, #use_sine_iimag
    mov #tbloffset(mes_no), w1
    call tx_str_232
	
    bra item_z

select_h:
	
	btg flags_rom, #use_sine_iimag
	
    bra menu_top

;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
item_z:
    print_txt mes_z

    bra mf_msg_choise
select_z:
	bclr menus_completed, #mc_KvLR
	
	btsc flags_rom2, #use_KvLR
    return
											;turn off sine_i_imag and check_KvLR when not using online KvLR
	bclr flags_rom, #use_sine_iimag
	return									
											
;------------------------------------------------------
select_count:
	print_txt countleft
	
	mov data_collect_countdown_R, w0
	print_udec
	print_tab
	mov data_collect_countdown_L, w0
	print_udec
	
	print_CR
	print_CR
	
	call rx_char_232
	
	bra menu_top

;------------------------------------------------------
mf_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, select_a
    mov #'b', w1
    cp w0, w1
    bra z, select_b
    mov #'c', w1
    cp w0, w1
    bra z, select_c
    mov #'d', w1
    cp w0, w1
    bra z, select_d
    mov #'e', w1
    cp w0, w1
    bra z, select_e
    mov #'f', w1
    cp w0, w1
    bra z, select_f
    mov #'g', w1
    cp w0, w1
    bra z, select_g
    mov #'h', w1
    cp w0, w1
    bra z, select_h
    mov #'z', w1
    cp w0, w1
    bra z, select_z
    mov #'#', w1
    cp w0, w1
    bra z, select_count
	
    bra menu_top

;**********************************************************

mes_a:
    .pascii "\na) use online Kv, L and R measurement: \0"
mes_b:
    .pascii "\n\n make sure f_sample is below 25kHz !\n\nb) autocomplete\0"
mes_amp:
    .pascii " A\0"
mes_c:
	.pascii "\nc) #data points for online impedance measurement: \0" 
mes_d:	
	.pascii "\nd) reset data collection\0" 
mes_e:
	.pascii "\ne) current data collection, R: \0"
mes_f:
	.pascii "\nf) current data collection, L: \0"
mes_g:
	.pascii "\ng) speed data collection: \0"
mes_kerpm:
	.pascii " k-erpm\0"
mes_h:
	.pascii "\nh) inject extra current : \0"
mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"
countleft:
	.pascii "\n\ninitialisation count left: \0"
mes_yes:
	.pascii "yes\0"
mes_no:
	.pascii "no\0"



.end
