/*
 * data_protocol.h
 *
 *  Created on: May 4, 2021
 *      Author: nonsochukwurah
 */

#ifndef DATA_PROTOCOL_H_
#define DATA_PROTOCOL_H_

enum DeviceStatus {
    Normal = 1,
    Alert = 2,
    Panicking = 3,
};

struct __attribute__((__packed__)) data_packet{
    unsigned char device_status;
    long temp;
    unsigned char lightIsOn;
}; // Total bytes: 6

#define PACKET_START_LEN (7)

void setup_data_protocol_module(void);

int TransferDataPacket(struct data_packet *data);

// Helpful macros
#define DATA_PACKET_SIZE (sizeof(struct data_packet))
#define CAST_TO_CHAR_PTR(ptr) ((unsigned char *) ptr)

#endif /* DATA_PROTOCOL_H_ */
