package om;

class Network {

    #if nodejs

    public static function getLocalIP() : Array<String> {
        var found = new Array<String>();
        var interfaces = js.node.Os.networkInterfaces();
        for( f in Reflect.fields( interfaces ) ) {
            var infos : NetworkInterface = Reflect.field( interfaces, f );
            for( info in infos ) {
                if( info.family == 'IPv4' && !info.internal ) {
                    found.push( info.address );
                }
            }
        }
        return found;
    }

    public static function isPortTaken( port : Int, callback : Bool->Void ) {
		var srv = js.node.Net.createServer();
		srv.once( 'error', function(e){
			callback( e.code == 'EADDRINUSE' );
		});
		srv.once( 'listening', function(){
			srv.once( 'close', function(){
				callback( false );
			});
			srv.close();
		});
		srv.listen( port );
	}

    #end

}
