/*-------------------------------------*/
/*-----------UART AGENT----------------*/
/*-------------------------------------*/
`ifndef __MS_UART_UVM_AGT
`define __MS_UART_UVM_AGT
class uart_agent extends uvm_agent;

 	`uvm_component_utils(uart_agent)
  	uvm_analysis_port #(uart_item) analysis_port_m;
	uvm_analysis_port #(uart_item_driver_base) analysis_port_d;
	
	typedef uvm_sequencer#(uart_item_driver_base) tb_seq_type;

	virtual MS_UART_INTERFACE uart_vif;
	uart_cfg 		tb_cfg;
	uart_driver 	tb_driver;
  	uart_monitor 	tb_monitor;
  	tb_seq_type 	tb_seq;

  function new( string name = "uart_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

	`uvm_info("AGENT : ", $sformatf("BUILD PHASE"), UVM_HIGH)
	
	// Get config
	`getconfig("AGENT")	
	
	//Get interface
	`getinterface("AGENT")
		
    tb_seq		= tb_seq_type::type_id::create("tb_seq"		, this);
    tb_driver	= uart_driver::type_id::create("tb_driver"	, this);
	tb_monitor 	= uart_monitor::type_id::create("tb_monitor", this);
	
	analysis_port_m = new("ANALYSIS-PORT-UART_MONITOR", this);
	analysis_port_d = new("ANALYSIS-PORT-UART_DRIVER", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
	`uvm_info("AGENT : ", $sformatf("CONNECT PHASE"), UVM_HIGH)
    tb_driver.seq_item_port.connect(tb_seq.seq_item_export);
    tb_monitor.analysis_port.connect(this.analysis_port_m);
	tb_driver.analysis_port.connect(this.analysis_port_d);
  endfunction : connect_phase
endclass : uart_agent
`endif