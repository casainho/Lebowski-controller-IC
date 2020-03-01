.include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_throttle
menu_throttle:
    call clr_scr_232

    clr w0
    bset w0, #throttle_AN7
    bset w0, #throttle_AN8
    and flags_rom, wreg
    cp0 w0
    bra z, mthr_all0
                                            ;use analog throttle
    bset flags_rom, #analog_throttle
    bra mthr_cont_1

mthr_all0:
                                            ;no analog throttle (this turns on CAN RX)
    bclr flags_rom, #analog_throttle
                                            ;no CAN TX
    bclr flags_rom, #tx_throttle

mthr_cont_1:

    mov #tblpage(menu_thr_msg), w0
    mov #tbloffset(menu_thr_msg), w1
    call tx_str_232

    mov thr_coeff_1, w0
    call menu_thr_print_number
    mov #',', w0
    call tx_char_232
    mov #' ', w0
    call tx_char_232
    mov thr_coeff_1+2, w0
    call menu_thr_print_number
    mov #',', w0
    call tx_char_232
    mov #' ', w0
    call tx_char_232
    mov thr_coeff_1+4, w0
    call menu_thr_print_number

    mov #tblpage(menu_thr_cont1), w0
    mov #tbloffset(menu_thr_cont1), w1
    call tx_str_232

    mov thr_coeff_2, w0
    call menu_thr_print_number
    mov #',', w0
    call tx_char_232
    mov #' ', w0
    call tx_char_232
    mov thr_coeff_2+2, w0
    call menu_thr_print_number
    mov #',', w0
    call tx_char_232
    mov #' ', w0
    call tx_char_232
    mov thr_coeff_2+4, w0
    call menu_thr_print_number

    mov #tblpage(menu_thr_cont2), w0
    mov #tbloffset(menu_thr_cont2), w1
    call tx_str_232

    btss flags_rom, #throttle_AN7
    bra mt_thr1_no
mt_thr1_yes:	
    mov #tblpage(menu_thr_yes), w0
    mov #tbloffset(menu_thr_yes), w1
    call tx_str_232
    bra mt_cont_3
mt_thr1_no:
    mov #tblpage(menu_thr_no), w0
    mov #tbloffset(menu_thr_no), w1
    call tx_str_232	

mt_cont_3:

    mov #tblpage(menu_thr_cont3), w0
    mov #tbloffset(menu_thr_cont3), w1
    call tx_str_232

    btss flags_rom, #throttle_AN8
    bra mt_thr2_no
mt_thr2_yes:	
    mov #tblpage(menu_thr_yes), w0
    mov #tbloffset(menu_thr_yes), w1
    call tx_str_232
    bra mt_cont_4
mt_thr2_no:
    mov #tblpage(menu_thr_no), w0
    mov #tbloffset(menu_thr_no), w1
    call tx_str_232	

mt_cont_4:

    mov #tblpage(menu_thr_cont4), w0
    mov #tbloffset(menu_thr_cont4), w1
    call tx_str_232

    btss flags_rom, #analog_throttle
    bra mt_thr_RXyes
mt_thr_RXno:	
    mov #tblpage(menu_thr_no), w0
    mov #tbloffset(menu_thr_no), w1
    call tx_str_232
    bra mt_cont_5
mt_thr_RXyes:
    mov #tblpage(menu_thr_yes), w0
    mov #tbloffset(menu_thr_yes), w1
    call tx_str_232	

mt_cont_5:

    mov #tblpage(menu_thr_cont5), w0
    mov #tbloffset(menu_thr_cont5), w1
    call tx_str_232

    btss flags_rom, #tx_throttle
    bra mt_thr_TXno
mt_thr_TXyes:	
    mov #tblpage(menu_thr_yes), w0
    mov #tbloffset(menu_thr_yes), w1
    call tx_str_232
    bra mt_cont_6
mt_thr_TXno:
    mov #tblpage(menu_thr_no), w0
    mov #tbloffset(menu_thr_no), w1
    call tx_str_232	

