//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// UART core created By Slim Msehli	V1                                          //
// the core support only 8bits data length but it have a control register to 	//
// implement the rest of the data lengths										//
// Only parity mode is implemnted 0 for none, 1 for even, and 2 for odd         //
// Baudrate generator module support 7 baudrates 9600, 19200, 38400, 57600, 	//
// 115200, 128000, 256000                                                       //
// the core have a flag register for RX and TX FIFO, and for TX and RX modules	//
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

/*---------------------------------------------------*/
/*---------------------------------------------------*/
/*--------------------BAUDRATE GENERATOR-------------*/
/*---------------------------------------------------*/
`include "MS_UART_BAUDGEN.v" 

/*---------------------------------------------------*/
/*---------------------UART TX-----------------------*/
/*---------------------------------------------------*/
`include "MS_UART_TX.v"

/*---------------------------------------------------*/
/*---------------------UART RX-----------------------*/
/*---------------------------------------------------*/
`include "MS_UART_RX.v"

/*---------------------------------------------------*/
/*---------------------UART FIFO---------------------*/
/*---------------------------------------------------*/
`include "MS_UART_FIFO.v"

/*---------------------------------------------------*/
/*---------------------UART -------------------------*/
/*---------------------------------------------------*/

module MSUART(

	input				CLK,
	input				RESETN, 		

	input reg			RX,
	input reg	[7:0]	TX_DIN,
	
	input 		[15:0]	UBRR,
	input 		[7:0]	UCR,
	output		[7:0]	UFR,
	
	input 				write_fifo,
	input 				read_fifo,

	output		 		TX,
	output [7:0]		RX_DOUT
);
	
	wire [7:0] OUT_FIFO_IN_TX;
	wire [7:0] OUT_RX_IN_FIFO;
	
	// UART CONTROL REGISTER UCR
	wire	[1:0]	DATASEL;
	wire 			STOPSEL;
	wire 			OVRSEL;
	wire	[1:0]	PARITYSEL;
	assign DATASEL 		= UCR[1:0]; // first  two bits of control register
	assign PARITYSEL	= UCR[3:2]; // second two bits of control register
	assign STOPSEL		= UCR[4]; 	// 5th bit of control register
	assign OVRSEL		= UCR[5]; 	// 6th bit of control register
	
	// UART FLAGS REGISTER 
	wire		TX_DONE;
	wire		RX_DONE;
	wire 		RX_ERR;
	wire		TX_FIFO_EMPTY;
	wire		TX_FIFO_FULL;
	wire		RX_FIFO_EMPTY;
	wire		RX_FIFO_FULL;
	
	assign		UFR[0]	= TX_DONE;
	assign		UFR[1]	= RX_DONE;
	assign		UFR[2]	= RX_ERR;
	assign		UFR[3]	= TX_FIFO_FULL;
	assign		UFR[4]	= TX_FIFO_EMPTY;
	assign		UFR[5]	= RX_FIFO_FULL;
	assign		UFR[6]	= RX_FIFO_EMPTY;

	reg TB_start;
	initial TB_start = 1'b0;

	// to send one pulse from TX to TX_FIFO
	// because the FIFO is working with the main system frequency 
	// the TX fifo its write enable with main clck
	// and read enable is with the low UART clock
	// this ensure that the fifo output one data
	// on each TX demande
	
	wire BAUDTICK;
	reg TX_NEXT;
	reg RX_NEXT;
	reg TX_START;
	wire TX_BUSY;
	initial begin
		TX_NEXT = 1'b0;
		RX_NEXT = 1'b0;
		TX_START = 1'b0;
	end
	
	
	// the below logic control is used because 
	// the TX module is much slower than the FIFO
	// the fifo is the main clock for read
	// while it uses the baudrate gen to write to the TX module
	// TX_NEXT is used as a pulse to read from the TX_FIFO
	always @(negedge BAUDTICK) begin
		if(TX_DONE & !TX_FIFO_EMPTY & !TX_START)
			TX_NEXT <= 1'b1;
	end
	
	always @(posedge CLK) 
		TX_NEXT <= 1'b0;
	
	// TX_START is used to send data byte when it is out of the fifo
	always @(negedge TX_NEXT) 
		TX_START	<= 1'b1;
	
	always @(posedge TX_BUSY)
		TX_START	<= 1'b0;
	
		
	// one pulse for the rx fifo to read from it 
	always @(posedge RX_DONE) begin
		RX_NEXT	<= 1'b1;
		@(posedge CLK);
		RX_NEXT	<= 1'b0;
	end
	
	// UART transmitter
	MS_UART_TX DUT_MS_UART_TX(
	.CLK(CLK),		
	.RESETN(RESETN),
	.START(TX_START),
	.TICK(BAUDTICK),
	.DIN(OUT_FIFO_IN_TX),
	
	.DATASEL(DATASEL),
	.PARITYSEL(PARITYSEL),
	.STOPSEL(STOPSEL),
	.OVRSEL(OVRSEL),
	
	.DONE(TX_DONE),
	.BUSY(TX_BUSY),
	.DOUT(TX));
	
	// UART Receiver
	MS_UART_RX DUT_MS_UART_RX(
	.CLK(CLK),		
	.RESETN(RESETN),
	.DIN(RX),
	.TICK(BAUDTICK),
	
	.DATASEL(DATASEL),
	.PARITYSEL(PARITYSEL),
	.STOPSEL(STOPSEL),
	.OVRSEL(OVRSEL),
	
	.DOUT(OUT_RX_IN_FIFO),
	.DONE(RX_DONE),
	.ERR(RX_ERR));
	
	// Baud rate generator
	MS_UART_BAUDGEN DUT_MS_UART_BAUDGEN(
    .CLK(CLK),
	.RESETN(RESETN),
    .BAUDTICK(BAUDTICK),
	.UBRR(UBRR));
	
	//transmitter fifo
	
	MS_UART_FIFO #(.DWIDTH(8), .DEPTH(8)) 
	DUT_MS_UART_FIFO_TX
	(
	.CLK(CLK),
	.RESETN(RESETN),
	.RD(TX_NEXT),						// read command from transmitter
	.WR(write_fifo & !TX_FIFO_FULL), 	// write command from tb 
	.DIN(TX_DIN), 						// input data from tb
						
	.EMPTY(TX_FIFO_EMPTY),				// output flag empty
	.FULL(TX_FIFO_FULL),				// output flag full
	.DOUT(OUT_FIFO_IN_TX) 				// output data to the transmitter
	);

	//Receiver fifo
	MS_UART_FIFO #(.DWIDTH(8), .DEPTH(8)) 
	DUT_MS_UART_FIFO_RX
	(
	.CLK(CLK),
	.RESETN(RESETN),
	.RD(read_fifo & !RX_FIFO_EMPTY),	// read command from transmitter
	.WR(RX_DONE & RX_NEXT), 			// write command from tb 
	.DIN(OUT_RX_IN_FIFO), 				// input data from tb
						
	.EMPTY(RX_FIFO_EMPTY),				// output flag empty
	.FULL(RX_FIFO_FULL),				// output flag full
	.DOUT(RX_DOUT) 						// output data to the transmitter
	);
	
endmodule