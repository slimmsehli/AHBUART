interface MS_UART_INTERFACE();
	logic 				CLK;
	logic				RESETN; 		
	logic				RX;
	logic		[7:0]	TX_DIN;
	logic 		[15:0]	UBRR;
	logic 		[7:0]	UCR;
	logic 				write_fifo;
	logic 				read_fifo;

	logic		[7:0]	UFR;
	logic		 		TX;
	logic 		[7:0]	RX_DOUT;
	
	clocking write @(posedge CLK);
		output	RESETN; 		
		output	RX;
		output	TX_DIN;
		output 	UBRR;
		output 	UCR;
		output 	write_fifo;
		output 	read_fifo;
  	endclocking: write
	
	clocking read @(negedge CLK);
		input	RESETN; 		
		input	RX;
		input	TX_DIN;
		input 	UBRR;
		input 	UCR;
		input 	write_fifo;
		input 	read_fifo;
	
		input	UFR;
		input	TX;
		input 	RX_DOUT;
  	endclocking: read

endinterface