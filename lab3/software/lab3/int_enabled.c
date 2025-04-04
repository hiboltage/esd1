/*
 * int_enabled.c
 *
 *  Created on: Feb 11, 2025
 *      Author: steve
 */

#define PB_ADDRESS		0x11040		//base addresses
#define SW_ADDRESS		0x11050
#define HEX0_ADDRESS	0x11020

#define BASE_ADDRESS	0x12340000

#define ZERO	0xC0	//ssd display values
#define ONE		0xF9
#define TWO		0xA4
#define THREE	0xB0
#define FOUR	0x99
#define FIVE	0x92
#define SIX		0x82
#define SEVEN	0xF8
#define EIGHT	0x80
#define NINE	0x98

typedef unsigned int		uint32;		//typedefs
typedef unsigned short		uint16;
typedef unsigned char		uint8;


void main(){

	uint32* hex0 = (uint32*)HEX0_ADDRESS;			//pointer to hex0
	volatile uint32* pb = (uint32*)PB_ADDRESS;		//pointer to pushbuttons
	volatile uint32* sw	= (uint32*)SW_ADDRESS;		//pointer to switches

	uint8 key1 = 0x00;	//variables to store read values
	uint8 sw0 = 0x00;

	uint8 dispNums[] = {ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE};
	uint8 dispNum = 0;	//dispNums index to display

	*(pb + 2) = 0x02;	//enable interrupts on key1

	*hex0 = dispNums[dispNum];	//write 0 to hex0

	while(1){

		key1 = 0x02 & *pb;	//read key1
		if (!key1){			//when key1 is pressed

			while (!key1){	//wait for key1 release
				key1 = 0x02 & *pb;	//check key1 again
			}

			sw0 = 0x01 & *sw;	//check sw0 value
			if (sw0){			//if sw0 high

				if (dispNum == 9){	//overflow protection
					dispNum = 9;
				}
				else{
					dispNum += 1;	//increment display number
				}
			}
			else{				//if sw0 low

				if (dispNum == 0){	//underflow protection
					dispNum = 0;
				}
				else{
					dispNum -= 1;	//decrement display number
				}
			}

			*hex0 = dispNums[dispNum];	//display number
		}

	}	//end while(1)
}	//end main
