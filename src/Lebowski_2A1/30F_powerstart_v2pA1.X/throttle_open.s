.include "p30F4011.inc"
.include "defines.inc"

.text
.global throttle_open
throttle_open:
;-------------------------------------- reverse pin as input, initialise direction to forward

    bset TRISF, #6
    bclr flags1, #reverse
    bclr flags1, #reverse_request

;-------------------------------------- select based on throttle mode

    btss flags_rom, #analog_throttle
    bra thop_no_analog_throttle

;-------------------------------------- initialise analog throttle
                                            ;initialise AN7 and AN8
    btss flags_rom, #throttle_AN7
    bra thop_skip_7
    bclr ADPCFG, #7
    bset TRISB, #7
thop_skip_7:
    btss flags_rom, #throttle_AN8
    bra thop_skip_8
    bclr ADPCFG, #8
    bset TRISB, #8
thop_skip_8:					

    btsc flags_rom, #tx_throttle
    call CAN_open_TX

    bra thop_end

;-------------------------------------- initialise CAN_rx throttle
thop_no_analog_throttle:

    call CAN_open_RX

;-------------------------------------- end
thop_end:
    return

;***********************************************************




.end
