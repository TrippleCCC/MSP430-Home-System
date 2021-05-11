/*
 * data_protocol.c
 *
 *  Created on: May 4, 2021
 *      Author: nonsochukwurah
 */


#include <msp430.h>
#include "data_protocol.h"

void setup_data_protocol_module() {
    // Setup light for flashing
    P1DIR |= BIT6;
    P1OUT |= BIT6;
}

// Protocol for transerfering data over bluetooth
int TransferDataPacket(struct data_packet *data)
{
    int i;
    unsigned char *data_buffer;

    data_buffer = CAST_TO_CHAR_PTR(data);

    // Begin the data message by sending zeros
    for (i = 0; i < PACKET_START_LEN; i++) {
        while (!(IFG2 & UCA0TXIFG));
        UCA0TXBUF = 0;
    }

    // Then send over each byte
    for (i = 0; i < DATA_PACKET_SIZE; i++) {
        while (!(IFG2 & UCA0TXIFG));
        UCA0TXBUF = *data_buffer;
        data_buffer++;
    }

    // End the message with all ones
    for (i = 0; i < PACKET_START_LEN; i++) {
        while (!(IFG2 & UCA0TXIFG));
        UCA0TXBUF = 0;
    }

    return 0;
}

