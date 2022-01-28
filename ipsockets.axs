PROGRAM_NAME='ipsockets'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/28/2022  AT: 10:17:25        *)
(***********************************************************)

DEFINE_DEVICE 

    dvTp = 10001:1:0
    vdvSystem = 33000:1:0

    // Dispositivo para conexi�n IP
    dvSocket = 0:5:0

DEFINE_CONSTANT

    // Id del timeline, �nica por cada bloque de c�digo cerrado
    volatile long _TLID = 1

DEFINE_VARIABLE

    // Definimos los tiempos de los que est� compuesto nuestro timeline
    volatile long lTimes[] = {500} // Actualiza el feedback cada 1/2 segundo
    volatile integer anCanales[] = {1,2,3,4,5,6}
    volatile slong snHandler = -1

DEFINE_START

    /*
    Argumentos
	1 - ID del timeline, debe ser un long
	2 - Tiempos de los que est� compuesto el timeline
	3 - Elegir entre:
	    * timeline_relative: cada tiempo definido es a partir del tiempo anterior
	    * timeline_absolute: cada tiempo definido es a partir del inicio del timeline
	4 - Elegir entre:
	    * timeline_once: el TL se ejecuta una �nica vez
	    * timeline_repeat: el timeline 
    */
    timeline_create(_TLID,lTimes,1,timeline_relative,timeline_repeat)


DEFINE_EVENT

    data_event[dvSocket]
    {
	onerror:
	{
	    // Nos indica si ha habido alg�n error con la conexi�n o el intento de conexi�n
	    send_string 0,"'Error: ',itoa(data.number)" // data.number almacena el n�mero del error
	    
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
	    // Entrar� por aqu� cuando la conexi�n se realice satisfactoriamente
	    send_string 0,'Online'
	}
	offline:
	{
	    // Entrar� por aqu� cuando se caiga o se cierre la conexi�n
	    send_string 0,'Offline'
	    
	    // Ponemos el manejador a -1 para que vuelva a reconectar
	    snHandler = -1
	}	
	string:
	{
	    // Aqu� recibimos las cadenas que nos env�en
	    send_string 0,"'Recibimos: ',data.text" // data.text contiene la cadena que recibamos
	}
    }


    timeline_event[_TLID]
    {
	// Entrar� aqu� cada 1/2 segundo
	wait 50
	{
	    if(snHandler < 0)
	    {
		// Se puede reutilizar �sto para reconectar siempre que se caiga
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