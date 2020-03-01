 .include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_pwm
menu_pwm:
    call clr_scr_232
;------------------------------------------------------
;a) PWM frequency
;------------------------------------------------------

    mov #tblpage(pwm_msg_a), w0
    mov #tbloffset(pwm_msg_a), w1
    call tx_str_232
                                                        ;calculate pwm frequency in kHz (15000 / (pwm_period+1))
    mov #15000, w0
    mov pwm_period, w2
;	inc w2, w2											;not done to prevent div 0 for virgin chip
    repeat #17
    div.u w0, w2                                        ;answer is in w0
                                                        ;display
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
	
    mov #tblpage(pwm_msg_a1), w0
    mov #tbloffset(pwm_msg_a1), w1
    call tx_str_232

    bra mp_msg_b

mp_opt_a:
                                                        ;new line
    mov #'\n', w0
    call tx_char_232
                                                        ;get number input, 4 digits max
    mov #4, w0
    call get_number
                                                        ;pwm_period = -1 + 15000 / w0 (w0 in kHz)
    mov w0, w2
    mov #15000, w0
    repeat #17
    div.u w0, w2                                        ;answer is in w0

	dec w0, w0
    mov w0, pwm_period
	
	bclr menus_completed, #mc_pwm

    bra menu_pwm

;------------------------------------------------------
;b) deadtime
;------------------------------------------------------
mp_msg_b:

    mov #tblpage(pwm_msg_b), w0
    mov #tbloffset(pwm_msg_b), w1
    call tx_str_232
                                                        ;calculate deadtime in ns ( (1)33 * pwm_deadtime)
    mov pwm_deadtime, w0
    bclr w0, #7                                         ;remove 4Tcy bit for correct number indication
    sl w0, #8, w0                                       ;256 * pwm_deadtime
    mov #8533, w1                                       ;256 * 33.3333
    btsc pwm_deadtime, #7
    mov #34133, w1                                      ;or use 256 * 133.33333
    mul.uu w0, w1, w2                                   ;now w3 = pwm_deadtime * (1)33.3333
    mov w3, w0

    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(pwm_msg_b1), w0
    mov #tbloffset(pwm_msg_b1), w1
    call tx_str_232

    bra mp_msg_c

mp_opt_b:
                                                        ;new line
    mov #'\n', w0
    call tx_char_232
                                                        ;get number input, 4 digits max
    mov #4, w0
    call get_number

    mov #1999, w1
    cp w0, w1
    bra gtu, mpob_over_2000

mpob_under_2000:
                                                        ;pwm_deadtime = w0/33.3333
    mov #256, w1
    mul.uu w0, w1, w0                                       ;w1:w0 = 256*input
    mov #8533, w2                                           ;w2 := 33.3333 * 256
    repeat #17
    div.ud w0, w2                                           ;answer in w0
                                                        ;apply mask to make number in range
    mov #0x003F, w1
    and w0, w1, w0
    mov w0, pwm_deadtime

    bra menu_pwm

mpob_over_2000:
                                                        ;pwm_deadtime = w0/133.3333
    mov #256, w1
    mul.uu w0, w1, w0                                       ;w1:w0 = 256*input
    mov #34133, w2                                          ;w2 := 133.3333 * 256
    repeat #17
    div.ud w0, w2                                           ;answer in w0
                                                        ;apply mask to make number in range
    mov #0x003F, w1
    and w0, w1, w0
                                                        ;select 4Tcy (133ns per step)
    bset w0, #7

    mov w0, pwm_deadtime

    bra menu_pwm

;------------------------------------------------------
;c) dutycycle testsignal
;------------------------------------------------------
mp_msg_c:
    mov #tblpage(pwm_msg_c), w0
    mov #tbloffset(pwm_msg_c), w1
    call tx_str_232
                                                        ;calculate dutycycle ( 50 * PDCx / pwm_period )
    mov PDC1, w0
    mov #50, w1
    mul.uu w0, w1, w2                                       ;50*PDCx, answer in w3:w2
    mov pwm_period, w4
    repeat #17
    div.ud w2, w4                                           ;answer (in %) in w0

    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232		
                                                        ;print active high/low for high side FET
    mov #0x00F8, w0
    mov w0,TBLPAG
    mov #0x0004, w0
    tblrdl [w0], w13

    mov #tblpage(pwm_msg_c1), w0
    mov #tbloffset(pwm_msg_c1), w1
    call tx_str_232

    bra mp_msg_d