mt_cont_6:

    mov #tblpage(menu_thr_cont6), w0
    mov #tbloffset(menu_thr_cont6), w1
    call tx_str_232

/*
    mov flags_ee, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov #'\n', w0
    call tx_char_232
*/

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, mthr_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, mthr_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, mthr_opt_c
    mov #'d', w1
    cp w0, w1
    bra z, mthr_opt_d
    mov #'e', w1
    cp w0, w1
    bra z, mthr_opt_e
    mov #'f', w1
    cp w0, w1
    bra z, mthr_opt_f
    mov #'g', w1
    cp w0, w1
    bra z, mthr_opt_g
    mov #'h', w1
    cp w0, w1
    bra z, mthr_opt_h
    mov #'z', w1
    cp w0, w1
    bra z, mthr_opt_z

    bra menu_throttle


;**********************************************************

mthr_opt_a:
                                            ;start ADC AN7
    bclr ADPCFG, #7
    bset TRISB, #7
    bclr IEC0, #11
    mov #0b1000000000001111, w0
    mov w0, ADCON1                          ;module on, integer output, manual start, sample all simultaneous
    mov #0b0000000000000000, w0
    mov w0, ADCON2                          ;no scan, convert just one, interrupt every sample, 16 word buffer
    mov #0b0000000000000101, w0
    mov w0, ADCON3                          ;no auto sample, use system clock, Tad=99ns
    mov #0b0000000000000111, w0
    mov w0, ADCHS                           ;preset to AN7,
                                            ;print message 'close or slightly open throttle 1 and press any key'
    mov #tblpage(menu_meas_offset_thr1), w0
    mov #tbloffset(menu_meas_offset_thr1), w1
    call tx_str_232
    call rx_char_232
                                            ;measure ADC voltage 16 times, store as offset
    clr w0
    do #15, mthr_opt1_doend1
    bclr ADCON1, #1
    nop
mthr_opt1_adcwait1:
    btss ADCON1, #0
    bra mthr_opt1_adcwait1
    add ADCBUF0, wreg
    repeat #16000
    nop
    nop
mthr_opt1_doend1:
    nop

    lsr w0, #4, w1
    mov w1, thr1_offset
                                            ;print measured voltage
    call mthr_print_voltage
                                            ;print message 'fully open throttle, press any key'
    mov #tblpage(menu_meas_max_thr1), w0
    mov #tbloffset(menu_meas_max_thr1), w1
    call tx_str_232
    call rx_char_232
                                            ;measure ADC voltage 16 times, compute difference, store as range
    clr w0
    do #15, mthr_opt1_doend2
    bclr ADCON1, #1
    nop
mthr_opt1_adcwait2:
    btss ADCON1, #0
    bra mthr_opt1_adcwait2
    add ADCBUF0, wreg
    repeat #16000
    nop
    nop
mthr_opt1_doend2:
    nop
	
    push w0

    lsr w0, #4, w0
    subr thr1_offset, wreg
    mov w0, thr1_range
                                            ;print measured voltage
    pop w0
    call mthr_print_voltage
    call rx_char_232
											;close ADC's
    bclr ADCON1, #15

    bra menu_throttle
;------------------------------------------------------

mthr_opt_b:
                                            ;start ADC AN8
    bclr ADPCFG, #8
    bset TRISB, #8
    bclr IEC0, #11
    mov #0b1000000000001111, w0
    mov w0, ADCON1                          ;module on, integer output, manual start, sample all simultaneous
    mov #0b0000000000000000, w0
    mov w0, ADCON2                          ;no scan, convert just one, interrupt every sample, 16 word buffer
    mov #0b0000000000000101, w0
    mov w0, ADCON3                          ;no auto sample, use system clock, Tad=99ns
    mov #0b0000000000001000, w0
    mov w0, ADCHS                           ;preset to AN8,
                                            ;print message 'close or slightly open throttle 1 and press any key'
    mov #tblpage(menu_meas_offset_thr2), w0
    mov #tbloffset(menu_meas_offset_thr2), w1
    call tx_str_232
    call rx_char_232
                                            ;measure ADC voltage 16 times, store as offset
    clr w0
    do #15, mthr_opt2_doend1
    bclr ADCON1, #1
    nop
