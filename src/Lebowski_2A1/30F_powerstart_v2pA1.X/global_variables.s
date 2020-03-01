; for debug
;.bss
	
.include "defines.inc"
	
.section *,bss ,address (0x800)

.global data_array_sin
data_array_sin:         .space 512				;256 * 16 bits

.section *,bss ,address (0xA00)

.global phi_motor
phi_motor:							.space 4	;current rotor position for applying power
.global phi_motor_magbased
phi_motor_magbased:     .space 4                ;current rotor position calculated from magnet detection, the +2 holds the previous
.global phi_int
phi_int:                .space 4				;integrator in the sensorless control loop, msb, lsb
.global phi_prop
phi_prop:               .space 4				;proportional phase component coming from loop filter
.global phi_int_max_erpm
phi_int_max_erpm:       .space 4                ;phi_int for max allowed e-rpm (forward and reverse), wanted_i_real is made 0 when this value is exceeded 
.global max_erpm_rampdown
max_erpm_rampdown:		.space 4			;range for rampdown
.global phi_int_max_erpm_shutdown
phi_int_max_erpm_shutdown:.space 2              ;phi_int for max allowed e-rpm, emergency shutdown when out of lock
.global phi_int_2to3
phi_int_2to3:           .space 2                ;phi_int (erpm) for transfer from drive 2 to 3
.global phi_int_3to2
phi_int_3to2:           .space 2                ;phi_int (erpm) for transfer from drive 3 to 2
.global phi_int_direction_change
phi_int_direction_change:.space 2              ;phi_int (erpm) below which a change in direction is accepted

.global phi_int_start_regen
phi_int_start_regen:		.space 2				;phi_int (erpm) above which regen rampup starts
.global regen_rampup
regen_rampup:				.space 2				;range for regen rampup

.global phi_int_hall_measure
phi_int_hall_measure:		.space 2			;phi_int (erpm) used when measuring hall positions


.global ampli_real                              ;amplitude of the to the motor delivered voltage, real part
ampli_real:             .space 4				;range: -1..1 
.global ampli_imag                              ;amplitude of the to the motor delivered voltage, imaginary part for timing advance
ampli_imag:             .space 4				;range: -1..1 
.global ampli_prop                              ;amplitude of the to the motor delivered voltage, proportional part
ampli_prop:             .space 2
.global ampli_imag_prop                         ;amplitude of the to the motor delivered voltage, proportional part
ampli_imag_prop:       .space 2
.global ampli_fw                                ;amplitude (0..1) at which field weakening starts
ampli_fw:              .space 2

.global i_force_regen
i_force_regen:          .space 2                ;current used to force regen
.global i_error_max_fixed
i_error_max_fixed:       .space 2                ;absolute 0.75 * imaginary phase current, Q15 signed
.global i_error_max_prop
i_error_max_prop:        .space 2                ;absolute 0.75 * imaginary phase current, Q15 signed

.global wir_thr
wir_thr:          .space 2                ;0.75 * real wanted phase current, Q15, 500 Lsb/Amp for 100mV/A sensors
.global wanted_i_real
wanted_i_real:          .space 2                ;0.75 * real wanted phase current, Q15, 500 Lsb/Amp for 100mV/A sensors
.global wanted_i_imag
wanted_i_imag:          .space 2                ;0.75 * imag wanted phase current (field weakening), Q15, 500 Lsb/Amp for 100mV/A sensors
.global phi_motor_prev
phi_motor_prev:           .space 2                ;motor position from previous loop, for speed measurment in certain routines

.global adc_current_offset                      ;very very low frequency filtered offset for current sensors
adc_current_offset:     .space 6
.global adc_current_offset_lsbs                 ;used for filtering the offset (only in drive 3)
adc_current_offset_lsbs: .space 6
.global adc_current_prev                        ;previous ADC (current) readings for FIR filtering
adc_current_prev:       .space 6
.global adc_current_polarity
adc_current_polarity:		.space 2			;XOR-ed with ADC readings (0x0000 or 0x03FF) to implement polarity
	   
