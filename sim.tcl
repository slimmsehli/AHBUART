package require Thread
package require Tclx
#package require Tk
# this is the version 3 of the project with AHB-Lite bus interface implementation

set ntests 4
set nsim 10
set maindir "C:/Users/dmseh/Desktop/DESIGN_VERIFICATION/UART_github_20_4_23_2"

source msim.tcl ;#for multiple test simulation 
source ssim.tcl ;#for one test with multiple simulations

proc f {} {
	puts "---------------------Refresh script--------------------------"
	source sim.tcl
}

proc del {} {
	puts "-----------------------DELETING ---------------------------"
	upvar maindir maindir
	cd $maindir
	upvar ntests ntests
	for {set i 1} {$i <= $ntests} {incr i} {
		file delete -force $maindir/uart_test$i ;# deleteing simulation folders
	}
	file delete -force $maindir/coverageFinal
	file delete -force $maindir/multi_simulation
	file delete -force transcript
	file delete {*}[glob -no complain *.log] ;#deleteing log files 
	puts "------------------DELETING COMPLETE------------------------"
}

proc se {} {
	puts "-----------------TESTS RESULT at [clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar maindir maindir
	cd $maindir/simmulti
	upvar ntests ntests
	upvar nsim nsim
	for {set i 1} {$i <= $ntests} {incr i} {
		for {set j 1} {$j <= $nsim} {incr j} {
			set number 0
			set filei "uart_test${i}_sim_${j}.log"
			#puts "searching file : $filei"
			
			set number 0
			set infile [open $filei r]
			while { [gets $infile line] >= 0 } {
				regexp {UVM_WARNING.\:.*} $line h1
				incr number
			}
			close $infile
			
			set number 0
			set infile [open $filei r]
			while { [gets $infile line] >= 0 } {
				regexp {UVM_ERROR.\:.*} $line h2
				incr number
			}
			close $infile
			
			set number 0
			set infile [open $filei r]
			while { [gets $infile line] >= 0 } {
				regexp {UVM_FATAL.\:.*} $line h3
				incr number
			}
			close $infile
			
			set number 0
			set infile [open $filei r]
			while { [gets $infile line] >= 0 } {
				regexp {UVM_INFO.\:.*} $line h4
				incr number
			}
			close $infile
			
			puts "$filei ($number)=> $h1, $h2, $h3, $h4"
		}
	}
	cd $maindir
}

# this will execute uvm tests regression simultaniously

proc do {} {
	puts "[clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar ntests ntests
	upvar nsim nsim
	upvar maindir maindir
	upvar simdir simdir
	comp
	cd $maindir
	sim	
	cd $maindir
	cov
	cd $maindir
	se
}

# this will execute a specific test referenced by its number 
#set singledir "simone1"

proc do1 {singledir testnumber nsim} {
	puts "[clock format [clock seconds] -format %D:%H:%M:%S]"
	#set testnumber 4 ;# set the number of the test in uvm
	puts $singledir
	upvar maindir maindir
	comp1
	cd $maindir
	sim1	
	cd $maindir
	cov1
	cd $maindir
}

# this will merge multi test coverage with signel test coverage

proc covt {numbertests} {
	puts "-----------------Collecting coverage total at [clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar maindir maindir 
	file mkdir $maindir/coverageFinal
	cd "$maindir/coverageFinal"
	puts "[pwd]"
	
	for {set j 1} {$j <= $numbertests} {incr j} {
		if {$j==1} {
			set tempdir "$maindir/multi_simulation/MergedDB_test1.ucdb"
		} else {
			set tempdir "${tempdir} $maindir/multi_simulation/MergedDB_test${j}.ucdb"
		}
	}
	puts $tempdir
	
	eval "exec vcover merge $tempdir -out MergedDB_Final.ucdb"
	exec vcover report -html -details MergedDB_Final.ucdb 
	puts "-----------------End Coverage at [clock format [clock seconds] -format %D:%H:%M:%S]"
	cd $maindir
}

proc c2v {} {
	puts "-----------------Collecting coverage total at [clock format [clock seconds] -format %D:%H:%M:%S]"
	upvar maindir maindir 
	file mkdir $maindir/coverageFinal1
	cd "$maindir/coverageFinal1"
	puts "[pwd]"
	set tempdir "${maindir}/coverageFinal/MergedDB_Final.ucdb"
	set tempdir "${tempdir} ${maindir}/sim5/MergedDB_test5.ucdb"
	
	eval "exec vcover merge $tempdir -out MergedDB_Final2.ucdb"
	exec vcover report -html -details MergedDB_Final2.ucdb 
	puts "-----------------End Coverage at [clock format [clock seconds] -format %D:%H:%M:%S]"
	cd $maindir
}

# -> run multiple tests in the same directory
# -> 

proc runs {ntests nsim maindir} {
	#upvar ntests ntests
	#upvar nsim nsim
	#upvar maindir maindir
	
	file mkdir "$maindir/multi_simulation"
	cd "$maindir/multi_simulation"
	
	for {set i 1} {$i <= $ntests} {incr i} {
		set simdirname "sim$i"
		do1 multi_simulation $i $nsim
	}
	covt $ntests
}
