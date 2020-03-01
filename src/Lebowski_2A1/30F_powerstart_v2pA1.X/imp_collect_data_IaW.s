.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"

.macro ICD_return_main

    mov #6, w0
    add PCL, wreg
    mov w0, imp_collect_address
    return

.endm

;.macro led_on
;	bset LATD, #2
;.endm
;.macro led_off
;	bclr LATD, #2
;.endm
	
.text

;*****************************************************************	

.global reset_collect_imp_data
reset_collect_imp_data:
	
	mov #tbloffset(imp_collect_data), w0
    mov w0, imp_collect_address
	
	bclr flags1, #valid_data_imp_meas
											;clear data variances
	mov #data_variance, w13
	repeat #11
	clr [w13++]
clr dummy1	
	return
	
;*****************************************************************	
.global store_imp_data
store_imp_data:
											;store collected data
	mov #data_collected, w12
	mov #data_collected_rom, w13
	repeat #32
	mov [w12++], [w13++]
											;store impedance data
	mov #real_impedance, w12
	mov #real_impedance_rom, w13
	reg_copy
	
	mov #imag_impedance, w12
	mov #imag_impedance_rom, w13
	reg_copy
											;store data collection counter
	mov data_collect_countdown, w0
	mov w0, data_collect_countdown_rom
	
	return
	
;*****************************************************************	
.global restore_imp_data
restore_imp_data:
											;restore collected data
	mov #data_collected_rom, w12
	mov #data_collected, w13
	repeat #32
	mov [w12++], [w13++]
											;restore impedance data
	mov #real_impedance_rom, w12
	mov #real_impedance, w13
	reg_copy
	
	mov #imag_impedance_rom, w12
	mov #imag_impedance, w13
	reg_copy
											;restore impedance derived data
	call calc_impedance_based_coeffs																			
											;restore data collection counter
	mov data_collect_countdown_rom, w0
	mov w0, data_collect_countdown
											
	return
	
;*****************************************************************	
	
.global imp_collect_data
imp_collect_data:
;--------------------------------------- check if data valid

	ICD_return_main	
	
	btss flags1, #valid_data_imp_meas
	bra imp_collect_data
											;I_real must be higher than specified
	mov filter_I+4, w0
	btsc w0, #15
	neg w0, w0
	cp data_current_limit
	bra gt, imp_collect_data
											;phi_int must be higher than specified
	mov phi_int, w0
	btsc w0, #15
	neg w0, w0
	cp data_speed_limit
	bra gt, imp_collect_data
	
;--------------------------------------- capture data and convert to fp
											;1/inv_vbat to reg1
	lsr filter_inv_vbat, wreg
	mov w0, reg1+2
	mov #1, w0
	mov w0, reg1
	
	mov #reg1, w13
	call fp_oneover 
											;V_real to Va, * 1/invvbat
	mov ampli_real, w0
;	add ampli_prop, wreg
	signed_w0_to_fp Va
	mov #Va, w13
	mov #reg1, w12
	call fp_mult
											;V_imag to Vb, * 1/invvbat
	signed_to_fp ampli_imag Vb
	mov #Vb, w13
	mov #reg1, w12
	call fp_mult
											;I_real to Ia
	signed_to_fp filter_I+4 Ia
											;I_imag to Ib
	signed_to_fp filter_Q+4 Ib
											;phi_int to w
	mov phi_int, w3
	mov phi_int+2, w2
;	mov phi_step, w0
;	add w3, w0, w3
	signed32_w3w2_to_fp w
	
	ICD_return_main		
;--------------------------------------- calc new data variances
											;calc differences
	mov #data_variance, w12
	mov #data_variance_new, w13
	do #5, 1f
	mov [w12++], [w13++]
	neg [w12++], [w13++]
	btsc SR, #OV
	com [--w13], [w13++]
