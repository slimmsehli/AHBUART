/*-------------------------------------*/
/*-----------UART DRIVER---------------*/
/*-------------------------------------*/
`ifndef __MS_UART_UVM_SB
`define __MS_UART_UVM_SB
class uart_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(uart_scoreboard)
	//uvm_analysis_port #(uart_item) analysis_port;
	virtual MS_UART_INTERFACE uart_vif;
	uart_cfg tb_cfg;
	
	//====analysis port for the input agent=================================//
	`uvm_analysis_imp_decl(_UART_INPUT_RX);
	uvm_analysis_imp_UART_INPUT_RX#(uart_item,        uart_scoreboard) u_input_port_rx;
	
	//====analysis port for the monitoring output agent=====================//
	`uvm_analysis_imp_decl(_UART_INPUT_TX);
	uvm_analysis_imp_UART_INPUT_TX#(uart_item_driver_base, uart_scoreboard) u_input_port_tx;
	
		//------------------------------ Reading RX output to testbench 
	virtual function void write_UART_INPUT_RX(uart_item data);
		
		if (data.RX_DOUT !== 8'hxx) begin
			this.tb_cfg.Monitor_rx[this.tb_cfg.Monitor_rx_counter] <= data.RX_DOUT;
			this.tb_cfg.Monitor_rx_counter++;
		end
	endfunction : write_UART_INPUT_RX 
	
		//------------------------------ Reading TX input from testbench 
	virtual function void write_UART_INPUT_TX(uart_item_driver_base data);
		this.tb_cfg.Monitor_tx[this.tb_cfg.Monitor_tx_counter] <= data.TX_DIN;
		this.tb_cfg.Monitor_tx_counter++;
endfunction : write_UART_INPUT_TX
	
	function new(string name = "uart_scoreboard", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		u_input_port_rx = new ("SB_ANALYSIS-PORT-UART_MONITOR", this);
		u_input_port_tx = new ("SB_ANALYSIS-PORT-UART_DRIVER", this);
		
		`uvm_info("SCOREBOARD : ", $sformatf("BUILD PHASE"), UVM_HIGH)
		
		// Get config 
		`getconfig("SCOREBOARD")

		// Get interface
		`getinterface("SCOREBOARD")
		
	endfunction

	virtual task run_phase(uvm_phase phase);
		//uart_item_driver_base uart_data;
		super.run_phase(phase);
		`uvm_info("SCOREBOARD : ", $sformatf("RUN PHASE"), UVM_HIGH)
		fork
		join_none
	endtask
	
	virtual function void final_phase(uvm_phase phase);
		super.final_phase(phase);
		`uvm_info("SCOREBOARD : ", $sformatf("FINAL PHASE"), UVM_HIGH)
		
		for(int i=1;i <= this.tb_cfg.uart_packets;i++) begin
			if (this.tb_cfg.Monitor_rx[i] !== this.tb_cfg.Monitor_tx[i]) 
				`uvm_error("SCOREBOARD", $sformatf("TX(%d)=%h !!! RX(%d)=%h",i, this.tb_cfg.Monitor_tx[i], i, this.tb_cfg.Monitor_rx[i]))
			/*	`uvm_info("SCOREBOARD", $sformatf("TX(%d)=%h, RX(%d)=%h",i, this.tb_cfg.Monitor_tx[i], i, this.tb_cfg.Monitor_rx[i]), UVM_LOW)
			else*/	

		end
	endfunction : final_phase
	
endclass : uart_scoreboard
`endif