.global pwm_period
pwm_period:             .space 2				;pwm frequency = 15000 / pwm_period
.global pwm_period_rec
pwm_period_rec:         .space 2				;pwm_period_rec [ns] = 33 * pwm_period_rec  (for during recovery)
.global pwm_deadtime
pwm_deadtime:           .space 2				;deadtime in ns = 33 * pwm_deadtime

.global main_loop_count
main_loop_count:        .space 2                ;loop frequency = 30000 / main_loop_count
.global counter
counter:                .space 4                ;general counter(s) for use in all kinds of subroutines
.global cycles_2to3
cycles_2to3:             .space 2               ;minimum amount of cycles to spend in drive 2to3
.global cycles_try_recov
cycles_try_recov:        .space 2               ;amount of cycles to try to recover in dr1_rec

.global monitoring_value
monitoring_value:   	.space 2                ;once in monitoring_value data is send over RS232 during motor use
.global monitoring_count
monitoring_count:   	.space 2                ;counter for monitoring
.global tx_var_address
tx_var_address:         .space 2				;address of variable that will be tx-ed during running motor

.global flags1
flags1:                 .space 2                ;general flags1
.global flags2
flags2:                 .space 2                ;general flags2
.global flags_rom
flags_rom:              .space 2                ;flags read from rom
.global flags_rom2
flags_rom2:              .space 2                ;flags read from rom
.global flags_CAN
flags_CAN:              .space 2                ;flags rx-ed / tx-ed via CAN bus

.global str_buf
str_buf:                .space 70				;70 bytes

.global filter_I
filter_I:               .space 4                ;integrator state filter, used for filtering i_real, for FOC timing advance
.global filter_Q
filter_Q:               .space 4                ;integrator state filter, used for filtering i_imag, for FOC timing advance
.global filter_I_error
filter_I_error:         .space 4                ;integrator states 2nd order filter, channel Q, used for filtering error current in drive 3
.global filter_spd
filter_spd:             .space 4                ;integrator states 2nd order filter, motor speed during drive 2
.global filter_inv_vbat
filter_inv_vbat:        .space 4                ;integrator states 2nd order filter, inverse v_battery calculation, 16 bit per stage, first 2nd stage then 1st stage
.global inv_vbat0
inv_vbat0:               .space 2                ;filter_inv_vbat at time of impedance measurement
.global filter_w8
filter_w8:               .space 4                ;filters w8 for i_total in drive_2, drive_2to3
.global filter_w9
filter_w9:               .space 4                ;filters w9 for i_total in drive_2, drive_2to3
.global filter_wir
filter_wir:               .space 4               ;filters wanted_i_real for i_total comparison in drive_2, drive_2to3
.global filter_hallX
filter_hallX:            .space 32               ;filters for the 8 X coordinates, hall sensor position measurement, hall code 000 to 111
.global filter_hallY
filter_hallY:            .space 32               ;filters for the 8 Y coordinates, hall sensor position measurement, hall code 000 to 111
.global filter_general_coeff
filter_general_coeff:    .space 2                ;coefficient for general all purpose 2nd order filter

.global supply_voltage
supply_voltage:         .space 2                ;raw ADC data for supply measurement
.global battery_voltage
battery_voltage:        .space 2                ;battery voltage as entered in menu, [12.4]V
.global vbat0
vbat0:				      .space 2                ;battery voltage at time of impedance measurement, [12.4]V

