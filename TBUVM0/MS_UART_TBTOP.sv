
import uvm_pkg::*;
`include "../DESIGN0/MS_UART.v"
`include "../TBUVM0/MS_UART_UVM_INTERFACE.sv"
`include "../TBUVM0/MS_UART_UVM_TEST.sv"

module MS_UART_TBTOP();
	//logic testok;
	logic TB_CLK;
	//TOP_UART_COVER grp = new;
	initial TB_CLK = 1'b0;
	always #10 TB_CLK = ~TB_CLK; //20ns periode = 50MHz
	always #100000 begin 
		//$strobe("Sim Time : %dus", $time/1000); //each 100us
		//$display("Coverage = %f", grp.get_coverage());
	end

	MS_UART_INTERFACE uart_if();
	assign uart_if.CLK = TB_CLK;
	
	MSUART DUT_MSUART(

	.CLK(uart_if.CLK),		
	.RESETN(uart_if.RESETN),		

	.RX(link),
	.TX_DIN(uart_if.TX_DIN),
	
	.UBRR(uart_if.UBRR),
	.UCR(uart_if.UCR),
	.UFR(uart_if.UFR),
	
	.write_fifo(uart_if.write_fifo),
	.read_fifo(uart_if.read_fifo),

	.TX(link),
	.RX_DOUT(uart_if.RX_DOUT)
);

	initial begin
		$timeformat(-9, 3, "ns", 8);
		uvm_config_db#(virtual MS_UART_INTERFACE )::set(uvm_root::get(),"*", "uart_vif", uart_if);
		run_test();
		uvm_root::get().print_topology();
	end
	
endmodule
