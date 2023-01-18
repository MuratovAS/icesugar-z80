;--------------------------------------------------------------------------
;  crt0.s - Generic crt0.s for a Z80
;
;  Copyright (C) 2000, Michael Hope
;  Modified for iceZ0mb1e - FPGA 8-Bit TV80 SoC (C) 2018, Franz Neumann
;
;  This library is free software; you can redistribute it and/or modify it
;  under the terms of the GNU General Public License as published by the
;  Free Software Foundation; either version 2.1, or (at your option) any
;  later version.
;
;  This library is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this library; see the file COPYING. If not, write to the
;  Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston,
;   MA 02110-1301, USA.
;
;  As a special exception, if you link this library with other files,
;  some of which are compiled with SDCC, to produce an executable,
;  this library does not by itself cause the resulting executable to
;  be covered by the GNU General Public License. This exception does
;  not however invalidate any other reasons why the executable file
;   might be covered by the GNU General Public License.
;--------------------------------------------------------------------------

stacktop = #0xFFFF

			.module crt0
			.globl	_main
			.globl	_isr1
			.globl	_isr2
			.globl	_isr3
			.globl	_isr4
			.globl	_isr5
			.globl	_isr6
			.globl	_isr7
			.globl	_isrn

			.area	_HEADER (ABS)

			;; Reset vector ;;irq0 low priority
			.org 	0x00
			im 0
			jp	init
			;;irq1
			.org	0x08
			jp	_isr1
			reti
			;;irq2
			.org	0x10
			jp	_isr2
			reti
			;;irq3
			.org	0x18
			jp	_isr3
			reti
			;;irq4
			.org	0x20
			jp	_isr4
			reti
			;;irq5
			.org	0x28
			jp	_isr5
			reti
			;;irq6
			.org	0x30
			jp	_isr6
			reti
			;;im1 or irq7 top priority
			.org	0x38
			jp	_isr7
			reti
			;;nmi
			.org	0x66
			jp	_isrn

			.org	0x100
init:
			;; Stack at the top of memory.
			ld	sp,#stacktop

			;; Initialise global variables
			call    gsinit
			call	_main
			jp	_exit

			;; Ordering of segments for the linker.
			.area	_HOME
			.area	_CODE
			.area   _GSINIT
			.area   _GSFINAL

			.area	_DATA
			.area	_BSEG
			.area   _BSS
			.area   _HEAP

			.area   _CODE

__clock::
			ld	a,#2
			rst	0x08
			ret

_exit::
			;; Exit - special code to the emulator
			ld	a,#0
			rst	0x08
			1$:
			halt
			jr	1$

.area   _GSINIT
			gsinit::

.area   _GSFINAL
			ret
