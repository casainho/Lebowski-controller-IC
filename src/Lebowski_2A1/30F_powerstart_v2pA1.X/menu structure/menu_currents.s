.include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_currents
menu_currents:
    call clr_scr_232
;------------------------------------------------------
;a) current sensor transimpedance
;------------------------------------------------------
    mov #tblpage(cur_men_mes_a), w0
    mov #tbloffset(cur_men_mes_a), w1
    call tx_str_232
														;display sign
	btss flags_rom2, #negative_current_sensors
	bra 1f
	mov #'-', w0
	call tx_char_232
1:                                                      ;display transimpedance
    mov transimpedance, w0
    lsr w0, #8, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov transimpedance, w0
    sl w0, #8, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf+3, w0
    clr.b [w0]
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(cur_men_mes_a1), w0
    mov #tbloffset(cur_men_mes_a1), w1
    call tx_str_232

    bra mc_msg_b

mc_opt_a:
    mov #10, w0
    call get_signed_decimal_number
												;process sign
	bclr flags_rom2, #negative_current_sensors
	btss w0, #15
	bra 1f
												;set sign bit and make positive
	bset flags_rom2, #negative_current_sensors
	com w0, w0
	neg w1, w1
	addc #0, w0
1:
    sl w0, #8, w0
    lsr w1, #8, w1
    ior w0, w1, w0
    mov w0, transimpedance

	bclr menus_completed, #mc_current
	
    bra menu_currents

;------------------------------------------------------
;b) maximum motor phase current:
;------------------------------------------------------
mc_msg_b:
    mov #tblpage(cur_men_mes_b), w0
    mov #tbloffset(cur_men_mes_b), w1
    call tx_str_232
                                                        ;display maximum motor phase current
    mov i_max_phase, w0
    call display_current

    mov #tblpage(cur_men_mes_amp), w0
    mov #tbloffset(cur_men_mes_amp), w1
    call tx_str_232

    bra mc_msg_c

mc_opt_b:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
    mov w0, i_max_phase

    bra menu_currents

;------------------------------------------------------
;c) maximum battery current, motor use:
;------------------------------------------------------
mc_msg_c:
    mov #tblpage(cur_men_mes_c), w0
    mov #tbloffset(cur_men_mes_c), w1
    call tx_str_232

    mov i_max_bat_motoruse, w0
    call display_current

    mov #tblpage(cur_men_mes_amp), w0
    mov #tbloffset(cur_men_mes_amp), w1
    call tx_str_232

    bra mc_msg_d

mc_opt_c:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
    mov w0, i_max_bat_motoruse

    bra menu_currents

;------------------------------------------------------
;d) maximum battery current, regen:
;------------------------------------------------------
mc_msg_d:
    mov #tblpage(cur_men_mes_d), w0
    mov #tbloffset(cur_men_mes_d), w1
    call tx_str_232

    mov i_max_bat_regenuse, w0
    call display_current

    mov #tblpage(cur_men_mes_amp), w0
    mov #tbloffset(cur_men_mes_amp), w1
    call tx_str_232

    bra mc_msg_e

mc_opt_d:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
    mov w0, i_max_bat_regenuse

    bra menu_currents

;------------------------------------------------------
;e) autocomplete
;------------------------------------------------------
mc_msg_e:
    mov #tblpage(cur_men_mes_e), w0
    mov #tbloffset(cur_men_mes_e), w1
    call tx_str_232

    bra mc_msg_f

mc_opt_e:
                                                        ;error current 1/4th of max for fixed, 1/8th for prop
    mov i_max_phase, w0
    asr w0, #2, w0
    mov w0, i_error_max_fixed
    asr w0, #1, w0
    mov w0, i_error_max_prop
														;dr2:: check i_total
    bset flags_rom, #check_i_total
														;over_i_total % to 150
    mov #24576, w0
    mov w0, over_i_total_prop
														;over_i_total_fixed: 30%
    mov #19660, w0
    mul i_max_phase
    mov w3, over_i_total_fixed
                                                        ;braking current on direction change = 0 A
	clr i_force_regen
														;as standard no field weakening
	clr max_fieldweak_ratio
														;use I_error for error current (not absolute), as before
	bclr flags_rom, #I_error_absolute
                                                        ;i_filter_offset is 0A as it not always works correctly
    clr i_filter_offset
	
    bra menu_currents
	
