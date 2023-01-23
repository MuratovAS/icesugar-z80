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
#include "uart.h"

void isr1(void)
{
    snprintf(strbuf, sizeof(strbuf), "isr1_isr\r\n");
    uart_write(strbuf);
}

void isr2(void)
{
    snprintf(strbuf, sizeof(strbuf), "isr2_isr\r\n");
    uart_write(strbuf);
}

void isr3(void)
{
    snprintf(strbuf, sizeof(strbuf), "isr3_isr\r\n");
    uart_write(strbuf);
}

void isr4(void)
{
    snprintf(strbuf, sizeof(strbuf), "isr4_isr\r\n");
    uart_write(strbuf);
}

void isr5(void)
{
    snprintf(strbuf, sizeof(strbuf), "isr5_isr\r\n");
    uart_write(strbuf);
}

void isr6(void)
{
    snprintf(strbuf, sizeof(strbuf), "isr6_isr\r\n");
    uart_write(strbuf);
}

void isr7(void)
{
    snprintf(strbuf, sizeof(strbuf), "isr7_isr\r\n");
    uart_write(strbuf);
}

void isrn(void) __critical __interrupt
{
    snprintf(strbuf, sizeof(strbuf), "isrn_isr\r\n");
    uart_write(strbuf);
}