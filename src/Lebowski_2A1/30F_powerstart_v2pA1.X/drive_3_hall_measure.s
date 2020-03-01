.include "p30F4011.inc"
.include "defines.inc"

.text

.global initialise_drive_3_hall_measure
initialise_drive_3_hall_measure:
                                                    ;indicate drive_3 and drive_0
    bset LATC, #15
    bclr LATC, #13
    bclr LATC, #14
    bset LATE, #8
                                                    ;clear shutdown bits
    bclr flags1, #over_i_imag
    bclr flags1, #over_erpm
		
;---------------------------------------------- save variables
													;save and clear max fieldweakening current
	push max_fieldweak_ratio
	clr max_fieldweak_ratio
;---------------------------------------------- spool up to high erpm
													;use phi_int_hall_measure
	mov phi_int_hall_measure, w0
	btsc flags1, #reverse
	neg w0, w0
	mov w0, wanted_phi_int
	mov #10, w0
	mov w0, filt_spd_ctrl_ffcoef

	call to_erpm

;---------------------------------------------- at high erpm, measure
													;- erpm at 100% amplitude, for compensation of magnetic angle
													;- hall positions
	call measure_halls
	
	call build_hall_array

;---------------------------------------------- recover variables
	
	pop max_fieldweak_ratio
	
;---------------------------------------------- end by saving
	goto online_store_in_progmem
	
.end

