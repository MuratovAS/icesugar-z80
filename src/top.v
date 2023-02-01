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
	
	inout  pin_usbp,
	inout  pin_usbn,
	output pin_pu,

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
	wire clk_48m;
	wire clk_12m;

	wire[7:0] P1_out;
	wire[7:0] P2_out;
	wire [3:0] SW;
	wire [7:0] DEBUG;

	wire i2c_scl;
	wire i2c_sda_out;
	wire i2c_sda_in;
	wire i2c_sda_oen;

	reg LED_R, LED_G, LED_B;

    always @(posedge clk_12m)
    begin
		LED_R <= !P1_out[0];
		LED_G <= !P1_out[1];
		LED_B <= !P1_out[2];
	end

	assign SW = {SW_4, SW_3, SW_2, SW_1};
	assign DEBUG = {DEBUG_7, DEBUG_6, DEBUG_5, DEBUG_4, DEBUG_3, DEBUG_2, DEBUG_1, DEBUG_0};

	//internal oscillators seen as modules
	//Source = 48MHz, CLKHF_DIV = 2’b00 : 00 = div1, 01 = div2, 10 = div4, 11 = div8 ; Default = “00”
	//SB_HFOSC SB_HFOSC_inst(
	SB_HFOSC #(.CLKHF_DIV("0b10")) SB_HFOSC_inst (
		.CLKHFEN(1),
		.CLKHFPU(1),
		.CLKHF(clk_12m)
	);

	//10khz used for low power applications (or sleep mode)
	/*SB_LFOSC SB_LFOSC_inst(
		.CLKLFEN(1),
		.CLKLFPU(1),
		.CLKLF(clk_10k)
	);*/
	
	// toolchain-ice40/bin/icepll
	/*SB_PLL40_CORE #(
      .FEEDBACK_PATH("SIMPLE"),
      .PLLOUT_SELECT("GENCLK"),
      .DIVR(4'b0000),
      .DIVF(7'b0111111),
      .DIVQ(3'b100),
      .FILTER_RANGE(3'b001),
    ) SB_PLL40_CORE_inst (
      .RESETB(1'b1),
      .BYPASS(1'b0),
      .PLLOUTCORE(clk_48m),
      .REFERENCECLK(clk_12m)
   );*/

	iceMCU core (
		.clk		(clk_12m),
		.clk_48m	(clk_48m),
		.uart_txd	(uart_txd),
		.uart_rxd	(uart_rxd),
    	.spi_cs		(spi_cs),
    	.spi_sclk	(spi_sclk),
		.spi_mosi	(spi_mosi),
		.spi_miso	(spi_miso),
		.i2c_scl	(i2c_scl),
		.i2c_sda	(i2c_sda),
		.pin_usbp	(pin_usbp),
		.pin_usbn	(pin_usbn),
		.pin_pu		(pin_pu),
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
