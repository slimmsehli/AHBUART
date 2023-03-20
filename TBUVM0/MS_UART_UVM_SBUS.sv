class uart_coverage extends uvm_subscriber #(uart_item);

    `uvm_component_utils(uart_coverage)

    uart_item	uart_data;

    covergroup UART_COVER;
        DIN : coverpoint uart_data.TX_DIN;
        DOUT : coverpoint uart_data.RX_DOUT;
    endgroup

    function new (string name = "uart_coverage", uvm_component parent);
        super.new(name, parent);
        UART_COVER = new();
    endfunction : new

    virtual function void write (uart_item	t);
        uart_data = t;
        UART_COVER.sample();
    endfunction : write

endclass : uart_coverage