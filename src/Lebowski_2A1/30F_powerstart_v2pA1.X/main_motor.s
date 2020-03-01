.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global main_motor
main_motor:
;---------------------------------------------- set motoring bit
    bset flags1, #motor_mode
;---------------------------------------------- initialise
    call initialise
;---------------------------------------------- start with drive_0	
    goto initialise_drive_0_all
	
;*****************************************************************

.end

