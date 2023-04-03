
/*-------------------------------------*/
/*-----------UART ENV------------------*/
/*-------------------------------------*/
`ifndef __MS_UART_UVM_ENV
`define __MS_UART_UVM_ENV
class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)
	
	virtual MS_UART_INTERFACE uart_vif;
	uart_cfg	tb_cfg;
	uart_agent 	tb_agent;
	uart_scoreboard tb_sb;
	uart_coverage tb_cov;
	
  function new( string name = "uart_env", uvm_component parent = null);
     super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

	`uvm_info("ENV : ", $sformatf("BUILD PHASE:"), UVM_HIGH)
	
	// Get config 
	`getconfig("ENV")
	
	// Get interface
	`getinterface("ENV")
 
	tb_agent 	= uart_agent::type_id::create("tb_agent", this);
	tb_sb	 	= uart_scoreboard::type_id::create("tb_scoreboard", this);
	tb_cov		= uart_coverage::type_id::create("tb_cov", this);
	
    endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
	`uvm_info("ENV : ", $sformatf("CONNECT PHASE:"), UVM_HIGH)
	
    tb_agent.analysis_port_m.connect(tb_sb.u_input_port_rx);
	tb_agent.analysis_port_d.connect(tb_sb.u_input_port_tx);
	tb_agent.analysis_port_d.connect(tb_cov.analysis_export);
  endfunction : connect_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass
`endif