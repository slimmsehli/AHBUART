class uart_coverage extends uvm_subscriber #(uart_item_driver_base);
    `uvm_component_utils(uart_coverage)

    uart_item_driver_base	uart_data;
	covergroup UART_COVER_SUB;
        //cov_reset	: coverpoint uart_vif.RESETN;
        cov_tx_din	: coverpoint uart_data.TX_DIN {
			bins din[10] = {[0:$]};
		}
		cov_ubrr 	: coverpoint uart_data.UBRR {
			bins b1[] = {16'h145};
			bins b2[] = {16'ha2};
			bins b3[] = {16'h51};
			bins b4[] = {16'h36};
			bins b5[] = {16'h1B};
			bins b6[] = {16'h18};
			bins b7[] = {16'hC};
		}
		cov_datasel	: coverpoint uart_data.UCR[1:0] {
			bins datas4[] = {2'b11};
		}
		cov_parisel	: coverpoint uart_data.UCR[3:2] {
			bins par1[] = {2'b00};
			bins par2[] = {2'b01};
			bins par3[] = {2'b10};
		}
		
		cov_parity_packet 		: cross cov_tx_din,cov_parisel;
		cov_ubrr_packet 		: cross cov_tx_din,cov_ubrr;
		
		cov_packet_parity_ubrr : cross cov_tx_din,cov_parisel,cov_ubrr;
		//cov_stopsel	: coverpoint uart_vif.UCR[4];
		//cov_ovrsel 	: coverpoint uart_vif.UCR[5];
		//cov_writefifo : coverpoint uart_vif.write_fifo;
		//cov_readfifo 	: coverpoint uart_vif.read_fifo;
	endgroup
	
    function new (string name = "uart_coverage", uvm_component parent);
        super.new(name, parent);
        UART_COVER_SUB = new();
    endfunction : new

    virtual function void write (uart_item_driver_base	t);
        uart_data = t;
        UART_COVER_SUB.sample();
		//`uvm_info("Subscriber",$sformatf("Cov(perc) = %f",UART_COVER_SUB.get_coverage()),UVM_LOW)
		//$display("Driver Coverage = %f", UART_COVER.get_coverage());
    endfunction : write

endclass : uart_coverage