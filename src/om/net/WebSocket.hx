package om.net;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesBuffer;
import haxe.io.Input;
import haxe.io.Output;
import haxe.crypto.Sha1;
import haxe.crypto.Base64;

class WebSocket {

	public static inline var MAGIC_STRING = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

	/**
		Handshake with given input.
	*/
	public static function handshake( i : Input ) : String {
		var l = i.readLine();
		if( !~/^GET (\/[^\s]*) HTTP\/1\.1$/.match( l ) ) {
			trace( "invalid header" );
			return null;
		}
		var host : String = null;
		var origin : String = null;
		var skey : String = null;
		var sversion : String = null;
		var r = ~/^([a-zA-Z0-9\-]+): (.+)$/;
		while( true ) {
			l = i.readLine();
			if( l == "" )
				break;
			if( !r.match( l ) )
				return null;
			switch( r.matched(1) ) {
			//case "Upgrade" :
			//case "Connection" :
			case "Host" : host = r.matched(2);
			case "Origin" : origin = r.matched(2);
			case "Sec-WebSocket-Key" : skey = r.matched(2);
			case "Sec-WebSocket-Version" : sversion = r.matched(2);
			case "Cookie" :
			case "" : break;
			}
		}
		var key = Base64.encode( Bytes.ofString(( hex2data( Sha1.encode( StringTools.trim( skey ) + MAGIC_STRING ) ) ) ) );
		var s = "HTTP/1.1 101 Switching Protocols\r\n"
			  + "Upgrade: websocket\r\n"
			  + "Connection: Upgrade\r\n"
			  + "Sec-WebSocket-Accept: " + key + "\r\n"
			  + "\r\n";
		return s;
	}

	public static function read( i : Input ) : String {
		switch i.readByte() {
		case 0x00 :
			var s = new StringBuf();
			var b : Int;
			while( (b = i.readByte()) != 0xFF )
				s.add( String.fromCharCode(b) );
			return s.toString();
		case 0x81 :
			var len = i.readByte();
			if( len & 0x80 != 0 ) { // mask
				len &= 0x7F;
				if( len == 126 ) {
					var b2 = i.readByte();
					var b3 = i.readByte();
					len = (b2 << 8) + b3;
				} else if( len == 127 ) {
					var b2 = i.readByte();
					var b3 = i.readByte();
					var b4 = i.readByte();
					var b5 =i.readByte();
					len = ( b2 << 24 ) + ( b3 << 16 ) + ( b4 << 8 ) + b5;
				}
				var mask = [];
				mask.push( i.readByte() );
				mask.push( i.readByte() );
				mask.push( i.readByte() );
				mask.push(  i.readByte() );
				var s = new StringBuf();
				for( n in 0...len )
					s.addChar( i.readByte() ^ mask[n % 4] );
				return s.toString();
			}
		}
		return null;
	}

	public static function write( o : Output, s : String ) {
		o.writeByte( 0x81 );
		var len = if( s.length < 126 ) s.length else if( s.length < 65536 ) 126 else 127;
		o.writeByte( len | 0x00 );
		if( s.length >= 126 ) {
			if( s.length < 65536 ) {
				o.writeByte( (s.length >> 8) & 0xFF );
				o.writeByte( s.length & 0xFF );
			} else {
				o.writeByte( (s.length >> 24) & 0xFF );
				o.writeByte( (s.length >> 16) & 0xFF );
				o.writeByte( (s.length >> 8) & 0xFF );
				o.writeByte( s.length & 0xFF );
			}
		}
		o.writeString( s );
	}

	public static function hex2data( hex : String ) : String {
		var t = "";
		for( i in 0...Std.int( hex.length / 2 ) )
			t += String.fromCharCode( Std.parseInt( "0x" + hex.substr( i * 2, 2 ) ) );
		return t;
	}

}
