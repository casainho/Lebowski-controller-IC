.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"

.macro ICD_return_main

    mov #6, w0
    add PCL, wreg
    mov w0, imp_collect_address
    return

.endm

.text
	
.global process_for_R
process_for_R:	

;--------------------------------------- calc new data variances
											;calc differences
	mov #data_variance_R, w12
	mov #data_variance_R_new, w13
	do #3, 1f
	mov [w12++], [w13++]
	neg [w12++], [w13++]
	btsc SR, #OV
	com [--w13], [w13++]
1:
	nop
	
	mov #w, w12
	mov #data_variance_R_new+varw, w13
	call fp_add
	
	mov #w, w12
	mov #reg1, w13
	reg_copy
	call fp_mult
	ICD_return_main			
	mov #reg1, w12
	mov #data_variance_R_new+varw2, w13
	call fp_add

	mov #Ia, w12
	mov #data_variance_R_new+varIa, w13
	call fp_add
	
	mov #Ia, w12
	mov #reg1, w13
	reg_copy
	call fp_mult
	ICD_return_main			
	mov #reg1, w12
	mov #data_variance_R_new+varIa2, w13
	call fp_add
											;mult with gain factor, 1/64	
	mov #-6, w0

	add data_variance_R_new+varw
	add data_variance_R_new+varw2
	add data_variance_R_new+varIa
	add data_variance_R_new+varIa2
											;add to originals
	mov #data_variance_R+varw, w12
	mov #data_variance_R_new+varw, w13
	call fp_add
									
	mov #data_variance_R+varw2, w12
	mov #data_variance_R_new+varw2, w13
	call fp_add
	ICD_return_main		

	mov #data_variance_R+varIa, w12
	mov #data_variance_R_new+varIa, w13
	call fp_add
										
	mov #data_variance_R+varIa2, w12
	mov #data_variance_R_new+varIa2, w13
	call fp_add
	
	ICD_return_main		
							
;--------------------------------------- check how many count as a new data point
											;valid if Ex2 - (1+alpha^2)*E2x > 0
											;use alpha = 20%
	clr reg2
											;process w
	mov #-14, w0
	mov w0, reg1
	mov #-17040, w0
	mov w0, reg1+2
	mov #data_variance_R_new+varw, w12
	mov #reg1, w13
	call fp_mult
	call fp_mult
	mov #data_variance_R_new+varw2, w12
	call fp_add
	btss reg1+2, #15
	inc reg2

	ICD_return_main		
											;process Ia
	mov #-14, w0
	mov w0, reg1
	mov #-17040, w0
	mov w0, reg1+2
	mov #data_variance_R_new+varIa, w12
	mov #reg1, w13
	call fp_mult
	call fp_mult
	mov #data_variance_R_new+varIa2, w12
	call fp_add
	btss reg1+2, #15
	inc reg2			
	ICD_return_main		

;--------------------------------------- continue ? If yes update data variances
											;need at least 3 to continue
	mov #2, w0
	cp reg2
	bra lt, pfr_end
	
	mov #data_variance_R_new, w12
	mov #data_variance_R, w13

	repeat #7
	mov [w12++], [w13++]	
	
	ICD_return_main		

;--------------------------------------- process Ia^2

	mov #Ia, w12
	mov #reg1, w13
	reg_copy
	call fp_mult				
											;and filter
	mov #reg1, w12
	mov #data_collected+3*iatia, w13
	call filter_collected
	
	ICD_return_main		

;--------------------------------------- process w^2

	mov #w, w12
	mov #reg2, w13
	reg_copy
	call fp_mult

	mov #reg2, w12
	mov #data_collected+3*wtw, w13
	call filter_collected

	ICD_return_main		
	
;--------------------------------------- process w*Ia
	
	mov #Ia, w12
	mov #reg1, w13
	reg_copy
	mov #w, w12
	call fp_mult
	
	mov #reg1, w12
	mov #data_collected+3*wtia, w13
	call filter_collected
	
	ICD_return_main		
	
;--------------------------------------- are we still in the initialisation phase ?
											;data_count_down = 0 -> initialisation has past, continue with data collection
	cp0 data_collect_countdown_R
	bra z, continue_data_collection_R
										
	dec data_collect_countdown_R
											;if now data_count_down = 0 it means this is the last cycle before normal
											;data collection starts -> initialise M15-M45 with calculated values
											;such that imag_impedance, real_impedance and kv are the start values
											;for the impedance measurement
	cp0 data_collect_countdown_R
	bra z, init_matrix_output_R
											;if not 0 then we are in initial data collection and we have to
											;measure an initial kv 'guess' value...
	bra measure_kv
	