.global throttle_raw1
throttle_raw1:          .space 2                ;0..1 linear throttle from AN7, tx-ed over CAN
.global throttle_raw2
throttle_raw2:          .space 2                ;0..1 linear throttle from AN8, tx-ed over CAN
.global throttle
throttle:               .space 2                ;-1..1 , result from polynomal calculation based on throttle_raw1 and throttle_raw2
.global thr_coeff_1
thr_coeff_1:            .space 6                ;-8..8, throttle = 1st * throttle_raw1 + 2nd * throttle_raw1 ^ 2 + 3rd * throttle_raw1 ^ 3
.global thr_coeff_2
thr_coeff_2:            .space 6                ;-8..8, throttle += 1st * throttle_raw2 + 2nd * throttle_raw2 ^ 2 + 3rd * throttle_raw2 ^ 3
.global thr1_offset                             ;throttle_raw1 = (ADC_7 - thr1_offset) / thr1_range
thr1_offset:            .space 2
.global thr1_range
thr1_range:             .space 2
.global thr2_offset                             ;throttle_raw2 = (ADC_8 - thr2_offset) / thr2_range
thr2_offset:            .space 2
.global thr2_range
thr2_range:             .space 2

.global i_max_phase
i_max_phase:            .space 2                ;absolute 0.75 * maximum motor phase current (wanted_I_real = throttle * I_max_phase)
.global i_max_bat_motoruse
i_max_bat_motoruse:     .space 2                ;absolute 0.75 * max battery current during motor use
.global i_max_bat_regenuse
i_max_bat_regenuse:     .space 2                ;absolute 0.75 * max battery current during regen

.global dr0_counter
dr0_counter:            .space 2                ;counter for 10 msec operation
.global dr0_XX_msec
dr0_XX_msec:            .space 2                ;count to be reached for XX msec period time
.global dr0_pulse_duration
dr0_pulse_duration:     .space 2                ;duration of pulse, in 33nsec steps
.global motor_standstill_voltage
motor_standstill_voltage:.space 2               ;standstill detection voltage (0-512 for 0-2.5V), for out of drive_0 transition

.global can_txsid
can_txsid:              .space 2                ;can bus TXSID address
.global can_rxsid
can_rxsid:              .space 2                ;can bus RXSID address
.global can_cfg1
can_cfg1:               .space 2                ;can bus cfg1
.global can_cfg2
can_cfg2:               .space 2                ;can bus cfg2

.global plic_3
plic_3:                   .space 20               ;phase loop integrator coefficients, 3rd order (32b), 2nd order(32b), 1st order prop(16b), 3rd order neg(32b), 2nd order neg(32b), 1st or prop neg(16b)
.global plic_2
plic_2:              	.space 20               ;phase loop integrator coefficients for drive_2 (separate coeffs)
.global plic_1
plic_1:              	.space 20               ;phase loop integrator coefficients for drive_2 (separate coeffs)
.global alic_3
alic_3:                   .space 12               ;amplitude loop integrator coefficients, 2nd order(32b), 1st order prop(16b), 2nd order neg(32b), 1st or prop neg(16b)
.global alic_1
alic_1:                   .space 12               ;amplitude loop integrator coefficients, 2nd order(32b), 1st order prop(16b), 2nd order neg(32b), 1st or prop neg(16b)
				   
.global hall_array
hall_array:            .space 16                ;hall codes for the 8 hall state, 16 bits eachs: 8 bits phase -- 7 bit amplitude -- 1 bit set if used, cleared if not

.global imag_impedance
imag_impedance:         .space 4                ;see equations file
.global imag_impedance_rom
imag_impedance_rom:     .space 4                ;original imag_impedance as read from rom, for drive_1
.global real_impedance
real_impedance:         .space 4                ;see equations file
.global real_impedance_rom
real_impedance_rom:     .space 4                ;original real_impedance as read from rom, for drive_1
.global Z_ratio
Z_ratio:				 .space 2                 ;real_impedance / imag_impedance
 
.global transimpedance
transimpedance:         .space 2                ;current sensor transimpedance, yyyy yyyy.xxxx xxxx milli-Ohm

