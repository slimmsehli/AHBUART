
proc comp1 {} {
	puts "------------------START COMPILING at [clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar maindir maindir
	upvar singledir singledir
	file mkdir $maindir/$singledir
	cd "$maindir/$singledir" 
	puts "TEST : COMPILE -> [pwd] , Thread:[thread::id]"
	puts "-----------------COMPILING----------------------------------"
	exec vlib work
	exec vmap work work
	exec vlog -coveropt 3 +cover=bcesft +acc $maindir/TBUVM0/MS_UART_TBTOP.sv;
	puts "-----------------DONE COMPILATION at [clock format [clock seconds] -format %D:%H:%M:%S]"
	cd $maindir
}

proc sim1 {} {
	puts "------------------START SIMULATION at [clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar nsim nsim
	upvar testnumber testnumber
	upvar maindir maindir
	upvar singledir singledir
	
	cd "$maindir/$singledir"
	#puts "Tests:$ntests, Sim:$nsim"

	puts "TEST uart_test$testnumber: SIM -> [pwd], nsim=$nsim"
	
	for {set thread 1} {$thread <= $nsim} {incr thread} {
		set mg [thread::create -joinable {
		set simname "sim_x"
		set testdirectory ""
		thread::wait;
		set threadtime [clock seconds]
		puts "STARTING TEST $testname: SIM:$simname at [clock format [clock seconds] -format %D:%H:%M:%S]"
		exec vsim -c -coverage work.MS_UART_TBTOP -voptargs=+acc -debugDB -l ${testname}_${simname}.log +UVM_TESTNAME=${testname} -wlf ${testname}_${simname} -sv_seed random +UVM_NO_RELNOTES -do " do $testdirectory/cmd.do ${testname} ${simname}"
		puts "FINISHING TEST $testname: SIM:$simname at [clock format [clock seconds] -format %D:%H:%M:%S]"
		}] ;
	lappend threadIds $mg
	} ;
	
	set counter 1
	set counter2 1
	foreach mg $threadIds {
		thread::send $mg [list set nsim "$nsim"]
		thread::send $mg [list set simname  "sim_$counter"];
		thread::send $mg [list set testname "uart_test$testnumber"] ;# "uart_test$counter2"];
		thread::send $mg [list set testdirectory "$maindir"]; 
		thread::release $mg
		incr counter
		incr counter2
	}
	
	foreach mg $threadIds {
		thread::join $mg
	}
	
	cd $maindir
	puts "------------------DONE SIMULATION at [clock format [clock seconds] -format %D:%H:%M:%S]"
}


proc cov1 {} {
	puts "-----------------Collecting coverage at [clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar maindir maindir 
	upvar singledir singledir
	cd "$maindir/$singledir"
	upvar testnumber testnumber
	upvar nsim nsim
	set testname "uart_test$testnumber"
	
	puts "[pwd] : $testname"
	for {set j 1} {$j <= $nsim} {incr j} {
		if {$j==1} {
			set tempdir "$maindir/${singledir}/${testname}_sim_1.ucdb"
		} else {
			set tempdir "${tempdir} $maindir/${singledir}/${testname}_sim_${j}.ucdb"
		}
	}
	puts $tempdir
	eval "exec vcover merge $tempdir -out MergedDB_test${testnumber}.ucdb"
	#exec vcover report -details MergedDB2.ucdb > rep.html
	exec vcover report -html -details MergedDB_test${testnumber}.ucdb 
	puts "---------------------End Coverage at [clock format [clock seconds] -format %D:%H:%M:%S]"
}