continue_data_collection_R:
;--------------------------------------- calculate y = Va+w*Ib*L to reg1 and reg2
											;use only 80% of L to prevent a 'circle' in L calculation
	mov #-15, w0
	mov w0, reg1
	mov #26214, w0
	mov w0, reg1+2
											
	mov #reg1, w13
	mov #imag_impedance, w12
	call fp_mult
	mov #w, w12
	call fp_mult
	mov #Ib, w12
	call fp_mult
	mov #Va, w12
	call fp_add
	
	mov #reg1, w12
	mov #reg2, w13
	reg_copy
	
	ICD_return_main	
/*
	mov #Va, w12
	mov #reg1, w13
	reg_copy
	mov #reg2, w13
	reg_copy
*/	
;--------------------------------------- process y*Ia
			
	mov #Ia, w12
	mov #reg1, w13
	call fp_mult
	
	mov #reg1, w12
	mov #data_collected+3*ytia, w13
	call filter_collected

;--------------------------------------- process y*w
	
	mov #w, w12
	mov #reg2, w13
	call fp_mult
	
	ICD_return_main	

	mov #reg2, w12
	mov #data_collected+3*ytw, w13
	call filter_collected

;--------------------------------------- write a copy of output data
											;only if allowed
	btsc flags1, #new_matrix_data_KR
	bra pfr_end										
	
	mov #data_collected, w12
	mov #data_for_imp, w13
	
	do #4, 1f
	mov [w12++], [w13++]
	mov [w12++], [w13++]
1:
	inc2 w12, w12
	
	bset flags1, #new_matrix_data_KR

;--------------------------------------- loop
	bra pfr_end
	
;*****************************************************************
measure_kv:

											;measure kv (= (Va - Ia*R + Ib*w*L) /w)
	mov #Ia, w12
	mov #reg2, w13
	mov [w12++], [w13++]
	neg [w12--], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]
	mov #real_impedance, w12
	call fp_mult
	
	mov #Ib, w12
	mov #reg1, w13
	reg_copy
	mov #w, w12
	call fp_mult
	mov #imag_impedance, w12
	call fp_mult
	
	mov #reg2, w12
	call fp_add
	
	ICD_return_main		
	
	mov #reg1, w13
	mov #Va, w12
	call fp_add
	
	mov #w, w12
	mov #reg2, w13
	reg_copy
	call fp_oneover
	
	mov #reg1, w12
	call fp_mult			
	
	ICD_return_main	
											;and filter
	mov #reg2, w12
	mov #data_collected+3*vaoverw, w13
	call filter_collected
	
	bra pfr_end
	
;*****************************************************************	
;
;kb = 0
;
init_matrix_output_R:
;--------------------------------------- keep kv in reg2
											;reg2 = kv/0.63 , this corrects for first order filter step response
	mov #data_collected+3*vaoverw, w12
	mov #-14, w0
	mov w0, reg2
	mov #25919, w0
	mov w0, reg2+2
	mov #reg2, w13
	call fp_mult
											;store in Kv for L measurement
	mov #reg2, w12
	mov #Kv, w13
	reg_copy
	
;--------------------------------------- y*Ia = Ia^2 * R + w*Ia * K
									
	mov #data_collected+3*iatia, w12
	mov #data_collected+3*ytia, w13
	reg_copy
	
	mov #real_impedance, w12
	call fp_mult
	
	mov #data_collected+3*wtia, w12
	mov #reg1, w13
	reg_copy
	mov #Kv, w12
	call fp_mult

	mov #reg1, w12
	mov #data_collected+3*ytia, w13
	call fp_add
	
	ICD_return_main	
;--------------------------------------- w*y = w*Ia * R + w^2 * K
											;reg2 = K
	mov #data_collected+3*wtia, w12
	mov #data_collected+3*ytw, w13
	reg_copy

	mov #real_impedance, w12
	call fp_mult
	
	mov #data_collected+3*wtw, w12
	mov #reg2, w13							
	call fp_mult
	
	mov #reg2, w12
	mov #data_collected+3*ytw, w13
	call fp_add

;--------------------------------------- finished, continue with next data sample	
pfr_end:
	goto imp_collect_data

;*****************************************************************
.bss
	

	


.end

	