.global phi_int_for_impedance_measurement
phi_int_for_impedance_measurement:	.space 2    ;for impedance measurement
.global i_inductor_measurement
i_inductor_measurement: .space 2                ;wanted_i_real for inductor measurement

.global class_d_remainder
class_d_remainder:      .space 6

.global fil1ord_i_foc
fil1ord_i_foc:         .space 2                ;w11 coefficient for foc current filtering
.global fil2ord_i_error
fil2ord_i_error:         .space 2                ;w11 coefficient for i_imag filtering for safety routine
.global fil2ord_dr2_motor_speed
fil2ord_dr2_motor_speed:.space 2                ;w11 coefficient for motor speed filtering during drive 2
.global filt_spd_ctrl
filt_spd_ctrl:			 .space 6				;fast speed filter for speed control
.global filt_spd_ctrl_ffcoef
filt_spd_ctrl_ffcoef: .space 2				;fast speed filter bypass coefficient
	
.global phi_wiggle
phi_wiggle:             .space 2                    ;wiggle phase
.global phi_int_wiggle
phi_int_wiggle:         .space 2                    ;phi_int for wiggle
.global ampli_wiggle
ampli_wiggle:           .space 2				;peak-peak wiggle

.global i_min_recov
i_min_recov:            .space 2                 ;when current drops below this a PWM pulse is given.
.global fil2ord_percentage
fil2ord_percentage:     .space 2                ;w11 coefficient for percentage filtering during dr1_rec
.global fil2ord_speed_recovery
fil2ord_speed_recovery: .space 2                ;w11 coefficient for speed filtering during dr1_rec
.global pulse_perc_to_reach
pulse_perc_to_reach:    .space 2                 ;pulse percentage to reach before exit dr1re (1000 = 100%)
.global over_i_total_prop
over_i_total_prop:       .space 2                 ;0-399% for proportional to wanted_i_real factor
.global over_i_total_fixed
over_i_total_fixed:       .space 2                ;fixed part for over_i_total
.global fil2ord_i_meas
fil2ord_i_meas:        .space 2                ;w11 coefficient for w8, w9 filtering during dr2_rec, dr2to3_rec

.global temp_readout
temp_readout:           .space 2                ;address to jump to for the temperature sensor readout
.global temp_stack
temp_stack:             .space 4                ;1 level stack allowing 1 level subroutine call
.global temp_data
temp_data:              .space 16               ;measured temperature or bit counter during identification
.global temp_sens_now
temp_sens_now:          .space 2               ;sensor being processed at the moment (0 = first)
.global temp_crc
temp_crc:                .space 2               ;temp sensor crc calculation
.global temp_counter
temp_counter:            .space 2               ;(bit) counter for temp id TX and scratchpad RX
.global temp_red_i_max_phase
temp_red_i_max_phase:		.space 2				;temperature reduced max phase current
.global temp_data_rxed
temp_data_rxed:			.space 2				;temperature data received, before crc check

.global temp_ids
temp_ids:               .space 64               ;64 bits for 8 sensors
.global number_temp_sensors
number_temp_sensors:    .space 2               ;amount of temp sensors found
.global temp_limit
temp_limit:             .space 16               ;temp limit above which current reduction starts to occur
.global temp_current_red
temp_current_red:       .space 16               ;current reduction in A / half of a degC

.global max_fieldweak_ratio
max_fieldweak_ratio:    .space 2				;max fieldweak current = i_max_phase * max_fieldweak_ratio [positive Q15]
.global fieldweak
fieldweak:		.space 2				;fieldweak current = i_max_phase * abs (fieldweak) [Q15]
.global fwlic
fwlic:			.space 2				;field weakening loop integrator coefficients, 16 bit 2nd, only positive.

.global phi_hf_offset
phi_hf_offset:           .space 2                ;delta phi for hf tone demodulation
.global phi_hf_motor
phi_hf_motor:           .space 2                ;phase for HF signal as sent to motor
.global ampli_hf_motor                          ;amplitude for motor hf signal, as send to motor
ampli_hf_motor:         .space 2
.global wanted_phi_int
wanted_phi_int:		.space 2                 ;phi_int (erpm) to be reached during automatic measurements				 			