1:
	nop
	
	mov #w, w12
	mov #data_variance_new+varw, w13
	call fp_add
	
	mov #w, w12
	mov #reg1, w13
	reg_copy
	call fp_mult
	ICD_return_main			
	mov #reg1, w12
	mov #data_variance_new+varw2, w13
	call fp_add

	mov #Ia, w12
	mov #data_variance_new+varIa, w13
	call fp_add
	
	mov #Ia, w12
	mov #reg1, w13
	reg_copy
	call fp_mult
	ICD_return_main			
	mov #reg1, w12
	mov #data_variance_new+varIa2, w13
	call fp_add

	mov #Ib, w12
	mov #data_variance_new+varIb, w13
	call fp_add
	
	mov #Ib, w12
	mov #reg1, w13
	reg_copy
	call fp_mult
	ICD_return_main		
	mov #reg1, w12
	mov #data_variance_new+varIb2, w13
	call fp_add
											;mult with gain factor, 1/32
	mov #-5, w0
	add data_variance_new+varw
	add data_variance_new+varw2
	add data_variance_new+varIa
	add data_variance_new+varIa2
	add data_variance_new+varIb
	add data_variance_new+varIb2
											;add to originals
	mov #data_variance+varw, w12
	mov #data_variance_new+varw, w13
	call fp_add
									
	mov #data_variance+varw2, w12
	mov #data_variance_new+varw2, w13
	call fp_add
	ICD_return_main		

	mov #data_variance+varIa, w12
	mov #data_variance_new+varIa, w13
	call fp_add
										
	mov #data_variance+varIa2, w12
	mov #data_variance_new+varIa2, w13
	call fp_add
										
	mov #data_variance+varIb, w12
	mov #data_variance_new+varIb, w13
	call fp_add
										
	mov #data_variance+varIb2, w12
	mov #data_variance_new+varIb2, w13
	call fp_add	
	
	ICD_return_main		
							
;--------------------------------------- check how many count as a new data point
											;valid if Ex2 - (1+alpha^2)*E2x > 0
											;use alpha = 10%
	clr reg2
											;process w
	mov #-14, w0
	mov w0, reg1
	mov #-16548, w0
	mov w0, reg1+2
	mov #data_variance_new+varw, w12
	mov #reg1, w13
	call fp_mult
	call fp_mult
	mov #data_variance_new+varw2, w12
	call fp_add
	btss reg1+2, #15
	inc reg2

	ICD_return_main		
											;process Ia
	mov #-14, w0
	mov w0, reg1
	mov #-16548, w0
	mov w0, reg1+2
	mov #data_variance_new+varIa, w12
	mov #reg1, w13
	call fp_mult
	call fp_mult
	mov #data_variance_new+varIa2, w12
	call fp_add
	btss reg1+2, #15
	inc reg2			
	
	ICD_return_main		
											;process Ib
	mov #-14, w0
	mov w0, reg1
	mov #-16548, w0
	mov w0, reg1+2
	mov #data_variance_new+varIb, w12
	mov #reg1, w13
	call fp_mult
	call fp_mult
	mov #data_variance_new+varIb2, w12
	call fp_add
	btss reg1+2, #15
	inc reg2																			
	
	ICD_return_main		

;--------------------------------------- continue ? If yes update data variances
											;need at least 3 to continue
	mov #3, w0
	cp reg2
	bra lt, imp_collect_data
	
	mov #data_variance_new, w12
	mov #data_variance, w13

	repeat #11
	mov [w12++], [w13++]
inc dummy1	
	
	ICD_return_main		

;--------------------------------------- process Ia^2 + Ib^2	
											;reg1 = Ia^2 + Ib^2
	mov #Ia, w12
	mov #reg1, w13
	reg_copy
	call fp_mult
	
	mov #Ib, w12
	mov #reg2, w13
	reg_copy
	call fp_mult

	mov #reg2, w12
	mov #reg1, w13
	call fp_add
	
	ICD_return_main						
											;and filter
	mov data_filt_exponent, w10
	mov #reg1, w12
	mov #data_collected+3*iatiapibtib, w13
	call filter_collected
	
	ICD_return_main		

;--------------------------------------- process w^2
											;reg2 = w^2
	mov #w, w12
	mov #reg2, w13
	reg_copy
	call fp_mult

	mov data_filt_exponent, w10
	mov #reg2, w12
	mov #data_collected+3*wtw, w13
	call filter_collected

	ICD_return_main		
;--------------------------------------- process w^2 * (Ia^2 + Ib^2)
											;reg1 = w^2 * (Ia^2 + Ib^2)
	mov #reg2, w12
	mov #reg1, w13
	call fp_mult
	
	mov data_filt_exponent, w10
	mov #reg1, w12
	mov #data_collected+3*wtwtiatiapibtib, w13
	call filter_collected
	
	ICD_return_main		
;--------------------------------------- process -w^2 * Ib

	mov #reg2, w13
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]	 
	mov #Ib, w12
	call fp_mult
	
	mov data_filt_exponent, w10
	mov #reg2, w12
	mov #data_collected+3*mwtwtib, w13
	call filter_collected

	ICD_return_main			
;--------------------------------------- process w * Ia
											;reg1 = w * Ia
	mov #w, w12
	mov #reg1, w13
	reg_copy
	mov #Ia, w12
	call fp_mult
	
	mov data_filt_exponent, w10
	mov #reg1, w12
	mov #data_collected+3*wtia, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- process w * Ia * Ib
											;reg1 = w * Ia
	mov #Ib, w12
	mov #reg2, w13
	reg_copy
	mov #reg1, w12
	call fp_mult
	
	mov data_filt_exponent, w10
	mov #reg2, w12
	mov #data_collected+3*wtiatib, w13
	call filter_collected

	ICD_return_main		
