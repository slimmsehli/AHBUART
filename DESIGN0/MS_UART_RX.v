/*---------------------------------------------------*/
/*---------------------UART RX-----------------------*/
/*---------------------------------------------------*/


module MS_UART_RX(
	input wire CLK,
	input wire RESETN,
	input wire DIN,
	input wire TICK,
	
	input [1:0] DATASEL,
	input [1:0] PARITYSEL,
	input STOPSEL,
	input OVRSEL,
	
	output reg [7:0] DOUT,
	output reg DONE,
	output reg ERR);
	
	wire [4:0] tempoversampling;
		assign tempoversampling = !OVRSEL ? 5'b01111 : 5'b00111;
	wire [7:0] tempdatalength;
		//assign tempdatalength = DATASEL + 3'b101;
		assign tempdatalength = 8'b00001000;
	
	reg RXDEBUG = 1'b0;
	// states of state machine
    reg [2:0] RESET 	= 3'b000;
    reg [2:0] IDLE 		= 3'b001;
    reg [2:0] DATA_BITS = 3'b010;
    reg [2:0] STOP_BIT 	= 3'b011;
	reg [2:0] PARITY_BIT= 3'b100;
	
	reg [2:0] state;
	reg [3:0] bitindex 	= 4'b0; //index for data
	reg [1:0] shift 	= 2'b0;//reg for input signal state
	reg [3:0] counter 	= 5'b0; // counter for 16 oversampling
	reg [7:0] rdata 	= 8'b0; //receiveed data
	reg EN;
	reg		  rxparitybitin = 1'b0; //temp parity bit
	reg 	  rxparitybitcal;//,rxparitybitcal2,rxparitybitcal3;
	reg [7:0] tempdataholder;
	
initial begin
	DOUT 		<= 8'b0; 
	DONE 		<= 1'b0;
	ERR 		<= 1'b0;
	EN			<= 1'b1;
	rxparitybitin 	<= 1'b0;
end

always @(posedge CLK) begin
	if (RESETN) begin
		state = RESET;
	end
end

always @(posedge TICK) begin
	if (!EN) state = RESET;
	
	case (state)
		RESET : begin 
			DONE 			<= 1'b0;
			//BUSY 			<= 1'b0;
			ERR 			<= 1'b0;
			bitindex 		<= 4'b0;
			counter 		<= 5'b0;
			rdata			<= 8'b0;
			rxparitybitin 		<= 1'b0;
			if (EN)	state 	<= IDLE;
		end
		IDLE : begin
			if (counter==(tempoversampling-4'b1000)) begin
				if(RXDEBUG) $display("RX : state 1 IDLE --> state 2 DATA_BITS"); 
				ERR 		<= 1'b0;
				bitindex 	<= 4'b0;
				counter 	<= 5'b0;
				rdata		<= 8'b0;
				rxparitybitin 	<= 1'b0;
				state 		<= DATA_BITS;
			end
			else if (!DIN) begin
				counter <= counter + 1'b1;
			end
			else begin
				counter <= counter;
			end
		end
		DATA_BITS : begin // state 2
			if (counter==tempoversampling) begin
				rdata[bitindex] <= DIN;
				bitindex 		<= bitindex + 1'b1;
				counter			<= 5'b0;
			end
			else begin
				counter 		<= counter + 1'b1;
			end
			
			if(bitindex== tempdatalength) begin
				counter 	<= 5'b0;
				bitindex 	<= 4'b0;
				DOUT		<= rdata;
				tempdataholder <= rdata;
				
				/*if (DATASEL == 2'b00) 
					DOUT	<= rdata & 8'b00011111;
				else if (DATASEL == 2'b01) 
					DOUT	<= rdata & 8'b00111111;
				else if (DATASEL == 2'b10) 
					DOUT	<= rdata & 8'b01111111;
				else
					DOUT	<= rdata & 8'b11111111;*/
					
				if (PARITYSEL == 2'b00)	begin// Using parity
					state		<= STOP_BIT;
					//if(RXDEBUG) $display("RX : state 2 DATA_BITS --> state 3 STOP_BIT"); 
				end
				else begin					// No parity
					//if(RXDEBUG) $display("RX : state 2 DATA_BITS --> state 4 PARITY_BIT"); 
					state		<= PARITY_BIT;
				end
			end
		end
		PARITY_BIT : begin		//state 4	
			if (counter==tempoversampling) begin
				//if(RXDEBUG) 
				//	$display("RX : state 4 PARITY_BIT --> state 3 STOP_BIT"); 
				counter 		<= 5'b0;
				rxparitybitin	<= DIN;
				state 			<= STOP_BIT;
			end
			else begin
				counter <= counter + 1'b1;
			end
		end
		STOP_BIT : begin	 //state 3
			if (counter==tempoversampling) begin
				//$display("RX : state 3 STOP_BIT --> state 0 RESET");
				if (PARITYSEL==2'b01) begin		// even parity
					rxparitybitcal	= ^rdata;
					//if(RXDEBUG)
					//	$display("RX : in =%h-%b, PARITYSEL:%h, ParIn  : %b, ParcalcEVEN : %b - %s", tempdataholder,tempdataholder, PARITYSEL, rxparitybitin, rxparitybitcal, (rxparitybitin===rxparitybitcal) ? "OKAY" : "ERROR");

					if (rxparitybitin !== rxparitybitcal) begin
						ERR 	<= 1'b1;
						//$display("RX : din  : %h, PARITYSEL:%h, ParIn  : %b, ParcalcEVEN : %b, Parity (EVEN) ERROR", tempdataholder, PARITYSEL, rxparitybitin, rxparitybitcal);
					end
				end
				else if(PARITYSEL==2'b10) begin	// odd parity
					rxparitybitcal	= ~(^rdata);
					//if(RXDEBUG)
					//	$display("RX : in =%h-%b, PARITYSEL:%h, ParIn  : %b, ParcalcEVEN : %b - %s", tempdataholder,tempdataholder, PARITYSEL, rxparitybitin, rxparitybitcal,  (rxparitybitin===rxparitybitcal) ? "OKAY" : "ERROR");
					if (rxparitybitin !== rxparitybitcal) begin
						ERR 	<= 1'b1;
						//$display("RX : din  : %h, PARITYSEL:%h, ParIn  : %b, ParcalcEVEN : %b, Parity (ODD) ERROR", tempdataholder, PARITYSEL, rxparitybitin, rxparitybitcal);
					end
				end
				else begin
					//if(RXDEBUG)
					//	$display("RX : in =%h-%b, PARITYSEL:%h, No parity is used",tempdataholder, tempdataholder, PARITYSEL);
					ERR 	<= 1'b0;
				end
				DONE 		<= 1'b1;
				bitindex 	<= 4'b0;
				counter 	<= 5'b0;
				rdata		<= 8'b0;
				state 		<= RESET;
			end
			else begin
				counter <= counter + 1'b1;
			end
		end
		
		default : begin
			DOUT 		<= 8'b0; 
			DONE 		<= 1'b0;	
			ERR 		<= 1'b0;
			bitindex 	<= 1'b0;
			counter 	<= 5'b0;
			rdata		<= 8'b0;
			if (EN)	state <= IDLE;
		end
	endcase
end
endmodule