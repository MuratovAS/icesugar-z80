//
// iceZ0mb1e - FPGA 8-Bit TV80 SoC for Lattice iCE40
// with complete open-source toolchain flow using yosys and SDCC
//
// Copyright (c) 2018 Franz Neumann (netinside2000@gmx.de)
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

`include "src/iceMCU.v"

module top(
	input uart_rxd,
	output uart_txd,

    output spi_cs,
	output spi_sclk,
	output spi_mosi,
	input  spi_miso,
	
	output i2c_scl,
	inout i2c_sda,
	
	output LED_R,
	output LED_G,
	output LED_B,
	
	input SW_1,
	input SW_2,
	input SW_3,
	input SW_4,

	output DEBUG_0,
	output DEBUG_1,
	output DEBUG_2,
	output DEBUG_3,
	output DEBUG_4,
	output DEBUG_5,
	output DEBUG_6,
	output DEBUG_7
);

	wire clk;

	wire[7:0] P1_out;
	wire[7:0] P2_out;
	wire [3:0] SW;
	wire [7:0] DEBUG;

	wire i2c_scl;
	wire i2c_sda_out;
	wire i2c_sda_in;
	wire i2c_sda_oen;

	reg LED_R, LED_G, LED_B;

    always @(posedge clk)
    begin
		LED_R <= !P1_out[0];
		LED_G <= !P1_out[1];
		LED_B <= !P1_out[2];
	end

	assign SW = {SW_4, SW_3, SW_2, SW_1};
	assign DEBUG = {DEBUG_7, DEBUG_6, DEBUG_5, DEBUG_4, DEBUG_3, DEBUG_2, DEBUG_1, DEBUG_0};

	//Source = 48MHz, CLKHF_DIV = 2’b00 : 00 = div1, 01 = div2, 10 = div4, 11 = div8 ; Default = “00”
	SB_HFOSC #(.CLKHF_DIV("0b10")) osc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(clk)
	);

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) i2c_sda_pin (
		.PACKAGE_PIN(i2c_sda),
		.OUTPUT_ENABLE(i2c_sda_oen),
		.D_OUT_0(i2c_sda_out),
		.D_IN_0(i2c_sda_in)
	);

	iceMCU core (
		.clk		(clk),
		.uart_txd	(uart_txd),
		.uart_rxd	(uart_rxd),
    	.spi_cs		(spi_cs),
    	.spi_sclk	(spi_sclk),
		.spi_mosi	(spi_mosi),
		.spi_miso	(spi_miso),
		.i2c_scl	(i2c_scl),
		.i2c_sda_in	(i2c_sda_in),
		.i2c_sda_out	(i2c_sda_out),
		.i2c_sda_oen	(i2c_sda_oen),
		.PA_out		(P1_out),
		.PA_in		(8'h55),
		.PA_oen		(),
		.PB_out		(P2_out),
		.PB_in		(8'hAA),
		.PB_oen		(),
		.SW			(SW),
		.debug		(DEBUG)
	);
	defparam core.RAM_TYPE = 1; // 0 => BRAM, 1 => SPRAM (UltraPlus)
	
endmodule
