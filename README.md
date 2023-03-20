# AHBUART
AHB UART IP 


This is the first part of the UART IP with AHB-Lite interface
The version one is a basic configurable UART Core with systemverilog UVM testbench 
The UART have transmitter and receiver modules with their respective configurable FIFO for buffering.
The UART contain the following features and registers: 
- Baudrate genrator, that can be configured via a 16 bits UBRR (Uart baudrate register) that can hold the dividor for the baudrate output signal 
- Control register is implemented that can configure the UART for the data length, parity bits and stop bits, ans also the oversampling y 8 or by 16
- Flag regfister is implemented to give a look to the status of the TX and RX FIFO, and also on the main receiver and transmitter incuding, 
RXfifoempty, RXfifofull, TXfifoempty, TXfifofull, TXdone, RXdone, and RXerror for signaling error during receiving data

The core data mode is only 8bits but it can be modified to add different data length by changing the FSM for both RX and TX modules.
The core stop bits for 1 or 2 stop bits is not implemnted but it can be added as the data length part.
Only parity mode is implemented for now, with 2bits in the control register, 0 for none parity, 1 for even parity bit and 2 for odd parity bit.

The core as it is can be used to create different AMBA bus interface for it and the FIFO for the TX and RX can be extended to match the desired working speed.

the Testbench is a UVM testbench that uses basic component for driving the UART and testing the different configuration for:
  - Baudrate
  - Data packets
  - Parity mode
and to vaidtate that a scoreboard is used with analysis ports connected to the driver and to the monitor to check the conformity of the input,
and the out data packets. in the testbench TOP the DUT is used as a transmitter and a receiver with the RX and the TX pins are connected together.

Formal verification is necessary to validate the clocking aspect of the design and it could be used alongside the UVM testbench to capture different
corners of the verification.


Simulation:
Two files are used for the simulation on questasim simulator, sim.tcl can be sources to launch the simulation, the cmd.do file is used to add waves and to collec coverage for the simulation.



Created By Slim Msehli