mthr_opt2_adcwait1:
    btss ADCON1, #0
    bra mthr_opt2_adcwait1
    add ADCBUF0, wreg
    repeat #16000
    nop
    nop
mthr_opt2_doend1:
    nop

    lsr w0, #4, w1
    mov w1, thr2_offset
                                            ;print measured voltage
    call mthr_print_voltage
                                            ;print message 'fully open throttle, press any key'
    mov #tblpage(menu_meas_max_thr2), w0
    mov #tbloffset(menu_meas_max_thr2), w1
    call tx_str_232
    call rx_char_232
                                            ;measure ADC voltage 16 times, compute difference, store as range
    clr w0
    do #15, mthr_opt2_doend2
    bclr ADCON1, #1
    nop
mthr_opt2_adcwait2:
    btss ADCON1, #0
    bra mthr_opt2_adcwait2
    add ADCBUF0, wreg
    repeat #16000
    nop
    nop
mthr_opt2_doend2:
    nop
	
    push w0

    lsr w0, #4, w0
    subr thr2_offset, wreg
    mov w0, thr2_range
                                            ;print measured voltage
    pop w0
    call mthr_print_voltage
    call rx_char_232
                                            ;close ADC's
    bclr ADCON1, #15

    bra menu_throttle

;------------------------------------------------------

mthr_opt_c:
    mov #thr_coeff_1, w13
    call mthr_enter_poly_coeff
	
	bclr menus_completed, #mc_throttle
	
    bra menu_throttle

;------------------------------------------------------

mthr_opt_d:
    mov #thr_coeff_2, w13
    call mthr_enter_poly_coeff
	
	bclr menus_completed, #mc_throttle
	
    bra menu_throttle

;------------------------------------------------------

mthr_opt_e:

    btg flags_rom, #throttle_AN7

    bra menu_throttle

;------------------------------------------------------

mthr_opt_f:

    btg flags_rom, #throttle_AN8

    bra menu_throttle

;------------------------------------------------------

mthr_opt_g:

    btg flags_rom, #tx_throttle

    bra menu_throttle

;------------------------------------------------------

mthr_opt_h:

    call throttle_tryout

    bra menu_throttle

;------------------------------------------------------

mthr_opt_z:
	
    return

;******************************************************


menu_thr_msg:
    .pascii "\na) calibrate throttle 1"
    .pascii "\nb) calibrate throttle 2"
    .pascii "\nc) polynomial coefficients throttle 1 (x, x^2, x^3): \0"
menu_thr_cont1:
    .pascii "\nd) polynomial coefficients throttle 2 (x, x^2, x^3): \0"
menu_thr_cont2:
    .pascii "\ne) use analog throttle 1: \0"
menu_thr_cont3:
    .pascii "\nf) use analog throttle 2: \0"
menu_thr_cont4:
    .pascii "\n\   receive throttle over CAN: \0"
menu_thr_cont5:
    .pascii "\ng) TX throttle over CAN: \0"
menu_thr_cont6:
    .pascii "\nh) test throttle"
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"

menu_thr_yes:
    .pascii "YES\0"
menu_thr_no:
    .pascii "NO\0"

menu_meas_offset_thr1:
    .pascii "\n close or hold slight open throttle 1 for offset measurement\n press any key to begin measurement\0"
menu_meas_max_thr1:
    .pascii "\n fully open throttle 1\n press any key to begin measurement\0"
menu_meas_offset_thr2:
    .pascii "\n close or hold slight open throttle 2 for offset measurement\n press any key to begin measurement\0"
menu_meas_max_thr2:
    .pascii "\n fully open throttle 2\n press any key to begin measurement\0"




.end