.global count_ldm
count_ldm:			.space 4                 ;#cycles spent in last drive mode, lsw first, msw second				 			
.global count_tot
count_tot:			.space 4                 ;#cycles total on-time, lsw first, msw second				 			

.global stored_status
stored_status:			.space 144                 ;chip status last 4 times entered drive_1, 36 bytes per status				 			

.global	pll_bw
pll_bw:					.space 2					;pll BW in Hz
.global pll_damp
pll_damp:				.space 2					;pll damping, [11.5]
.global pll_coefs
pll_coefs:				.space 4					;pll loop coefficients a0, a1 calculated from BW and damping
.global pll_phi
pll_phi:				.space 4					;pll phase
.global pll_int
pll_int:			    .space 4					;pll phi int
			
.global pred_i_real
pred_i_real:			.space 4				;real part of predicted motor current
.global pred_i_imag
pred_i_imag:			.space 4				;imag part of predicted motor current
.global motor_filt_coeff
motor_filt_coeff:		.space 2				;motor time constant
.global phase_comp_coeff
phase_comp_coeff:		.space 2				;constant for phase loop step response
.global phi_step
phi_step:              .space 2				;step in phi_motor update to be compensated for in motor_sinus
.global phi_step_int
phi_step_int:           .space 2				;step in phi_motor update to be compensated for in motor_sinus, integrated
.global phi_step_max
phi_step_max:           .space 2				;max step in phi_motor update
					
.global ampli_lower_limit                       ;amplitude at which throttle rampdown begins
ampli_lower_limit:    .space 2				;range: -1..1 
.global ampli_upper_limit                       ;amplitude at which throttle is completely ramped down to 0
ampli_upper_limit:    .space 2				;range: -1..1 
.global ampli_rampdown                          ;coefficient for auto reduction of throttle based on ampli_real
ampli_rampdown:        .space 2				    

.global filter_vbat
filter_vbat:           .space 4                ;integrator state 1st order filter
.global vbat_filt_coeff
vbat_filt_coeff:		.space 2				;2^8 * battery filter time constant
.global volt_scale
volt_scale:			.space 2				;vbat[12.4] = 2^-16 * volt_scale * filter_vbat
.global hvc_cutoff
hvc_cutoff:			.space 2				; = 2^-16 * volt_scale * hvc_vutoff_in_V[12.4]
.global hvc_start
hvc_start:			    .space 2				; = 2^-16 * volt_scale * hvc_start_i_reduction_in_V[12.4], should be lower than hvc_cutoff
.global hvc_ramp
hvc_ramp:			    .space 2				; = 2^16 / |hvc_cutoff - hvc_start|
.global lvc_cutoff
lvc_cutoff:			.space 2				; = 2^-16 * volt_scale * lvc_vutoff_in_V[12.4]
.global lvc_start
lvc_start:			    .space 2				; = 2^-16 * volt_scale * lvc_start_i_reduction_in_V[12.4], should be higher than lvc_cutoff
.global lvc_ramp
lvc_ramp:			    .space 2				; = 2^16 / |lvc_cutoff - lvc_start|
		
.global max_accel
max_accel:			    .space 4				; kerpm/sec[8.8] = max_accel * 3.22e6 / (mlc^2)
.global accel_ramp
accel_ramp:			.space 2				; = 2^16 / |max_accel - max_accel+2|
.global filter_accel
filter_accel:          .space 4                ;integrator state 1st order filter
.global accel_filt_coef
accel_filt_coef:       .space 2                ;16 * accelleration filter constant
.global phi_int_prev
phi_int_prev:           .space 4				;integrator in the sensorless control loop, msb, lsb, previous for accelleration filter

