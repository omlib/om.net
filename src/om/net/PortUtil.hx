package om.net;

#if nodejs

class PortUtil {

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

}

#end
