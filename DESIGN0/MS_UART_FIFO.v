/*---------------------------------------------------*/
/*---------------------UART FIFO---------------------*/
/*---------------------------------------------------*/

module MS_UART_FIFO #(parameter DWIDTH=8, DEPTH=1) 	
	(
	input wire 					CLK,
	input wire 					RESETN,
	input wire 					RD,
	input wire 					WR,
	input wire 					[DWIDTH-1:0] DIN,
						
	output reg 					EMPTY,
	output reg 					FULL,
	output reg 					[DWIDTH-1:0] DOUT
	);
	
	reg [DWIDTH-1:0] fifobody 	[0:DEPTH-1]; 	// fifo memory space 8 vectors deep of 8bits each
	reg [$clog2(DEPTH)-1:0] 	r_counter;		// read counter
	reg [$clog2(DEPTH)-1:0] 	w_counter;		// write counter	
	integer i;
	
	reg 						almost_empty;
	reg 						almost_full;
	
	// initial block have the same as reset block
	initial begin 
		r_counter 				<= 'b0;
		w_counter 				<= 'b0;
		EMPTY					<= 1'b0;
		FULL					<= 1'b0;
		for (i=0;i<DEPTH;i=i+1) begin
			fifobody[i] 		<= 'bx;
		end
	end
	
	always @(negedge CLK) begin
		if (RESETN) begin
			EMPTY					<= 1'b0;
			FULL					<= 1'b0;
		end
		else begin
			if ((w_counter+1'b1) == r_counter)
				almost_full <= 1'b1;
			else
				almost_full <= 1'b0;

			// Set adn reset almost empty flag 
			if ((r_counter+1'b1) == w_counter)
				almost_empty <= 1'b1;
			else 
				almost_empty 	<= 1'b0;
				
			// Set full flag 
			if (almost_full & (w_counter == r_counter))
				FULL 			<= 1'b1;
			
			// Set empty flag 
			if (almost_empty & (w_counter == r_counter))
				EMPTY 			<= 1'b1;				
		
			// Reset full andd empty flags 
			if (w_counter != r_counter) begin
				FULL 			<= 1'b0;
				EMPTY			<= 1'b0;
			end
		end
	end
	
	always @(posedge CLK) begin
		// reset the counters and
		// reset the Fifo array to x
		if(RESETN) begin
			r_counter 			<= 3'b0;
			w_counter 			<= 3'b0;
			EMPTY				<= 1'b1;
			FULL				<= 1'b0;
			for (i=0;i<DEPTH;i=i+1) begin
				fifobody[i] 	<= 'bx;
			end
		end
		else begin
			//read access to the Fifo
			if(RD & !EMPTY) begin
					DOUT	<= fifobody[r_counter];
					fifobody[r_counter] <= 'bx;
					r_counter	<= r_counter + 1'b1; 
					if (almost_empty)
						EMPTY	<= 1'b1;
					else 
						EMPTY 	<= 1'b0;
			end	
			// write access to the Fifo
			if(WR & !FULL) begin
					fifobody[w_counter]	<= DIN;
					w_counter	<= w_counter + 1'b1; 
					if (almost_full)
						FULL	<= 1'b1;
					else 
						FULL 	<= 1'b0;
			end
			
			// Set adn reset almost full flag 		
		end
	end
endmodule