.global phi_offset
phi_offset:			.space 2				;angle difference between hall and sensorless at start of dr23hl (is slowly reduced for transition)

.global imp_collect_address
imp_collect_address:	.space 2				;address for imp_collect_data process
.global imp_process_address
imp_process_address:	.space 2				;address for imp_process_data process
		   
.global regA
regA:					.space 2*fp_N			;floating point register
.global regB
regB:					.space 2*fp_N			;floating point register
						
.global data_collected
data_collected:		.space 42				;raw filtering data for impedance measurement, exponent followed by 2 mantissa
.global data_collected_rom
data_collected_rom:	.space 42				;raw filtering data for impedance measurement, as read from ROM, for drive_1 recovery
.global data_for_imp
data_for_imp:			.space 28					;filtered data for matrix inversion, exponent followed by mantissa
.global data_variance_R		
data_variance_R:		.space 16				;variance of w and Ia sampled data
.global data_variance_R_new	
data_variance_R_new:	.space 16
.global data_variance_L		
data_variance_L:		.space 16				;variance of w and Ib sampled data
.global data_variance_L_new	
data_variance_L_new:	.space 16
					
					
.global data_collect_countdown_R
data_collect_countdown_R:	.space 2			;while <> 0 do not use data_collected as we need lots before we can do matrix inversion.
.global data_collect_countdown_L
data_collect_countdown_L:	.space 2			;while <> 0 do not use data_collected as we need lots before we can do matrix inversion.
.global data_collect_countdown_R_rom
data_collect_countdown_R_rom:	.space 2		;as read from rom, for drive_1
.global data_collect_countdown_L_rom
data_collect_countdown_L_rom:	.space 2		;as read from rom, for drive_1
.global data_filt_exponent
data_filt_exponent:	.space 2				;filter coefficient data collection: data_filt_exponent is subtracted from exponent to create filter gain factor
.global data_current_limit_R
data_current_limit_R:	.space 2				;data for impedance is only used when (i_real) current is higher than specified here, for KR
.global data_current_limit_L
data_current_limit_L:	.space 2				;data for impedance is only used when (i_real) current is higher than specified here, for L
.global data_speed_limit
data_speed_limit:	.space 2				    ;data for impedance is only used when phi_int is higher than specified here
	
.global Kv
Kv:						.space 4               
.global Kv_rom
Kv_rom:					.space 4               
.global meas_L
meas_L:                 .space 2                
.global meas_R
meas_R:                 .space 2                
.global Va_raw
Va_raw:                 .space 2                
;.global match_KvLR
;match_KvLR:              .space 2       

.global sine_i_imag
sine_i_imag:			.space 2				;additional sine part for i_imag, for impedance measurement            
.global ampl_sine_iimag
ampl_sine_iimag:		.space 4				;amplitude [between 0 and 1] of iimag sine
.global phi_sine_iimag
phi_sine_iimag:		.space 2				;phase of iimag sine
.global phiint_sine_iimag
phiint_sine_iimag:	.space 2				;phase update of iimag sine
		
.global hall_offset
hall_offset:			.space 4				;phase added to raw hall data, forward and reverse
.global hall_stat
hall_stat:				.space 20				;count, fp average, fp average^2, forward and reverse
		
.global menus_completed
menus_completed:		.space 2				;bits are unset based on menus being completed / triggered
		
.global i_filter_offset
i_filter_offset:	.space 2		           ;when i_real < i_offset_filter, use ADC info to filter offset (only in drive 3)
		
.global post_dr1_ramp
post_dr1_ramp:			.space 4					;ramping of throttle after conkout
.global post_dr1_incr
post_dr1_incr:			.space 4					;increment for ramping of throttle after conkout
.global	post_dr1_time
post_dr1_time:			.space 2					;time [4.12] in seconds how long the ramp takes
		
.global dummy1
dummy1:                 .space 2                
.global dummy2
dummy2:                 .space 2                

.end