mp_opt_c:
                                                    ;new line
    mov #'\n', w0
    call tx_char_232
                                                    ;get number input, 2 digits max
    mov #2, w0
    call get_number
                                                    ;PDCx = w0 * pwm_period / 50
    mov pwm_period, w1
    mul.uu w0, w1, w0                               ;w1:w0 = input # * pwm_period
    mov #50, w2
    repeat #17
    div.ud w0, w2                                   ;answer in w0

    mov w0, PDC1

    bra menu_pwm

;------------------------------------------------------
;d) toggle high side polarity, now active
;------------------------------------------------------
mp_msg_d:
    mov #tblpage(pwm_msg_d), w0
    mov #tbloffset(pwm_msg_d), w1
    call tx_str_232

    btss w13, #9
    bra mp_hs_actL
mp_hs_actH:	
    mov #tblpage(pwm_message_high), w0
    mov #tbloffset(pwm_message_high), w1
    call tx_str_232
    bra mp_msg_e
mp_hs_actL:
    mov #tblpage(pwm_message_low), w0
    mov #tbloffset(pwm_message_low), w1
    call tx_str_232
    bra mp_msg_e

mp_opt_d:
                                                        ;set bit to be toggled
    mov #0b0000001000000000, w2
                                                        ;and toggle
    call update_FBORPOR

    bra menu_pwm

;------------------------------------------------------
;e) toggle low side polarity, now active
;------------------------------------------------------
mp_msg_e:
    mov #tblpage(pwm_msg_e), w0
    mov #tbloffset(pwm_msg_e), w1
    call tx_str_232

    btss w13, #8
    bra mp_ls_actL
mp_ls_actH:
    mov #tblpage(pwm_message_high), w0
    mov #tbloffset(pwm_message_high), w1
    call tx_str_232
    bra mp_msg_f
mp_ls_actL:
    mov #tblpage(pwm_message_low), w0
    mov #tbloffset(pwm_message_low), w1
    call tx_str_232
    bra mp_msg_f

mp_opt_e:
                                                        ;set bit to be toggled
    mov #0b0000000100000000, w2
                                                        ;and toggle
    call update_FBORPOR

    bra menu_pwm
;------------------------------------------------------
;f) test PWM signals
;------------------------------------------------------
mp_msg_f:

    mov #tblpage(pwm_msg_f), w0
    mov #tbloffset(pwm_msg_f), w1
    call tx_str_232

    bra mp_msg_g

mp_opt_f:

                                                        ;write variables to pwm register
    mov pwm_period, w0
    mov w0, PTPER
    mov pwm_deadtime, w0
    mov w0, DTCON1
                                                        ;give all 3 channels the same dutycycle
    mov PDC1, w0
    mov w0, PDC2
    mov w0, PDC3
                                                        ;pwm on
    bset PTCON, #15
                                                        ;show message
    mov #tblpage(pwm_message_pak), w0
    mov #tbloffset(pwm_message_pak), w1
    call tx_str_232

    call rx_char_232
                                                        ;pwm off
    bclr PTCON, #15

    bra menu_pwm

;------------------------------------------------------
;g) autocomplete
;------------------------------------------------------
mp_msg_g:
    mov #tblpage(pwm_msg_g), w0
    mov #tbloffset(pwm_msg_g), w1
    call tx_str_232

    bra mp_msg_h

mp_opt_g:
                                                        ;(n+1/2)*loop frequency = 2*PWM frequency
														;translates to: main_loop_count = (n+1/2) * pwm_period
														;use w4 = 2n+1
	mov #1, w4
mog_lp:						                                                      
	mov pwm_period, w2
	lsr w2, w2
	mul.uu w4, w2, w2									;w2 = (2n+1) * pwm/2
	
                                                        ;check that result (in w2) not too small (too high freq), else use n+1
														;longest processing time: 33.0 usec during drive 3 (with accel limiter)
	inc2 w4, w4
	mov #990, w1
    cpsgt w2, w1
    bra mog_lp

	dec w2, w2
    mov w2, main_loop_count

    bra calc_moni_count

