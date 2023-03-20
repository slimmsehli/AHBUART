/*---------------------------------------------------*/
/*--------------------BAUDRATE GENERATOR-------------*/
/*---------------------------------------------------*/
module MS_UART_BAUDGEN(
    input CLK,   		 // board clock
	input RESETN,
    output reg BAUDTICK, // baud rate for rx
	input reg [15:0] UBRR
);

reg [16 - 1:0] Counter = 0;

initial begin
    BAUDTICK = 1'b0;
end

always @(posedge CLK) begin
	if (RESETN) begin
	BAUDTICK = 1'b0;
	end 
	else begin
		if (Counter == UBRR) begin
			Counter <= 0;
			BAUDTICK <= 1'b1; //~BAUDTICK;
		end 
		else begin
			Counter <= Counter + 1'b1;
			if (Counter==2) BAUDTICK <= 1'b0;
		end
	end
end
endmodule