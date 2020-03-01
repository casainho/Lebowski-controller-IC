.include "p30F4011.inc"
.include "defines.inc"
.include "print_macros.mac"

.text
.global main_menu
main_menu:
    bclr flags1, #motor_mode

    call initialise

    call rx_char_232

mm_top_menu:
    call clr_scr_232

;------------------------------------------------------
;0) mode:
;------------------------------------------------------

    mov #tblpage(top_menu), w0
    mov #tbloffset(top_menu), w1
    call tx_str_232

    btss flags_rom, #sensorless_mode
    bra no_sensorless
    mov #tblpage(mode_sensorless), w0
    mov #tbloffset(mode_sensorless), w1
    bclr flags_rom, #hall_mode
    bclr flags_rom, #hf_mode
    bra cont_0

no_sensorless:
;    btss flags_rom, #hall_mode
;    bra no_hall
    mov #tblpage(mode_hall), w0
    mov #tbloffset(mode_hall), w1
	bset flags_rom, #hall_mode
    bclr flags_rom, #sensorless_mode
    bclr flags_rom, #hf_mode
;    bra cont_0

;no_hall:
;    bset flags_rom, #hf_mode
;    mov #tblpage(mode_hf), w0
;    mov #tbloffset(mode_hf), w1
;    bclr flags_rom, #sensorless_mode
;    bclr flags_rom, #hall_mode

cont_0:
    call tx_str_232
    bra mm_z

mm_top_0:
    mov #0x0007, w0
    and flags_rom, wreg

    lsr w0, w1
    btsc SR, #Z
;    mov #0x0004, w1
    mov #0x0002, w1

    mov #0xFFF8, w0
    and flags_rom, wreg
    ior w0, w1, w0
    mov w0, flags_rom

    bra mm_top_menu

;------------------------------------------------------
; rest of menu
;------------------------------------------------------

mm_z:
    mov #tblpage(top_menu_2), w0
    mov #tbloffset(top_menu_2), w1
    call tx_str_232

	call get_choise

    mov #'0', w1
    cp w0, w1
    bra z, mm_top_0
    mov #'a', w1
    cp w0, w1
    bra z, mm_top_a
    mov #'b', w1
    cp w0, w1
    bra z, mm_top_b
    mov #'c', w1
    cp w0, w1
    bra z, mm_top_c
    mov #'d', w1
    cp w0, w1
    bra z, mm_top_d
    mov #'e', w1
    cp w0, w1
    bra z, mm_top_e
    mov #'f', w1
    cp w0, w1
    bra z, mm_top_f
    mov #'g', w1
    cp w0, w1
    bra z, mm_top_g
    mov #'h', w1
    cp w0, w1
    bra z, mm_top_h
    mov #'i', w1
    cp w0, w1
    bra z, mm_top_i
    mov #'j', w1
    cp w0, w1
    bra z, mm_top_j
    mov #'k', w1
    cp w0, w1
    bra z, mm_top_k
    mov #'l', w1
    cp w0, w1
    bra z, mm_top_l
    mov #'m', w1
    cp w0, w1
    bra z, mm_top_m
    mov #'n', w1
    cp w0, w1
    bra z, mm_top_n
    mov #'o', w1
    cp w0, w1
    bra z, mm_top_o
    mov #'y', w1
    cp w0, w1
    bra z, mm_top_y
    mov #'z', w1
    cp w0, w1
    bra z, mm_top_z
    mov #'%', w1
    cp w0, w1
    bra z, mm_top_checksum
    mov #'!', w1
    cp w0, w1
    bra z, mm_top_chipupdate
	
    bra mm_top_menu

mm_top_a:
    call menu_pwm
    bra mm_top_menu

mm_top_b:
    call menu_currents
    bra mm_top_menu

mm_top_c:
    call menu_throttle
    bra mm_top_menu

mm_top_d:
    call menu_erpms
    bra mm_top_menu

mm_top_e:
    call menu_battery
    bra mm_top_menu

mm_top_f:
    call menu_sensors
    bra mm_top_menu

mm_top_g:
    call menu_loop_coeffs
    bra mm_top_menu

mm_top_h:
    call menu_filters
    bra mm_top_menu

mm_top_i:
    call menu_foc
    bra mm_top_menu

mm_top_j:
    call menu_can
    bra mm_top_menu

mm_top_k:
    call menu_recov
    bra mm_top_menu

mm_top_l:
    call menu_halls
    bra mm_top_menu

mm_top_m:
    call menu_temp
    bra mm_top_menu

mm_top_n:
    call menu_misc
    bra mm_top_menu

mm_top_o:
    call menu_KvLR
    bra mm_top_menu

mm_top_y:
    call menu_stored_status
    bra mm_top_menu

mm_top_z:
	call calc_rom_variables
    call menu_rom
    bra mm_top_menu

mm_top_checksum:
    call report_checksum
    bra mm_top_menu
	
mm_top_chipupdate:
	goto pre_update

.global chip_version
chip_version:
.ascii "2A1_"
	
.section *, code	
top_menu:
    .pascii "\n"
    .pascii "########################################\n"
    .pascii "#   (c)opyright 2017, B.M. Putter      #\n"
    .pascii "#   Adliswil, Switzerland              #\n"
    .pascii "#   bmp72@hotmail.com                  #\n"
    .pascii "#                                      #\n" 
	.pascii "#  version 2.A1                        #\n"
    .pascii "#  experimental, use at your own risk  #\n"
    .pascii "########################################\n"
    .pascii "\n\n"
    .pascii "0) mode: \0"
mode_hf:
    .pascii "HF tone\n\0"
mode_sensorless:
    .pascii "Sensorless\n\0"
mode_hall:
    .pascii "Hall sensored\n\0"
top_menu_2:
    .pascii "a) PWM parameters\n"
    .pascii "b) current settings\n"
    .pascii "c) throttle setup\n"
    .pascii "d) erpm limits\n"
    .pascii "e) battery\n"
    .pascii "f) current sensor calibration\n"
    .pascii "g) control loop coefficients\n"
    .pascii "h) filter bandwidths\n"
    .pascii "i) FOC motor impedance\n"
    .pascii "j) CAN setup\n"
    .pascii "k) recovery\n"
    .pascii "l) hall sensored only\n"
    .pascii "m) temperature sensors\n"
    .pascii "n) miscellaneous\n"
    .pascii "o) online Kv, L and R\n"
	.pascii "y) chip status at last drive_1\n"
    .pascii "z) store parameters in ROM for motor use\n"
    .pascii "\n\0"


.end

