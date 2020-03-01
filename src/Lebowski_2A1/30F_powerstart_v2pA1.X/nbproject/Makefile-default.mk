#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=mkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=cof
DEBUGGABLE_SUFFIX=cof
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/30F_powerstart_v2pA1.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=cof
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/30F_powerstart_v2pA1.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

ifeq ($(COMPARE_BUILD), true)
COMPARISON_BUILD=-mafrlcsj
else
COMPARISON_BUILD=
endif

ifdef SUB_IMAGE_ADDRESS

else
SUB_IMAGE_ADDRESS_COMMAND=
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=reset_vector.s init_interrupts.s subrout_str.s subrout_232.s global_variables.s fill_pwm_and_sin_arrays.s motor_sinus.s timers.s PWM.s ADC.s monitoring.s initialise.s demod.s angle_amplitude.s throttle_open.s can_initialise.s throttle_read.s can_motor.s main_motor.s LEDs.s current_control.s backemf_phase_control.s safety.s inverse_vbat.s prog_mem.s "menu structure/main_menu.s" "menu structure/menu_pwm.s" "menu structure/menu_functions.s" "menu structure/menu_throttle.s" "menu structure/menu_throttle_functions.s" "menu structure/menu_currents.s" "menu structure/menu_erpms.s" "menu structure/menu_battery.s" "menu structure/menu_sensors.s" "menu structure/menu_foc.s" "menu structure/convert_to_readable_L_and_R.s" "menu structure/motor_impedance_measurement.s" "menu structure/menu_loop_coeffs.s" "menu structure/menu_filters.s" "menu structure/menu_can.s" "menu structure/menu_rom.s" process_all_variables.s "menu structure/report_checksum.s" "menu structure/menu_misc.s" "menu structure/menu_recov.s" halls.s "menu structure/menu_halls.s" hallbased_phase_control.s "menu structure/menu_temp.s" temp_macros.s temp_routines.s "menu structure/menu_temp_functions.s" "menu structure/calc_rom_variables.s" drive_0_all.s drive_1_all.s drive_2_hall.s drive_2_sensorless.s drive_3_all.s drive_3_measurement_functions.s speed_control.s correct_drive_selection.s "menu structure/current_sensor_offset_measurement.s" drive_3_hall_measure.s drive_2to3_sensorless.s drive_2to3_hall.s chip_status.s "menu structure/menu_stored_status.s" chip_update.s current_filtering.s determine_update.s calc_wanted_ampli_imag.s "menu structure/mim_calculations.s" throttle_ramp.s floating_point.s imp_process_data.s imp_collect_data.s imp_collect_data_L.s imp_collect_data_R.s sine_i_imag.s "menu structure/menu_KvLR.s"

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/reset_vector.o ${OBJECTDIR}/init_interrupts.o ${OBJECTDIR}/subrout_str.o ${OBJECTDIR}/subrout_232.o ${OBJECTDIR}/global_variables.o ${OBJECTDIR}/fill_pwm_and_sin_arrays.o ${OBJECTDIR}/motor_sinus.o ${OBJECTDIR}/timers.o ${OBJECTDIR}/PWM.o ${OBJECTDIR}/ADC.o ${OBJECTDIR}/monitoring.o ${OBJECTDIR}/initialise.o ${OBJECTDIR}/demod.o ${OBJECTDIR}/angle_amplitude.o ${OBJECTDIR}/throttle_open.o ${OBJECTDIR}/can_initialise.o ${OBJECTDIR}/throttle_read.o ${OBJECTDIR}/can_motor.o ${OBJECTDIR}/main_motor.o ${OBJECTDIR}/LEDs.o ${OBJECTDIR}/current_control.o ${OBJECTDIR}/backemf_phase_control.o ${OBJECTDIR}/safety.o ${OBJECTDIR}/inverse_vbat.o ${OBJECTDIR}/prog_mem.o "${OBJECTDIR}/menu structure/main_menu.o" "${OBJECTDIR}/menu structure/menu_pwm.o" "${OBJECTDIR}/menu structure/menu_functions.o" "${OBJECTDIR}/menu structure/menu_throttle.o" "${OBJECTDIR}/menu structure/menu_throttle_functions.o" "${OBJECTDIR}/menu structure/menu_currents.o" "${OBJECTDIR}/menu structure/menu_erpms.o" "${OBJECTDIR}/menu structure/menu_battery.o" "${OBJECTDIR}/menu structure/menu_sensors.o" "${OBJECTDIR}/menu structure/menu_foc.o" "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o" "${OBJECTDIR}/menu structure/motor_impedance_measurement.o" "${OBJECTDIR}/menu structure/menu_loop_coeffs.o" "${OBJECTDIR}/menu structure/menu_filters.o" "${OBJECTDIR}/menu structure/menu_can.o" "${OBJECTDIR}/menu structure/menu_rom.o" ${OBJECTDIR}/process_all_variables.o "${OBJECTDIR}/menu structure/report_checksum.o" "${OBJECTDIR}/menu structure/menu_misc.o" "${OBJECTDIR}/menu structure/menu_recov.o" ${OBJECTDIR}/halls.o "${OBJECTDIR}/menu structure/menu_halls.o" ${OBJECTDIR}/hallbased_phase_control.o "${OBJECTDIR}/menu structure/menu_temp.o" ${OBJECTDIR}/temp_macros.o ${OBJECTDIR}/temp_routines.o "${OBJECTDIR}/menu structure/menu_temp_functions.o" "${OBJECTDIR}/menu structure/calc_rom_variables.o" ${OBJECTDIR}/drive_0_all.o ${OBJECTDIR}/drive_1_all.o ${OBJECTDIR}/drive_2_hall.o ${OBJECTDIR}/drive_2_sensorless.o ${OBJECTDIR}/drive_3_all.o ${OBJECTDIR}/drive_3_measurement_functions.o ${OBJECTDIR}/speed_control.o ${OBJECTDIR}/correct_drive_selection.o "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o" ${OBJECTDIR}/drive_3_hall_measure.o ${OBJECTDIR}/drive_2to3_sensorless.o ${OBJECTDIR}/drive_2to3_hall.o ${OBJECTDIR}/chip_status.o "${OBJECTDIR}/menu structure/menu_stored_status.o" ${OBJECTDIR}/chip_update.o ${OBJECTDIR}/current_filtering.o ${OBJECTDIR}/determine_update.o ${OBJECTDIR}/calc_wanted_ampli_imag.o "${OBJECTDIR}/menu structure/mim_calculations.o" ${OBJECTDIR}/throttle_ramp.o ${OBJECTDIR}/floating_point.o ${OBJECTDIR}/imp_process_data.o ${OBJECTDIR}/imp_collect_data.o ${OBJECTDIR}/imp_collect_data_L.o ${OBJECTDIR}/imp_collect_data_R.o ${OBJECTDIR}/sine_i_imag.o "${OBJECTDIR}/menu structure/menu_KvLR.o"
POSSIBLE_DEPFILES=${OBJECTDIR}/reset_vector.o.d ${OBJECTDIR}/init_interrupts.o.d ${OBJECTDIR}/subrout_str.o.d ${OBJECTDIR}/subrout_232.o.d ${OBJECTDIR}/global_variables.o.d ${OBJECTDIR}/fill_pwm_and_sin_arrays.o.d ${OBJECTDIR}/motor_sinus.o.d ${OBJECTDIR}/timers.o.d ${OBJECTDIR}/PWM.o.d ${OBJECTDIR}/ADC.o.d ${OBJECTDIR}/monitoring.o.d ${OBJECTDIR}/initialise.o.d ${OBJECTDIR}/demod.o.d ${OBJECTDIR}/angle_amplitude.o.d ${OBJECTDIR}/throttle_open.o.d ${OBJECTDIR}/can_initialise.o.d ${OBJECTDIR}/throttle_read.o.d ${OBJECTDIR}/can_motor.o.d ${OBJECTDIR}/main_motor.o.d ${OBJECTDIR}/LEDs.o.d ${OBJECTDIR}/current_control.o.d ${OBJECTDIR}/backemf_phase_control.o.d ${OBJECTDIR}/safety.o.d ${OBJECTDIR}/inverse_vbat.o.d ${OBJECTDIR}/prog_mem.o.d "${OBJECTDIR}/menu structure/main_menu.o.d" "${OBJECTDIR}/menu structure/menu_pwm.o.d" "${OBJECTDIR}/menu structure/menu_functions.o.d" "${OBJECTDIR}/menu structure/menu_throttle.o.d" "${OBJECTDIR}/menu structure/menu_throttle_functions.o.d" "${OBJECTDIR}/menu structure/menu_currents.o.d" "${OBJECTDIR}/menu structure/menu_erpms.o.d" "${OBJECTDIR}/menu structure/menu_battery.o.d" "${OBJECTDIR}/menu structure/menu_sensors.o.d" "${OBJECTDIR}/menu structure/menu_foc.o.d" "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o.d" "${OBJECTDIR}/menu structure/motor_impedance_measurement.o.d" "${OBJECTDIR}/menu structure/menu_loop_coeffs.o.d" "${OBJECTDIR}/menu structure/menu_filters.o.d" "${OBJECTDIR}/menu structure/menu_can.o.d" "${OBJECTDIR}/menu structure/menu_rom.o.d" ${OBJECTDIR}/process_all_variables.o.d "${OBJECTDIR}/menu structure/report_checksum.o.d" "${OBJECTDIR}/menu structure/menu_misc.o.d" "${OBJECTDIR}/menu structure/menu_recov.o.d" ${OBJECTDIR}/halls.o.d "${OBJECTDIR}/menu structure/menu_halls.o.d" ${OBJECTDIR}/hallbased_phase_control.o.d "${OBJECTDIR}/menu structure/menu_temp.o.d" ${OBJECTDIR}/temp_macros.o.d ${OBJECTDIR}/temp_routines.o.d "${OBJECTDIR}/menu structure/menu_temp_functions.o.d" "${OBJECTDIR}/menu structure/calc_rom_variables.o.d" ${OBJECTDIR}/drive_0_all.o.d ${OBJECTDIR}/drive_1_all.o.d ${OBJECTDIR}/drive_2_hall.o.d ${OBJECTDIR}/drive_2_sensorless.o.d ${OBJECTDIR}/drive_3_all.o.d ${OBJECTDIR}/drive_3_measurement_functions.o.d ${OBJECTDIR}/speed_control.o.d ${OBJECTDIR}/correct_drive_selection.o.d "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o.d" ${OBJECTDIR}/drive_3_hall_measure.o.d ${OBJECTDIR}/drive_2to3_sensorless.o.d ${OBJECTDIR}/drive_2to3_hall.o.d ${OBJECTDIR}/chip_status.o.d "${OBJECTDIR}/menu structure/menu_stored_status.o.d" ${OBJECTDIR}/chip_update.o.d ${OBJECTDIR}/current_filtering.o.d ${OBJECTDIR}/determine_update.o.d ${OBJECTDIR}/calc_wanted_ampli_imag.o.d "${OBJECTDIR}/menu structure/mim_calculations.o.d" ${OBJECTDIR}/throttle_ramp.o.d ${OBJECTDIR}/floating_point.o.d ${OBJECTDIR}/imp_process_data.o.d ${OBJECTDIR}/imp_collect_data.o.d ${OBJECTDIR}/imp_collect_data_L.o.d ${OBJECTDIR}/imp_collect_data_R.o.d ${OBJECTDIR}/sine_i_imag.o.d "${OBJECTDIR}/menu structure/menu_KvLR.o.d"

