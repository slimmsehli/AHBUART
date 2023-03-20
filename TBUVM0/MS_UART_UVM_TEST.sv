import uvm_pkg::*;
`include "uvm_macros.svh"
`include "MS_UART_UVM_CFG.sv"
`include "MS_UART_UVM_ITEM.sv"
`include "MS_UART_UVM_SEQ.sv"
`include "MS_UART_UVM_MONITOR.sv"
`include "MS_UART_UVM_DRIVER.sv" 
`include "MS_UART_UVM_AGENT.sv"
`include "MS_UART_UVM_SCOREBOARD.sv"
`include "MS_UART_UVM_ENV.sv"

/*-------------------------------------*/
/*-----------UART TEST-----------------*/
/*-------------------------------------*/

`ifndef __MS_UART_UVM_TEST
`define __MS_UART_UVM_TEST

//------ This is the base test to be extended
class uart_test_base extends uvm_test;
	`uvm_component_utils(uart_test_base)
	uart_env	tb_env;
	uart_cfg    tb_cfg;
	virtual MS_UART_INTERFACE uart_vif;
	
	function new(string name = "test_base", uvm_component parent =  null);
		super.new(name, parent);
	endfunction
  
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		tb_cfg = uart_cfg::type_id::create("tb_cfg");
		uvm_resource_db#(uart_cfg)::set("*","tb_cfg", tb_cfg);
		
		tb_env = uart_env::type_id::create("tb_env",this);
		`uvm_info("TEST : ", $sformatf("BUILD PHASE"), UVM_HIGH)

	endfunction : build_phase
	
	virtual function void final_phase(uvm_phase phase);
		super.final_phase(phase);
		`uvm_info("TEST : ", $sformatf("FINAL PHASE"), UVM_HIGH)
		uvm_root::get().print_topology();
	endfunction : final_phase
endclass : uart_test_base


//----------------------------------------------------------
//-----------------------------DATA LENGTH test-------------
//----------------------------------------------------------
class uart_test1 extends uart_test_base;
	`uvm_component_utils(uart_test1)
	uart_seq2	tb_seq; 

  function new(string name = "uart_test1_rand_data", uvm_component parent =  null);
    super.new(name, parent);
  endfunction
	
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
			
	phase.raise_objection(this);					  
		`uvm_info("TEST : ", $sformatf("RUN PHASE"), UVM_HIGH)						
		tb_seq = uart_seq2::type_id::create("SEQ-UART");
		tb_seq.randdata 	<= 1'b1;
		tb_seq.randparity 	<= 1'b0;
		tb_seq.randubrr 	<= 1'b0;
	fork 
		begin 
			`uvm_info("TEST", $sformatf("TEST1 : RANDOMIZE data"), UVM_LOW)
			forever begin
				tb_seq.start(tb_env.tb_agent.tb_seq);
			end
		end
		
		begin
			@(posedge this.tb_cfg.testfinishrx); //after finish receiving the packets
			phase.drop_objection(this);
		end
	join
	phase.drop_objection(this);
  endtask

endclass : uart_test1

//----------------------------------------------------------
//--------------------------------Parity test---------------
//----------------------------------------------------------
class uart_test2 extends uart_test_base;
	`uvm_component_utils(uart_test2)
	uart_seq2	tb_seq; 

  function new(string name = "uart_test2_rand_parity", uvm_component parent =  null);
    super.new(name, parent);
  endfunction
	
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
		`uvm_info("TEST : ", $sformatf("RUN PHASE"), UVM_HIGH)
		phase.raise_objection(this);							
		tb_seq = uart_seq2::type_id::create("SEQ-UART");
		tb_seq.randdata 	<= 1'b0;
		tb_seq.randparity 	<= 1'b1;
		tb_seq.randubrr 	<= 1'b0;
	fork 
		begin 
			`uvm_info("TEST", $sformatf("TEST2 : RANDOMIZE Parity"), UVM_LOW)
			forever begin
				tb_seq.start(tb_env.tb_agent.tb_seq);
			end
		end
		
		begin
			@(posedge this.tb_cfg.testfinishrx); //after finish receiving the packets
			phase.drop_objection(this);
		end
	join
	phase.drop_objection(this);
  endtask
endclass : uart_test2

//----------------------------------------------------------
//--------------------------------Baudrate test-------------
//----------------------------------------------------------
class uart_test3 extends uart_test_base;
	`uvm_component_utils(uart_test3)
	uart_seq2	tb_seq; 

  function new(string name = "uart_test3_rand_burr", uvm_component parent =  null);
    super.new(name, parent);
  endfunction
	
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
		`uvm_info("TEST : ", $sformatf("RUN PHASE"), UVM_HIGH)
		phase.raise_objection(this);							
		tb_seq = uart_seq2::type_id::create("SEQ-UART");
		tb_seq.randdata 	<= 1'b0;
		tb_seq.randparity 	<= 1'b0;
		tb_seq.randubrr 	<= 1'b1;
	fork 
		begin 
			`uvm_info("TEST", $sformatf("TEST1 : RANDOMIZE Baudrate"), UVM_LOW)
			forever begin
				tb_seq.start(tb_env.tb_agent.tb_seq);
			end
		end
		
		begin
			@(posedge this.tb_cfg.testfinishrx); //after finish receiving the packets
			phase.drop_objection(this);
		end
	join
	phase.drop_objection(this);
  endtask
endclass : uart_test3

//----------------------------------------------------------
//--------------------------------All test-------------
//----------------------------------------------------------
class uart_test4 extends uart_test_base;
	`uvm_component_utils(uart_test4)
	uart_seq2	tb_seq; 

  function new(string name = "uart_test4_rand_all", uvm_component parent =  null);
    super.new(name, parent);
  endfunction
	
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
		`uvm_info("TEST : ", $sformatf("RUN PHASE"), UVM_HIGH)
	phase.raise_objection(this);							
	tb_seq = uart_seq2::type_id::create("SEQ-UART");
	tb_seq.randdata 	<= 1'b1;
	tb_seq.randparity 	<= 1'b1;
	tb_seq.randubrr 	<= 1'b1;
	fork 
		begin 
			`uvm_info("TEST", $sformatf("TEST1 : RANDOMIZE data"), UVM_LOW)
			forever begin
				tb_seq.start(tb_env.tb_agent.tb_seq);
			end
		end
		
		begin
			@(posedge this.tb_cfg.testfinishrx); //after finish receiving the packets
			phase.drop_objection(this);
		end
	join
	phase.drop_objection(this);
  endtask
endclass : uart_test4
`endif