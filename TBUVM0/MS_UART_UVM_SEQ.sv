/*-------------------------------------*/
/*-----------UART SEQUENCE-------------*/
/*-------------------------------------*/
`ifndef __MS_UART_UVM_SEQ
`define __MS_UART_UVM_SEQ

class uart_seq2 extends uvm_sequence#(uart_item_driver);
	`uvm_object_utils(uart_seq2)
	rand uart_item_driver uitem;
	uart_cfg tb_cfg;
	
	int packetcounter;
	logic [1:0] seqstate; 
	int t = 0;
	logic [1:0] 	TB_DATASEL 		= 2'b11; 	// 8 bits data
	logic 			TB_STOPSEL 		= 1'b0;		// Normal oversamling by 16
	logic 			TB_OVRSEL  		= 1'b0;		// One stop bit
	logic [1:0]		TB_PARITYSEL 	= 2'b01;	// No parity bit
	logic [7:0] 	TB_UCR 			= 8'b0;

	logic randdata;
	logic randstop;
	logic randovr;
	logic randparity;
	logic randubrr;
function new(string name="uart_seq2");
	super.new(name);
	this.uitem = new();
	this.seqstate = 2'b11; // init the state of the transmission sequence
	this.t = 0;
	this.packetcounter = 1;
	this.randdata = 0;
	this.randubrr = 0;
	this.randparity = 0;
	endfunction : new

	virtual task pre_body();
    super.pre_body();

	`uvm_info("SEQUENCE : ", $sformatf("PREBODY"), UVM_HIGH)

	if(!uvm_resource_db#(uart_cfg)::read_by_name(get_full_name(), "tb_cfg", tb_cfg)) 
			`uvm_error("AGENT", $sformatf("%s %s", "no valid config at=", get_full_name()))
		else
			this.tb_cfg = tb_cfg;
    if(starting_phase != null) 
		starting_phase.raise_objection(this);		
	endtask

	virtual task post_body();
		super.post_body();
		if(starting_phase != null) 
		starting_phase.drop_objection(this);
		`uvm_info("SEQUENCE : ", $sformatf("POSTBODY"), UVM_HIGH)
	endtask
  
	virtual task body();
		`uvm_info("SEQUENCE : ", $sformatf("BODY"), UVM_HIGH)
		// send item to driver after complete
		case (this.seqstate) 
			2'b00 : begin // state for no sending
			//nothing
			end
			2'b01 : begin // transmission part1 send signals 
				if (this.tb_cfg.testok) begin
					if ((this.packetcounter > this.tb_cfg.uart_packets)) begin
						$display("seqstate:(%b): packet reached %d", this.seqstate, this.tb_cfg.uart_packets);
						this.tb_cfg.testfinishtx	<= 1'b1;
						this.uitem.write_fifo		<= 1'b0;
						this.uitem.read_fifo		<= 1'b0;
						this.tb_cfg.testok 			<= 1'b0;
						this.seqstate 				<= 2'b00;
					end
					else begin
						if(!this.uitem.randomize())
							`uvm_error("SEQ", $sformatf(" cannot randomize"))
						this.packetcounter++;
						this.tb_cfg.Monitor_seq_counter++;
						this.uitem.write_fifo		<= 1'b1;
						this.uitem.read_fifo		<= 1'b1;
						this.seqstate 				<= 2'b01; //go to the default state
					end
				end
			end
			2'b10 : begin // transmission part2 reset signals
				this.uitem.write_fifo		 <= 1'b0;
				this.tb_cfg.testok 			 <= 1'b0;
				this.seqstate 				<= 2'b01; //go to the default state
			end
			2'b11 : begin
				if(!this.uitem.randomize())
					`uvm_error("SEQ", $sformatf(" cannot randomize"))
				if (this.tb_cfg.testok) begin
					if (this.randdata == 1'b0) 
						uitem.DATASEL.rand_mode(0);
					
					if (this.randparity == 1'b0) 
						uitem.PARITYSEL.rand_mode(0);
					
					if (this.randubrr == 1'b0) 
						uitem.UBRR.rand_mode(0);
					`uvm_info("SEQUENCE : ", $sformatf("DATASEL:%b, DATAPARITY:%b, BURR:%h Datain:%h|", uitem.DATASEL, uitem.PARITYSEL, uitem.UBRR, uitem.TX_DIN), UVM_LOW)
				end
				this.seqstate 				 <= 2'b01; // go to init
			end
			default : begin //do the same as state1
				if (this.tb_cfg.testok) begin
					this.seqstate 				 <= 2'b01; // go to trans part1
				end
			end
		endcase
		`uvm_create(req);
		req = this.uitem;
		`uvm_send(req);
	endtask : body
endclass : uart_seq2

`endif