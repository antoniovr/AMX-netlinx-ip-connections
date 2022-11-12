PROGRAM_NAME='ipsockets_connect_to_send'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/12/2022  AT: 17:46:16        *)
(***********************************************************)

DEFINE_DEVICE 

    dvTp = 10001:1:0
    vdvSystem = 33000:1:0

    // Device for ip connection
    dvSocket = 0:5:0


DEFINE_VARIABLE

    volatile integer anChannels[] = {1,2,3,4,5,6}

    // Global variable to store the command to send
    volatile char sCommandToSend[64] = ''

DEFINE_EVENT

    data_event[dvSocket]
    {
	online:
	{
	    // It will get into this section when the connection is established
	    send_string 0,'Online and ready to send'
	    send_string dvSocket,"sCommandToSend"
	    ip_client_close(dvSocket.PORT)
	}	
	string:
	{
	    // It will get into this section when we receive a string through the socket connection
            // data.text will store the string we have received
	    send_string 0,"'Recibimos: ',data.text" 
	}
    }

    channel_event[dvTp,anChannels]
    {
	on:
	{
	    stack_var integer nActivatedChannel
	    nActivatedChannel = get_last(anChannels)
	    switch(nActivatedChannel)
	    {
		case 1: 
		{
		    sCommandToSend = "'POWER ON',$0d"
		    ip_client_open(dvSocket.port,'192.168.1.100',5000,IP_TCP)
		}
	    }
	}
    }
    
(***********************************************************)
(*		    	END OF PROGRAM			   *)
(***********************************************************) 