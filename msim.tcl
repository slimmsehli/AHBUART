proc comp {} {
	puts "------------------START COMPILING at [clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar maindir maindir
	file mkdir $maindir/simmulti
	cd "$maindir/simmulti" 
	puts "TEST : COMPILE -> [pwd] , Thread:[thread::id]"
	puts "-----------------COMPILING----------------------------------"
	exec vlib work
	exec vmap work work
	exec vlog -coveropt 3 +cover=bcesft +acc $maindir/TBUVM0/MS_UART_TBTOP.sv;
	puts "-----------------DONE COMPILATION at [clock format [clock seconds] -format %D:%H:%M:%S]"
	cd $maindir
}

proc sim {} {
	puts "------------------START SIMULATION at [clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar ntests ntests
	upvar nsim nsim
	upvar maindir maindir
	
	cd "$maindir/simmulti"
	puts "Tests:$ntests, Sim:$nsim"
	
	for {set thread 1} {$thread <= $ntests} {incr thread} {
		set gd [thread::create -joinable {
			set testdirectory ""
			set simname  "uart_simu1"
			set testname "uart_test1"
			set nsim 1
			thread::wait;
			cd $testdirectory
			file mkdir "$testdirectory/simmulti"
			cd "$testdirectory/simmulti"
			puts "TEST $testname: SIM -> [pwd], nsim=$nsim"
			
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
			
			set simcounter 1
			foreach mg $threadIds {
			thread::send $mg [list set simname "sim_$simcounter"] 
			thread::send $mg [list set testname "$testname"] 
			thread::send $mg [list set testdirectory "$testdirectory"]			
			thread::release $mg;
			incr simcounter
			}

			foreach mg $threadIds {
				thread::join $mg
			}
		}] ;
		lappend threadIds $gd
	} ;
	
	set counter 1
	set counter2 1
	foreach gd $threadIds {
		thread::send $gd [list set nsim "$nsim"]
		thread::send $gd [list set simname  "uart_sim$counter"];
		thread::send $gd [list set testname "uart_test$counter2"];
		thread::send $gd [list set testdirectory "$maindir"]; 
		thread::release $gd
		incr counter
		incr counter2
	}

	foreach gd $threadIds {
		thread::join $gd
	}
	cd $maindir
	puts "------------------DONE SIMULATION at [clock format [clock seconds] -format %D:%H:%M:%S]"
}

proc cov {} {
	puts "-----------------Collecting coverage at [clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar maindir maindir 
	cd "$maindir/simmulti"
	puts "[pwd]"
	upvar ntests ntests
	upvar nsim nsim
	puts "[pwd] : $ntests"
	for {set i 1} {$i <= $ntests} {incr i} {
		for {set j 1} {$j <= $nsim} {incr j} {
			if {$i==1 && $j==1} {
				set tempdir "${maindir}/simmulti/uart_test1_sim_1.ucdb"
			} else {
				set tempdir "${tempdir} ${maindir}/simmulti/uart_test${i}_sim_${j}.ucdb"
			}
		}
	}
	puts $tempdir
	eval "exec vcover merge $tempdir -out MergedDBmulti.ucdb"
	#exec vcover report -details MergedDB2.ucdb > rep.html
	exec vcover report -html -details MergedDBmulti.ucdb 
	puts "---------------------End Coverage at [clock format [clock seconds] -format %D:%H:%M:%S]"
	cd $maindir
}