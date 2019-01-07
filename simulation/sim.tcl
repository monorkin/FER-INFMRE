# Authors
# Stanko Krtalic Rusendic - 0036463148

###############
# DEFINITIONS #
###############

# Assign `ns` to an instance of the simulator
set ns [new Simulator]

# Specify which colors to use for which flow id
# This is used for the `NAM` part of the assignment
# This has no influence on the simulation itself
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green

# Instruct the simulator to record each step of the simulation
# This is, again, used for the `NAM` part of the assignment
# `NAM` uses the generated `out.nam` file to generate it's graph
# We will use the `nf` variable to stor the output file
set nf [open out.nam w]
$ns namtrace-all $nf


#########
# PROCS #
#########

# The `finish` proc is called when the simulation is finished. In it we write
# out the steps of the simulation to `out.nam` and call `NAM` to process
# it.
proc finish {} {
  # Use the `ns` and `nf` global variables
  global ns nf
  # Writes out the steps of the simulation to `out.nam`
  $ns flush-trace
  # Close the NAM trace file
  close $nf
  # Execute NAM on the trace file
  exec nam out.nam &
  exit 0
}


#########
# NODES #
#########

# Define all nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]


#########
# LINKS #
#########

# Define all links
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n1 $n3 1Mb 5ms DropTail
$ns duplex-link $n2 $n3 0.5Mb 10ms DropTail
$ns duplex-link $n3 $n4 1.5Mb 10ms DropTail
$ns duplex-link $n4 $n5 0.5Mb 10ms DropTail
$ns duplex-link $n4 $n6 1Mb 10ms DropTail
$ns duplex-link $n4 $n7 1Mb 5ms DropTail

# Define the node position sin the `NAM` graph
$ns duplex-link-op $n0 $n3 orient right-down
$ns duplex-link-op $n1 $n3 orient right
$ns duplex-link-op $n2 $n3 orient right-up
$ns duplex-link-op $n3 $n4 orient right
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right
$ns duplex-link-op $n4 $n7 orient right-down


#####################################
# CBR traffic between nodes 0 and 5 #
#####################################

# Create a UDP sender and a traffic sink for it
# Set `udp1` to a new UDP agent
set udp1 [new Agent/UDP]
# Color all traffic from this agent with color 1
$udp1 set class_ 1
# Set the flow ID
$udp1 set fid_ 1
# Assign the UDP agent to node 0
$ns attach-agent $n0 $udp1
# Assign `sink1` a new LossMonitor which is a traffic sink
set sink1 [new Agent/LossMonitor]
# Assign the LossMonitor to node 5
$ns attach-agent $n5 $sink1
# Establish a logical connection between the two UDP clients
$ns connect $udp1 $sink1

# Send CBR packets over the beforehand created UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp1
# Set the transmission speed/rate
$cbr set rate_ 512k
# Set the packet size
$cbr set packetSize_ 1500


########################################
# ON/OFF traffic between nodes 1 and 6 #
########################################

# Create a UDP sender and a traffic sink for it
# Set `udp2` to a new UDP agent
set udp2 [new Agent/UDP]
# Color all traffic from this agent with color 2
$udp2 set class_ 2
# Set the flow ID
$udp2 set fid_ 2
# Assign the UDP agent to node 0
$ns attach-agent $n1 $udp2
# Assign `sink1` a new LossMonitor which is a traffic sink
set sink2 [new Agent/LossMonitor]
# Assign the LossMonitor to node 5
$ns attach-agent $n6 $sink2
# Establish a logical connection between the two UDP clients
$ns connect $udp2 $sink2

# Create the On/Off flow with Partt's distribution
set flow [new Application/Traffic/Pareto]
# Assign the flow to the UDP client/server
$flow attach-agent $udp2
# Set ON time
$flow set burst_time_ 500ms
# Set OFF time
$flow set idle_time_ 50ms
# Set the transmission speed/rate
$flow set rate_ 500k
# Set the packet size
$flow set packetSize_ 1000
# Set Paret's distribution facot
$flow set shape_ 1


#####################################
# FTP traffic between nodes 2 and 7 #
#####################################

# Create a TCP sender and receiver for the FTP transmission
set tcp1 [new Agent/TCP/Vegas]
# Set `tcp1` to a new TCP Vegas agent
# Color all traffic from this agent with color 3
$tcp1 set class_ 3
# Set the flow ID
$tcp1 set fid_ 3
# Assign the TCP Vegas agent to node 2
$ns attach-agent $n2 $tcp1
# Set `sink3` to a new TCP Sink agent
set sink3 [new Agent/TCPSink]
# Assign the TCP Sink agent to node 7
$ns attach-agent $n7 $sink3
# Establish a logical connection between the two TCP clients
$ns connect $tcp1 $sink3

# Send FTP packets over the beforehand created TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp1
$ftp set type_ FTP
# Set the max size of the congestion window
$ftp set window_ 5
# Set the packet size
$ftp set packet_size_ 1500


###############
# PACKET LOSS #
###############

# Models packet loss on link (n3 - n4) of 1% using the loss module
set loss_module [new ErrorModel]
$loss_module set rate_ 0.01
$loss_module unit pkt ;
$loss_module ranvar [new RandomVariable/Uniform]
$loss_module drop-target [new Agent/Null]
$ns link-lossmodel $loss_module $n3 $n4


################
# EVENT TIMING #
################

# Specify the start and end time of each protocol
$ns at 2 "$ftp start"
$ns at 4.5 "$ftp stop"
$ns at 1 "$cbr start"
$ns at 3.5 "$cbr stop"
$ns at 2 "$flow start"
$ns at 4.5 "$flow stop"

# Terminate the TCP connection at 4.5s (after the FTP transfer is over)
# UDP connections don't require termination
$ns at 4.5 "$ns detach-agent $n2 $tcp1 ; $ns detach-agent $n7 $sink2"
# Execute the `finish` procedure after the simulation has finished (after 5s)
$ns at 5.0 "finish"


#######
# RUN #
#######

# Run the simulation
$ns run
