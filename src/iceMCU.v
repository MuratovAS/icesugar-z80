//
// iceZ0mb1e - FPGA 8-Bit TV80 SoC for Lattice iCE40
// with complete open-source toolchain flow using yosys and SDCC
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

`include "src/membram.v"
`include "src/memspram.v"
`include "src/simplei2c_wrapper.v"
`include "src/simplespi_wrapper.v"
`include "src/simpleuart_wrapper.v"
`include "src/simpleusb_wrapper.v"
`include "src/simpleio.v"
`include "src/simpleirq.v"
`include "src/simpledma.v"
`include "src/simplewdt.v"
`include "src/tv80/tv80s.v"
`include "src/clk_divider.v"

module iceMCU  #(
	parameter RAM_TYPE = 0,
	parameter RAM_WIDTH = 15,
	parameter ROM_WIDTH = 13,
	parameter RAM_LOC = 16'h8000
) (
	input clk,
	input clk_48m,
	output uart_txd,
	input uart_rxd,
	output i2c_scl,
	input i2c_sda,
    output spi_sclk,
	output spi_mosi,
	input  spi_miso,
    output spi_cs,
	inout  pin_usbp,
	inout  pin_usbn,
	output pin_pu,
    output[7:0] PA_out,
    input[7:0] PA_in,
    output PA_oen,
    output[7:0] PB_out,
    input[7:0] PB_in,
    output PB_oen,
	input[3:0] SW,
	output[7:0] debug
);
	localparam ROM_SIZE = (1 << ROM_WIDTH);
	localparam RAM_SIZE = (1 << RAM_WIDTH);

	//Z80 Bus:
	reg         wait_n = 1'b0;
	reg         nmi_n = 1'b0;
	reg         sys_reset_n = 1'b0;
	reg         sys_busrq_n = 1'b0;
	reg         sys_int_n = 1'b0;

	wire        reset_n;
	wire        busrq_n;
	wire        int_n;
	wire        m1_n;
	wire        mreq_n;
	wire        iorq_n;
	wire        rd_n;
	wire        wr_n;
	wire        rfsh_n;
	wire        halt_n;
	wire        busak_n;
	wire [15:0] addr;
	wire [7:0]  data_miso;
	wire [7:0]  data_mosi;

	wire [7:0] cpu_data_mosi;
	wire [7:0] dma_data_mosi;
	wire [7:0] data_miso_rom;
	wire [7:0] data_miso_ram;
	wire [7:0] data_miso_io;
	wire [7:0] data_miso_usb;
	wire [7:0] data_miso_uart;
	wire [7:0] data_miso_i2c;
	wire [7:0] data_miso_spi;
	wire [7:0] data_miso_irq;
	wire [7:0] data_miso_dma;
	wire [7:0] data_miso_wdt;
	
	wire [15:0] cpu_addr;
	wire        cpu_mreq_n;
	wire        cpu_iorq_n;
	wire        cpu_rd_n;
	wire        cpu_wr_n;
	wire [15:0] dma_addr;
	wire        dma_busrq_n;
	wire        dma_mreq_n;
	wire        dma_iorq_n;
	wire        dma_rd_n;
	wire        dma_wr_n;
	wire        wdt_reset;
	wire        irq_int_n;

	//i2c
	wire	i2c_sda_oen;
	wire	i2c_sda_out;
	wire	i2c_sda_in;

	tristate i2c_sda_buffer(
		.pin(i2c_sda),
		.enable(i2c_sda_oen),
		.data_in(i2c_sda_in),
		.data_out(i2c_sda_out)
	);

	// usb
	wire usb_p_tx;
	wire usb_n_tx;
	wire usb_p_rx;
	wire usb_n_rx;
	wire usb_tx_en;

	wire usb_p_rx_io;
	wire usb_n_rx_io;

	assign pin_pu = 1'b1;
	assign usb_p_rx = usb_tx_en ? 1'b1 : usb_p_rx_io;
	assign usb_n_rx = usb_tx_en ? 1'b0 : usb_n_rx_io;

	tristate usbn_buffer(
		.pin(pin_usbn),
		.enable(usb_tx_en),
		.data_in(usb_n_rx_io),
		.data_out(usb_n_tx)
	);

	tristate usbp_buffer(
		.pin(pin_usbp),
		.enable(usb_tx_en),
		.data_in(usb_p_rx_io),
		.data_out(usb_p_tx)
	);

	//Reset Controller:
	always @(posedge clk) begin
		if( reset_n == 1'b0 ) 
			begin
				wait_n		<= 1'b1;
				nmi_n		<= 1'b1;
				sys_reset_n		<= 1'b1;
				sys_busrq_n	<= 1'b1;
				sys_int_n	<= 1'b1;
			end
	end

	//bus
	assign data_miso = data_miso_rom  | data_miso_ram | data_miso_io | data_miso_usb |
			data_miso_uart | data_miso_i2c | data_miso_spi | data_miso_irq | data_miso_dma | data_miso_wdt;

	assign data_mosi = busak_n ? cpu_data_mosi : dma_data_mosi;
	assign addr = busak_n ? cpu_addr : dma_addr;

	assign reset_n = sys_reset_n & !wdt_reset;
	assign busrq_n = sys_busrq_n & dma_busrq_n;
	assign mreq_n = cpu_mreq_n & dma_mreq_n;
	assign iorq_n = cpu_iorq_n & dma_iorq_n;
	assign rd_n = cpu_rd_n & dma_rd_n;
	assign wr_n = cpu_wr_n & dma_wr_n;
	assign int_n = sys_int_n & irq_int_n;

	//Decoder:
	wire uart_cs_n, usb_cs_n, port_cs_n, i2c_cs_n, spi_cs_n, dma_cs_n, wdt_cs_n;
	wire irq_en_n, dma_trig_n;
	wire rom_cs_n, ram_cs_n;
	//I/O Address
	assign wdt_cs_n = ~(!iorq_n & (addr[7:3] == 5'b00001)); // WDT base 0x8
	assign uart_cs_n = ~(!iorq_n & (addr[7:3] == 5'b00011)); // UART base 0x18
	assign port_cs_n = ~(!iorq_n & (addr[7:3] == 5'b01000)); // PORT base 0x40
	assign i2c_cs_n = ~(!iorq_n & (addr[7:3] == 5'b01010)); // I2C base 0x50
	assign spi_cs_n = ~(!iorq_n & (addr[7:3] == 5'b01100)); // SPI base 0x60
	assign dma_cs_n = ~(!iorq_n & (addr[7:3] == 5'b01110)); // DMA base 0x70
	assign usb_cs_n = ~(!iorq_n & (addr[7:3] == 5'b10000)); // USB base 0x80
	//Memory Address
	assign rom_cs_n = ~(!mreq_n & (addr  < ROM_SIZE));
	assign ram_cs_n = ~(!mreq_n & (addr >= RAM_LOC) & (addr < (RAM_LOC+RAM_SIZE)));

	//Access:
	assign irq_en_n = ~(!iorq_n & !m1_n);
	assign dma_trig_n = 1'b0; // FIXME:

	tv80s cpu
	(
		.m1_n		(m1_n),
		.mreq_n		(cpu_mreq_n),
		.iorq_n		(cpu_iorq_n),
		.rd_n		(cpu_rd_n),
		.wr_n		(cpu_wr_n),
		.rfsh_n		(rfsh_n),
		.halt_n		(halt_n),
		.busak_n	(busak_n),
		.A			(cpu_addr),
		.data_out	(cpu_data_mosi),
		.reset_n	(reset_n),
		.clk		(clk),
		.wait_n		(wait_n),
		.int_n		(int_n),
		.nmi_n		(nmi_n),
		.busrq_n	(busrq_n),
		.data_in	(data_miso)
	);
	defparam cpu.Mode = 0; // 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	defparam cpu.IOWait = 1; // 0 => Single cycle I/O, 1 => Std I/O cycle

	membram #(ROM_WIDTH, `__def_fw_img, 1) rom
	(
    	.clk		(clk),
    	.reset_n	(reset_n),
    	.data_out	(data_miso_rom),
    	.data_in	('h0),
    	.cs_n		(rom_cs_n),
    	.rd_n		(rd_n),
    	.wr_n		(wr_n),
    	.addr		(cpu_addr[ROM_WIDTH-1:0])//FIXME: no way to read ROM via DMA
	);

	generate
    if(RAM_TYPE == 1) begin
		//UltraPlus SPRAM
		memspram #(RAM_WIDTH) ram
		(
			.clk		(clk),
			.reset_n	(reset_n),
			.data_out	(data_miso_ram),
			.data_in	(data_mosi),
			.cs_n		(ram_cs_n),
			.rd_n		(rd_n),
			.wr_n		(wr_n),
			.addr		(addr[RAM_WIDTH-1:0])
		);
	end else if(RAM_TYPE == 2) begin
		//ext. SRAM => todo
		//
    end else begin
		//FPGA BRAM
		membram #(RAM_WIDTH)  ram
		(
			.clk		(clk),
			.reset_n	(reset_n),
			.data_out	(data_miso_ram),
			.data_in	(data_mosi),
			.cs_n		(ram_cs_n),
			.rd_n		(rd_n),
			.wr_n		(wr_n),
			.addr		(addr[RAM_WIDTH-1:0])
		);
	end
	endgenerate

	simplewdt wdt 
	(
		.clk		(clk),
		.reset_n	(reset_n),
		.pause_n	(busrq_n),
		.data_out	(data_miso_wdt),
		.data_in	(data_mosi),
		.cs_n		(wdt_cs_n),
		.rd_n		(rd_n),
		.wr_n		(wr_n),
		.addr		(addr[1:0]),
		.reset		(wdt_reset)
	);

	simpleirq irq 
	(
		.clk		(clk),
		.m1_n		(m1_n),
		.en_n		(irq_en_n),
		.int_n		(irq_int_n),
		.data_out	(data_miso_irq),
		.irq		(SW)
	);

	simpledma dma
	(
		.clk		(clk),
		.reset_n	(reset_n),
		.data_cfg_out	(data_miso_dma),
		.data_cfg_in	(data_mosi),
		.cs_cfg_n		(dma_cs_n),
		.rd_cfg_n		(rd_n),
		.wr_cfg_n		(wr_n),
		.addr_cfg		(addr[2:0]),

		.busak_n	(busak_n),
		.busrq_n	(dma_busrq_n),
		
		.trig_n		(dma_trig_n),
		.data_out	(dma_data_mosi),
		.data_in	(data_miso),
		.addr_out	(dma_addr),
		.rd_n		(dma_rd_n),
		.wr_n		(dma_wr_n),
		.iorq_n		(dma_iorq_n),
    	.mreq_n		(dma_mreq_n)
	);

	simpleio ioport
	(
		.clk		(clk),
		.reset_n	(reset_n),
		.data_out	(data_miso_io),
		.data_in	(data_mosi),
		.cs_n		(port_cs_n),
		.rd_n		(rd_n),
		.wr_n		(wr_n),
		.addr		(addr[1:0]),
		.PA_out		(PA_out),
		.PA_in		(PA_in),
		.PA_oen		(PA_oen),
		.PB_out		(PB_out),
		.PB_in		(PB_in),
		.PB_oen		(PB_oen)
	);

	simpleusb_wrapper usb
	(
		.clk		(clk),
		.clk_48m	(clk_48m),
		.reset_n	(reset_n),
		.data_out	(data_miso_usb),
		.data_in	(data_mosi),
		.cs_n		(usb_cs_n),
		.rd_n		(rd_n),
		.wr_n		(wr_n),
		.addr		(addr[2:0]),
		.usb_p_tx	(usb_p_tx),
		.usb_n_tx	(usb_n_tx),
		.usb_p_rx	(usb_p_rx),
		.usb_n_rx	(usb_n_rx),
		.usb_tx_en	(usb_tx_en)
	);

	simpleuart_wrapper uart0
	(
		.clk		(clk),
		.reset_n	(reset_n),
		.data_out	(data_miso_uart),
		.data_in	(data_mosi),
		.cs_n		(uart_cs_n),
		.rd_n		(rd_n),
		.wr_n		(wr_n),
		.addr		(addr[2:0]),
		.rx			(uart_rxd),
		.tx			(uart_txd)
	);

	simplei2c_wrapper i2c0 (
		.clk		(clk),
		.reset_n	(reset_n),
		.data_out	(data_miso_i2c),
		.data_in	(data_mosi),
		.cs_n		(i2c_cs_n),
		.rd_n		(rd_n),
		.wr_n		(wr_n),
		.addr		(addr[2:0]),
		.i2c_sda_in		(i2c_sda_in),
		.i2c_sda_out	(i2c_sda_out),
		.i2c_sda_oen	(i2c_sda_oen),
		.i2c_scl_out	(i2c_scl)
	);

	simplespi_wrapper spi0 (
		.clk		(clk),
		.reset_n	(reset_n),
		.data_out	(data_miso_spi),
		.data_in	(data_mosi),
		.cs_n		(spi_cs_n),
		.rd_n		(rd_n),
		.wr_n		(wr_n),
		.addr		(addr[2:0]),
		.sclk		(spi_sclk),
		.mosi		(spi_mosi),
		.miso		(spi_miso),
		.cs			(spi_cs)
	);

	//SoC Info
	initial begin
		$display("iceZ0mb1e Configuration Info" );
		$display("ROM width = %d, size = %X", ROM_WIDTH, ROM_SIZE );
		$display("RAM width = %d, size = %X", RAM_WIDTH, RAM_SIZE );
		$display("RAM type = %d", RAM_TYPE );
	end

endmodule

module tristate(
  inout pin,
  input enable,
  input data_out,
  output data_in
);
  SB_IO #(
    .PIN_TYPE(6'b1010_01) // tristatable output
	//.PULLUP(1'b 0)
  ) buffer(
    .PACKAGE_PIN(pin),
    .OUTPUT_ENABLE(enable),
    .D_IN_0(data_in),
    .D_OUT_0(data_out)
  );
endmodule
