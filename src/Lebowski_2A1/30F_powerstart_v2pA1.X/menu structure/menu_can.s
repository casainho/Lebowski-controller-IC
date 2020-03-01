.include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_can
menu_can:
    call clr_scr_232

    mov #tblpage(menu_can_msg), w0
    mov #tbloffset(menu_can_msg), w1
    call tx_str_232
			 				;can address
    mov can_rxsid, w0
    lsr w0, #2, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(menu_can_cont1), w0
    mov #tbloffset(menu_can_cont1), w1
    call tx_str_232
							;cfg1 
    mov can_cfg1, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(menu_can_cont2), w0
    mov #tbloffset(menu_can_cont2), w1
    call tx_str_232		
			 				;cfg2
    mov can_cfg2, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(menu_can_cont3), w0
    mov #tbloffset(menu_can_cont3), w1
    call tx_str_232		
							;rs232 rate = 30e6 / (main_loop_count * monitoring_value)
    mov main_loop_count, w0
    mov monitoring_value, w1
    mul.uu w0, w1, w0
    mov w0, w2
    mov #457, w1
    mov #50048, w0
    repeat #17
    div.ud w0, w2
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(menu_can_cont4), w0
    mov #tbloffset(menu_can_cont4), w1
    call tx_str_232
			 
    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, mcan_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, mcan_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, mcan_opt_c
    mov #'z', w1
    cp w0, w1
    bra z, mcan_opt_z

    bra menu_can

;------------------------------------------------------

mcan_opt_a:

    mov #4, w0
    call get_number

    mov #2047, w1
    cpslt w0, w1
    bra menu_can

    sl w0, #2, w1
    mov w1, can_rxsid

    mov #0x00FF, w2
    and w1, w2, w1
    sl w0, #5, w0
    mov #0xF800, w2
    and w0, w2, w0
    ior w0, w1, w0

    mov w0, can_txsid

    bra menu_can

;------------------------------------------------------

mcan_opt_b:
    mov #5, w0
    call get_number
	
    mov w0, can_cfg1

    bra menu_can

;------------------------------------------------------

mcan_opt_c:
    mov #5, w0
    call get_number
	
    mov w0, can_cfg2

    bra menu_can

;------------------------------------------------------

mcan_opt_z:
    return

;**********************************************************

menu_can_msg:
    .pascii "\na) CAN 'address': \0"
menu_can_cont1:
    .pascii "\nb) CAN CFG1 as per Microchip 30F manual: \0"
menu_can_cont2:
    .pascii "\nc) CAN CFG2 as per Microchip 30F manual: \0"
menu_can_cont3:
    .pascii"\n   RS232 output rate: \0"
menu_can_cont4:
    .pascii " Hz\nz) return to main menu"
    .pascii "\n\n\0"
.end