;------------------------------------------------------
;f) current to check
;------------------------------------------------------
mc_msg_f:
    mov #tblpage(cur_men_mes_f), w0
    mov #tbloffset(cur_men_mes_f), w1
    call tx_str_232

    mov #tblpage(cur_men_mes_total), w0
    mov #tbloffset(cur_men_mes_total), w1
    btss, flags_rom, #check_i_total
    mov #tblpage(cur_men_mes_error), w0
    btss, flags_rom, #check_i_total
    mov #tbloffset(cur_men_mes_error), w1
    call tx_str_232

    bra mc_msg_g

mc_opt_f:
    btg flags_rom, #check_i_total

    bra menu_currents
	
;------------------------------------------------------
;g) fixed part:
;------------------------------------------------------
mc_msg_g:
    mov #tblpage(cur_men_mes_g), w0
    mov #tbloffset(cur_men_mes_g), w1
    call tx_str_232
                                                        ;display current
    mov over_i_total_fixed, w0
    call display_current

    mov #tblpage(cur_men_mes_amp), w0
    mov #tbloffset(cur_men_mes_amp), w1
    call tx_str_232

    bra mc_msg_h

mc_opt_g:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
    mov w0, over_i_total_fixed

    bra menu_currents

;------------------------------------------------------
;h) proportional factor:
;------------------------------------------------------
mc_msg_h:
    mov #tblpage(cur_men_mes_h), w0
    mov #tbloffset(cur_men_mes_h), w1
    call tx_str_232
                                                            ;0-399%
    mov #400, w0
    mul over_i_total_prop
    mov w3, w0

    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(cur_men_mes_h1), w0
    mov #tbloffset(cur_men_mes_h1), w1
    call tx_str_232

    bra mc_msg_i

mc_opt_h:
    mov #5, w0
    call get_number

    mov #164, w1
    mul.uu w0, w1, w0
    mov w0, over_i_total_prop

    bra menu_currents
	
;------------------------------------------------------
;i) dr3: maximum shutdown error current, fixed:
;------------------------------------------------------
mc_msg_i:
    mov #tblpage(cur_men_mes_i), w0
    mov #tbloffset(cur_men_mes_i), w1
    call tx_str_232
                                                        ;display maximum error current, fixed
    mov i_error_max_fixed, w0
    call display_current

    mov #tblpage(cur_men_mes_amp), w0
    mov #tbloffset(cur_men_mes_amp), w1
    call tx_str_232

    bra mc_msg_j

mc_opt_i:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
    mov w0, i_error_max_fixed

    bra menu_currents

;------------------------------------------------------
;j) dr3: maximum shutdown error current, proportional:
;------------------------------------------------------
mc_msg_j:
    mov #tblpage(cur_men_mes_j), w0
    mov #tbloffset(cur_men_mes_j), w1
    call tx_str_232
                                                        ;display maximum error current, fixed
    mov i_error_max_prop, w0
    call display_current

    mov #tblpage(cur_men_mes_amp), w0
    mov #tbloffset(cur_men_mes_amp), w1
    call tx_str_232

    bra mc_msg_k

mc_opt_j:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
    mov w0, i_error_max_prop

    bra menu_currents

;------------------------------------------------------
;k) shutdown based on
;------------------------------------------------------
mc_msg_k:
    mov #tblpage(cur_men_mes_k), w0
    mov #tbloffset(cur_men_mes_k), w1
    call tx_str_232
	
	mov #tblpage(cur_men_normal), w0
    mov #tbloffset(cur_men_normal), w1
    btsc flags_rom, #I_error_absolute
    mov #tblpage(cur_men_absolute), w0
    btsc flags_rom, #I_error_absolute
    mov #tbloffset(cur_men_absolute), w1
    call tx_str_232
	
    bra mc_msg_l

