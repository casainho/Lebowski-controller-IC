.include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_rom
menu_rom:
;------------------------------------------------------
;a) save data to ROM for motor use
;------------------------------------------------------
    mov #tblpage(rom_mes_a), w0
    mov #tbloffset(rom_mes_a), w1
    call tx_str_232

    bra mr_msg_b

mr_opt_a:
    call store_in_progmem

    bra menu_rom

;------------------------------------------------------
;b) print data in HEX format
;------------------------------------------------------
mr_msg_b:
    mov #tblpage(rom_mes_b), w0
    mov #tbloffset(rom_mes_b), w1
    call tx_str_232

    bra mr_msg_c

mr_opt_b:
	mov #tblpage(rom_mes_b1), w0
    mov #tbloffset(rom_mes_b1), w1
    call tx_str_232

    call store_in_ascii

    bra menu_rom

;------------------------------------------------------
;c) enter data in HEX format
;------------------------------------------------------
mr_msg_c:
    mov #tblpage(rom_mes_c), w0
    mov #tbloffset(rom_mes_c), w1
    call tx_str_232

    bra mr_msg_d

mr_opt_c:

    call restore_from_ascii

    bra menu_rom

;------------------------------------------------------
;d) online parameter save:
;------------------------------------------------------
mr_msg_d:
    mov #tblpage(rom_mes_d), w0
    mov #tbloffset(rom_mes_d), w1
    call tx_str_232

    mov #tblpage(rom_mes_en), w0
    mov #tbloffset(rom_mes_en), w1
    btss flags_rom, #allow_rom_write
    mov #tblpage(rom_mes_dis), w0
    btss flags_rom, #allow_rom_write
    mov #tbloffset(rom_mes_dis), w1
    call tx_str_232

    bra mr_msg_z

mr_opt_d:
    btg flags_rom, #allow_rom_write

    bra menu_rom

;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
mr_msg_z:
    mov #tblpage(rom_mes_z), w0
    mov #tbloffset(rom_mes_z), w1
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
    mov #'z', w1
    cp w0, w1
    bra z, mr_opt_z

    bra menu_rom

;**********************************************************

rom_mes_a:
    .pascii "\na) save data to ROM for motor use\0"
rom_mes_b:
    .pascii "\nb) print data in HEX format\0"
rom_mes_b1:
    .pascii "\n save the following HEX lines in a text file, including the '*' termination character\n\n\0"
rom_mes_c:
    .pascii "\nc) enter data in HEX format\0"
rom_mes_d:
    .pascii "\nd) online parameter save: \0"
rom_mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"
rom_mes_en:
    .pascii "enabled\0"
rom_mes_dis:
    .pascii "disabled\0"



.end

