coverage save -onexit -codeAll -cvg uart_sim.ucdb

add wave -noupdate -group TX /MS_UART_TBTOP/DUT_MSUART/DUT_MS_UART_TX/*
add wave -noupdate -group TX_FIFO /MS_UART_TBTOP/DUT_MSUART/DUT_MS_UART_FIFO_TX/*
add wave -noupdate -group TX_FIFO /MS_UART_TBTOP/DUT_MSUART/DUT_MS_UART_FIFO_TX/fifobody
add wave -noupdate -group BAUDGEN /MS_UART_TBTOP/DUT_MSUART/DUT_MS_UART_BAUDGEN/*
add wave -noupdate -group RX /MS_UART_TBTOP/DUT_MSUART/DUT_MS_UART_RX/*
add wave -noupdate -group RX_FIFO /MS_UART_TBTOP/DUT_MSUART/DUT_MS_UART_FIFO_RX/*
add wave -noupdate -group RX_FIFO /MS_UART_TBTOP/DUT_MSUART/DUT_MS_UART_FIFO_RX/fifobody
add wave -noupdate -expand -group UART /MS_UART_TBTOP/DUT_MSUART/*
add wave -group TB /MS_UART_TBTOP/*

run -all;