.include "p30F4011.inc"
.include "defines.inc"

.text
.global menu_loop_coeffs
;
;sine array and angle accurate must have been initalised before coming here !
;
menu_loop_coeffs:
    call clr_scr_232
;------------------------------------------------------
;a) autocomplete
;------------------------------------------------------
    mov #tblpage(mlc_mes_a), w0
    mov #tbloffset(mlc_mes_a), w1
    call tx_str_232

    bra mlc_msg_b

mlc_opt_a:
;------------------------------------------------------ set ampli_lower_limit to 98%, ampli_upper_limit to 100%
    mov #32046, w0
    mov w0, ampli_lower_limit    
	mov #32700, w0
    mov w0, ampli_upper_limit
;------------------------------------------------------ phase coefficients, drive 3
                                                        ;0.3, 24, 480
    mov #0, w0
    mov w0, plic_3
    mov #19661, w0
    mov w0, plic_3+2
    mov #24, w0
    mov w0, plic_3+4
    mov #0, w0
    mov w0, plic_3+6
    mov #480, w0
    mov w0, plic_3+8
                                                        ;make negative phase loop coeffs
    mov plic_3+0, w0
    mov plic_3+2, w1
    com w0, w0
    neg w1, w1
    addc #0, w0
    mov w0, plic_3+10
    mov w1, plic_3+12

    mov plic_3+4, w0
    mov plic_3+6, w1
    com w0, w0
    neg w1, w1
    addc #0, w0
    mov w0, plic_3+14
    mov w1, plic_3+16

    mov plic_3+8, w0
    neg w0, w0
    mov w0, plic_3+18
;------------------------------------------------------ phase coefficients, drive 2
                                                        ;0.03, 24, 480
    mov #0, w0
    mov w0, plic_2
    mov #1966, w0
    mov w0, plic_2+2
    mov #24, w0
    mov w0, plic_2+4
    mov #0, w0
    mov w0, plic_2+6
    mov #480, w0
    mov w0, plic_2+8
                                                        ;make negative phase loop coeffs
    mov plic_2+0, w0
    mov plic_2+2, w1
    com w0, w0
    neg w1, w1
    addc #0, w0
    mov w0, plic_2+10
    mov w1, plic_2+12

    mov plic_2+4, w0
    mov plic_2+6, w1
    com w0, w0
    neg w1, w1
    addc #0, w0
    mov w0, plic_2+14
    mov w1, plic_2+16

    mov plic_2+8, w0
    neg w0, w0
    mov w0, plic_2+18

;------------------------------------------------------ amplitude coefficients
                                                        ;10, 200
    mov #100, w0
    mov w0, alic_3+4
    
    mov #5, w0
    mov w0, alic_3+0
    mov #0, w0
    mov w0, alic_3+2
                                                        ;generate negative coefficients
    mov alic_3+4, w0
    neg w0, w0
    mov w0, alic_3+10

    mov alic_3+0, w0
    mov alic_3+2, w1
    com w0, w0
    neg w1, w1
    addc #0, w0
    mov w0, alic_3+6
    mov w1, alic_3+8
	
;------------------------------------------------------ field weakening coefficients
	
	mov #5, w0
	mov w0, fwlic
	
;------------------------------------------------------ invoke field weakening at 95%
	
    mov #31070, w0
    mov w0, ampli_fw

;------------------------------------------------------ max step at twice 2nd order loop coeff
	
	mov #48, w0	    
	mov w0, phi_step_max
		
	bclr menus_completed, #mc_coeffs
	
    bra menu_loop_coeffs

;------------------------------------------------------
;b) 1st order:
;------------------------------------------------------
mlc_msg_b:
    mov #tblpage(mlc_mes_b), w0
    mov #tbloffset(mlc_mes_b), w1
    call tx_str_232

    mov plic_3+8, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_c

mlc_opt_b:

    mov #5, w0
    call get_number
    mov w0, plic_3+8
    neg w0, w0
    mov w0, plic_3+18

    bra menu_loop_coeffs

