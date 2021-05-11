#include <msp430.h> 


/**
 * main.c
 */
#include <msp430.h>

#include "data_protocol.h"
#include "bluetooth_module.h"
#include "temp_module.h"

struct data_packet packet = {
                                    Normal,
                                    0xFFFFFFFF,
                                    1
};

void general_setup() {
    WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
    DCOCTL = 0;                               // Select lowest DCOx and MODx settings
    BCSCTL1 = CALBC1_1MHZ;                    // Set DCO
    DCOCTL = CALDCO_1MHZ;

    // Set up interrupt for light sensor pin
    P1SEL &= ~BIT3;
    P1DIR &= ~BIT3;

    // Set up on board LED
    P1SEL &= ~BIT0;
    P1DIR |= BIT0;
    P1OUT |= BIT0;

    // Set up timer for periodic sending of information
    CCTL0 = CCIE;                             // CCR0 interrupt enabled
    CCR0 = 50000;
    TACTL = TASSEL_2 + MC_1 + ID_3;           // SMCLK, upmode
}

int main(void)
{
    general_setup();
    setup_data_protocol_module();
    setup_bluetooth_module();
    setup_temp_module();


    while (1) {
        __bis_SR_register(LPM0_bits + GIE);

        get_temperature_sample(&packet);

        // Get light sensor data
        if (P1IN & BIT3)
            packet.lightIsOn = 0;
        else
            packet.lightIsOn = 1;


        P1OUT ^= BIT6;
        TransferDataPacket(&packet);
    }

}


// Timer A0 interrupt service routine
// This Routine periodically sends data over bluetoothooth
#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer_A (void)
#elif defined(__GNUC__)
void __attribute__ ((interrupt(TIMER0_A0_VECTOR))) Timer_A (void)
#else
#error Compiler not supported!
#endif
{
    __bic_SR_register_on_exit(LPM0_bits);
}


