/*-------------------------------------*/
/*-----------UART ITEM-----------------*/
/*-------------------------------------*/
`ifndef __MS_UART_UVM_ITEM
`define __MS_UART_UVM_ITEM
class uart_item extends uvm_sequence_item;
	logic				RESETN; 		
	logic		[7:0]	TX_DIN;
	logic 		[15:0]	UBRR;
	logic 		[7:0]	UCR;
	logic 				write_fifo;
	logic 				read_fifo;

	logic		 		TX;
	logic				RX;
	logic		[7:0]	UFR;
	logic 		[7:0]	RX_DOUT;
	`uvm_object_utils_begin(uart_item)
    `uvm_field_int(RESETN, 		UVM_ALL_ON)
    `uvm_field_int(RX, 			UVM_ALL_ON)
	`uvm_field_int(TX_DIN, 		UVM_ALL_ON)
	`uvm_field_int(UBRR,		UVM_ALL_ON)
	`uvm_field_int(UCR, 		UVM_ALL_ON)
	`uvm_field_int(write_fifo, 	UVM_ALL_ON)
	`uvm_field_int(read_fifo, 	UVM_ALL_ON)
	`uvm_field_int(UFR, 		UVM_ALL_ON)
	`uvm_field_int(TX, 			UVM_ALL_ON)
	`uvm_field_int(RX_DOUT, 	UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "");
		super.new(name);
		this.RESETN			= 0; 		
		this.TX_DIN			= 0;
		this.UBRR			= 0;
		this.UCR			= 0;
		this.write_fifo		= 0;
		this.read_fifo		= 0;

		
		this.TX 			= 0;
		this.RX				= 0;
		this.UFR			= 0;
		this.RX_DOUT 		= 0;
	endfunction : new
endclass : uart_item 

class uart_item_driver extends uvm_sequence_item;
	logic				RESETN; 		
	rand logic		[7:0]	TX_DIN;
	rand logic 		[15:0]	UBRR;
	rand logic 		[1:0] 	DATASEL;
	rand logic 			 	STOPSEL;
	rand logic				OVRSEL;
	rand logic		[1:0] 	PARITYSEL;
	rand logic 		[7:0]	UCR;
	rand logic 				write_fifo;
	rand logic 				read_fifo;

	`uvm_object_utils_begin(uart_item_driver)
    `uvm_field_int(RESETN, 		UVM_ALL_ON)
	`uvm_field_int(TX_DIN, 		UVM_ALL_ON)
	`uvm_field_int(UBRR,		UVM_ALL_ON)
	`uvm_field_int(DATASEL,		UVM_ALL_ON)
	`uvm_field_int(STOPSEL,		UVM_ALL_ON)
	`uvm_field_int(OVRSEL,		UVM_ALL_ON)
	`uvm_field_int(PARITYSEL,	UVM_ALL_ON)
	`uvm_field_int(write_fifo, 	UVM_ALL_ON)
	`uvm_field_int(read_fifo, 	UVM_ALL_ON)
	`uvm_object_utils_end
	function new(string name = "");
		super.new(name);
		this.RESETN			= 1'b0;
		this.TX_DIN			= 8'h00;
		this.UBRR			= 16'h0000;
		this.DATASEL		= 2'b00;
		this.STOPSEL		= 1'b0;
		this.OVRSEL			= 1'b0;
		this.PARITYSEL		= 2'b00;
		this.write_fifo		= 1'b0;
		this.read_fifo		= 1'b0;
		
	endfunction : new

	constraint UART_constraint1 {
   
	//TX_DIN 			inside {[0:255]};
	//TX_DIN			dist {[0:127] :/ 50, [128:255]:/50}; //equal distribution
		//Testing baudrates
		// 9600, 19200, 38400, 57600, 115200, 128000, 256000
	UBRR			dist {16'h145:=1,16'ha2:=1,16'h51:=1,16'h36:=1,16'h1B:=1,16'h18:=1,16'hC:=1}; // test multiple baudrates	
	//UBRR			== 16'hC; // highest baudrate
		// read and write constrtaints
	//write_fifo 		== 1'b1;
	//read_fifo 		== 1'b1;
		// configuration constraints
	//DATASEL 		dist {2'b00:=1, 2'b01:=1, 2'b10:=1, 2'b11:=1};	// 6, 7 or 8 bits data only
	DATASEL 		== 2'b11;
	STOPSEL			== 0; // only 1 stop bit
	OVRSEL 			== 0; // oversampling only by 16
	//PARITYSEL		inside {2'b00, 2'b01, 2'b10}; //use parity only
	PARITYSEL		dist {2'b00:=1, 2'b01:=1, 2'b10:=1}; //use parity only
	
	}
endclass : uart_item_driver 

`endif