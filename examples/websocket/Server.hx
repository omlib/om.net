
import om.net.WebSocket;

class Server {

	static function main() {

		var host = '127.0.0.1';
		var port = 7700;

		trace( 'Starting websocket server $host:$port' );

		var socket = new sys.net.Socket();
		socket.bind( new sys.net.Host( host ), port );
		socket.listen(1);

		while( true ) {

			var client = socket.accept();
		    trace( 'client connected ('+client.peer().host.toString()+')' );

			var response = WebSocket.handshake( client.input );
			WebSocket.write( client.output, response );
			trace( "handshake complete" );

			var msg = WebSocket.read( client.input );
			trace( 'client message: $msg' );
			WebSocket.write( client.output, msg );

		    client.close();
		}
	}
}
