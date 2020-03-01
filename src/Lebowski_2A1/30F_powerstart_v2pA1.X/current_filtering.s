.include "p30F4011.inc"
.include "defines.inc"
.include "macros.mac"

.text

;*****************************************************************

.global current_filtering
current_filtering:
	
;--------------------------------------- filter i_real for FOC and measurement
	mov w8, filter_I
	
	mov #filter_w8, w13
    mov fil2ord_i_meas, w11
    filter w8	

;--------------------------------------- filter i_imag for FOC and measurement
	mov w9, filter_Q

    mov #filter_w9, w13
    filter w9
	
;--------------------------------------- filter wanted_i_real with dr23 error current filter, for proportional error current part
	
	mov wanted_i_real, w0
    mov #filter_wir, w13
    filter w0
	
;--------------------------------------- filter 1/V_battery
	
    call inverse_vbat

;--------------------------------------- filter V_battery
	
	mov #filter_vbat, w13
	mov supply_voltage, w0
	sl w0, #6, w0							;times 64 as ADC outputs raw integer
											;calc difference, mult with coeff						
	sub w0, [w13], w0
	mov vbat_filt_coeff, w1
	mul.us w1, w0, w2
											;times 2^-8
	lsr w2, #8, w0
	sl w3, #8, w1
	ior w0, w1, w0
	asr w3, #8, w1
											;add to filter integrator
	add w0, [++w13], [w13]
	addc w1, [--w13], [w13]
	
;--------------------------------------- end
	
    return

;*****************************************************************
	
	
	
	
.end