;------------------------------------------------------
;c) 2nd order:
;------------------------------------------------------
mlc_msg_c:
    mov #tblpage(mlc_mes_c), w0
    mov #tbloffset(mlc_mes_c), w1
    call tx_str_232

    mov plic_3+4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov plic_3+6, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_d

mlc_opt_c:
    mov #10, w0
    call get_signed_decimal_number
                                                            ;don't accept negative values
    btsc w0, #15
    bra menu_loop_coeffs

    mov w0, plic_3+4
    mov w1, plic_3+6

    com w0, w0
    neg w1, w1
    addc #0, w0

    mov w0, plic_3+14
    mov w1, plic_3+16

    bra menu_loop_coeffs

;------------------------------------------------------
;d) 3rd order:
;------------------------------------------------------
mlc_msg_d:
    mov #tblpage(mlc_mes_d), w0
    mov #tbloffset(mlc_mes_d), w1
    call tx_str_232

    mov plic_3+0, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov plic_3+2, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_e

mlc_opt_d:
    mov #10, w0
    call get_signed_decimal_number
                                                            ;don't accept negative values
    btsc w0, #15
    bra menu_loop_coeffs

    mov w0, plic_3+0
    mov w1, plic_3+2

    com w0, w0
    neg w1, w1
    addc #0, w0

    mov w0, plic_3+10
    mov w1, plic_3+12

    bra menu_loop_coeffs

;------------------------------------------------------
;e) 1st order:
;------------------------------------------------------
mlc_msg_e:
    mov #tblpage(mlc_mes_e), w0
    mov #tbloffset(mlc_mes_e), w1
    call tx_str_232

    mov plic_2+8, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_f

mlc_opt_e:

    mov #5, w0
    call get_number
    mov w0, plic_2+8
    neg w0, w0
    mov w0, plic_2+18

    bra menu_loop_coeffs

;------------------------------------------------------
;f) 2nd order:
;------------------------------------------------------
mlc_msg_f:
    mov #tblpage(mlc_mes_f), w0
    mov #tbloffset(mlc_mes_f), w1
    call tx_str_232

    mov plic_2+4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov plic_2+6, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_g

mlc_opt_f:
    mov #10, w0
    call get_signed_decimal_number
                                                            ;don't accept negative values
    btsc w0, #15
    bra menu_loop_coeffs

    mov w0, plic_2+4
    mov w1, plic_2+6

    com w0, w0
    neg w1, w1
    addc #0, w0

    mov w0, plic_2+14
    mov w1, plic_2+16

    bra menu_loop_coeffs

;------------------------------------------------------
;g) 3rd order:
;------------------------------------------------------
mlc_msg_g:
    mov #tblpage(mlc_mes_g), w0
    mov #tbloffset(mlc_mes_g), w1
    call tx_str_232

    mov plic_2+0, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov plic_2+2, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_h

mlc_opt_g:
    mov #10, w0
    call get_signed_decimal_number
                                                            ;don't accept negative values
    btsc w0, #15
    bra menu_loop_coeffs

    mov w0, plic_2+0
    mov w1, plic_2+2

    com w0, w0
    neg w1, w1
    addc #0, w0

    mov w0, plic_2+10
    mov w1, plic_2+12

    bra menu_loop_coeffs

;------------------------------------------------------
;h) 1st order:
;------------------------------------------------------
mlc_msg_h:
    mov #tblpage(mlc_mes_h), w0
    mov #tbloffset(mlc_mes_h), w1
    call tx_str_232

    mov alic_3+4, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_i

mlc_opt_h:
    mov #5, w0
    call get_number
    mov w0, alic_3+4
    neg w0, w0
    mov w0, alic_3+10

    bra menu_loop_coeffs

