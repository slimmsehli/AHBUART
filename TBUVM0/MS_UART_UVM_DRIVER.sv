/*-------------------------------------*/
/*-----------UART DRIVER---------------*/
/*-------------------------------------*/
`ifndef __MS_UART_UVM_DRV
`define __MS_UART_UVM_DRV
class uart_driver extends uvm_driver#(uart_item_driver);
	`uvm_component_utils(uart_driver)
	uvm_analysis_port #(uart_item_driver) analysis_port;
	virtual MS_UART_INTERFACE uart_vif;
	uart_cfg tb_cfg;
	logic [7:0] Driver_Vout [0:1000];
	logic [10:0] Driver_Vout_counter;
	int counter;
	covergroup UART_COVER;
        //cov_reset	: coverpoint uart_vif.RESETN;
        cov_tx_din	: coverpoint uart_vif.TX_DIN;
		cov_ubrr 	: coverpoint uart_vif.UBRR {
			bins b1[] = {16'h145};
			bins b2[] = {16'ha2};
			bins b3[] = {16'h51};
			bins b4[] = {16'h36};
			bins b5[] = {16'h1B};
			bins b6[] = {16'h18};
			bins b7[] = {16'hC};
		}
		cov_datasel	: coverpoint uart_vif.UCR[1:0] {
			bins datas1[] = {2'b00};
			bins datas2[] = {2'b01};
			bins datas3[] = {2'b10};
			bins datas4[] = {2'b11};
		}
		cov_parisel	: coverpoint uart_vif.UCR[3:2] {
			bins par1[] = {2'b00};
			bins par2[] = {2'b01};
			bins par3[] = {2'b10};
		}
		
		cov_parity_packet 	: cross cov_tx_din,cov_parisel;
		cov_datasel_packet 	: cross cov_tx_din,cov_datasel;
		cov_ubrr_packet 	: cross cov_tx_din,cov_ubrr;
		
		cov_packet_parity_datasel_ubrr : cross cov_tx_din,cov_parisel,cov_datasel,cov_ubrr;
		//cov_stopsel	: coverpoint uart_vif.UCR[4];
		//cov_ovrsel 	: coverpoint uart_vif.UCR[5];
		//cov_writefifo 	: coverpoint uart_vif.write_fifo;
		//cov_readfifo 	: coverpoint uart_vif.read_fifo;
	endgroup
	
	function new(string name = "tb_driver_conf", uvm_component parent);
		super.new(name, parent);
		UART_COVER = new();
		this.Driver_Vout_counter <= 0;
		this.counter <= 1;
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);		
		`uvm_info("DRIVER : ", $sformatf("BUILD PHASE"), UVM_HIGH)
		analysis_port = new("tb_driver_analysis", this);

		// Get the interface from the db and assign it to the local cfg
		if(!uvm_resource_db#(uart_cfg)::read_by_name(get_full_name(), "tb_cfg", tb_cfg)) 
			`uvm_error("DRIVER", $sformatf("%s %s", "no valid config at=", get_full_name()))
		else
			this.tb_cfg = tb_cfg;

		// Get the interface from db 
		if(!uvm_config_db#(virtual MS_UART_INTERFACE)::get(this, "", "uart_vif", uart_vif)) 
			`uvm_error("DRIVER", "No interface found");
			
		for (int i=0;i<1000;i++) begin
			this.Driver_Vout[i] <= 8'b0;
		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		uart_item_driver uart_data;
		super.run_phase(phase);
		`uvm_info("DRIVER : ", $sformatf("RUN PHASE"), UVM_HIGH)
		fork
			forever begin
				// the driver only send packet from sequencer
				// only if the testok flag in the configuration is enabled high "1" 
			@(uart_vif.write);
			if (!this.tb_cfg.testfinishtx) begin
				if (this.tb_cfg.testok) begin 
				UART_COVER.sample();
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