
import js.Browser.console;
import js.Browser.document;

class App {

	static function main() {

		var btn = document.getElementById( 'connect' );
		btn.onclick = function() {

			var ip = untyped document.getElementById( "ip" ).value;
			var port = untyped document.getElementById( "port" ).value;
			var url = 'ws://$ip:$port';

			trace( 'Connecting to $url ...' );

			var socket = new js.html.WebSocket( url );
			socket.onopen = function () {
				console.debug( 'onopen' );
				//socket.send( "abc" );
			};
			socket.onerror = function(e) {
				console.error( 'onerror '+e);
			};
			socket.onclose = function(e) {
				console.info( 'onclose '+e );
			};
			socket.onmessage = function(e) {

				console.info( 'onmessage '+e );

				//var message = document.createDivElement();
				//message.textContent = e.data;
				//document.body.appendChild( message );
			};
		}
	}
}
