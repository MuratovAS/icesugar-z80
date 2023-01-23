//
// icesugar-z80 for TV80 SoC for Lattice iCE40
//
// Copyright (c) 2018 Franz Neumann (netinside2000@gmx.de)
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
#include "mini-printf.h"
#include "stdlib.h"
#include "uart.h"
#include "i2c.h"
#include "spi.h"
#include "dma.h"
#include "gpio.h"

int8_t start = 0;
uint16_t last_usable_addr = 0;
uint16_t *addr;
char strbuf[180];


void main ()
{
    uint8_t buffer[64];

    //UART Test:
    uart_initialize(9600);
    uart_write("BOOT\r\n");
    snprintf(strbuf, sizeof(strbuf), "Hello world, TV80 SoC\r\n");
    uart_write(strbuf);

    //i2c Test: // DHT12 // PCF8523
    i2c_config(120); //100kHz
    i2c_read_buf(0x5C, buffer, 5); // DHT12
    viewMemory(buffer, 5);
    i2c_read_buf(0x68, buffer, 20); // PCF8523
    viewMemory(buffer, 20);

    //SPI Test // 25L008A
    spi_config(0, 12); //1MHz
    uint16_t len = 64;
    uint8_t spi_send[4] = {0x3, 0x00, 0x00, 0x00};
    spi_xfer(spi_send, buffer, 4, len);
    viewMemory(buffer, 64);

    //Port test
    gpio_conf(PORTA,OUTPUT);
    gpio_write(PORTA, PIN1, true);
    delay(24000);
    gpio_write(PORTA, PIN1, false);
    delay(24000);
    gpio_write(PORTA, PIN2, true);
    delay(24000);
    gpio_write(PORTA, PIN2, false);
    delay(24000);
    gpio_write(PORTA, PIN3, true);
    delay(24000);
    gpio_write(PORTA, PIN3, false);
    delay(24000);
    port_a = 0b00000000;

    gpio_conf(PORTB,INPUT);
    snprintf(strbuf, sizeof(strbuf), "port B, pin 2 = %d\n\r", gpio_read(PORTB,PIN2));
    uart_write(strbuf);

    
    //Interrupt en
    cpu_im(0);
    cpu_ei();

    //UART Terminal
    snprintf(strbuf, sizeof(strbuf), "Action key:\n\r a - Test portA \n\r b - Test portB \n\r r - CPU Reset \n\r c - View ROM \n\r d - Test DMA \n\r m - View RAM \n\r t - Test RAM \n\r");
    uart_write(strbuf);
    while(1)
    {
        int8_t uart_rx = getchar();

        switch(uart_rx)
        {
            case 'a': // Test portA
                port_a = getchar();
                snprintf(strbuf, sizeof(strbuf), "port_a = ");
                uart_write(strbuf);
                printBits(sizeof(port_a), port_a);
                snprintf(strbuf, sizeof(strbuf), "\n\r");
                uart_write(strbuf);
                break;
            case 'b': // Test portB
                port_b = getchar();
                snprintf(strbuf, sizeof(strbuf), "port_b = 0x%X\n\r", port_b);
                uart_write(strbuf);
                break;
            case 'r': // CPU Reset
                cpu_reset();
                break;
            case 'c': // View ROM
                viewMemory((uint8_t*)SYS_ROM_ADDR, SYS_ROM_SIZE);
                break;
            case 'd': // Test DMA
                snprintf(strbuf, sizeof(strbuf), "Test DMA A(0x8000) -> B(0x8010)x8\n\r");
                uart_write(strbuf);
                viewMemory((uint8_t*)0x8000, 0x0050);
                dma_confA(MEM, (uint16_t)0x8000, 0);
                dma_confB(MEM, (uint16_t)0x8010, 7);
                dma_cmd(CONF_FLAG, true);
                dma_cmd(CONF_LOOP, false);
                dma_cmd(CONF_EN, true);
                viewMemory((uint8_t*)0x8000, 0x0050);
                break;
            case 'm': // View RAM
                viewMemory((uint8_t*)SYS_RAM_ADDR, SYS_RAM_SIZE);
                break;
            case 't': // Test RAM
                last_usable_addr = 0;
                int8_t free = 0;
                uint16_t *addr = &free;
                while((uint16_t)addr < (SYS_RAM_ADDR+SYS_RAM_SIZE))
                {
                    *(addr) = (uint16_t)addr;
                    if(*(addr) != addr)
                    {
                        break;
                    }
                    last_usable_addr = (uint16_t)addr;
                    addr++;
                }
                snprintf(strbuf, sizeof(strbuf), "RAM: start = 0x%X, last usable = 0x%X, ramsize = %u\n\r",
                    (uint16_t)&start, last_usable_addr, last_usable_addr-(uint16_t)&start
                );
                uart_write(strbuf);
                break;
            default:
                putchar(uart_rx);
                break;
        }
    }
}