/*
 * lab6_part2.c
 *
 *  Created on: Mar 25, 2025
 *      Author: steven bolt
 */

typedef unsigned int		uint32;
typedef unsigned short		uint16;
typedef unsigned char		uint8;

#define LEDS_ADDRESS 		0x9010		// leds base address
uint32* leds = (uint32*)LEDS_ADDRESS;	// pointer to leds base address

void byte_ram_test(uint32 start_addr, int num_bytes, uint8 test_data){
	uint8 read = 0x00;						// return value for verification
	uint8 *byte_ptr = (uint8*)start_addr;	// point to starting address

	for(int i=0; i < num_bytes; i++){
		byte_ptr = start_addr + i;		// offset from start address by i bytes
		*byte_ptr = test_data;			// write data to offset address
	}

	*byte_ptr = start_addr;		// reset to starting adddress
	for(int i=0; i < num_bytes; i++){
		read = (*byte_ptr + i);		// read data from start address offset by i bytes

		if(read != test_data){		// if read data does not match input
			*leds = 0x00000000;		// turn all leds red
		}

	}

}

// FIX THIS BEFORE RUNNING (make identical to int_ram_test)
void short_ram_test(uint32 start_addr, int num_bytes, uint16 test_data){
	uint16 read = 0x0000;				// return value for verification
	uint16* short_ptr = (uint16*)start_addr;	// point to starting address

	for(int i=0; i < num_bytes; i++){
		short_ptr = start_addr + i;		// offset from start address by i*2 bytes
		*short_ptr = test_data;			// write data to offset address
	}

	*short_ptr = start_addr;	// reset to starting address
	for(int i=0; i < num_bytes; i++){
		read = (*short_ptr + i);		// read data from start address offset by i*2 bytes

		if(read != test_data){		// if read data does not match input
			*leds = 0x00000000;		// turn all leds red
		}

	}

}

// FIX THIS BEFORE RUNNING (make identical to int_ram_test)
void int_ram_test(uint32 start_addr, uint32 num_bytes, uint32 test_data){
	uint32 read = 0x00000000;				//return value for verification
	uint32 *int_ptr = (uint32*)start_addr;	// point to starting address
	uint32 *offset = (uint32*)0x00000000;	// offset counter

	for(uint32 i=0; i < num_bytes; i++){
		offset = int_ptr + i;	// increment offset pointer
		*offset = test_data;	// write to offset from start address by i*4 bytes
	}

	for(uint32 i=0; i < num_bytes; i++){
		offset = int_ptr + i;	// increment offset pointer
		read = *offset;			// read data from start address offset by i*4 bytes

		if(read != test_data){		// if read data does not match input
			*leds = 0b11111111;		// turn all leds red
		}

	}

}

int main(){
	//uint8 byte_data = 0xFF;
	//uint8 byte_base = 0x00;

	//uint16 short_data = 0x1234;
	//uint16 short_base = 0x0000;

	uint32 int_data = 0x89ABCDEF;
	uint32 int_base = 0x00000000;

	while(1){

		int_ram_test(int_base, 4096, int_data);

	}

	return 0;
}
