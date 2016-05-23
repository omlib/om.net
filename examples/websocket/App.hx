
import js.Browser.console;
import js.Browser.document;

class App {

	static function main() {

		var btn = document.getElementById( 'connect' );
		btn.onclick = function() {
			var socket = new js.html.WebSocket( 'ws://127.0.0.1:7700' );
			socket.onopen = function () {
				console.debug( 'onopen' );
				socket.send( "abc" );
			};
			socket.onerror = function(e) {
				console.error(e);
			};
			socket.onclose = function(e) {
				console.info(e);
			};
			socket.onmessage = function(e) {
				console.info(e);
				var message = document.createDivElement();
				message.textContent = e.data;
				document.body.appendChild( message );
			};
		}
	}
}
