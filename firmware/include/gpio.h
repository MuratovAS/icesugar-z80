//
// icesugar-z80 for TV80 SoC for Lattice iCE40
//
// Copyright (c) 2022 Aleksej Muratov
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#ifndef __GPIO_H
#define __GPIO_H

#include <stdint.h>
#include <stdbool.h>

typedef enum
{
    PIN1    = 0b00000001,
    PIN2    = 0b00000010,
    PIN3    = 0b00000100,
    PIN4    = 0b00001000,
    PIN5    = 0b00010000,
    PIN6    = 0b00100000,
    PIN7    = 0b01000000,
    PIN8    = 0b10000000
}PIN_IO;

typedef enum
{
    PORTA    = 0b00000001,
    PORTB    = 0b00000010
}PORT_IO;

typedef enum
{
    INPUT   = 0,
    OUTPUT  = 1
}TYPE_IO;


bool gpio_read(PORT_IO port, PIN_IO pin);
void gpio_write(PORT_IO port, PIN_IO pin, bool state);
void gpio_conf(PORT_IO port, TYPE_IO type);

#endif
