PROGRAM_NAME='ipsockets'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/28/2022  AT: 10:17:25        *)
(***********************************************************)

DEFINE_DEVICE 

    dvTp = 10001:1:0
    vdvSystem = 33000:1:0

    // Dispositivo para conexión IP
    dvSocket = 0:5:0

DEFINE_CONSTANT

    // Id del timeline, única por cada bloque de código cerrado
    volatile long _TLID = 1

DEFINE_VARIABLE

    // Definimos los tiempos de los que está compuesto nuestro timeline
    volatile long lTimes[] = {500} // Actualiza el feedback cada 1/2 segundo
    volatile integer anCanales[] = {1,2,3,4,5,6}
    volatile slong snHandler = -1

DEFINE_START

    /*
    Argumentos
	1 - ID del timeline, debe ser un long
	2 - Tiempos de los que está compuesto el timeline
	3 - Elegir entre:
	    * timeline_relative: cada tiempo definido es a partir del tiempo anterior
	    * timeline_absolute: cada tiempo definido es a partir del inicio del timeline
	4 - Elegir entre:
	    * timeline_once: el TL se ejecuta una única vez
	    * timeline_repeat: el timeline 
    */
    timeline_create(_TLID,lTimes,1,timeline_relative,timeline_repeat)


DEFINE_EVENT

    data_event[dvSocket]
    {
	onerror:
	{
	    // Nos indica si ha habido algún error con la conexión o el intento de conexión
	    send_string 0,"'Error: ',itoa(data.number)" // data.number almacena el número del error
	    
	    // Ponemos el manejador a -1 para que vuelva a reconectar
	    snHandler = -1
		
	    /* Tipos de errores:
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
		Otros: Unknown
	    */
	}
	online:
	{
	    // Entrará por aquí cuando la conexión se realice satisfactoriamente
	    send_string 0,'Online'
	}
	offline:
	{
	    // Entrará por aquí cuando se caiga o se cierre la conexión
	    send_string 0,'Offline'
	    
	    // Ponemos el manejador a -1 para que vuelva a reconectar
	    snHandler = -1
	}	
	string:
	{
	    // Aquí recibimos las cadenas que nos envíen
	    send_string 0,"'Recibimos: ',data.text" // data.text contiene la cadena que recibamos
	}
    }


    timeline_event[_TLID]
    {
	// Entrará aquí cada 1/2 segundo
	wait 50
	{
	    if(snHandler < 0)
	    {
		// Se puede reutilizar ésto para reconectar siempre que se caiga
		snHandler = ip_client_open(dvSocket.port,'192.168.1.100',5000,IP_TCP)
	    }
	}
    }
	
    channel_event[vdvSystem,anCanales]
    {
	on:
	{
	    stack_var integer nCanalActivado
	    nCanalActivado = get_last(anCanales)
	    switch(nCanalActivado)
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