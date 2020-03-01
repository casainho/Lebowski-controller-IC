.include "p30F4011.inc"
.include "defines.inc"

.text


.global report_checksum
report_checksum:
						
;---------------------------------------------- initialise

    clr w4
    clr w5
    clr w6

    clr TBLPAG
;---------------------------------------------- compute checksum over variables to negate their effect

    mov #tbloffset(setup_rom) + 1024, w13

rech_var_lp:

    tblrdl [w13], w0
    tblrdh [w13], w1
    ze w1, w1

    xor w4, w0, w4
    xor w6, w1, w6

    dec2 w13, w13
    mov #tbloffset(setup_rom) - 2, w0
    cp w13,w0
    bra z, rech_full

    tblrdl [w13], w0
    tblrdh [w13], w1
    sl w1, #8, w1

    xor w5, w0, w5
    xor w6, w1, w6

    dec2 w13, w13
    mov #tbloffset(setup_rom) - 2, w0
    cp w13,w0
    bra nz, rech_var_lp

;---------------------------------------------- start from beginning
rech_full:

    mov #0x7FFC, w13                                ;program memory address

;---------------------------------------------- loop over 32 kB
rech_lp:

;---------------------------------------------- read memory and xor with checksum variables

    tblrdl [w13], w0
    tblrdh [w13], w1
    ze w1, w1

    xor w4, w0, w4
    xor w6, w1, w6

    dec2 w13, w13
    bra n, rech_lpend

    tblrdl [w13], w0
    tblrdh [w13], w1
    sl w1, #8, w1

    xor w5, w0, w5
    xor w6, w1, w6

    dec2 w13, w13
    bra n, rech_lpend

;---------------------------------------------- next iteration

    bra rech_lp

;---------------------------------------------- print checksum message
rech_lpend:
	
    mov #tblpage(checksum_msg), w0
    mov #tbloffset(checksum_msg), w1
    call tx_str_232

;---------------------------------------------- print checksum output

    mov w4, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #' ', w0
    call tx_char_232

    mov w5, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #' ', w0
    call tx_char_232

    mov w6, w0
    mov #str_buf, w1
    call word_to_hex_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #'\n', w0
    call tx_char_232
    mov #'\n', w0
    call tx_char_232

;---------------------------------------------- wait for any key

    call rx_char_232

;---------------------------------------------- end						

    return

checksum_msg:
	.pascii "\n\n CHECKSUM : \0"

.end

