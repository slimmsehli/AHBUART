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
	//uart_coverage ucov;
	
  function new( string name = "uart_env", uvm_component parent = null);
     super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

	`uvm_info("ENV : ", $sformatf("BUILD PHASE:"), UVM_HIGH)

    if(!uvm_resource_db#(uart_cfg)::read_by_name(get_full_name(), "tb_cfg", tb_cfg)) 
      `uvm_error("ENV", $sformatf("%s %s", "no valid config at=", get_full_name()))
	else
		this.tb_cfg = tb_cfg;

	if(!uvm_config_db#(virtual MS_UART_INTERFACE)::get(this, "", "uart_vif", uart_vif)) 
		`uvm_error("[ENV]", "No interface found");
	
	if(uart_vif != null) begin
		uvm_config_db#(virtual MS_UART_INTERFACE)::set(this, "*", "uart_vif", uart_vif);		
	end
	else 
		`uvm_error("ENV", "Empty interface found")
 
	tb_agent = uart_agent::type_id::create("tb_agent", this);
	tb_sb	 = uart_scoreboard::type_id::create("tb_scoreboard", this);
	//ucov		 = uart_coverage::type_id::create("tb_coverage", this);
	//uvm_config_db#(int)::set(this, "AGENT-VDD", "is_active", UVM_PASSIVE);
	
    endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
	`uvm_info("ENV : ", $sformatf("CONNECT PHASE:"), UVM_HIGH)
	
    tb_agent.analysis_port_m.connect(tb_sb.u_input_port_rx);
	tb_agent.analysis_port_d.connect(tb_sb.u_input_port_tx);
  endfunction : connect_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass
`endif