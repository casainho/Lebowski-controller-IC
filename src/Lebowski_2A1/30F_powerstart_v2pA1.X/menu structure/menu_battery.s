.include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_battery
menu_battery:
    call clr_scr_232
	
	setm filter_vbat
	btsc flags_rom2, #use_hvc_lvc
	call battery_measurement
	
;------------------------------------------------------
;a) use HVC, LVC battery current limiting
;------------------------------------------------------
mb_msg_a:
	mov #tblpage(bat_mes_a), w0
    mov #tbloffset(bat_mes_a), w1
    call tx_str_232
	
	mov #tblpage(bat_mes_yes), w0
    mov #tbloffset(bat_mes_yes), w1
    btss flags_rom2, #use_hvc_lvc
    mov #tblpage(bat_mes_no), w0
    btss flags_rom2, #use_hvc_lvc
    mov #tbloffset(bat_mes_no), w1
    call tx_str_232

	bra mb_msg_b
	
mb_opt_a:
	
	btg flags_rom2, #use_hvc_lvc
	
	bra menu_battery
;------------------------------------------------------
;b) battery voltage
;------------------------------------------------------
mb_msg_b:
	mov #tblpage(bat_mes_b), w0
    mov #tbloffset(bat_mes_b), w1
    call tx_str_232
														;calculate battery_voltage [12.4] from measurement
														;vbat[12.4] = 2^-16 * volt_scale * filter_vbat
	mov volt_scale, w0
	mul filter_vbat
	mov w3, battery_voltage
	
    mov battery_voltage, w0
    lsr w0, #4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov battery_voltage, w0
    sl w0, #12, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+2
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(bat_mes_V), w0
    mov #tbloffset(bat_mes_V), w1
    call tx_str_232

	btss flags_rom2, #use_hvc_lvc
	bra mb_msg_z
    bra mb_msg_c

mb_opt_b:

    mov #10, w0
    call get_signed_decimal_number

    sl w0, #4, w0
    lsr w1, #12, w1
    ior w0, w1, w1
														;volt_scale = 2^16*vbat[12.4] / filter_vbat
	clr w0
	mov filter_vbat, w2
	cp0 w2
	bra z, 1f
	
	repeat #17
	div.ud w0, w2
	
1:			
    mov w0, volt_scale
	
	bclr menus_completed, #mc_battery
	
    bra menu_battery
	
;------------------------------------------------------
;c) hvc cutoff
;------------------------------------------------------
mb_msg_c:
	mov #tblpage(bat_mes_c), w0
    mov #tbloffset(bat_mes_c), w1
    call tx_str_232
	
	mov hvc_cutoff, w0
	call display_volt
	
	mov #tblpage(bat_mes_V), w0
    mov #tbloffset(bat_mes_V), w1
    call tx_str_232
	
	bra mb_msg_d
	
mb_opt_c:
	
	call input_volt						
    mov w0, hvc_cutoff
	
	bra menu_battery
	
;------------------------------------------------------
;d) HVC start
;------------------------------------------------------
mb_msg_d:
	mov #tblpage(bat_mes_d), w0
    mov #tbloffset(bat_mes_d), w1
    call tx_str_232
	
	mov hvc_start, w0
	call display_volt
	
	mov #tblpage(bat_mes_V), w0
    mov #tbloffset(bat_mes_V), w1
    call tx_str_232
	
	bra mb_msg_e
	
mb_opt_d:
	
	call input_volt						
    mov w0, hvc_start
	
	bra menu_battery
	
;------------------------------------------------------
;e) LVC start
;------------------------------------------------------
mb_msg_e:
	mov #tblpage(bat_mes_e), w0
    mov #tbloffset(bat_mes_e), w1
    call tx_str_232
	
	mov lvc_start, w0
	call display_volt
	
	mov #tblpage(bat_mes_V), w0
    mov #tbloffset(bat_mes_V), w1
    call tx_str_232
	
	bra mb_msg_f
	
mb_opt_e:
	
	call input_volt						
    mov w0, lvc_start
	
	bra menu_battery
;------------------------------------------------------
;f) LVC cutoff
;------------------------------------------------------
mb_msg_f:
	mov #tblpage(bat_mes_f), w0
    mov #tbloffset(bat_mes_f), w1
    call tx_str_232
	
	mov lvc_cutoff, w0
	call display_volt
	
	mov #tblpage(bat_mes_V), w0
    mov #tbloffset(bat_mes_V), w1
    call tx_str_232
	
	bra mb_msg_z
	
mb_opt_f:
	
	call input_volt						
    mov w0, lvc_cutoff
	
	bra menu_battery
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
mb_msg_z:
    mov #tblpage(bat_mes_z), w0
    mov #tbloffset(bat_mes_z), w1
    call tx_str_232

    bra mb_msg_choise
mb_opt_z:
    return

;------------------------------------------------------
mb_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, mb_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, mb_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, mb_opt_c
    mov #'d', w1
    cp w0, w1
    bra z, mb_opt_d
    mov #'e', w1
    cp w0, w1
    bra z, mb_opt_e
    mov #'f', w1
    cp w0, w1
    bra z, mb_opt_f
    mov #'z', w1
    cp w0, w1
    bra z, mb_opt_z

    bra menu_battery

;**********************************************************

bat_mes_a:
    .pascii "\na) use HVC, LVC battery current limiting: \0"
bat_mes_b:
    .pascii "\nb) battery voltage: \0"
bat_mes_c:
    .pascii "\nc) HVC cutoff: \0"
bat_mes_d:
    .pascii "\nd) HVC start : \0"
bat_mes_e:
    .pascii "\ne) LVC start : \0"
bat_mes_f:
    .pascii "\nf) LVC cutoff: \0"
bat_mes_V:
    .pascii " V\0"
bat_mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"
bat_mes_yes:
	.pascii "yes\0"
bat_mes_no:
	.pascii "no\0"
	
;**********************************************************
	
display_volt:
	
	mul volt_scale
	
	push w3
    lsr w3, #4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

	pop w3
    sl w3, #12, w0
    mov #str_buf, w1
    call word_to_01_str
    clr.b str_buf+2
    mov #str_buf, w0
    call tx_ram_str_232
	
	return

;**********************************************************
	
input_volt:
	
	mov #10, w0
    call get_signed_decimal_number

    sl w0, #4, w0
    lsr w1, #12, w1
    ior w0, w1, w1
														;result = 2^16 * input[12.4] / volt_scale
	clr w0
	mov volt_scale, w2
	cp0 w2
	bra z, 1f
	
	repeat #17
	div.ud w0, w2
	
1:						
	return
	
;**********************************************************
	
battery_measurement:
;------------------------------------------------------ initialise
    call ADC_open
    call ADC_current
	call timers_open

	mov #filter_vbat+2, w13
	clr [w13--]
	clr [w13]
;------------------------------------------------------ make 4096 measurements, integrate
	
	do #4095, bm_doend
														;main sampling loop
bm_lp:		
	btss IFS0, #3
    bra bm_lp
    bclr IFS0, #3
														;wait for ADC measurement
	bclr ADCON1, #1
	repeat #100
    nop
    call ADC_read_current	
														;mult by 1/4096, add to result (comes down to mult by 64*16 = 1024)
	mov supply_voltage, w0
	sl w0, #10, w1
	lsr w0, #6, w2
	add w1, [++w13], [w13]
bm_doend:
	addc w2, [--w13], [w13]

;------------------------------------------------------ prevent div0
	cp0 filter_vbat
	btsc SR, #Z
	setm filter_vbat
;------------------------------------------------------ end	
	
	return					

.end

