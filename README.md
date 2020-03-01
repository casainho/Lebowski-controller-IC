# About Lebowski controller IC firmware
This is an archive of the Lebowski controller IC 2.A1 source code and (short) explanation [as shared on endless-sphere forum](https://endless-sphere.com/forums/viewtopic.php?p=1533403&sid=e2e5ab24d0e911ac110ec6a7a4b55f2a#p1533223):

![](Screenshot%20from%202020-03-01%2014-48-37.png)

You [view the source code here](https://github.com/OpenSource-EBike-firmware/Lebowski-controller-IC/tree/master/src/Lebowski_2A1/30F_powerstart_v2pA1.X) or [download the original ZIP file here](https://github.com/OpenSource-EBike-firmware/Lebowski-controller-IC/raw/master/src/Lebowski_2A1.zip).

# Original notes shared on forum

In essence the sensorless part of the controller is a Stator Oriented Controller but with an added shift in the output stage to make it a Field Oriented Controller.

A Stator Oriented Controller works on a simple principle: to get maximum power at the stator point of view the voltage vector must align with the current vector. The voltage vector is known as this is the voltage at the output of the controller. The controller generates this itself so it knows the vector location. The current vector is also known as this is measured with current sensors in the controller output lines. This is a pure electrical view of getting max power, no knowledge magnetic fields, motor construction or motor properties is necessary for this.

All calculations are done on the stator level. Only at the last stage in the output section a 90 degree voltage shift is added. This shift is calculated based on 2 * pi * I_throttle * L_motor (assuming no fieldweakening). This shift moves the controller output voltage ahead of the motor current, making it a Field Oriented Controller. Again, from a pure electrical point of view this is all that is necessary to get max power.

Maximum power is achieved when the current is aligned with the RECEIVING voltage source. So for generating mechanical power the current is aligned with the motor BackEMF (by means of adding the 90 degree shifted inductor voltage from the previous paragraph). For regen however the receiving voltage is the stator voltage, so for regen the 90 degree shifted voltage is not added and the controller operates as a Stator Oriented Controller. This gives less than maximum (braking) torque, but does give maximum current back into the battery (max regen efficiency).

![](DSC02269-800x800.jpg)

The picture above shows the block diagram for sensorless mode (drive 3). On the left is the conversion from the 3 motor currents to the current vector (in the complex domain, I_r +j*I_i , r stands for real, i stands for imaginary, j is the sqrt(-1)) . In standard literature this is both the Clarke and Park transform in one (when this code was written I didn't know about Clarke and Park..) . This then goes into the loop filters. The output of the loop filters is motor speed (omega in the picture, phi_int in the code), motor phase (phi_motor in the code) and output amplitude (ampli_real in the code). The for FOC necessary voltage shift is directly calculated based on omega*L*I_throttle and placed in ampli_imag in the code. Then on the right the output block calculates the three motor voltages.

There is no observer or anything like that (I actually dont know what that is). Underneath the loopfilter block and output block are further explained.

![](DSC02270-800x800.jpg)

The loopfilters is where things get interesting. The loopfilter part for phase and speed is based on a PLL and contains 2 integrators. The loopfilter part for amplitude (the real part V_r of the amplitude) is a simple first order loopfilter containing only 1 integrator.

The inputs of this block is based on the errors in the motor currents. The loopfilters however directly control the controller output voltages. To make the translation from currents to voltages, a multiplication with the (phase of the) motor impedance is included before the actual loop filters. Ideally the phase of the motor impedance is used here, but if unknown then 45 degrees is also good. The impact of adding this rotator is very interesting. It links both phase and amplitude together. At low speed (where the rotator rotates over 0 degrees as motor impedance is dominated by R) an error in phase results in action taken by the phase control loop, and an error in amplitude is dealt with by the amplitude control loop. But at high speed where the motor L impedance is much higher than motor R, so the rotator rotates over 90 degrees. This means that errors in phase are dealt with by the AMPLITUDE control loop, and error in current amplitude is dealt with by the PHASE control loop. A 'golden', always good phase to rotate over is 45 degrees.

Lastly, before the loopfilters simple quantisers are added. These generate a simple +1 or -1 output based on the sign of their input signals. The effect of these is that the control loops are like Sigma Delta converter control loops, not the more standard PID etc. The quantizers are in series with the unknown motor integrator. Because of the adaptive gain inherent in quantizers (see Sigma Delta theory) this makes the control loops independent of the motor R and L (and this is the reason why Arlo1's Nissan Leaf motor runs with the same control loop coefficients as my 4025 low inductance small RC motor). In laymans terms, the motor L and R determines the amplitude of the signals going into the quantizers. But since the quantizers only output +1 or -1, the size of the signals going into the quantizers does not matter. And therefore motor L and R does not matter. In technical terms, in 1 bit Sigma Delta theory it is known that the single integrator in the control loop representing the 1st order does not matter, its properties ONLY determine the amount of quantisation noise in the loop but it does not impact loop stability. Here the motor L and R are the single integrator representing the 1st order, so therefore the motor properties determine the amount of quantisation noise BUT NOT THE LOOP STABILITY.

![](DSC02271-800x800.jpg)

Lastly the output voltages for the 3 output phases are calculated. I do not use SVM or anything like that, each phase is calculated independently of the other 2. Simple 1st order noise shapers are used to deal with the quantisation inherent in the PWM process. The output amplitude of the loop filter (V_r) together with the inductor based (no fieldweakening) voltage shift (V_i) is rotated over motor phase phi . Then controller output phase A is the real part of this complex voltage. For phase B the complex voltage is rotated 120 degrees forward and the real part is taken. For phase C a rotation over -120 degrees is applied.