# Object Files
OBJECTFILES=${OBJECTDIR}/reset_vector.o ${OBJECTDIR}/init_interrupts.o ${OBJECTDIR}/subrout_str.o ${OBJECTDIR}/subrout_232.o ${OBJECTDIR}/global_variables.o ${OBJECTDIR}/fill_pwm_and_sin_arrays.o ${OBJECTDIR}/motor_sinus.o ${OBJECTDIR}/timers.o ${OBJECTDIR}/PWM.o ${OBJECTDIR}/ADC.o ${OBJECTDIR}/monitoring.o ${OBJECTDIR}/initialise.o ${OBJECTDIR}/demod.o ${OBJECTDIR}/angle_amplitude.o ${OBJECTDIR}/throttle_open.o ${OBJECTDIR}/can_initialise.o ${OBJECTDIR}/throttle_read.o ${OBJECTDIR}/can_motor.o ${OBJECTDIR}/main_motor.o ${OBJECTDIR}/LEDs.o ${OBJECTDIR}/current_control.o ${OBJECTDIR}/backemf_phase_control.o ${OBJECTDIR}/safety.o ${OBJECTDIR}/inverse_vbat.o ${OBJECTDIR}/prog_mem.o ${OBJECTDIR}/menu\ structure/main_menu.o ${OBJECTDIR}/menu\ structure/menu_pwm.o ${OBJECTDIR}/menu\ structure/menu_functions.o ${OBJECTDIR}/menu\ structure/menu_throttle.o ${OBJECTDIR}/menu\ structure/menu_throttle_functions.o ${OBJECTDIR}/menu\ structure/menu_currents.o ${OBJECTDIR}/menu\ structure/menu_erpms.o ${OBJECTDIR}/menu\ structure/menu_battery.o ${OBJECTDIR}/menu\ structure/menu_sensors.o ${OBJECTDIR}/menu\ structure/menu_foc.o ${OBJECTDIR}/menu\ structure/convert_to_readable_L_and_R.o ${OBJECTDIR}/menu\ structure/motor_impedance_measurement.o ${OBJECTDIR}/menu\ structure/menu_loop_coeffs.o ${OBJECTDIR}/menu\ structure/menu_filters.o ${OBJECTDIR}/menu\ structure/menu_can.o ${OBJECTDIR}/menu\ structure/menu_rom.o ${OBJECTDIR}/process_all_variables.o ${OBJECTDIR}/menu\ structure/report_checksum.o ${OBJECTDIR}/menu\ structure/menu_misc.o ${OBJECTDIR}/menu\ structure/menu_recov.o ${OBJECTDIR}/halls.o ${OBJECTDIR}/menu\ structure/menu_halls.o ${OBJECTDIR}/hallbased_phase_control.o ${OBJECTDIR}/menu\ structure/menu_temp.o ${OBJECTDIR}/temp_macros.o ${OBJECTDIR}/temp_routines.o ${OBJECTDIR}/menu\ structure/menu_temp_functions.o ${OBJECTDIR}/menu\ structure/calc_rom_variables.o ${OBJECTDIR}/drive_0_all.o ${OBJECTDIR}/drive_1_all.o ${OBJECTDIR}/drive_2_hall.o ${OBJECTDIR}/drive_2_sensorless.o ${OBJECTDIR}/drive_3_all.o ${OBJECTDIR}/drive_3_measurement_functions.o ${OBJECTDIR}/speed_control.o ${OBJECTDIR}/correct_drive_selection.o ${OBJECTDIR}/menu\ structure/current_sensor_offset_measurement.o ${OBJECTDIR}/drive_3_hall_measure.o ${OBJECTDIR}/drive_2to3_sensorless.o ${OBJECTDIR}/drive_2to3_hall.o ${OBJECTDIR}/chip_status.o ${OBJECTDIR}/menu\ structure/menu_stored_status.o ${OBJECTDIR}/chip_update.o ${OBJECTDIR}/current_filtering.o ${OBJECTDIR}/determine_update.o ${OBJECTDIR}/calc_wanted_ampli_imag.o ${OBJECTDIR}/menu\ structure/mim_calculations.o ${OBJECTDIR}/throttle_ramp.o ${OBJECTDIR}/floating_point.o ${OBJECTDIR}/imp_process_data.o ${OBJECTDIR}/imp_collect_data.o ${OBJECTDIR}/imp_collect_data_L.o ${OBJECTDIR}/imp_collect_data_R.o ${OBJECTDIR}/sine_i_imag.o ${OBJECTDIR}/menu\ structure/menu_KvLR.o

