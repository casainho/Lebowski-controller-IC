.include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_sensors
menu_sensors:
    call clr_scr_232
;------------------------------------------------------
;a) restore calibration
;------------------------------------------------------
    mov #tblpage(sens_mes_a), w0
    mov #tbloffset(sens_mes_a), w1
    call tx_str_232

    bra ms_msg_b

ms_opt_a:

    mov #1024, w0
    mov w0, adc_current_offset
    mov w0, adc_current_offset+2
    mov w0, adc_current_offset+4
	mov #512, w0
    mov w0, adc_current_prev
    mov w0, adc_current_prev+2
    mov w0, adc_current_prev+4
	
	bclr menus_completed, #mc_sensors

    bra menu_sensors

;------------------------------------------------------
;b) offset measurement
;------------------------------------------------------
ms_msg_b:
    mov #tblpage(sens_mes_b), w0
    mov #tbloffset(sens_mes_b), w1
    call tx_str_232

    mov #tblpage(sens_mes_b1), w0
    mov #tbloffset(sens_mes_b1), w1
    call tx_str_232

    mov adc_current_offset, w0
    call display_offset

    mov #tblpage(sens_mes_b2), w0
    mov #tbloffset(sens_mes_b2), w1
    call tx_str_232

    mov adc_current_offset+2, w0
    call display_offset

    mov #tblpage(sens_mes_b3), w0
    mov #tbloffset(sens_mes_b3), w1
    call tx_str_232

    mov adc_current_offset+4, w0
    call display_offset

    mov #tblpage(sens_mes_b4), w0
    mov #tbloffset(sens_mes_b4), w1
    call tx_str_232

    bra ms_msg_z

ms_opt_b:
    call current_sensor_offset_measurement

    bra menu_sensors

;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
ms_msg_z:
    mov #tblpage(sens_mes_z), w0
    mov #tbloffset(sens_mes_z), w1
    call tx_str_232

    bra ms_msg_choise
ms_opt_z:
    return

;------------------------------------------------------
ms_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, ms_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, ms_opt_b
    mov #'z', w1
    cp w0, w1
    bra z, ms_opt_z

    bra menu_sensors

;**********************************************************

sens_mes_a:
    .pascii "\na) restore calibration, autocomplete\0"
sens_mes_b:
    .pascii "\nb) perform offset measurement\0"
sens_mes_b1:
    .pascii "\n   sensor a: \0"
sens_mes_b2:
    .pascii " mV\n   sensor b: \0"
sens_mes_b3:
    .pascii " mV\n   sensor c: \0"
sens_mes_b4:
    .pascii " mV\0"
sens_mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"

;**********************************************************
display_offset:
                                                            ;determine offset
    mov #1024, w1
    sub w0, w1, w0
                                                            ;one LSB = 2.5 mV which is 000010.1 in [15.1]
    mul.su w0, #5, w0
                                                            ;make positive, print '-' if necessary
    mov #str_buf, w1

    btss w0, #15
    bra do_pos
    push w0
    mov.b #'-', w0
    mov.b w0, [w1++]
    pop w0
    neg w0, w0
do_pos:
                                                            ;keep result for later
    push w0
                                                            ;print before comma part
    asr w0, w0
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    pop w0
                                                            ;no need to invert for after comma part
    sl w0, #15, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+2
    mov #str_buf, w0
    call tx_ram_str_232

    return

;**********************************************************

.end