;------------------------------------------------------
;h) loop sample frequency:
;------------------------------------------------------
mp_msg_h:
    mov #tblpage(pwm_msg_h), w0
    mov #tbloffset(pwm_msg_h), w1
    call tx_str_232
                                                            ;display loop frequency
    mov #117, w1                                            ;w1:w0 = 256 * 30000
    mov #12288, w0
    mov main_loop_count, w2
;	inc w2, w2												;not done to prevent div 0 in virgin chip
    repeat #17
    div.ud w0, w2

    sl w0, #8, w2
    lsr w0, #8, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov w2, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf+3, w0
    clr.b [w0]
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(pwm_msg_h1), w0
    mov #tbloffset(pwm_msg_h1), w1
    call tx_str_232

    bra mp_msg_z

mp_opt_h:

    mov #10, w0
    call get_signed_decimal_number

    sl w0, #8, w2
    lsr w1, #8, w1
    ior w2, w1, w2
    mov #117, w1                                            ;w1:w0 = 256 * 30000
    mov #12288, w0
    repeat #17
    div.ud w0, w2

	dec w0, w0
    mov w0, main_loop_count	
                                                            ;calculate RS232 monitoring count value ( 1 + round(7500 / mlc) )
    mov w0, w2
calc_moni_count:
	mov #7500, w0
    repeat #17
    div.u w0, w2

    inc w0, w0
    mov w0, monitoring_value

    bra menu_pwm

;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
mp_msg_z:
    mov #tblpage(pwm_msg_z), w0
    mov #tbloffset(pwm_msg_z), w1
    call tx_str_232

    bra mp_choise

mp_opt_z:
    return

;------------------------------------------------------
mp_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, mp_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, mp_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, mp_opt_c
    mov #'d', w1
    cp w0, w1
    bra z, mp_opt_d
    mov #'e', w1
    cp w0, w1
    bra z, mp_opt_e
    mov #'f', w1
    cp w0, w1
    bra z, mp_opt_f
    mov #'g', w1
    cp w0, w1
    bra z, mp_opt_g
    mov #'h', w1
    cp w0, w1
    bra z, mp_opt_h
    mov #'z', w1
    cp w0, w1
    bra z, mp_opt_z

    bra menu_pwm

;**********************************************************

update_FBORPOR:
                                                    ;read current setting
    mov #0x00F8, w0
    mov w0,TBLPAG
    mov #0x0004, w1
    tblrdl [w1], w0
                                                    ;toggle required bit with XOR
    xor w0, w2, w0
                                                    ;follow correct sequence to write back
    tblwtl w0, [w1]
	
    mov #0x4008, w0
    mov w0, NVMCON
                                                    ;write key sequence
    disi #5
    mov #0x55, w0
    mov w0, NVMKEY
    mov #0xAA, w0
    mov w0, NVMKEY
                                                    ;set write bit
    bset NVMCON, #15
    nop
    nop
mp_uF_lp:                                           ;wait until write finished
    btsc NVMCON, #15
    bra mp_uF_lp
	
    return

;**********************************************************

pwm_msg_a:
    .pascii "\na) PWM frequency: \0"
pwm_msg_a1:
    .pascii "kHz\0"
pwm_msg_b:
    .pascii "\nb) deadtime: \0"
pwm_msg_b1:
    .pascii "ns\0"
pwm_msg_c:
    .pascii "\nc) dutycycle testsignal: \0"
pwm_msg_c1:
    .pascii "%\0"
pwm_msg_d:
    .pascii "\nd) toggle high side polarity, now active \0"
pwm_msg_e:
    .pascii "\ne) toggle low side polarity, now active \0"
pwm_msg_f:
    .pascii "\nf) test PWM signals\0"
pwm_msg_g:
    .pascii "\n\ng) autocomplete\n\0"
pwm_msg_h:
    .pascii "\nh) loop sample frequency: \0"
pwm_msg_h1:
    .pascii " kHz\0"
pwm_msg_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"
pwm_message_pak:
    .pascii "\n\nPWM test signals active\nPress any key to deactivate\n\0"
pwm_message_low:
    .pascii "LOW\0"
pwm_message_high:
    .pascii "HIGH\0"



.end