# Source Files
SOURCEFILES=reset_vector.s init_interrupts.s subrout_str.s subrout_232.s global_variables.s fill_pwm_and_sin_arrays.s motor_sinus.s timers.s PWM.s ADC.s monitoring.s initialise.s demod.s angle_amplitude.s throttle_open.s can_initialise.s throttle_read.s can_motor.s main_motor.s LEDs.s current_control.s backemf_phase_control.s safety.s inverse_vbat.s prog_mem.s menu structure/main_menu.s menu structure/menu_pwm.s menu structure/menu_functions.s menu structure/menu_throttle.s menu structure/menu_throttle_functions.s menu structure/menu_currents.s menu structure/menu_erpms.s menu structure/menu_battery.s menu structure/menu_sensors.s menu structure/menu_foc.s menu structure/convert_to_readable_L_and_R.s menu structure/motor_impedance_measurement.s menu structure/menu_loop_coeffs.s menu structure/menu_filters.s menu structure/menu_can.s menu structure/menu_rom.s process_all_variables.s menu structure/report_checksum.s menu structure/menu_misc.s menu structure/menu_recov.s halls.s menu structure/menu_halls.s hallbased_phase_control.s menu structure/menu_temp.s temp_macros.s temp_routines.s menu structure/menu_temp_functions.s menu structure/calc_rom_variables.s drive_0_all.s drive_1_all.s drive_2_hall.s drive_2_sensorless.s drive_3_all.s drive_3_measurement_functions.s speed_control.s correct_drive_selection.s menu structure/current_sensor_offset_measurement.s drive_3_hall_measure.s drive_2to3_sensorless.s drive_2to3_hall.s chip_status.s menu structure/menu_stored_status.s chip_update.s current_filtering.s determine_update.s calc_wanted_ampli_imag.s menu structure/mim_calculations.s throttle_ramp.s floating_point.s imp_process_data.s imp_collect_data.s imp_collect_data_L.s imp_collect_data_R.s sine_i_imag.s menu structure/menu_KvLR.s


CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk dist/${CND_CONF}/${IMAGE_TYPE}/30F_powerstart_v2pA1.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=30F4011
MP_LINKER_FILE_OPTION=,--script=p30F4011.gld
# ------------------------------------------------------------------------------------
# Rules for buildStep: compile
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/reset_vector.o: reset_vector.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/reset_vector.o.d 
	@${RM} ${OBJECTDIR}/reset_vector.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  reset_vector.s  -o ${OBJECTDIR}/reset_vector.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/reset_vector.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/reset_vector.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/init_interrupts.o: init_interrupts.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/init_interrupts.o.d 
	@${RM} ${OBJECTDIR}/init_interrupts.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  init_interrupts.s  -o ${OBJECTDIR}/init_interrupts.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/init_interrupts.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/init_interrupts.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/subrout_str.o: subrout_str.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/subrout_str.o.d 
	@${RM} ${OBJECTDIR}/subrout_str.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  subrout_str.s  -o ${OBJECTDIR}/subrout_str.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/subrout_str.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/subrout_str.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/subrout_232.o: subrout_232.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/subrout_232.o.d 
	@${RM} ${OBJECTDIR}/subrout_232.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  subrout_232.s  -o ${OBJECTDIR}/subrout_232.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/subrout_232.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/subrout_232.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/global_variables.o: global_variables.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/global_variables.o.d 
	@${RM} ${OBJECTDIR}/global_variables.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  global_variables.s  -o ${OBJECTDIR}/global_variables.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/global_variables.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/global_variables.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/fill_pwm_and_sin_arrays.o: fill_pwm_and_sin_arrays.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/fill_pwm_and_sin_arrays.o.d 
	@${RM} ${OBJECTDIR}/fill_pwm_and_sin_arrays.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  fill_pwm_and_sin_arrays.s  -o ${OBJECTDIR}/fill_pwm_and_sin_arrays.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/fill_pwm_and_sin_arrays.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/fill_pwm_and_sin_arrays.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/motor_sinus.o: motor_sinus.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/motor_sinus.o.d 
	@${RM} ${OBJECTDIR}/motor_sinus.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  motor_sinus.s  -o ${OBJECTDIR}/motor_sinus.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/motor_sinus.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/motor_sinus.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/timers.o: timers.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/timers.o.d 
	@${RM} ${OBJECTDIR}/timers.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  timers.s  -o ${OBJECTDIR}/timers.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/timers.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/timers.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/PWM.o: PWM.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/PWM.o.d 
	@${RM} ${OBJECTDIR}/PWM.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  PWM.s  -o ${OBJECTDIR}/PWM.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/PWM.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/PWM.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/ADC.o: ADC.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/ADC.o.d 
	@${RM} ${OBJECTDIR}/ADC.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  ADC.s  -o ${OBJECTDIR}/ADC.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/ADC.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/ADC.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/monitoring.o: monitoring.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/monitoring.o.d 
	@${RM} ${OBJECTDIR}/monitoring.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  monitoring.s  -o ${OBJECTDIR}/monitoring.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/monitoring.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/monitoring.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/initialise.o: initialise.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/initialise.o.d 
	@${RM} ${OBJECTDIR}/initialise.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  initialise.s  -o ${OBJECTDIR}/initialise.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/initialise.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/initialise.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/demod.o: demod.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/demod.o.d 
	@${RM} ${OBJECTDIR}/demod.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  demod.s  -o ${OBJECTDIR}/demod.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/demod.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/demod.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/angle_amplitude.o: angle_amplitude.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/angle_amplitude.o.d 
	@${RM} ${OBJECTDIR}/angle_amplitude.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  angle_amplitude.s  -o ${OBJECTDIR}/angle_amplitude.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/angle_amplitude.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/angle_amplitude.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/throttle_open.o: throttle_open.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/throttle_open.o.d 
	@${RM} ${OBJECTDIR}/throttle_open.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  throttle_open.s  -o ${OBJECTDIR}/throttle_open.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/throttle_open.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/throttle_open.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/can_initialise.o: can_initialise.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/can_initialise.o.d 
	@${RM} ${OBJECTDIR}/can_initialise.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  can_initialise.s  -o ${OBJECTDIR}/can_initialise.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/can_initialise.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/can_initialise.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/throttle_read.o: throttle_read.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/throttle_read.o.d 
	@${RM} ${OBJECTDIR}/throttle_read.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  throttle_read.s  -o ${OBJECTDIR}/throttle_read.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/throttle_read.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/throttle_read.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/can_motor.o: can_motor.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/can_motor.o.d 
	@${RM} ${OBJECTDIR}/can_motor.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  can_motor.s  -o ${OBJECTDIR}/can_motor.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/can_motor.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/can_motor.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/main_motor.o: main_motor.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main_motor.o.d 
	@${RM} ${OBJECTDIR}/main_motor.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  main_motor.s  -o ${OBJECTDIR}/main_motor.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/main_motor.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/main_motor.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/LEDs.o: LEDs.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/LEDs.o.d 
	@${RM} ${OBJECTDIR}/LEDs.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  LEDs.s  -o ${OBJECTDIR}/LEDs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/LEDs.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/LEDs.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/current_control.o: current_control.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/current_control.o.d 
	@${RM} ${OBJECTDIR}/current_control.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  current_control.s  -o ${OBJECTDIR}/current_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/current_control.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/current_control.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/backemf_phase_control.o: backemf_phase_control.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/backemf_phase_control.o.d 
	@${RM} ${OBJECTDIR}/backemf_phase_control.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  backemf_phase_control.s  -o ${OBJECTDIR}/backemf_phase_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/backemf_phase_control.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/backemf_phase_control.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/safety.o: safety.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/safety.o.d 
	@${RM} ${OBJECTDIR}/safety.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  safety.s  -o ${OBJECTDIR}/safety.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/safety.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/safety.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/inverse_vbat.o: inverse_vbat.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/inverse_vbat.o.d 
	@${RM} ${OBJECTDIR}/inverse_vbat.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  inverse_vbat.s  -o ${OBJECTDIR}/inverse_vbat.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/inverse_vbat.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/inverse_vbat.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/prog_mem.o: prog_mem.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/prog_mem.o.d 
	@${RM} ${OBJECTDIR}/prog_mem.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  prog_mem.s  -o ${OBJECTDIR}/prog_mem.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/prog_mem.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/prog_mem.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/main_menu.o: menu\ structure/main_menu.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/main_menu.o".d 
	@${RM} "${OBJECTDIR}/menu structure/main_menu.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/main_menu.s"  -o "${OBJECTDIR}/menu structure/main_menu.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/main_menu.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/main_menu.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_pwm.o: menu\ structure/menu_pwm.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_pwm.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_pwm.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_pwm.s"  -o "${OBJECTDIR}/menu structure/menu_pwm.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_pwm.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_pwm.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_functions.o: menu\ structure/menu_functions.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_functions.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_functions.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_functions.s"  -o "${OBJECTDIR}/menu structure/menu_functions.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_functions.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_functions.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_throttle.o: menu\ structure/menu_throttle.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_throttle.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_throttle.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_throttle.s"  -o "${OBJECTDIR}/menu structure/menu_throttle.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_throttle.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_throttle.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_throttle_functions.o: menu\ structure/menu_throttle_functions.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_throttle_functions.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_throttle_functions.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_throttle_functions.s"  -o "${OBJECTDIR}/menu structure/menu_throttle_functions.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_throttle_functions.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_throttle_functions.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_currents.o: menu\ structure/menu_currents.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_currents.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_currents.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_currents.s"  -o "${OBJECTDIR}/menu structure/menu_currents.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_currents.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_currents.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_erpms.o: menu\ structure/menu_erpms.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_erpms.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_erpms.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_erpms.s"  -o "${OBJECTDIR}/menu structure/menu_erpms.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_erpms.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_erpms.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_battery.o: menu\ structure/menu_battery.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_battery.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_battery.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_battery.s"  -o "${OBJECTDIR}/menu structure/menu_battery.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_battery.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_battery.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_sensors.o: menu\ structure/menu_sensors.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_sensors.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_sensors.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_sensors.s"  -o "${OBJECTDIR}/menu structure/menu_sensors.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_sensors.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_sensors.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_foc.o: menu\ structure/menu_foc.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_foc.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_foc.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_foc.s"  -o "${OBJECTDIR}/menu structure/menu_foc.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_foc.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_foc.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/convert_to_readable_L_and_R.o: menu\ structure/convert_to_readable_L_and_R.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o".d 
	@${RM} "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/convert_to_readable_L_and_R.s"  -o "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/motor_impedance_measurement.o: menu\ structure/motor_impedance_measurement.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/motor_impedance_measurement.o".d 
	@${RM} "${OBJECTDIR}/menu structure/motor_impedance_measurement.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/motor_impedance_measurement.s"  -o "${OBJECTDIR}/menu structure/motor_impedance_measurement.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/motor_impedance_measurement.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/motor_impedance_measurement.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_loop_coeffs.o: menu\ structure/menu_loop_coeffs.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_loop_coeffs.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_loop_coeffs.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_loop_coeffs.s"  -o "${OBJECTDIR}/menu structure/menu_loop_coeffs.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_loop_coeffs.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_loop_coeffs.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_filters.o: menu\ structure/menu_filters.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_filters.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_filters.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_filters.s"  -o "${OBJECTDIR}/menu structure/menu_filters.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_filters.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_filters.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_can.o: menu\ structure/menu_can.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_can.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_can.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_can.s"  -o "${OBJECTDIR}/menu structure/menu_can.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_can.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_can.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_rom.o: menu\ structure/menu_rom.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_rom.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_rom.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_rom.s"  -o "${OBJECTDIR}/menu structure/menu_rom.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_rom.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_rom.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/process_all_variables.o: process_all_variables.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/process_all_variables.o.d 
	@${RM} ${OBJECTDIR}/process_all_variables.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  process_all_variables.s  -o ${OBJECTDIR}/process_all_variables.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/process_all_variables.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/process_all_variables.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/report_checksum.o: menu\ structure/report_checksum.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/report_checksum.o".d 
	@${RM} "${OBJECTDIR}/menu structure/report_checksum.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/report_checksum.s"  -o "${OBJECTDIR}/menu structure/report_checksum.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/report_checksum.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/report_checksum.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_misc.o: menu\ structure/menu_misc.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_misc.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_misc.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_misc.s"  -o "${OBJECTDIR}/menu structure/menu_misc.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_misc.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_misc.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_recov.o: menu\ structure/menu_recov.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_recov.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_recov.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_recov.s"  -o "${OBJECTDIR}/menu structure/menu_recov.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_recov.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_recov.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/halls.o: halls.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/halls.o.d 
	@${RM} ${OBJECTDIR}/halls.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  halls.s  -o ${OBJECTDIR}/halls.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/halls.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/halls.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_halls.o: menu\ structure/menu_halls.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_halls.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_halls.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_halls.s"  -o "${OBJECTDIR}/menu structure/menu_halls.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_halls.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_halls.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/hallbased_phase_control.o: hallbased_phase_control.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/hallbased_phase_control.o.d 
	@${RM} ${OBJECTDIR}/hallbased_phase_control.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  hallbased_phase_control.s  -o ${OBJECTDIR}/hallbased_phase_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/hallbased_phase_control.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/hallbased_phase_control.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_temp.o: menu\ structure/menu_temp.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_temp.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_temp.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_temp.s"  -o "${OBJECTDIR}/menu structure/menu_temp.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_temp.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_temp.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/temp_macros.o: temp_macros.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/temp_macros.o.d 
	@${RM} ${OBJECTDIR}/temp_macros.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  temp_macros.s  -o ${OBJECTDIR}/temp_macros.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/temp_macros.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/temp_macros.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/temp_routines.o: temp_routines.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/temp_routines.o.d 
	@${RM} ${OBJECTDIR}/temp_routines.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  temp_routines.s  -o ${OBJECTDIR}/temp_routines.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/temp_routines.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/temp_routines.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_temp_functions.o: menu\ structure/menu_temp_functions.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_temp_functions.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_temp_functions.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_temp_functions.s"  -o "${OBJECTDIR}/menu structure/menu_temp_functions.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_temp_functions.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_temp_functions.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/calc_rom_variables.o: menu\ structure/calc_rom_variables.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/calc_rom_variables.o".d 
	@${RM} "${OBJECTDIR}/menu structure/calc_rom_variables.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/calc_rom_variables.s"  -o "${OBJECTDIR}/menu structure/calc_rom_variables.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/calc_rom_variables.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/calc_rom_variables.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_0_all.o: drive_0_all.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_0_all.o.d 
	@${RM} ${OBJECTDIR}/drive_0_all.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_0_all.s  -o ${OBJECTDIR}/drive_0_all.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_0_all.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_0_all.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_1_all.o: drive_1_all.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_1_all.o.d 
	@${RM} ${OBJECTDIR}/drive_1_all.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_1_all.s  -o ${OBJECTDIR}/drive_1_all.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_1_all.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_1_all.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_2_hall.o: drive_2_hall.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_2_hall.o.d 
	@${RM} ${OBJECTDIR}/drive_2_hall.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_2_hall.s  -o ${OBJECTDIR}/drive_2_hall.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_2_hall.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_2_hall.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_2_sensorless.o: drive_2_sensorless.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_2_sensorless.o.d 
	@${RM} ${OBJECTDIR}/drive_2_sensorless.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_2_sensorless.s  -o ${OBJECTDIR}/drive_2_sensorless.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_2_sensorless.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_2_sensorless.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_3_all.o: drive_3_all.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_3_all.o.d 
	@${RM} ${OBJECTDIR}/drive_3_all.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_3_all.s  -o ${OBJECTDIR}/drive_3_all.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_3_all.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_3_all.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_3_measurement_functions.o: drive_3_measurement_functions.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_3_measurement_functions.o.d 
	@${RM} ${OBJECTDIR}/drive_3_measurement_functions.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_3_measurement_functions.s  -o ${OBJECTDIR}/drive_3_measurement_functions.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_3_measurement_functions.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_3_measurement_functions.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/speed_control.o: speed_control.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/speed_control.o.d 
	@${RM} ${OBJECTDIR}/speed_control.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  speed_control.s  -o ${OBJECTDIR}/speed_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/speed_control.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/speed_control.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/correct_drive_selection.o: correct_drive_selection.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/correct_drive_selection.o.d 
	@${RM} ${OBJECTDIR}/correct_drive_selection.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  correct_drive_selection.s  -o ${OBJECTDIR}/correct_drive_selection.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/correct_drive_selection.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/correct_drive_selection.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/current_sensor_offset_measurement.o: menu\ structure/current_sensor_offset_measurement.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o".d 
	@${RM} "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/current_sensor_offset_measurement.s"  -o "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_3_hall_measure.o: drive_3_hall_measure.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_3_hall_measure.o.d 
	@${RM} ${OBJECTDIR}/drive_3_hall_measure.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_3_hall_measure.s  -o ${OBJECTDIR}/drive_3_hall_measure.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_3_hall_measure.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_3_hall_measure.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_2to3_sensorless.o: drive_2to3_sensorless.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_2to3_sensorless.o.d 
	@${RM} ${OBJECTDIR}/drive_2to3_sensorless.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_2to3_sensorless.s  -o ${OBJECTDIR}/drive_2to3_sensorless.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_2to3_sensorless.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_2to3_sensorless.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_2to3_hall.o: drive_2to3_hall.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_2to3_hall.o.d 
	@${RM} ${OBJECTDIR}/drive_2to3_hall.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_2to3_hall.s  -o ${OBJECTDIR}/drive_2to3_hall.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_2to3_hall.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_2to3_hall.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/chip_status.o: chip_status.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/chip_status.o.d 
	@${RM} ${OBJECTDIR}/chip_status.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  chip_status.s  -o ${OBJECTDIR}/chip_status.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/chip_status.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/chip_status.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_stored_status.o: menu\ structure/menu_stored_status.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_stored_status.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_stored_status.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_stored_status.s"  -o "${OBJECTDIR}/menu structure/menu_stored_status.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_stored_status.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_stored_status.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/chip_update.o: chip_update.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/chip_update.o.d 
	@${RM} ${OBJECTDIR}/chip_update.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  chip_update.s  -o ${OBJECTDIR}/chip_update.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/chip_update.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/chip_update.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/current_filtering.o: current_filtering.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/current_filtering.o.d 
	@${RM} ${OBJECTDIR}/current_filtering.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  current_filtering.s  -o ${OBJECTDIR}/current_filtering.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/current_filtering.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/current_filtering.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/determine_update.o: determine_update.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/determine_update.o.d 
	@${RM} ${OBJECTDIR}/determine_update.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  determine_update.s  -o ${OBJECTDIR}/determine_update.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/determine_update.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/determine_update.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/calc_wanted_ampli_imag.o: calc_wanted_ampli_imag.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/calc_wanted_ampli_imag.o.d 
	@${RM} ${OBJECTDIR}/calc_wanted_ampli_imag.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  calc_wanted_ampli_imag.s  -o ${OBJECTDIR}/calc_wanted_ampli_imag.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/calc_wanted_ampli_imag.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/calc_wanted_ampli_imag.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/mim_calculations.o: menu\ structure/mim_calculations.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/mim_calculations.o".d 
	@${RM} "${OBJECTDIR}/menu structure/mim_calculations.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/mim_calculations.s"  -o "${OBJECTDIR}/menu structure/mim_calculations.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/mim_calculations.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/mim_calculations.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/throttle_ramp.o: throttle_ramp.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/throttle_ramp.o.d 
	@${RM} ${OBJECTDIR}/throttle_ramp.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  throttle_ramp.s  -o ${OBJECTDIR}/throttle_ramp.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/throttle_ramp.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/throttle_ramp.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/floating_point.o: floating_point.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/floating_point.o.d 
	@${RM} ${OBJECTDIR}/floating_point.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  floating_point.s  -o ${OBJECTDIR}/floating_point.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/floating_point.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/floating_point.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/imp_process_data.o: imp_process_data.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/imp_process_data.o.d 
	@${RM} ${OBJECTDIR}/imp_process_data.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  imp_process_data.s  -o ${OBJECTDIR}/imp_process_data.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/imp_process_data.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/imp_process_data.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/imp_collect_data.o: imp_collect_data.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/imp_collect_data.o.d 
	@${RM} ${OBJECTDIR}/imp_collect_data.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  imp_collect_data.s  -o ${OBJECTDIR}/imp_collect_data.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/imp_collect_data.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/imp_collect_data.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/imp_collect_data_L.o: imp_collect_data_L.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/imp_collect_data_L.o.d 
	@${RM} ${OBJECTDIR}/imp_collect_data_L.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  imp_collect_data_L.s  -o ${OBJECTDIR}/imp_collect_data_L.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/imp_collect_data_L.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/imp_collect_data_L.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/imp_collect_data_R.o: imp_collect_data_R.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/imp_collect_data_R.o.d 
	@${RM} ${OBJECTDIR}/imp_collect_data_R.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  imp_collect_data_R.s  -o ${OBJECTDIR}/imp_collect_data_R.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/imp_collect_data_R.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/imp_collect_data_R.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/sine_i_imag.o: sine_i_imag.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/sine_i_imag.o.d 
	@${RM} ${OBJECTDIR}/sine_i_imag.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  sine_i_imag.s  -o ${OBJECTDIR}/sine_i_imag.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/sine_i_imag.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/sine_i_imag.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_KvLR.o: menu\ structure/menu_KvLR.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_KvLR.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_KvLR.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_KvLR.s"  -o "${OBJECTDIR}/menu structure/menu_KvLR.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_KvLR.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_KvLR.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
