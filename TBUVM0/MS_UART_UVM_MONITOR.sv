

/*-------------------------------------*/
/*-----------UART MONITOR--------------*/
/*-------------------------------------*/
`ifndef __MS_UART_UVM_MON
`define __MS_UART_UVM_MON
class uart_monitor extends uvm_monitor;
	`uvm_component_utils(uart_monitor)
	
	uvm_analysis_port #(uart_item) analysis_port;
	virtual MS_UART_INTERFACE uart_vif;
	uart_cfg 	tb_cfg;
	uart_item	uart_data;
	int Monitor_Vin_counter;
	int counter;

	function new(string name = "uart_monitor", uvm_component parent);
    super.new(name, parent);
	this.counter <= 1;
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	`uvm_info("MONITOR : ", $sformatf("BUILD PHASE"), UVM_HIGH)

    uart_data = uart_item::type_id::create("tb_item_monitor");
    analysis_port = new("tb_monitor_analysis", this);

		// Get config 
		`getconfig("SCOREBOARD")
		
		// Get interface
		`getinterface("SCOREBOARD")

  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
	`uvm_info("MONITOR : ", $sformatf("RUN PHASE"), UVM_HIGH)	
    fork
		forever begin
			@(uart_vif.read);
			uart_data.RESETN <= uart_vif.read.RESETN;

			uart_data.RX 		<= uart_vif.RX;
			uart_data.TX_DIN 	<= uart_vif.TX_DIN;
			uart_data.UBRR 		<= uart_vif.UBRR;
			uart_data.UCR 		<= uart_vif.UCR;
			uart_data.write_fifo<= uart_vif.write_fifo;
			uart_data.read_fifo <= uart_vif.read_fifo;
			uart_data.UFR 		<= uart_vif.UFR;

			uart_data.TX 		<= uart_vif.TX;
			uart_data.RX_DOUT 	<= uart_vif.RX_DOUT;
		end
		
		// this part is to prevent the driver from sending pacet while TX fifo IS FULL
		forever begin 
			// [3] : TX FIFO FULL
			// [4] : TX FIFO EMPTY 
			@(posedge uart_data.UFR[3]) begin
				this.tb_cfg.testok <= 1'b0;
			end
			
			@(negedge uart_data.UFR[3]) begin
				this.tb_cfg.testok <= 1'b1;
			end
			
		end
		// this part is 
		
		//UFR[6] , UFR[5] , UFR[4] , UFR[3] , UFR[2] , UFR[1] , UFR[0]
		//rxempt , rxfull , txempt , txfull , rxerro , Rxdone , Txdone
		
		forever begin
			@(posedge uart_data.UFR[1]);
			repeat (4) @(posedge uart_vif.CLK);
			if (uart_data.RX_DOUT !== 8'bx) begin		
				`uvm_info("MONITOR : ", $sformatf("Monitor: Packet(%d / %d): %h", this.counter, this.tb_cfg.uart_packets, uart_data.RX_DOUT), UVM_HIGH)
				//$display("Monitor: Packet(%d / %d): %h", this.counter, this.tb_cfg.uart_packets, uart_data.RX_DOUT);
				this.tb_cfg.Monitor_rx[this.counter] <= uart_data.RX_DOUT;
				this.tb_cfg.Monitor_rx_counter++;
				
				this.counter++; 
				// when we reach the number of packets 
				if (this.counter>this.tb_cfg.uart_packets) begin
					this.tb_cfg.testfinishrx <= 1'b1;
				end
				analysis_port.write(uart_data);
			end
		end
    join_none
  endtask
endclass : uart_monitor
`endif
