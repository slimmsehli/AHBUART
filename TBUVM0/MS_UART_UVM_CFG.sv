
import "DPI-C" function string getenv(input string env_name);
/*-------------------------------------*/
/*-----------UART CFG------------------*/
/*-------------------------------------*/
`ifndef __MS_UART_UVM_CFG
`define __MS_UART_UVM_CFG
    class uart_cfg extends uvm_object;
        `uvm_object_utils(uart_cfg)
        int uart_packets = 10;
		logic testextend = 1'b1;
        logic testfinishrx = 1'b0;
		logic testfinishtx = 1'b0;
		
        int t;	
        logic testok = 1'b1;
        logic ok = 1'b1;
		
		
		// SECTION 2 
		int Monitor_tx_counter;
		int Monitor_seq_counter;
		int Monitor_rx_counter;
		logic [7:0] Monitor_tx  [0:999];
		logic [7:0] Monitor_rx  [0:999];
		logic [7:0] Monitor_seq [0:999];
		
        function new(string name = "ana_cfg");
            super.new(name); 
			uart_packets = 256;
			testok = 1'b1;
			testextend = 1'b1;
            testfinishrx = 1'b0;
			testfinishtx = 1'b0;
			Monitor_rx_counter = 1;
            ok = 1'b1;
			
			//section 2
			Monitor_tx_counter <= 1;
			Monitor_rx_counter <= 1;
			Monitor_seq_counter<= 1;
        endfunction
    endclass
`endif