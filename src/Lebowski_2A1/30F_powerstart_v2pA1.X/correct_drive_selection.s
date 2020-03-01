.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global correct_drive_2
correct_drive_2:
	
;--------------------------------------- maybe force drive_2_sensorless, only when allow_rom_write
	btss flags_rom, #allow_rom_write
	bra no_force_dr2
											;force drive_2_sensorless when flags_rom, #calib_halls set
	btsc flags_rom, #calib_halls
	goto initialise_drive_2_sensorless
	
no_force_dr2:	
;--------------------------------------- drive_2_hall when selected	
	
	btsc flags_rom, #hall_mode
	goto initialise_drive_2_hall
	
;--------------------------------------- drive_2_sensorless as last resort
	goto initialise_drive_2_sensorless

	
;*****************************************************************

.global correct_drive_2to3
correct_drive_2to3:
;--------------------------------------- maybe force drive_2to3_sensorless, only when allow_rom_write
	btss flags_rom, #allow_rom_write
	bra no_force_dr2to3
											;force drive_2to3_sensorless when flags_rom, #calib_halls set
	btsc flags_rom, #calib_halls
	goto initialise_drive_2to3_sensorless
	
no_force_dr2to3:	
;--------------------------------------- drive_2to3_hall when selected	
	
	btsc flags_rom, #hall_mode
	goto initialise_drive_2to3_hall
	
;--------------------------------------- drive_2to3_sensorless as last resort
	goto initialise_drive_2to3_sensorless
	
;*****************************************************************

.global correct_drive_3
correct_drive_3:

;--------------------------------------- when selected: go to drive_3_hall_measure
	btss flags_rom, #allow_rom_write
	bra no_force_dr3
	
	btsc flags_rom, #calib_halls
	goto initialise_drive_3_hall_measure

;--------------------------------------- else go to the normal one. 
no_force_dr3:
    goto initialise_drive_3_all
	
;*****************************************************************

.end