;--------------------------------------- process w * Ia * Vb
											;reg1 = w * Ia
	mov #Vb, w12
	mov #reg_wIaVb, w13
	reg_copy
	mov #reg1, w12
	call fp_mult
	
	mov data_filt_exponent, w10
	mov #reg_wIaVb, w12
	mov #data_collected+3*wtiatvb, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- process (w * Ia)^2
											;reg1 = w * Ia
	mov #reg1, w12
	mov #reg2, w13
	reg_copy
	call fp_mult
	
	mov data_filt_exponent, w10
	mov #reg2, w12
	mov #data_collected+3*wtiatwtia, w13
	call filter_collected

	ICD_return_main	
	
;--------------------------------------- are we still in the initialisation phase ?
											;data_count_down = 0 -> initialisation has past, continue with data collection
	cp0 data_collect_countdown
	bra z, continue_data_collection
										
	dec data_collect_countdown
											;if now data_count_down = 0 it means this is the last cycle before normal
											;data collection starts -> initialise M15-M45 with calculated values
											;such that imag_impedance, real_impedance and kv are the start values
											;for the impedance measurement
	cp0 data_collect_countdown
	bra z, init_matrix_output
											;if not 0 then we are in initial data collection and we have to
											;measure an initial kv 'guess' value...
	bra measure_kv
	
continue_data_collection:
;--------------------------------------- process w * Va
											;reg1 = w * Va
	mov #w, w12
	mov #reg1, w13
	reg_copy
	mov #Va, w12
	call fp_mult
	
	mov data_filt_exponent, w10
	mov #reg1, w12
	mov #data_collected+3*wtva, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- process w * Ia * Vb - w * Ib * Va
											;reg1 = w * Va
	mov #reg1, w13
	neg [++w13], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]	 
	mov #Ib, w12
	call fp_mult
											;reg1 = -w * Ib * Va
	mov #reg_wIaVb, w12
	call fp_add
											;reg1 = w * Ia * Vb - w * Ib * Va	
	ICD_return_main	

	mov data_filt_exponent, w10
	mov #reg1, w12
	mov #data_collected+3*wtiatvbmwtibtva, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- process Ia*Va + Ib*Vb

	mov #Ia, w12
	mov #reg1, w13
	reg_copy
	mov #Va, w12
	call fp_mult
	
	mov #Ib, w12
	mov #reg2, w13
	reg_copy
	mov #Vb, w12
	call fp_mult
	
	mov #reg1, w13
	mov #reg2, w12
	call fp_add

	ICD_return_main	
	
	mov data_filt_exponent, w10
	mov #reg1, w12
	mov #data_collected+3*iatvapibtvb, w13
	call filter_collected

	ICD_return_main	
;--------------------------------------- write a copy of output data

;	btsc flags1, #new_matrix_data
;	bra imp_collect_data
	
	mov #data_collected, w12
	mov #data_for_matrix, w13
	
	do #10, 1f
	mov [w12++], [w13++]
	mov [w12++], [w13++]
1:
	inc2 w12, w12
	
	bset flags1, #new_matrix_data

;--------------------------------------- loop
	bra imp_collect_data
	
;*****************************************************************
measure_kv:

											;measure kv (= Va/w)
	mov #w, w12
	mov #reg1, w13
	reg_copy
	call fp_oneover
	
	mov #Va, w12
	call fp_mult						
											;and filter
	mov data_filt_exponent, w10
	mov #reg1, w12
	mov #data_collected+3*vaoverw, w13
	call filter_collected
	
	bra imp_collect_data
	
;*****************************************************************	
;
;kb = 0
;
init_matrix_output:
;--------------------------------------- keep kv in reg2
											;reg2 = kv/0.63 , this corrects for first order filter step response
	mov #data_collected+3*vaoverw, w12
	mov #-14, w0
	mov w0, reg2
	mov #25919, w0
	mov w0, reg2+2
	mov #reg2, w13
	call fp_mult
	
;--------------------------------------- IaVa+IbVb = (Ia^2+Ib^2) * R + w*Ia * kv
	mov #data_collected+3*iatiapibtib, w12
	mov #data_collected+3*iatvapibtvb, w13
	reg_copy
	
	mov #real_impedance, w12
	call  fp_mult
	
	mov #data_collected+3*wtia, w12
	mov #reg1, w13
	reg_copy
	mov #reg2, w12							;reg2 = kv
	call fp_mult

	mov #reg1, w12
	mov #data_collected+3*iatvapibtvb, w13
	call fp_add
	
	ICD_return_main	
