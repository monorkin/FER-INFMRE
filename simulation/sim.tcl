# Authors
# Stanko Krtalic Rusendic - 0036463148

# Assign `ns` to an instance of the simulator
set ns [new Simulator]

# Specify which colors to use for which flow id
# This is used for the `NAM` part of the assignment
# This has no influence on the simulation itself
$ns color 1 Blue
$ns color 2 Red

# Instruct the simulator to record each step of the simulation
# This is, again, used for the `NAM` part of the assignment
# `NAM` uses the generated `out.nam` file to generate it's graph
# We will use the `nf` variable to stor the output file
set nf [open out.nam w]
$ns namtrace-all $nf

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

# Define all nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

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

# Set `tcp` to a new TCP Vegas agent
set tcp [new Agent/TCP/Vegas]
# Assign the TCP Vegas agent to node 2
$ns attach-agent $n2 $tcp
# Set `sink` to a new TCP Sink agent
set sink [new Agent/TCPSink]
# Assign the TCP Sink agent to node 7
$ns attach-agent $n7 $sink
# Establish a logical connection between the two TCP clients
$ns connect $tcp $sink
$tcp set fid_ 1

# Send FTP packets over the beforehand created TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
# Set the max size of the congestion window
$ftp set window_ 5
# Set the packet size
$ftp set packet_size_ 1500

# Models packet loss on link (n3 - n4) of 1% using the loss module
set loss_module [new ErrorModel]
$loss_module set rate_ 0.01
$loss_module unit pkt ;
$loss_module ranvar [new RandomVariable/Uniform]
$loss_module drop-target [new Agent/Null]
$ns link-lossmodel $loss_module $n3 $n4

# Specify the start and end time of each protocol
$ns at 2 "$ftp start"
$ns at 4.5 "$ftp stop"

# Terminate the TCP connection at 4.5s (after the FTP transfer is over)
$ns at 4.5 "$ns detach-agent $n2 $tcp ; $ns detach-agent $n7 $sink"

# Execute the `finish` procedure after the simulation has finished (after 5s)
$ns at 5.0 "finish"

# Run the simulation
$ns run