mc_opt_k:	
	btg flags_rom, #I_error_absolute
	
	bra menu_currents
	
;------------------------------------------------------
;l) applied braking current (phase) on direction change
;------------------------------------------------------
mc_msg_l:
    mov #tblpage(cur_men_mes_l), w0
    mov #tbloffset(cur_men_mes_l), w1
    call tx_str_232
                                                        ;display maximum error current, fixed
    mov i_force_regen, w0
    call display_current

    mov #tblpage(cur_men_mes_amp), w0
    mov #tbloffset(cur_men_mes_amp), w1
    call tx_str_232

    bra mc_msg_m

mc_opt_l:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
    mov w0, i_force_regen

    bra menu_currents
	
;------------------------------------------------------
;m) offset filtering (phase) current limit
;------------------------------------------------------
mc_msg_m:
    mov #tblpage(cur_men_mes_m), w0
    mov #tbloffset(cur_men_mes_m), w1
    call tx_str_232
                                                        ;display maximum error current, fixed
    mov i_filter_offset, w0
    call display_current

    mov #tblpage(cur_men_mes_amp), w0
    mov #tbloffset(cur_men_mes_amp), w1
    call tx_str_232

    bra mc_msg_n

mc_opt_m:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
    mov w0, i_filter_offset

    bra menu_currents
;------------------------------------------------------
;n) maximum field weakening current
;------------------------------------------------------
mc_msg_n:
    mov #tblpage(cur_men_mes_n), w0
    mov #tbloffset(cur_men_mes_n), w1
    call tx_str_232
                                                        ;max fw current is i_max_phase * 
    mov i_max_phase, w0
	mul max_fieldweak_ratio
														;sl as max_fieldweak_ratio is in Q15
	sl w3, w0
    call display_current

    mov #tblpage(cur_men_mes_amp), w0
    mov #tbloffset(cur_men_mes_amp), w1
    call tx_str_232

    bra mc_msg_y

mc_opt_n:
    mov #10, w0
    call get_signed_decimal_number
    call current_to_lsb
	
	mov w0, w1
	clr w0
	mov i_max_phase, w2
	
	repeat #17
	div.ud w0, w2
                                                        ;clear on overflow (entered current higher than i_max_phase)
	btsc SR, #OV
	clr w0
	
	lsr w0, w0
														;store as Q15
    mov w0, max_fieldweak_ratio

    bra menu_currents
	
;------------------------------------------------------
;check --combination g & h out of range--
;------------------------------------------------------
mc_msg_y:
    mov i_max_phase, w0
    mul over_i_total_prop

    sl w3, #2, w2
    lsr w3, #14, w3

    mov over_i_total_fixed, w0
    add w2, w0, w2
    addc #0, w3

    cp0 w3
    bra z, mc_msg_z

    mov #tblpage(cur_men_mes_oor), w0
    mov #tbloffset(cur_men_mes_oor), w1
    call tx_str_232
	
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
mc_msg_z:
    mov #tblpage(cur_men_mes_z), w0
    mov #tbloffset(cur_men_mes_z), w1
    call tx_str_232

    bra mc_msg_choise
mc_opt_z:
    return

;------------------------------------------------------
mc_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, mc_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, mc_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, mc_opt_c
    mov #'d', w1
    cp w0, w1
    bra z, mc_opt_d
    mov #'e', w1
    cp w0, w1
    bra z, mc_opt_e
    mov #'f', w1
    cp w0, w1
    bra z, mc_opt_f
    mov #'g', w1
    cp w0, w1
    bra z, mc_opt_g
    mov #'h', w1
    cp w0, w1
    bra z, mc_opt_h
    mov #'i', w1
    cp w0, w1
    bra z, mc_opt_i
    mov #'j', w1
    cp w0, w1
    bra z, mc_opt_j
    mov #'k', w1
    cp w0, w1
    bra z, mc_opt_k
    mov #'l', w1
    cp w0, w1
    bra z, mc_opt_l
    mov #'m', w1
    cp w0, w1
    bra z, mc_opt_m
    mov #'n', w1
    cp w0, w1
    bra z, mc_opt_n
    mov #'z', w1
    cp w0, w1
    bra z, mc_opt_z

    bra menu_currents