else
${OBJECTDIR}/reset_vector.o: reset_vector.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/reset_vector.o.d 
	@${RM} ${OBJECTDIR}/reset_vector.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  reset_vector.s  -o ${OBJECTDIR}/reset_vector.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/reset_vector.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/reset_vector.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/init_interrupts.o: init_interrupts.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/init_interrupts.o.d 
	@${RM} ${OBJECTDIR}/init_interrupts.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  init_interrupts.s  -o ${OBJECTDIR}/init_interrupts.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/init_interrupts.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/init_interrupts.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/subrout_str.o: subrout_str.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/subrout_str.o.d 
	@${RM} ${OBJECTDIR}/subrout_str.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  subrout_str.s  -o ${OBJECTDIR}/subrout_str.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/subrout_str.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/subrout_str.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/subrout_232.o: subrout_232.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/subrout_232.o.d 
	@${RM} ${OBJECTDIR}/subrout_232.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  subrout_232.s  -o ${OBJECTDIR}/subrout_232.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/subrout_232.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/subrout_232.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/global_variables.o: global_variables.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/global_variables.o.d 
	@${RM} ${OBJECTDIR}/global_variables.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  global_variables.s  -o ${OBJECTDIR}/global_variables.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/global_variables.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/global_variables.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/fill_pwm_and_sin_arrays.o: fill_pwm_and_sin_arrays.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/fill_pwm_and_sin_arrays.o.d 
	@${RM} ${OBJECTDIR}/fill_pwm_and_sin_arrays.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  fill_pwm_and_sin_arrays.s  -o ${OBJECTDIR}/fill_pwm_and_sin_arrays.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/fill_pwm_and_sin_arrays.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/fill_pwm_and_sin_arrays.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/motor_sinus.o: motor_sinus.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/motor_sinus.o.d 
	@${RM} ${OBJECTDIR}/motor_sinus.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  motor_sinus.s  -o ${OBJECTDIR}/motor_sinus.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/motor_sinus.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/motor_sinus.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/timers.o: timers.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/timers.o.d 
	@${RM} ${OBJECTDIR}/timers.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  timers.s  -o ${OBJECTDIR}/timers.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/timers.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/timers.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/PWM.o: PWM.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/PWM.o.d 
	@${RM} ${OBJECTDIR}/PWM.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  PWM.s  -o ${OBJECTDIR}/PWM.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/PWM.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/PWM.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/ADC.o: ADC.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/ADC.o.d 
	@${RM} ${OBJECTDIR}/ADC.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  ADC.s  -o ${OBJECTDIR}/ADC.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/ADC.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/ADC.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/monitoring.o: monitoring.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/monitoring.o.d 
	@${RM} ${OBJECTDIR}/monitoring.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  monitoring.s  -o ${OBJECTDIR}/monitoring.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/monitoring.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/monitoring.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/initialise.o: initialise.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/initialise.o.d 
	@${RM} ${OBJECTDIR}/initialise.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  initialise.s  -o ${OBJECTDIR}/initialise.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/initialise.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/initialise.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/demod.o: demod.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/demod.o.d 
	@${RM} ${OBJECTDIR}/demod.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  demod.s  -o ${OBJECTDIR}/demod.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/demod.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/demod.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/angle_amplitude.o: angle_amplitude.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/angle_amplitude.o.d 
	@${RM} ${OBJECTDIR}/angle_amplitude.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  angle_amplitude.s  -o ${OBJECTDIR}/angle_amplitude.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/angle_amplitude.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/angle_amplitude.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/throttle_open.o: throttle_open.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/throttle_open.o.d 
	@${RM} ${OBJECTDIR}/throttle_open.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  throttle_open.s  -o ${OBJECTDIR}/throttle_open.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/throttle_open.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/throttle_open.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/can_initialise.o: can_initialise.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/can_initialise.o.d 
	@${RM} ${OBJECTDIR}/can_initialise.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  can_initialise.s  -o ${OBJECTDIR}/can_initialise.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/can_initialise.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/can_initialise.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/throttle_read.o: throttle_read.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/throttle_read.o.d 
	@${RM} ${OBJECTDIR}/throttle_read.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  throttle_read.s  -o ${OBJECTDIR}/throttle_read.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/throttle_read.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/throttle_read.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/can_motor.o: can_motor.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/can_motor.o.d 
	@${RM} ${OBJECTDIR}/can_motor.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  can_motor.s  -o ${OBJECTDIR}/can_motor.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/can_motor.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/can_motor.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/main_motor.o: main_motor.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main_motor.o.d 
	@${RM} ${OBJECTDIR}/main_motor.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  main_motor.s  -o ${OBJECTDIR}/main_motor.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/main_motor.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/main_motor.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/LEDs.o: LEDs.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/LEDs.o.d 
	@${RM} ${OBJECTDIR}/LEDs.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  LEDs.s  -o ${OBJECTDIR}/LEDs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/LEDs.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/LEDs.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/current_control.o: current_control.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/current_control.o.d 
	@${RM} ${OBJECTDIR}/current_control.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  current_control.s  -o ${OBJECTDIR}/current_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/current_control.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/current_control.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/backemf_phase_control.o: backemf_phase_control.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/backemf_phase_control.o.d 
	@${RM} ${OBJECTDIR}/backemf_phase_control.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  backemf_phase_control.s  -o ${OBJECTDIR}/backemf_phase_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/backemf_phase_control.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/backemf_phase_control.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/safety.o: safety.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/safety.o.d 
	@${RM} ${OBJECTDIR}/safety.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  safety.s  -o ${OBJECTDIR}/safety.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/safety.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/safety.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/inverse_vbat.o: inverse_vbat.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/inverse_vbat.o.d 
	@${RM} ${OBJECTDIR}/inverse_vbat.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  inverse_vbat.s  -o ${OBJECTDIR}/inverse_vbat.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/inverse_vbat.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/inverse_vbat.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/prog_mem.o: prog_mem.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/prog_mem.o.d 
	@${RM} ${OBJECTDIR}/prog_mem.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  prog_mem.s  -o ${OBJECTDIR}/prog_mem.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/prog_mem.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/prog_mem.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/main_menu.o: menu\ structure/main_menu.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/main_menu.o".d 
	@${RM} "${OBJECTDIR}/menu structure/main_menu.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/main_menu.s"  -o "${OBJECTDIR}/menu structure/main_menu.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/main_menu.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/main_menu.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_pwm.o: menu\ structure/menu_pwm.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_pwm.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_pwm.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_pwm.s"  -o "${OBJECTDIR}/menu structure/menu_pwm.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_pwm.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_pwm.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_functions.o: menu\ structure/menu_functions.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_functions.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_functions.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_functions.s"  -o "${OBJECTDIR}/menu structure/menu_functions.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_functions.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_functions.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_throttle.o: menu\ structure/menu_throttle.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_throttle.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_throttle.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_throttle.s"  -o "${OBJECTDIR}/menu structure/menu_throttle.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_throttle.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_throttle.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_throttle_functions.o: menu\ structure/menu_throttle_functions.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_throttle_functions.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_throttle_functions.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_throttle_functions.s"  -o "${OBJECTDIR}/menu structure/menu_throttle_functions.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_throttle_functions.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_throttle_functions.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_currents.o: menu\ structure/menu_currents.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_currents.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_currents.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_currents.s"  -o "${OBJECTDIR}/menu structure/menu_currents.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_currents.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_currents.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_erpms.o: menu\ structure/menu_erpms.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_erpms.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_erpms.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_erpms.s"  -o "${OBJECTDIR}/menu structure/menu_erpms.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_erpms.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_erpms.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_battery.o: menu\ structure/menu_battery.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_battery.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_battery.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_battery.s"  -o "${OBJECTDIR}/menu structure/menu_battery.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_battery.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_battery.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_sensors.o: menu\ structure/menu_sensors.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_sensors.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_sensors.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_sensors.s"  -o "${OBJECTDIR}/menu structure/menu_sensors.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_sensors.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_sensors.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_foc.o: menu\ structure/menu_foc.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_foc.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_foc.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_foc.s"  -o "${OBJECTDIR}/menu structure/menu_foc.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_foc.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_foc.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/convert_to_readable_L_and_R.o: menu\ structure/convert_to_readable_L_and_R.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o".d 
	@${RM} "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/convert_to_readable_L_and_R.s"  -o "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/convert_to_readable_L_and_R.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/motor_impedance_measurement.o: menu\ structure/motor_impedance_measurement.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/motor_impedance_measurement.o".d 
	@${RM} "${OBJECTDIR}/menu structure/motor_impedance_measurement.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/motor_impedance_measurement.s"  -o "${OBJECTDIR}/menu structure/motor_impedance_measurement.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/motor_impedance_measurement.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/motor_impedance_measurement.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_loop_coeffs.o: menu\ structure/menu_loop_coeffs.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_loop_coeffs.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_loop_coeffs.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_loop_coeffs.s"  -o "${OBJECTDIR}/menu structure/menu_loop_coeffs.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_loop_coeffs.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_loop_coeffs.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_filters.o: menu\ structure/menu_filters.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_filters.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_filters.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_filters.s"  -o "${OBJECTDIR}/menu structure/menu_filters.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_filters.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_filters.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_can.o: menu\ structure/menu_can.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_can.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_can.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_can.s"  -o "${OBJECTDIR}/menu structure/menu_can.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_can.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_can.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_rom.o: menu\ structure/menu_rom.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_rom.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_rom.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_rom.s"  -o "${OBJECTDIR}/menu structure/menu_rom.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_rom.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_rom.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/process_all_variables.o: process_all_variables.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/process_all_variables.o.d 
	@${RM} ${OBJECTDIR}/process_all_variables.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  process_all_variables.s  -o ${OBJECTDIR}/process_all_variables.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/process_all_variables.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/process_all_variables.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/report_checksum.o: menu\ structure/report_checksum.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/report_checksum.o".d 
	@${RM} "${OBJECTDIR}/menu structure/report_checksum.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/report_checksum.s"  -o "${OBJECTDIR}/menu structure/report_checksum.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/report_checksum.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/report_checksum.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_misc.o: menu\ structure/menu_misc.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_misc.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_misc.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_misc.s"  -o "${OBJECTDIR}/menu structure/menu_misc.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_misc.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_misc.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_recov.o: menu\ structure/menu_recov.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_recov.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_recov.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_recov.s"  -o "${OBJECTDIR}/menu structure/menu_recov.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_recov.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_recov.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/halls.o: halls.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/halls.o.d 
	@${RM} ${OBJECTDIR}/halls.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  halls.s  -o ${OBJECTDIR}/halls.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/halls.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/halls.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_halls.o: menu\ structure/menu_halls.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_halls.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_halls.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_halls.s"  -o "${OBJECTDIR}/menu structure/menu_halls.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_halls.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_halls.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/hallbased_phase_control.o: hallbased_phase_control.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/hallbased_phase_control.o.d 
	@${RM} ${OBJECTDIR}/hallbased_phase_control.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  hallbased_phase_control.s  -o ${OBJECTDIR}/hallbased_phase_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/hallbased_phase_control.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/hallbased_phase_control.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_temp.o: menu\ structure/menu_temp.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_temp.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_temp.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_temp.s"  -o "${OBJECTDIR}/menu structure/menu_temp.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_temp.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_temp.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/temp_macros.o: temp_macros.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/temp_macros.o.d 
	@${RM} ${OBJECTDIR}/temp_macros.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  temp_macros.s  -o ${OBJECTDIR}/temp_macros.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/temp_macros.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/temp_macros.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/temp_routines.o: temp_routines.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/temp_routines.o.d 
	@${RM} ${OBJECTDIR}/temp_routines.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  temp_routines.s  -o ${OBJECTDIR}/temp_routines.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/temp_routines.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/temp_routines.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_temp_functions.o: menu\ structure/menu_temp_functions.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_temp_functions.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_temp_functions.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_temp_functions.s"  -o "${OBJECTDIR}/menu structure/menu_temp_functions.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_temp_functions.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_temp_functions.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/calc_rom_variables.o: menu\ structure/calc_rom_variables.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/calc_rom_variables.o".d 
	@${RM} "${OBJECTDIR}/menu structure/calc_rom_variables.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/calc_rom_variables.s"  -o "${OBJECTDIR}/menu structure/calc_rom_variables.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/calc_rom_variables.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/calc_rom_variables.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_0_all.o: drive_0_all.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_0_all.o.d 
	@${RM} ${OBJECTDIR}/drive_0_all.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_0_all.s  -o ${OBJECTDIR}/drive_0_all.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_0_all.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_0_all.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_1_all.o: drive_1_all.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_1_all.o.d 
	@${RM} ${OBJECTDIR}/drive_1_all.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_1_all.s  -o ${OBJECTDIR}/drive_1_all.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_1_all.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_1_all.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_2_hall.o: drive_2_hall.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_2_hall.o.d 
	@${RM} ${OBJECTDIR}/drive_2_hall.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_2_hall.s  -o ${OBJECTDIR}/drive_2_hall.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_2_hall.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_2_hall.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_2_sensorless.o: drive_2_sensorless.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_2_sensorless.o.d 
	@${RM} ${OBJECTDIR}/drive_2_sensorless.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_2_sensorless.s  -o ${OBJECTDIR}/drive_2_sensorless.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_2_sensorless.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_2_sensorless.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_3_all.o: drive_3_all.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_3_all.o.d 
	@${RM} ${OBJECTDIR}/drive_3_all.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_3_all.s  -o ${OBJECTDIR}/drive_3_all.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_3_all.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_3_all.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_3_measurement_functions.o: drive_3_measurement_functions.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_3_measurement_functions.o.d 
	@${RM} ${OBJECTDIR}/drive_3_measurement_functions.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_3_measurement_functions.s  -o ${OBJECTDIR}/drive_3_measurement_functions.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_3_measurement_functions.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_3_measurement_functions.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/speed_control.o: speed_control.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/speed_control.o.d 
	@${RM} ${OBJECTDIR}/speed_control.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  speed_control.s  -o ${OBJECTDIR}/speed_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/speed_control.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/speed_control.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/correct_drive_selection.o: correct_drive_selection.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/correct_drive_selection.o.d 
	@${RM} ${OBJECTDIR}/correct_drive_selection.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  correct_drive_selection.s  -o ${OBJECTDIR}/correct_drive_selection.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/correct_drive_selection.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/correct_drive_selection.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/current_sensor_offset_measurement.o: menu\ structure/current_sensor_offset_measurement.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o".d 
	@${RM} "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/current_sensor_offset_measurement.s"  -o "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/current_sensor_offset_measurement.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_3_hall_measure.o: drive_3_hall_measure.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_3_hall_measure.o.d 
	@${RM} ${OBJECTDIR}/drive_3_hall_measure.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_3_hall_measure.s  -o ${OBJECTDIR}/drive_3_hall_measure.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_3_hall_measure.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_3_hall_measure.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_2to3_sensorless.o: drive_2to3_sensorless.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_2to3_sensorless.o.d 
	@${RM} ${OBJECTDIR}/drive_2to3_sensorless.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_2to3_sensorless.s  -o ${OBJECTDIR}/drive_2to3_sensorless.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_2to3_sensorless.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_2to3_sensorless.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/drive_2to3_hall.o: drive_2to3_hall.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/drive_2to3_hall.o.d 
	@${RM} ${OBJECTDIR}/drive_2to3_hall.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  drive_2to3_hall.s  -o ${OBJECTDIR}/drive_2to3_hall.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/drive_2to3_hall.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/drive_2to3_hall.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/chip_status.o: chip_status.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/chip_status.o.d 
	@${RM} ${OBJECTDIR}/chip_status.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  chip_status.s  -o ${OBJECTDIR}/chip_status.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/chip_status.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/chip_status.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_stored_status.o: menu\ structure/menu_stored_status.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_stored_status.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_stored_status.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_stored_status.s"  -o "${OBJECTDIR}/menu structure/menu_stored_status.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_stored_status.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_stored_status.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/chip_update.o: chip_update.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/chip_update.o.d 
	@${RM} ${OBJECTDIR}/chip_update.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  chip_update.s  -o ${OBJECTDIR}/chip_update.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/chip_update.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/chip_update.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/current_filtering.o: current_filtering.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/current_filtering.o.d 
	@${RM} ${OBJECTDIR}/current_filtering.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  current_filtering.s  -o ${OBJECTDIR}/current_filtering.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/current_filtering.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/current_filtering.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/determine_update.o: determine_update.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/determine_update.o.d 
	@${RM} ${OBJECTDIR}/determine_update.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  determine_update.s  -o ${OBJECTDIR}/determine_update.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/determine_update.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/determine_update.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/calc_wanted_ampli_imag.o: calc_wanted_ampli_imag.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/calc_wanted_ampli_imag.o.d 
	@${RM} ${OBJECTDIR}/calc_wanted_ampli_imag.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  calc_wanted_ampli_imag.s  -o ${OBJECTDIR}/calc_wanted_ampli_imag.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/calc_wanted_ampli_imag.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/calc_wanted_ampli_imag.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/mim_calculations.o: menu\ structure/mim_calculations.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/mim_calculations.o".d 
	@${RM} "${OBJECTDIR}/menu structure/mim_calculations.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/mim_calculations.s"  -o "${OBJECTDIR}/menu structure/mim_calculations.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/mim_calculations.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/mim_calculations.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/throttle_ramp.o: throttle_ramp.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/throttle_ramp.o.d 
	@${RM} ${OBJECTDIR}/throttle_ramp.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  throttle_ramp.s  -o ${OBJECTDIR}/throttle_ramp.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/throttle_ramp.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/throttle_ramp.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/floating_point.o: floating_point.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/floating_point.o.d 
	@${RM} ${OBJECTDIR}/floating_point.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  floating_point.s  -o ${OBJECTDIR}/floating_point.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/floating_point.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/floating_point.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/imp_process_data.o: imp_process_data.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/imp_process_data.o.d 
	@${RM} ${OBJECTDIR}/imp_process_data.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  imp_process_data.s  -o ${OBJECTDIR}/imp_process_data.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/imp_process_data.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/imp_process_data.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/imp_collect_data.o: imp_collect_data.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/imp_collect_data.o.d 
	@${RM} ${OBJECTDIR}/imp_collect_data.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  imp_collect_data.s  -o ${OBJECTDIR}/imp_collect_data.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/imp_collect_data.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/imp_collect_data.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/imp_collect_data_L.o: imp_collect_data_L.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/imp_collect_data_L.o.d 
	@${RM} ${OBJECTDIR}/imp_collect_data_L.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  imp_collect_data_L.s  -o ${OBJECTDIR}/imp_collect_data_L.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/imp_collect_data_L.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/imp_collect_data_L.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/imp_collect_data_R.o: imp_collect_data_R.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/imp_collect_data_R.o.d 
	@${RM} ${OBJECTDIR}/imp_collect_data_R.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  imp_collect_data_R.s  -o ${OBJECTDIR}/imp_collect_data_R.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/imp_collect_data_R.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/imp_collect_data_R.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/sine_i_imag.o: sine_i_imag.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/sine_i_imag.o.d 
	@${RM} ${OBJECTDIR}/sine_i_imag.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  sine_i_imag.s  -o ${OBJECTDIR}/sine_i_imag.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/sine_i_imag.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/sine_i_imag.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/menu\ structure/menu_KvLR.o: menu\ structure/menu_KvLR.s  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}/menu structure" 
	@${RM} "${OBJECTDIR}/menu structure/menu_KvLR.o".d 
	@${RM} "${OBJECTDIR}/menu structure/menu_KvLR.o" 
	${MP_CC} $(MP_EXTRA_AS_PRE)  "menu structure/menu_KvLR.s"  -o "${OBJECTDIR}/menu structure/menu_KvLR.o"  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  -Wa,-MD,"${OBJECTDIR}/menu structure/menu_KvLR.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax,--keep-locals$(MP_EXTRA_AS_POST)
	@${FIXDEPS} "${OBJECTDIR}/menu structure/menu_KvLR.o.d"  $(SILENT)  -rsi ${MP_CC_DIR}../  
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemblePreproc
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
dist/${CND_CONF}/${IMAGE_TYPE}/30F_powerstart_v2pA1.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o dist/${CND_CONF}/${IMAGE_TYPE}/30F_powerstart_v2pA1.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}      -mcpu=$(MP_PROCESSOR_OPTION)        -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  $(COMPARISON_BUILD)   -mreserve=data@0x800:0x81F -mreserve=data@0x820:0x821 -mreserve=data@0x822:0x823 -mreserve=data@0x824:0x84F   -Wl,,,--defsym=__MPLAB_BUILD=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--isr,--no-gc-sections,--fill-upper=0,--stackguard=16,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem,--memorysummary,dist/${CND_CONF}/${IMAGE_TYPE}/memoryfile.xml$(MP_EXTRA_LD_POST) 
	
else
dist/${CND_CONF}/${IMAGE_TYPE}/30F_powerstart_v2pA1.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o dist/${CND_CONF}/${IMAGE_TYPE}/30F_powerstart_v2pA1.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}      -mcpu=$(MP_PROCESSOR_OPTION)        -omf=coff -DXPRJ_default=$(CND_CONF)  -no-legacy-libc  $(COMPARISON_BUILD)  -Wl,,,--defsym=__MPLAB_BUILD=1,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--isr,--no-gc-sections,--fill-upper=0,--stackguard=16,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem,--memorysummary,dist/${CND_CONF}/${IMAGE_TYPE}/memoryfile.xml$(MP_EXTRA_LD_POST) 
	${MP_CC_DIR}/xc16-bin2hex dist/${CND_CONF}/${IMAGE_TYPE}/30F_powerstart_v2pA1.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX} -a  -omf=coff  
	
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/default
	${RM} -r dist/default

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(shell "${PATH_TO_IDE_BIN}"mplabwildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
