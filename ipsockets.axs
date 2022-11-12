PROGRAM_NAME='ipsockets'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/12/2022  AT: 17:42:10        *)
(***********************************************************)

DEFINE_DEVICE 

    dvTp = 10001:1:0
    vdvSystem = 33000:1:0

    // Device for ip connection (note that device is 0 and the important thing is the port parameter (device:port:system)
    dvSocket = 0:5:0

DEFINE_CONSTANT

    // Timeline ID, it's unique for each closed code block
    volatile long _TLID = 1

DEFINE_VARIABLE

    // We define the times that are part of our timeline, in this case is only one because we need a timeline that executes 
    // every 1/2 seconds
    volatile long lTimes[] = {500} // milliseconds, 1/2 seconds
    volatile integer anChannels[] = {1,2,3,4,5,6}
    volatile slong snHandler = -1

DEFINE_START

    /*
    Arguments
	1 - Timeline ID, it has to be LONG
	2 - Array of times for our timeline
	3 - Choose between:
	    * timeline_relative: each time it's starting from the previous one
	    * timeline_absolute: each times takes the start of the timeline as base
	4 - Choose between:
	    * timeline_once: The timeline executes only one time
	    * timeline_repeat: The timeline repeats until you stop it
    */
    timeline_create(_TLID,lTimes,1,timeline_relative,timeline_repeat)


DEFINE_EVENT

    data_event[dvSocket]
    {
	onerror:
	{
	    // The execution enters on this section if there has been an error trying to pen the connection or 
            // during the connection
	    send_string 0,"'Error: ',itoa(data.number)" // data.number stores the number of the error
	    
	    // We put the handler to -1 to reconnect again in the TIMELINE_EVENT (on the bottom of the file)
	    snHandler = -1
		
	    /* Types of error:
		2:  General Failure (IP_CLIENT_OPEN/IP_SERVER_OPEN)
		4:  Unknown host or DNS error (IP_CLIENT_OPEN)
		6:  Connection refused (IP_CLIENT_OPEN)
		7:  Connection timed out (IP_CLIENT_OPEN)
		8:  Unknown connection error (IP_CLIENT_OPEN)
		9:  Already closed (IP_CLIENT_CLOSE/IP_SERVER_CLOSE)
		14: Local port already used (IP_CLIENT_OPEN/IP_SERVER_OPEN)
		16: Too many open sockets (IP_CLIENT_OPEN/IP_SERVER_OPEN)
		10: Binding error (IP_SERVER_OPEN)
		11: Listening error (IP_SERVER_OPEN)
		15: UDP socket already listening (IP_SERVER_OPEN)
		17: Local port not open, can not send string (IP_CLIENT_OPEN)
		Others: Unknown
	    */
	}
	online:
	{
	    // It will enter in this section when the connection is established
	    send_string 0,'Online'
	}
	offline:
	{
	    // It will enter in this section when the connection drops or has been closed from the code
	    send_string 0,'Offline'
	    
	    // We put the handler to -1 to make the program connect again on the timeline_event (on the bottom of the file)
	    snHandler = -1
	}	
	string:
	{
	    // It will enter in this section when we receive strings through the connection
	    send_string 0,"'We receive: ',data.text" // data.text stores the received string
	}
    }


    timeline_event[_TLID]
    {
	// It will enter in this section every 1/2 second
        
        // we wait extra 5 seconds to check the socket connection
	wait 50
	{
	    if(snHandler < 0) // Is the handler is lower than 0, the connection is closed and we need to open it again
	    {
		snHandler = ip_client_open(dvSocket.port,'192.168.1.100',5000,IP_TCP)
	    }
	}
    }

    // Channel event, just for test purposes
    channel_event[vdvSystem,anChannels]
    {
	on:
	{
	    stack_var integer nActivatedChannel
	    nActivatedChannel = get_last(anChannels)
	    switch(nActivatedChannel)
	    {
		case 1: 
		{
		    
		}
	    }
	}
    }
    
(***********************************************************)
(*		    	END OF PROGRAM			   *)
(***********************************************************) 