;------------------------------------------------------
;i) 2nd order:
;------------------------------------------------------
mlc_msg_i:
    mov #tblpage(mlc_mes_i), w0
    mov #tbloffset(mlc_mes_i), w1
    call tx_str_232

    mov alic_3+0, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
    mov alic_3+2, w0
    mov #str_buf, w1
    call word_to_01_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_j

mlc_opt_i:
    mov #10, w0
    call get_signed_decimal_number
                                                            ;don't accept negative values
    btsc w0, #15
    bra menu_loop_coeffs

    mov w0, alic_3+0
    mov w1, alic_3+2

    com w0, w0
    neg w1, w1
    addc #0, w0

    mov w0, alic_3+6
    mov w1, alic_3+8

    bra menu_loop_coeffs

;------------------------------------------------------
;j) invoke fieldweakening at amplitude
;------------------------------------------------------
mlc_msg_j:
    mov #tblpage(mlc_mes_j), w0
    mov #tbloffset(mlc_mes_j), w1
    call tx_str_232

    mov ampli_fw, w0
    mov #327, w2
    repeat #17
    div.u w0, w2
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(mlc_mes_j1), w0
    mov #tbloffset(mlc_mes_j1), w1
    call tx_str_232

    bra mlc_msg_k

mlc_opt_j:
    mov #10, w0
    call get_number
    
    bclr w0, #15
    mov #100, w1
    cpslt w0, w1
    mov #100, w0

    mov #327, w1
    mul.uu w0, w1, w0

    mov w0, ampli_fw

    bra menu_loop_coeffs
	
;------------------------------------------------------
;k) reduce throttle from amplitude:
;------------------------------------------------------
mlc_msg_k:
    mov #tblpage(mlc_mes_k), w0
    mov #tbloffset(mlc_mes_k), w1
    call tx_str_232

    mov ampli_lower_limit, w0
    mov #327, w2
    repeat #17
    div.u w0, w2
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(mlc_mes_k1), w0
    mov #tbloffset(mlc_mes_k1), w1
    call tx_str_232

    bra mlc_msg_l

mlc_opt_k:
    mov #10, w0
    call get_number
    
    bclr w0, #15
    mov #100, w1
    cpslt w0, w1
    mov #100, w0

    mov #327, w1
    mul.uu w0, w1, w0

    mov w0, ampli_lower_limit

    bra menu_loop_coeffs
	
;------------------------------------------------------
;l) closed throttle at amplitude:
;------------------------------------------------------
mlc_msg_l:
    mov #tblpage(mlc_mes_l), w0
    mov #tbloffset(mlc_mes_l), w1
    call tx_str_232

    mov ampli_upper_limit, w0
    mov #327, w2
    repeat #17
    div.u w0, w2
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    mov #tblpage(mlc_mes_l1), w0
    mov #tbloffset(mlc_mes_l1), w1
    call tx_str_232

    bra mlc_msg_m

mlc_opt_l:
    mov #10, w0
    call get_number
    
    bclr w0, #15
    mov #100, w1
    cpslt w0, w1
    mov #100, w0

    mov #327, w1
    mul.uu w0, w1, w0

    mov w0, ampli_upper_limit

    bra menu_loop_coeffs
	
;------------------------------------------------------
;m) 2nd order:
;------------------------------------------------------
mlc_msg_m:
    mov #tblpage(mlc_mes_m), w0
    mov #tbloffset(mlc_mes_m), w1
    call tx_str_232

    mov fwlic, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_n

mlc_opt_m:
    mov #10, w0
    call get_number
											;make 1st order coefficient 0
    mov w0, fwlic

    bra menu_loop_coeffs
	
;------------------------------------------------------
;n) additional motor phase compensation:
;------------------------------------------------------
	
mlc_msg_n:
    mov #tblpage(mlc_mes_n), w0
    mov #tbloffset(mlc_mes_n), w1
    call tx_str_232

	mov phi_step_max, w0
    mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232

    bra mlc_msg_z