;--------------------------------------- wIaVb-wIbVa = w^2(Ia^2+Ib^2) * L + -w^2Ib * kv
	
	mov #data_collected+3*wtwtiatiapibtib, w12
	mov #data_collected+3*wtiatvbmwtibtva, w13
	reg_copy

	mov #imag_impedance, w12
	call fp_mult
	
	mov #data_collected+3*mwtwtib, w12
	mov #reg1, w13
	reg_copy
	
	mov #reg2, w12							;reg2 = kv
	call fp_mult
	
	mov #reg1, w12
	mov #data_collected+3*wtiatvbmwtibtva, w13
	call fp_add

	ICD_return_main		
;--------------------------------------- wVa = wIa * R + -w^2Ib * L + w^2 * kv

	mov #data_collected+3*wtia, w12
	mov #data_collected+3*wtva, w13
	reg_copy
	mov #real_impedance, w12
	call fp_mult
	
	mov #data_collected+3*mwtwtib, w12
	mov #reg1, w13
	reg_copy
	mov #imag_impedance, w12
	call fp_mult
											;last time using kv (reg2), so can be overwritten
	mov #data_collected+3*wtw, w12
	mov #reg2, w13
	call fp_mult
	
	ICD_return_main	
	
	mov #data_collected+3*wtva, w13
	mov #reg1, w12
	call fp_add
	mov #reg2, w12
	call fp_add

	ICD_return_main	
;--------------------------------------- wIaVb = wIaIb * R + w^2*Ia^2 * L

	mov #data_collected+3*wtiatib, w12
	mov #data_collected+3*wtiatvb, w13
	reg_copy
	mov #real_impedance, w12
	call fp_mult
	
	mov #data_collected+3*wtiatwtia, w12
	mov #reg1, w13
	reg_copy
	mov #imag_impedance, w12
	call fp_mult
	
	mov #reg1, w12
	mov #data_collected+3*wtiatvb, w13
	call fp_add

	ICD_return_main	
;--------------------------------------- finished, continue with next data sample	
	bra imp_collect_data

;*****************************************************************
	
filter_collected:
;input in [w12]
;filter integrator in [w13]
;--------------------------------------- determine difference
											;difference to reg_filt
	mov #reg_filt, w11
	mov [w13++], [w11++]
	neg [w13--], [w11--]
	btsc SR, #OV
	com reg_filt+2
	exch w11, w13
	call fp_add
	exch w11, w13
;--------------------------------------- mult with filter coefficient (exponent only)   
	subr w10, [w11], [w11]
;--------------------------------------- add to integrator			
											;which exponent is bigger ?
	mov [w13], w10
    sub w10, [w11], w0
    bra ge, 1f
											;w11_e > w13_e
											;build the two 32 bit words
	mov [w11], w10
	sub w10, [w13], w0
	
	mov [w13+2], w1
	mov [w13+4], w2
	
	asr w1, w0, w3
	lsr w2, w0, w2
	subr w0, #16, w0
	sl w1, w0, w1
	ior w2, w1, w2

	add w3, [++w11], w3
	bra fc_cont
1:	
											;w13_e >= w11_e
											;build the two 32 bit words
	mov [w11+2], w2
											;w13_e >= w11_e, if larger by more than 31, skip alltogether, 
	cp w0, #31
	bra ge, fc_end
	cp w0, #16
	bra lt, fc_small_shift
fc_big_shift:								;shift of 16 bits or more
	asr w2, #15, w3
	sub w0, #16, w0
	asr w2, w0, w2
	bra fc_add
	
fc_small_shift:							;shift of less than 16 bits
	asr w2, w0, w3
	subr w0, #16, w0
	sl w2, w0, w2
	
fc_add:
	mov [w13+2], w1
	mov [w13+4], w0
											;add
	add w0, w2, w2
	addc w1, w3, w3
fc_cont:
											;deal with possible overflow
	bra nov, 1f
	rrc w3, w3
	rrc w2, w2
	inc w10, w10
1:	
											;calculate exponent, shift mantissa
	fbcl w3, w0
    neg w0, w0
	sub w10, w0, w10
	
	sl w3, w0, w3
	sl w2, w0, w1
	subr w0, #16, w0
	lsr w2, w0, w2
	ior w3, w2, w3
											;store
	mov w1, [w13+4]
	mov w3, [w13+2]
	mov w10, [w13]
;--------------------------------------- end
fc_end:
	return
;*****************************************************************
	
.bss
	
w:		.space 4
Va:		.space 4
Vb:		.space 4
Ia:		.space 4
Ib:		.space 4
			
reg1:	.space 4
reg2:	.space 4
reg_wIaVb:	.space 4
reg_filt:	.space 4
	


.end

	