#Create a simulator object
set ns [new Simulator]

#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Define different colors for data flows (for NAM)
$n0 color Red
$n1 color Red
$n2 color Black
$n3 color Blue



Agent/TCP   set   kd  0    
Agent/TCP set window_ 15
Agent/TCP set trf 0

$ns at 0.0 "$n2 label BottleNeck"
$ns at 0.0 "$n0 label Sender"
$ns at 0.0 "$n1 label Sender"
$ns at 0.0 "$n3 label Receiver"


#Open the NAM trace file
set f [open out.tr w]
$ns trace-all $f


#Open the NAM trace file
#trace file
                set nf [open out.nam w]
                $ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam out.nam &
        exit 0
}



#Create links between the nodes
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n2 $n3 10

#Give node position (for NAM)
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5


#Setup a TCP connection
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
$ns connect $tcp $sink


#tracing cwnd_
                 $tcp trace cwnd_
                  set trace_kk [open cwnd.tr w]
                $tcp attach $trace_kk


#tracing cwnd_
                 # $tcp trace ssthresh_
                #  set trace_kk [open cwnd.tr w]
               #   $tcp attach $trace_kk



#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp



#Setup a TCP(2nd) connection
set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink1
$ns connect $tcp1 $sink1


#Setup a FTP over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1




#Trace for plotting CWND_ Graph
	proc plotting {tcpsource file1} {
	global ns
	set conges [$tcpsource set cwnd_]
	set now [$ns now]
	puts $file1 "$now $conges"
	$ns at [expr $now+0.1] "plotting $tcpsource $file1"
	}

set print [open tcpcongesnew.xg w]
$ns at 0.0 "plotting $tcp $print"
$ns at 5.0 "finish"

#Schedule events for FTP agents
$ns at 1.0 "$ftp start"
$ns at 1.0 "$ftp1 start"
$ns at 4.0 "$ftp stop"
$ns at 4.0 "$ftp1 stop"

#Detach tcp and sink agents (not really necessary)
$ns at 4.2 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"

#Call the finish procedure after 5 seconds of simulation time
$ns at 6.0 "finish"



#Run the simulation
$ns run

