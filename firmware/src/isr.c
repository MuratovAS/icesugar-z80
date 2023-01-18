#include "icez0mb1e.h"
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