/*-------------------------------------*/
/*-----------UART DRIVER---------------*/
/*-------------------------------------*/
`ifndef __MS_UART_UVM_DRV
`define __MS_UART_UVM_DRV
class uart_driver extends uvm_driver#(uart_item_driver_base);
	`uvm_component_utils(uart_driver)
	uvm_analysis_port #(uart_item_driver_base) analysis_port;
	virtual MS_UART_INTERFACE uart_vif;
	uart_cfg tb_cfg;
	logic [7:0] Driver_Vout [0:1000];
	logic [10:0] Driver_Vout_counter;
	int counter;
	
	function new(string name = "tb_driver_conf", uvm_component parent);
		super.new(name, parent);
		this.Driver_Vout_counter <= 0;
		this.counter <= 1;
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);		
		`uvm_info("DRIVER : ", $sformatf("BUILD PHASE"), UVM_HIGH)
		analysis_port = new("tb_driver_analysis", this);
			
		// Get config
		`getconfig("DRIVER")
		
		//Get interface
		`getinterface("DRIVER")
			
		for (int i=0;i<1000;i++) begin
			this.Driver_Vout[i] <= 8'b0;
		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		uart_item_driver_base uart_data;
		super.run_phase(phase);
		`uvm_info("DRIVER : ", $sformatf("RUN PHASE"), UVM_HIGH)
		fork
			forever begin
				// the driver only send packet from sequencer
				// only if the testok flag in the configuration is enabled high "1" 
			@(uart_vif.write);
			if (!this.tb_cfg.testfinishtx) begin
				if (this.tb_cfg.testok) begin 
				seq_item_port.get_next_item(uart_data);
				
				uart_vif.RESETN 	<= uart_data.RESETN;
				uart_vif.TX_DIN 	<= uart_data.TX_DIN;
				uart_vif.UBRR 		<= uart_data.UBRR;
				uart_vif.UCR[1:0]	<= uart_data.DATASEL;
				uart_vif.UCR[3:2]	<= uart_data.PARITYSEL;
				uart_vif.UCR[4]		<= uart_data.STOPSEL;
				uart_vif.UCR[5]		<= uart_data.OVRSEL;
				uart_vif.UCR[7:6]	<= 2'b00;

				uart_vif.write_fifo <= uart_data.write_fifo;
				uart_vif.read_fifo 	<= uart_data.read_fifo;	
				
				//$display("Driver Coverage = %f", UART_COVER.get_coverage());
				if (uart_data.write_fifo) begin
					`uvm_info("DRIVER : ", $sformatf("Driver : Packet(%d / %d): %h", this.counter, this.tb_cfg.uart_packets, uart_data.TX_DIN), UVM_HIGH)	
					//$display("Driver : Packet(%d / %d): %h", this.counter, this.tb_cfg.uart_packets, uart_data.TX_DIN);					
					this.tb_cfg.Monitor_tx[this.counter] <= uart_data.TX_DIN;
					this.tb_cfg.Monitor_tx_counter++;
					this.counter++;
					analysis_port.write(uart_data);
				end
				seq_item_port.item_done();
				end
			end
			end
		join_none
	endtask
endclass : uart_driver
`endif