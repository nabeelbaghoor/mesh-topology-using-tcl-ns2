#Creating simulator object 
set ns [new Simulator]   

#Creating the nam file
set nf [open out.nam w]      
#It opens the file 'out.nam' for writing and gives it the file handle 'nf'. 
$ns namtrace-all $nf

#Finish Procedure  (closes the trace file and starts nam) 
proc finish {} {
        global ns nf
        $ns flush-trace
        close $nf
        exec nam out.nam &
        exit 0
        }
#The trace data is flushed into the file by using command $ns flush-trace and then file is closed.

$ns color 0 red
$ns color 1 yellow

#Creating Nodes
for {set i 0} {$i<9} {incr i} {
set n($i) [$ns node]
}

#Creating Links
for {set i 0} {$i<9} {incr i} {
    for {set j 0} {$j<9} {incr j} {
        if {$i<$j} {
        $ns duplex-link $n($i) $n($j) 320Kb 20ms DropTail 
        }
    }
}

$ns rtproto DV

#Creating a TCP agent,Specifying tcp traffic to have yellow color and attaching it to n1
set tcp0 [new Agent/TCP]
$ns attach-agent $n(1) $tcp0
$tcp0 set fid_ 1       
#Creating a Sink Agent and attaching it to n4,Connecting TCP agent with Sink agent
set sink0 [new Agent/TCPSink]
$ns attach-agent $n(4) $sink0
$ns connect $tcp0 $sink0
#Creating FTP agent for traffic and attaching it to tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

#Creating a UDP agent,Specifying udp traffic to have red color and attaching it to n3
set udp0 [new Agent/UDP]
$udp0 set fid_ 0        
$ns attach-agent $n(3) $udp0
#Creating the Null agent,Attaching it to n8 and connecting it with udp agent
set null0 [new Agent/Null]
$ns attach-agent $n(8) $null0     
$ns connect $udp0 $null0
#Creating the CBR agent to generate the traffic over udp0 agent ,and attaching cbr0 with udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set rate_ 220Kb
$cbr0 attach-agent $udp0

#Bring the link between n2 and n3 down at 2.5 and bring it back up at 3.9
$ns rtmodel-at 2.5 down $n(2) $n(3)
$ns rtmodel-at 3.9 up $n(2) $n(3)

#Bring the link between n4 and n5 down at 1.7 and bring it back up at 2.5
$ns rtmodel-at 1.7 down $n(4) $n(5)
$ns rtmodel-at 2.5 up $n(4) $n(5)

#Starting the FTP Traffic
$ns at 0.9 "$ftp0 start"
$ns at 3.5 "$ftp0 stop"

#Starting the cbr traffic
$ns at 1.5 "$cbr0 start"
$ns at 4.3 "$cbr0 stop"

#Calling the finish procedure
$ns at 4.0 "finish"

#Run the simulation
$ns run

#donepracticelab