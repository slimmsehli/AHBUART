/*---------------------------------------------------*/
/*---------------------UART TX-----------------------*/
/*---------------------------------------------------*/

`define TXDEBUG 1 

`define RESET		3'b001
`define IDLE		3'b010
`define START_BIT	3'b011
`define DATA_BITS	3'b100
`define STOP_BIT	3'b101
`define PARITY_BIT	3'b110

module MS_UART_TX(
	input wire CLK,		
	input wire RESETN,
	input wire START,
	input wire TICK,
	input wire [7:0] DIN,
	
	input [1:0] DATASEL,
	input [1:0] PARITYSEL,
	input STOPSEL,
	input OVRSEL,
	
	output reg DONE,
	output reg BUSY,
	output reg DOUT);
	
	reg TXDEBUG = 1'b0;
	
	wire [4:0] tempoversampling;
		assign tempoversampling = !OVRSEL ? 5'b01111 : 5'b00111;
	wire [7:0] tempdatalength;
	//initial tempdatalength <= 8'b00001000;
	
		assign tempdatalength = DATASEL + 3'b100;
		//assign tempdatalength = 8'b0001000;

reg [2:0]	state  = `RESET;
reg [7:0]	data   = 8'b0; // temporary data
reg [2:0]	dataindex = 3'b0; // for 8-bit data
reg 		txparitybitout = 1'b0;
//integer i;

// counting 16 ticks and send data 
reg internalclk;
reg [4:0] clkindex = 5'b0;
initial clkindex <= 5'b0;
always @(posedge TICK) begin
	if (clkindex == tempoversampling) begin
		clkindex <= 5'b0;
		internalclk <= 1'b1;
	end
	else begin
		clkindex <= clkindex + 1'b1;
		internalclk <= 1'b0;
	end
end

always @(posedge CLK) begin
	if (RESETN) begin
		DOUT 		<= 1'b1; 
		BUSY		<= 1'b0;
		DONE 		<= 1'b1;
		dataindex 	<= 3'b0;
		data    	<= 8'b0;
		txparitybitout 	<= 1'b0;
	end
end

initial begin
	DOUT 		<= 1'b1; 
	DONE 		<= 1'b1;
	BUSY		<= 1'b0;
	dataindex 	<= 3'b0;
	data    	<= 8'b0;
	txparitybitout 	<= 1'b0;
end
// the main State machine
always @(posedge internalclk) begin
	case (state)
		default : begin
			state <= `IDLE;
			if (START) begin // THIS WAS (START & EN)
                data    <= DIN; // save a copy of input data
				DONE 	<= 1'b1;
				BUSY	<= 1'b0;
                state   <= `START_BIT;
            end
		end
		`IDLE : begin // 2 - reset everything to 0 and put high the tx line
			DOUT 		<= 1'b1; 
			DONE 		<= 1'b1;
			BUSY		<= 1'b0;
			dataindex 	<= 3'b0;
			data    	<= 8'b0;
			if (START) begin  // THIS WAS (START & EN)
                state   <= `START_BIT;
            end
		end
		`START_BIT : begin // 3 - 
			data    	<= DIN; // save a copy of input data
			DOUT 		<= 1'b0; //send start bit low "0"
			DONE 		<= 1'b0;
			BUSY		<= 1'b1;
			state		<= `DATA_BITS; //change state to data frame
		end
		`DATA_BITS : begin // 4 -
			/*if (dataindex == 3'b011)
				DOUT <= 1'b1;
			else*/
				DOUT 		<= data[dataindex];
			if (dataindex==tempdatalength) begin
				dataindex	<= 3'b0;
				if (PARITYSEL==2'b01) begin		// even parity
					txparitybitout 	= ^data; 
					state 			<= `PARITY_BIT;
				end
				else if(PARITYSEL==2'b10) begin	// odd parity
					txparitybitout 	= ~^data;
					state 			<= `PARITY_BIT;
				end
				else begin
					txparitybitout 	<= 1'b0;
					state 			<= `STOP_BIT;
				end
			end
			else
				dataindex 	<= dataindex + 1'b1;
		end
		`PARITY_BIT : begin
			DOUT 		<= txparitybitout; //send parity bit
			state		<= `STOP_BIT; //change state to data frame
		end
		`STOP_BIT : begin
			/*if(TXDEBUG) begin // for debug purpose only
				if (PARITYSEL !=2'b0)
					$display("TX : out=%h-%b, PARITYSEL:%h, ParOut : %b, ParcalcEVEN : %b, ParcalcODD : %b", data, data, PARITYSEL, DOUT, ^data, ~^data);
					//$display("RX : in =%h-%b, PARITYSEL:%h, ParIn  : %b, ParcalcEVEN : %b", tempdataholder,tempdataholder, PARITYSEL, rxparitybitin, rxparitybitcal);
				else 
					$display("TX : out=%h-%b No parity is used",data, data);
			end*/
			DOUT 	<= 1'b1;
			DONE	<= 1'b1;
			BUSY	<= 1'b0;
			txparitybitout <= 1'b0;
			state	<= `IDLE;
		end
	endcase
end
endmodule