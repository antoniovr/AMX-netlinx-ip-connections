PROGRAM_NAME='ipsockets_connect_to_send'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/28/2022  AT: 10:20:51        *)
(***********************************************************)

DEFINE_DEVICE 

    dvTp = 10001:1:0
    vdvSystem = 33000:1:0

    // Dispositivo para conexión IP
    dvSocket = 0:5:0


DEFINE_VARIABLE

    volatile integer anCanales[] = {1,2,3,4,5,6}

    // Variable global para almacenar el comando a enviar
    volatile char sCommandToSend[64] = ''

DEFINE_EVENT

    data_event[dvSocket]
    {
	online:
	{
	    // Entrará por aquí cuando la conexión se realice satisfactoriamente
	    send_string 0,'Online y listo para enviar'
	    send_string dvSocket,"sCommandToSend"
	    ip_client_close(dvSocket.PORT)
	}	
	string:
	{
	    // Aquí recibimos las cadenas que nos envíen
	    send_string 0,"'Recibimos: ',data.text" // data.text contiene la cadena que recibamos
	}
    }


    channel_event[dvTp,anCanales]
    {
	on:
	{
	    stack_var integer nCanalActivado
	    nCanalActivado = get_last(anCanales)
	    switch(nCanalActivado)
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