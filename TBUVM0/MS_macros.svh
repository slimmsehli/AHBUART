`define getinterface(ASK) \
	if(!uvm_config_db#(virtual MS_UART_INTERFACE)::get(this, "", "uart_vif", uart_vif)) `uvm_error($sformatf("[%s]", `ASK), "No interface found"); \
	if(uart_vif != null) uvm_config_db#(virtual MS_UART_INTERFACE)::set(this, "*", "uart_vif", uart_vif); else `uvm_error($sformatf("[%s]", `ASK), "Empty interface found")

`define getconfig(ASK) \
	if(!uvm_resource_db#(uart_cfg)::read_by_name(get_full_name(), "tb_cfg", tb_cfg)) `uvm_error($sformatf("[%s]", `ASK), $sformatf("%s %s", "no valid config at=", get_full_name())) else this.tb_cfg = tb_cfg;




// $display("-----------get UART IF - %s------------------------", ASK); \

// $display("-----------get config IF - %s------------------------", ASK); \