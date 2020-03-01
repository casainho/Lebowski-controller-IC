;bits in flags1

.equiv  tx_allowed,                         0       ;enable tx variable during motor use
.equiv  ADCs_to_current_sensors,            1       ;1 = ADC's to current sensors, 0 = ADC's to motor voltage
.equiv  over_i_imag,                        2       ;1 = error current event, shutdown. 0 = no error current event
.equiv  motor_mode,                         3       ;1 = motor mode, 0 = in the setup menu's
.equiv	new_matrix_data_KR,		    4	    ;1 = new matrix data for K and R, 0 = already processed
.equiv	new_matrix_data_L,		    5	    ;1 = new matrix data for L, 0 = already processed
.equiv  reverse,                            6       ;1=reverse, 0=forward
.equiv  reverse_request,                    7       ;1=reverse, 0=forward (bit nessary for when the throttle is over CAN)
.equiv  over_erpm,                          8       ;1=erpm runaway, 0=no erpm runaway
.equiv  over_i_total,                       9       ;1=total current too high (in recov dr2, dr2to3), 0=not too high
.equiv  valid_data_imp_meas,               10       ;1=data valid, 0=do not use
.equiv  temp_sensor_found,                 11       ;1=temp sensors found, 0=not found
.equiv  temp_sensor_cycle,                 12       ;1=cycled through all temp sensors, 0=still busy reading out temp sensors
.equiv	clipping,			   13	    ;1=at max amplitude, use actual current for FOC
.equiv	exit_to_dr3,			   14	    ;1=exit to drive_3, used in dr23 hall mode, 0=do not exit
.equiv	allow_sine_iimag,		   15	    ;1 = allowed, 0 = force reduction    
    
;bits in flags2
    
.equiv	direction_phase_loop,		    0	    ;1=decrease phi etc, 0=increase
.equiv	direction_ampli_loop,		    1	    ;1=decrease ampli etc, 0=increase		    
.equiv	direction_imag_loop,		    2	    ;1=decrease ampli etc, 0=increase, used during hall running		    
.equiv	can_transition,			    3	    ;1=yes, 0=no (transition to hall23 only when pll error input = 0 and low w9)
    
;bits in flags_rom

.equiv	sensorless_mode,                    0       ;sensorless mode
.equiv	hall_mode,                          1	    ;hall mode
.equiv	hf_mode,			    2       ;hf tone mode
.equiv  analog_throttle,                    3       ;1 = use analog throttle, 0 = throttle over CAN
.equiv  throttle_AN7,                       4       ;1 = use AN7 in throttle routine
.equiv  throttle_AN8,                       5       ;1 = use AN8 in throttle routine
.equiv  tx_throttle,                        6       ;1 = transmit throttle over CAN
.equiv  pulse_low_side,                     7       ;1 = pulse low side during drive_0
.equiv  allow_rom_write,                    8       ;1 = allow writing settings to ROM upon setup push during motor run
.equiv  perform_voltage_test,               9       ;1 = skip 0.5V check in drive_0_rec
.equiv  perform_throttle_check,            10       ;1 = skip throttle closed check in drive_0_rec
.equiv  check_i_total,                     11       ;1 = check i_total, 0 = check i_imag in drive_2_rec and drive_2to3_rec
.equiv  calib_halls,                       12       ;if hall run mode selected: 1 = detect hall position, 0 = run with halls
.equiv  use_temp_sensors,                  13       ;1=yes, 0=no
.equiv	use_sine_iimag,			   14	    ;1=yes, 0=no
.equiv	I_error_absolute,		   15	    ;1 = use abs(I_error), 0 = use I_error

;bits in flags_rom2

.equiv	FOC_overflow,			    0	    ;1 = overflow occurred during FOC measurement, 0 = no overflow    
.equiv	use_hvc_lvc,			    1	    ;1 = use hvc lvc limiting, 0 = do not use
.equiv	limit_accel,			    2	    ;1 = use accelleration limiting, 0 = do not use
.equiv	use_KvLR,			    3	    ;1 = use online Kv,L and R measurement, 0 = do not use
.equiv  use_hall_assisted_sl,		    4	    ;1 = yes, 0 = no    
.equiv	negative_current_sensors,	    5	    ;1 = yes, 0 = no 
    
;bits in stored_status+0

.equiv	cs_led0,			    15	    ;1 = on, 0 = off  
.equiv	cs_led1,			    14	    ;1 = on, 0 = off  
.equiv	cs_led2,			    13	    ;1 = on, 0 = off  
.equiv	cs_led3,			    12	    ;1 = on, 0 = off  
.equiv  cs_over_i_total,		    11   
.equiv  cs_over_i_imag,                     10    
.equiv	cs_over_erpm,			    9
.equiv  cs_clipping,			    8     
    
;bits in menus_completed, cleared when menu was triggered:
.equiv	mc_mask,			    0x1FFF  ;used bits must be set to 1
.equiv	mc_pwm,				    0
.equiv  mc_current,			    1
.equiv	mc_throttle,			    2
.equiv	mc_erpms,			    3
.equiv	mc_battery,			    4
.equiv	mc_sensors,			    5
.equiv	mc_coeffs,			    6
.equiv	mc_filters,			    7
.equiv	mc_foc,				    8
.equiv	mc_recovery,			    9
.equiv	mc_temp,			    10
.equiv	mc_misc,			    11
.equiv	mc_KvLR,			    12
    
;bits in flags_can

.equiv  reverse_CAN,                        0       ;reverse_request from the can bus

;temperature timer 2 equivalents

.equiv  t2_600u,                            2250
.equiv  t2_100u,                            375
.equiv  t2_80u,                             300
.equiv  t2_10u,                             37
.equiv  t2_5u,                              18
.equiv  t2_2u,                              7
.equiv  ic2_triplevel,                      48
    
;floating point    
    
.equiv	fp_N,				    2  
    
;positions in data_collected array
.equiv	iatia,				    0	    ;Ia^2 = ia times ia
.equiv	wtw,				    2	    ;w^2 = w times w
.equiv	wtia,				    4	    ;w * Ia
.equiv  ytia,				    6	    ;y * Ia
.equiv	ytw,				    8	    ;y * w
.equiv	vaoverw,			    8	    ;Va/w
.equiv  wtwtibtib,			   10	    ;w^2*Ib^2
.equiv	bty,				   12	    ;b*y, or wIb(IaR + wKx - Va)

;variance data positwions
.equiv	varw,				    0
.equiv	varw2,				    4
.equiv	varIa,				    8
.equiv	varIa2,				   12
.equiv	varIb,				    8
.equiv	varIb2,				   12

    