;**********************************************************
.global display_current

;w1: on call current is in w0
;displays current according to ((I_lsb / (4915 * R))

display_current:
 								;I_lsb * (8192 / 4.915) -> 16.0 * 3.13 = 19.13 in bits
    mov #1667, w1
    mul.uu w0, w1, w0
								;I_lsb * (8192 / 4.915) / R_mOhm * 256 = 19.13 / 8.8 = 11.5 in bits
    mov transimpedance, w2
    repeat #17
    div.ud w0, w2
								;answer in w0, store in w2 for later for decimal part
    mov w0, w2
    lsr w0, #5, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    sl w2, #11, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf+2, w0
    clr.b [w0]
    mov #str_buf, w0
    call tx_ram_str_232

    return


;**********************************************************
.global current_to_lsb

;on call:
;w0:integer part of current to be turned into LSB's
;w1:decimal part
;on return
;w0:current in LSB's

current_to_lsb:
								;convert I from 16.16 to 11.5
    sl w0, #5, w0
    lsr w1, #11, w1
    ior w0, w1, w0
								;mult I with transimpedance to 19.13
    mov transimpedance, w1
    mul.uu w0, w1, w0
								;divide by contant (3.13) to arrive at 16.0
    mov #1667, w2
    repeat #17
    div.ud w0, w2
								;answer in w0
    return
	
;**********************************************************

cur_men_mes_a:
    .pascii "\na) current sensor transimpedance: \0"
cur_men_mes_a1:
    .pascii " mV/A\0"
cur_men_mes_b:
    .pascii "\nb) maximum motor phase current: \0"
cur_men_mes_c:
    .pascii "\nc) maximum battery current, motor use: \0"
cur_men_mes_d:
    .pascii "\nd) maximum battery current, regen: \0"
cur_men_mes_e:
    .pascii "\n\ne) autocomplete\n\0"
cur_men_mes_f:
    .pascii "\nf) dr2, dr23: current to check: \0"
cur_men_mes_g:
    .pascii "\ng) dr2, dr23: fixed part: \0"
cur_men_mes_h:
    .pascii "\nh) dr2, dr23: proportional to throttle current, factor: \0"
cur_men_mes_h1:
    .pascii " %\0"
cur_men_mes_i:
    .pascii "\ni) dr3: maximum shutdown error current, fixed: \0"
cur_men_mes_i1:
    .pascii " A\0"
cur_men_mes_j:
    .pascii "\nj) dr3: maximum shutdown error current, proportional: \0"
cur_men_mes_k:
    .pascii "\nk) dr3: shutdown based on : \0"
cur_men_mes_l:
    .pascii "\nl) applied braking current (phase) on direction change: \0"
cur_men_mes_m:
    .pascii "\nm) offset filtering (phase) current limit: \0"
cur_men_mes_n:
    .pascii "\nn) maximum field weakening current: \0"
cur_men_mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"
cur_men_mes_amp:
    .pascii " A\0"
cur_men_normal:
	.pascii "I_error\0"
cur_men_absolute:
	.pascii "abs(I_error)\0"
cur_men_noacclim:
	.pascii "not limited\0"
cur_men_yesacclim:
	.pascii "auto limited\0"
cur_men_mes_error:
    .pascii "error current\0"
cur_men_mes_total:
    .pascii "total current\0"
cur_men_mes_oor:
    .pascii "\n\n--combination g & h out of range--\0"


.end