mlc_opt_n:
	cp0 phase_comp_coeff
	bra z, 1f
	
    mov #tblpage(mlc_mes_ns), w0
    mov #tbloffset(mlc_mes_ns), w1
    call tx_str_232
	
	clr w1
	mov #32700, w0
	mov phase_comp_coeff, w2
	repeat #17
	div.ud w0, w2
	
	mov #str_buf, w1
    call word_to_udec_str
    mov #str_buf, w0
    call tx_ram_str_232
	
	mov #'\n', w0
	call tx_char_232
1:	
	mov #10, w0
    call get_number

    mov w0, phi_step_max

    bra menu_loop_coeffs
	
;------------------------------------------------------
;z) return to main menu
;------------------------------------------------------
mlc_msg_z:
    mov #tblpage(mlc_mes_z), w0
    mov #tbloffset(mlc_mes_z), w1
    call tx_str_232

    bra mlc_msg_choise
mlc_opt_z:
    return

;------------------------------------------------------
mlc_msg_choise:

    call get_choise

    mov #'a', w1
    cp w0, w1
    bra z, mlc_opt_a
    mov #'b', w1
    cp w0, w1
    bra z, mlc_opt_b
    mov #'c', w1
    cp w0, w1
    bra z, mlc_opt_c
    mov #'d', w1
    cp w0, w1
    bra z, mlc_opt_d
    mov #'e', w1
    cp w0, w1
    bra z, mlc_opt_e
    mov #'f', w1
    cp w0, w1
    bra z, mlc_opt_f
    mov #'g', w1
    cp w0, w1
    bra z, mlc_opt_g
    mov #'h', w1
    cp w0, w1
    bra z, mlc_opt_h
    mov #'i', w1
    cp w0, w1
    bra z, mlc_opt_i
    mov #'j', w1
    cp w0, w1
    bra z, mlc_opt_j
    mov #'k', w1
    cp w0, w1
    bra z, mlc_opt_k
	mov #'l', w1
    cp w0, w1
    bra z, mlc_opt_l
	mov #'m', w1
    cp w0, w1
    bra z, mlc_opt_m
	mov #'n', w1
    cp w0, w1
    bra z, mlc_opt_n

    mov #'z', w1
    cp w0, w1
    bra z, mlc_opt_z

    bra menu_loop_coeffs

;**********************************************************

mlc_mes_a:
    .pascii "\na) autocomplete\n\0"
mlc_mes_b:
    .pascii "\n  phase control loop, drive 3"
    .pascii "\nb) 1st order: \0"
mlc_mes_c:
    .pascii "\nc) 2nd order: \0"
mlc_mes_d:
    .pascii "\nd) 3rd order: \0"
mlc_mes_e:
    .pascii "\n  phase control loop, drive 2"
    .pascii "\ne) 1st order: \0"
mlc_mes_f:
    .pascii "\nf) 2nd order: \0"
mlc_mes_g:
    .pascii "\ng) 3rd order: \0"
mlc_mes_h:
    .pascii "\n  amplitude control loop"
    .pascii "\nh) 1st order: \0"
mlc_mes_i:
    .pascii "\ni) 2nd order: \0"
mlc_mes_j:
    .pascii "\nj) invoke fieldweakening at amplitude: \0"
mlc_mes_j1:
    .pascii " %\0"
mlc_mes_k:
    .pascii "\nk) reduce throttle from amplitude: \0"
mlc_mes_k1:
    .pascii " %\0"
mlc_mes_l:
    .pascii "\nl) to closed throttle at amplitude: \0"
mlc_mes_l1:
    .pascii " %\0"
mlc_mes_m:
    .pascii "\n  field weakening control loop"
	.pascii "\nm) 2nd order: \0"
mlc_mes_n:
    .pascii "\n  miscellaneous"
	.pascii "\nn) immediate motor phase step: \0"
mlc_mes_ns:
	.pascii "\nmax value before overflow: \0"
mlc_mes_z:
    .pascii "\n\nz) return to main menu"
    .pascii "\n\n\0"



.end

