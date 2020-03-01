.include "p30F4011.inc"
.include "defines.inc"

.text

.global menu_stored_status
menu_stored_status:
menu_start:
    call clr_scr_232

    mov #tblpage(lastbut3), w0
    mov #tbloffset(lastbut3), w1
    call tx_str_232

	mov #stored_status+108, w13
	call print_status

    mov #tblpage(lastbut2), w0
    mov #tbloffset(lastbut2), w1
    call tx_str_232

	mov #stored_status+72, w13
	call print_status

    mov #tblpage(lastbut1), w0
    mov #tbloffset(lastbut1), w1
    call tx_str_232

	mov #stored_status+36, w13
	call print_status

    mov #tblpage(lastbut0), w0
    mov #tbloffset(lastbut0), w1
    call tx_str_232

	mov #stored_status+0, w13
	call print_status
	
;------------------------------------------------------
;z) clear_all
;------------------------------------------------------
msg_a:
    mov #tblpage(mes_a), w0
    mov #tbloffset(mes_a), w1
    call tx_str_232

    bra msg_z
opt_a:
	
	mov #stored_status, w13
;	mov #1000, w10
	
	repeat #63
	clr [w13++]
	
    bra menu_start
	
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
msg_z:
    mov #tblpage(mes_z), w0
    mov #tbloffset(mes_z), w1
    call tx_str_232

    bra msg_choise
opt_z:
    return

;------------------------------------------------------
msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, opt_a
    mov #'z', w1
    cp w0, w1
    bra z, opt_z

    bra menu_start

;**********************************************************

lastbut3:
	.pascii "\n\n\n Last but 2 entry into drive_1:\n\0"
lastbut2:
	.pascii "\n\n\n Last but 1 entry into drive_1:\n\0"
lastbut1:
	.pascii "\n\n\n Last entry into drive_1:\n\0"
lastbut0:
	.pascii "\n\n\n Chip status at button press:\n\0"
mes_a:
	.pascii "\n\n\na) clear all\0"
mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"



.end

