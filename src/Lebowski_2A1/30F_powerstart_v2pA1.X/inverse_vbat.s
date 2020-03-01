.include "p30F4011.inc"
.include "defines.inc"

.text

;*****************************************************************

.global inverse_vbat
;
;corrupted variables
; w0, w1, w2, w3
;
;filter_inv_vbat = (512*65536 / battery adc reading)
inverse_vbat:
;--------------------------------------- get supply, force in-range [512..1023]
    mov supply_voltage, w0
    btss w0, #9
    mov #513, w0
;--------------------------------------- calc loop filter input
    mul filter_inv_vbat
    mov #512, w0
    sub w0, w3, w0
;--------------------------------------- update integrator 1
    add filter_inv_vbat+2
;--------------------------------------- calc value to be added to output integrator
    sl w0, w1
    mov filter_inv_vbat+2, w0
    asr w0, #6, w0
    add w1, w0, w0
;--------------------------------------- add to output integrator but stay in range !
    add filter_inv_vbat
                                            ;no problem if w0 is negative, end
    btsc w0, #15
    return
                                            ;clip if carry after add
    btsc SR, #C
    setm filter_inv_vbat
;--------------------------------------- end
    return

.end

