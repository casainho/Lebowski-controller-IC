.include "p30F4011.inc"
.include "defines.inc"
.include "temp_macros.s"

.text
.global menu_temp
menu_temp:
    call clr_scr_232
;------------------------------------------------------
;a) use temp sensors:
;------------------------------------------------------
    mov #tblpage(temp_mes_a), w0
    mov #tbloffset(temp_mes_a), w1
    call tx_str_232

    mov #tblpage(temp_mes_yes), w0
    mov #tbloffset(temp_mes_yes), w1
    btss flags_rom, #use_temp_sensors
    mov #tblpage(temp_mes_no), w0
    btss flags_rom, #use_temp_sensors
    mov #tbloffset(temp_mes_no), w1
    call tx_str_232

    btsc flags_rom, #use_temp_sensors
    bra temp_msg_b

    bra temp_msg_z

temp_opt_a:

    btg flags_rom, #use_temp_sensors
	
	bclr menus_completed, #mc_temp

    bra menu_temp

;------------------------------------------------------
;b) identify temp sensors
;------------------------------------------------------
temp_msg_b:
    mov #tblpage(temp_mes_b), w0
    mov #tbloffset(temp_mes_b), w1
    call tx_str_232

    bra temp_msg_c

temp_opt_b:
    call temp_read_ids
                                                            ;print whatever message came from the identification routine
    call tx_str_232

    call rx_char_232
	
	bclr menus_completed, #mc_temp

    bra menu_temp

;------------------------------------------------------
;c) temperature readings
;------------------------------------------------------
temp_msg_c:
    mov #tblpage(temp_mes_c), w0
    mov #tbloffset(temp_mes_c), w1
    call tx_str_232

    bra temp_msg_z

temp_opt_c:
    call temperature_readings
    bra menu_temp
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
temp_msg_z:
    mov #tblpage(temp_mes_z), w0
    mov #tbloffset(temp_mes_z), w1
    call tx_str_232
                                                            ;do not print sensor data when not in use
    btss flags_rom, #use_temp_sensors
    bra tmz_skip
    call print_sensor_ids
	call print_temp_limits
tmz_skip:
    mov #'\n', w0
    call tx_char_232

    bra temp_msg_choise

temp_opt_z:
	
    return

;------------------------------------------------------
temp_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z,  temp_opt_a

    btss flags_rom, #use_temp_sensors
    bra tmc_z

    mov #'b', w1
    cp w0, w1
    bra z,  temp_opt_b
    mov #'c', w1
    cp w0, w1
    bra z,  temp_opt_c

	call enter_temp_limits
	
tmc_z:
    mov #'z', w1
    cp w0, w1
    bra z, temp_opt_z

    bra menu_temp

;**********************************************************

temp_mes_a:
    .pascii "\na) use temp sensors: \0"
temp_mes_b:
    .pascii "\nb) identify temp sensors\0"
temp_mes_c:
    .pascii "\nc) temperature readings\0"
temp_mes_z:
    .pascii "\n\nz) return to main menu\n\0"
temp_mes_yes:
    .pascii "yes\0"
temp_mes_no:
    .pascii "no\0"
.end

