
import js.Browser.console;
import js.Browser.document;
import js.html.CloseEvent;
import js.html.MessageEvent;

class Client {

	static function main() {

		var btn = document.getElementById( 'connect' );

		btn.onclick = function() {

			var ip = untyped document.getElementById( "ip" ).value;
			var port = untyped document.getElementById( "port" ).value;
			var url = 'ws://$ip:$port';

			console.debug( 'Connecting $url' );

			var socket = new js.html.WebSocket( url );
			socket.onopen = function(e) {
				console.debug( e );
				socket.send( "Hello!" );
			};
			socket.onerror = function(e) {
				console.error(e);
			};
			socket.onclose = function( e : CloseEvent ) {
				console.debug(e);
			};
			socket.onmessage = function( e : MessageEvent ) {
				console.debug( e.data );
			};
		}
	}
	
}
