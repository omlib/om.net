
import Sys.println;
import om.net.WebSocket;

class Server {

	static function main() {

		var host = '127.0.0.1';
		var port = 7700;

		println( 'Starting websocket server $host:$port' );

		#if sys

		var server = new sys.net.Socket();
		server.bind( new sys.net.Host( host ), port );
		server.listen( 1 );

		while( true ) {

			var socket = server.accept();
		    println( 'Socket connected ('+socket.peer().host.toString()+')' );

			WebSocket.writeFrame( socket.output, WebSocket.createHandshake( socket.input ) );
			println( 'Handshake complete' );

			var msg = WebSocket.readFrame( socket.input );
			println( 'Client message: $msg' );

			WebSocket.writeFrame( socket.output, msg );

			socket.close();
			println( 'Socket closed' );
		}

		#elseif nodejs

		js.node.Net.createServer( function(socket) {

			var handshaked = false;

			socket.on( 'end', function(data){
				trace('disconnected from server');
			});
			socket.on( 'data', function(buf:js.node.Buffer) {

				if( handshaked ) {
					var msg = WebSocket.readFrame( buf );
					println( '  Client message: $msg' );
					var res = new js.node.Buffer( msg );
					socket.write( WebSocket.writeFrame( res ) );

					socket.end();


				} else {
					var str = buf.toString();
					var res = WebSocket.createHandshake( new haxe.io.StringInput( str ) );
					socket.write( res );
					handshaked = true;
				}
			});
		}).listen( port, host );

		#end
	}
}
