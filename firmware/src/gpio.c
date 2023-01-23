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

#include "main.h"
#include "gpio.h"

bool gpio_read(PORT_IO port, PIN_IO pin)
{
    bool state;
    switch(port)
    {
        case PORTA: state = port_a & pin; break;
        case PORTB: state = port_b & pin; break;
        default: state = 0;
    }
    return state;
}

void gpio_write(PORT_IO port, PIN_IO pin, bool state)
{
    switch(port)
    {
        case PORTA:
            if (state == true)
                port_a |= pin; //set the bit
            else
                port_a &= ~pin; //reset the bit
            break;
        case PORTB:
            if (state == true)
                port_b |= pin; //set the bit
            else
                port_b &= ~pin; //reset the bit
            break;
    }
}

void gpio_conf(PORT_IO port, TYPE_IO type)
{
    if (type == INPUT)
        port_cfg &= ~port; //reset the bit
    else
        port_cfg |= port; //set the bit
}
