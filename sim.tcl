# this is the version 3 of the project with AHB-Lite bus interface implementation

set maindir "C:/Users/dmseh/OneDrive/Desktop/AHB_UART_GITHUB/UART_github" ;# put your project directory here 


# source this tcl script and refresh it 
proc f {} {
	puts "---------------------Refresh script--------------------------"
	source sim.tcl
}

proc del {} {
	puts "-----------------------DELETING ---------------------------"
	upvar maindir maindir
	cd $maindir
	file delete -force $maindir/covhtmlreport
	file delete -force $maindir/sim
	file delete -force $maindir/work
	file delete {*}[glob -no complain *.log] ;#deleteing log files 
	file delete {*}[glob -no complain *.ucdb] ;#deleteing log files
	file delete {*}[glob -no complain *.dbg] ;#deleteing log files	
	file delete {*}[glob -no complain *.vstf] ;#deleteing log files
	file delete {*}[glob -no complain uart_sim] ;#deleteing log files
	puts "------------------DELETING COMPLETE------------------------"
}

proc r {} {
	upvar maindir maindir
	file mkdir sim
	cd sim
	puts "-----------------COMPILING----------------------------------"
	#vdel work
	vlib work
	vmap work work
	vlog -coveropt 3 +cover=bcesft +acc $maindir/TBUVM0/MS_UART_TBTOP.sv;
	puts "-----------------DONE COMPILATION---------------------------"
	puts "-----------------START SIMULATION---------------------------"
	vsim -c -coverage work.MS_UART_TBTOP -voptargs=+acc -debugDB -l uart_sim.log +UVM_TESTNAME=uart_test2 +UVM_NO_RELNOTES -wlf uart_sim -sv_seed random
	do "$maindir/cmd.do"
	puts "-----------------DONE SIMULATION----------------------------"
	cd $maindir
}

proc r2 {} {
	upvar maindir maindir
	del
	#exec vdel work
	file mkdir sim
	cd sim
	puts "-----------------COMPILING----------------------------------"
	exec vlib work
	exec vmap work work
	exec vlog -coveropt 3 +cover=bcesft +acc $maindir/TBUVM0/MS_UART_TBTOP.sv;
	puts "-----------------DONE COMPILATION---------------------------"
	puts "-----------------START SIMULATION---------------------------"
	exec vsim -c -coverage work.MS_UART_TBTOP -voptargs=+acc -debugDB -l uart_sim.log +UVM_TESTNAME=uart_test2 +UVM_NO_RELNOTES -wlf uart_sim -sv_seed random
	exec do "$maindir/cmd.do"
	puts "-----------------DONE SIMULATION----------------------------"
	cd $maindir
}