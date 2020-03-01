.include "p30F4011.inc"
.include "defines.inc"
.include "fp_macros.mac"
.include "macros.mac"

.macro ICD_return_main

    mov #6, w0
    add PCL, wreg
    mov w0, imp_collect_address
    return

.endm
	
.text

	
.global process_for_L
process_for_L:	

;--------------------------------------- calc new data variances
											;calc differences
	mov #data_variance_L, w12
	mov #data_variance_L_new, w13
	do #3, 1f
	mov [w12++], [w13++]
	neg [w12++], [w13++]
	btsc SR, #OV
	com [--w13], [w13++]
1:
	nop
	
	mov #w, w12
	mov #data_variance_L_new+varw, w13
	call fp_add
	
	mov #w, w12
	mov #reg1, w13
	reg_copy
	call fp_mult
	ICD_return_main			
	mov #reg1, w12
	mov #data_variance_L_new+varw2, w13
	call fp_add

	mov #Ib, w12
	mov #data_variance_L_new+varIb, w13
	call fp_add
	
	mov #Ib, w12
	mov #reg1, w13
	reg_copy
	call fp_mult
	ICD_return_main		
	mov #reg1, w12
	mov #data_variance_L_new+varIb2, w13
	call fp_add
											;mult with gain factor, 1/64	
	mov #-6, w0

	add data_variance_L_new+varw
	add data_variance_L_new+varw2
	add data_variance_L_new+varIb
	add data_variance_L_new+varIb2
											;add to originals
	mov #data_variance_L+varw, w12
	mov #data_variance_L_new+varw, w13
	call fp_add
	
	ICD_return_main										

	mov #data_variance_L+varw2, w12
	mov #data_variance_L_new+varw2, w13
	call fp_add
										
	mov #data_variance_L+varIb, w12
	mov #data_variance_L_new+varIb, w13
	call fp_add
										
	mov #data_variance_L+varIb2, w12
	mov #data_variance_L_new+varIb2, w13
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
	mov #data_variance_L_new+varw, w12
	mov #reg1, w13
	call fp_mult
	call fp_mult
	mov #data_variance_L_new+varw2, w12
	call fp_add
	btss reg1+2, #15
	inc reg2

	ICD_return_main		
											;process Ib
	mov #-14, w0
	mov w0, reg1
	mov #-17040, w0
	mov w0, reg1+2
	mov #data_variance_L_new+varIb, w12
	mov #reg1, w13
	call fp_mult
	call fp_mult
	mov #data_variance_L_new+varIb2, w12
	call fp_add
	btss reg1+2, #15
	inc reg2																			
	
	ICD_return_main		

;--------------------------------------- continue ? If yes update data variances
											;need at least 2 to continue, else maybe process this data point for R ?
	mov #2, w0
	cp reg2
	bra lt, try_R
	
	mov #data_variance_L_new, w12
	mov #data_variance_L, w13

	repeat #7
	mov [w12++], [w13++]
	
	ICD_return_main		

;--------------------------------------- process w^2Ib^2
	mov #w, w12
	mov #reg1, w13
	reg_copy
	
	mov #Ib, w12
	call fp_mult
	
	mov #reg1, w12
	call fp_mult
											;and filter
	mov #reg1, w12
	mov #data_collected+3*wtwtibtib, w13
	call filter_collected
;--------------------------------------- are we still in the initialisation phase ?
											;data_count_down = 0 -> initialisation has past, continue with data collection
	cp0 data_collect_countdown_L
	bra z, continue_data_collection_L
										
	dec data_collect_countdown_L
											;if now data_count_down = 0 it means this is the last cycle before normal
											;data collection starts -> initialise M15-M45 with calculated values
											;such that imag_impedance, real_impedance and kv are the start values
											;for the impedance measurement
	cp0 data_collect_countdown_L
	bra z, init_matrix_output_L
											;if not 0 then we are in initial data collection, so end
	bra pfl_end
	
continue_data_collection_L:	
	
	ICD_return_main	
;--------------------------------------- process wIb(IaR + wKv - Va)
	mov #Va, w12
	mov #reg1, w13
	mov [w12++], [w13++]
	neg [w12--], [w13--]
	btsc SR, #OV
	com [++w13], [w13--]
	
	mov #w, w12
	mov #reg2, w13
	reg_copy
	mov #Kv, w12
	call fp_mult
	
	mov #reg2, w12
	mov #reg1, w13
	call fp_add
	
	mov #Ia, w12
	mov #reg2, w13
	reg_copy
	
	ICD_return_main	
	
	mov #real_impedance, w12
	mov #reg2, w13
	call fp_mult
	
	mov #reg2, w12
	mov #reg1, w13
	call fp_add
	
	mov #w, w12
	call fp_mult
	mov #Ib, w12
	call fp_mult
	
	ICD_return_main		
	
	mov #reg1, w12
	mov #data_collected+3*bty, w13
	call filter_collected	
	
;--------------------------------------- write a copy of output data
											;only if allowed
	btsc flags1, #new_matrix_data_L
	bra pfl_end										
	
	mov #data_collected+3*wtwtibtib, w12
	mov #data_for_imp+2*wtwtibtib, w13
	
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	inc2 w12, w12
	mov [w12++], [w13++]
	mov [w12++], [w13++]
	
	bset flags1, #new_matrix_data_L

;--------------------------------------- loop
	bra pfl_end
	
init_matrix_output_L:	
;--------------------------------------- bty = w^2Ib^2 * L
	mov #data_collected+3*wtwtibtib, w12
	mov #data_collected+3*bty, w13
	reg_copy
	mov #imag_impedance, w12
	call fp_mult
;--------------------------------------- finished, continue with next data sample	
pfl_end:
	goto imp_collect_data

	
	
	
	
	
.end

	