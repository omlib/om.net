package om.net;

import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;
import haxe.crypto.Sha1;
import haxe.crypto.Base64;

#if nodejs
import js.node.Buffer;
#end

using StringTools;

/**
	https://www.w3.org/TR/websockets/
*/
class WebSocket {

	public static inline var MAGIC_STRING = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

	public static function createHandshake( inp : Input ) : String {

		//+ 'Sec-WebSocket-Version: 13\r\n'

		var line = inp.readLine();
		if( !~/^GET (\/[^\s]*) HTTP\/1\.1$/.match( line ) ) {
			return throw 'invalid header';
		}

		//var host : String = null;
		//var origin : String = null;
		var skey : String = null;
		var sversion : String = null;

		var rexp = ~/^([a-zA-Z0-9\-]+): (.+)$/;
		while( (line = inp.readLine()) != "" ) {
			if( !rexp.match( line ) )
				return throw 'invalid header';
			switch rexp.matched( 1 ) {
			case "Sec-WebSocket-Key": skey = rexp.matched( 2 );
			case "Sec-WebSocket-Version" : sversion = rexp.matched( 2 );
			}
		}

		var key = createKey( skey );

		return
			'HTTP/1.1 101 Switching Protocols\r\n'
			+ 'Connection: Upgrade\r\n'
			+ 'Upgrade: websocket\r\n'
			+ 'Sec-WebSocket-Accept: '+key+'\r\n'
			+ '\r\n';
	}

	public static function createKey( skey : String ) : String {

		#if sys
		return Base64.encode( Bytes.ofString( hex2data( Sha1.encode( skey + MAGIC_STRING ) ) ) );

		#elseif nodejs
		var sha1 = js.node.Crypto.createHash( 'sha1' );
		sha1.end( skey + MAGIC_STRING, 'utf8' );
		var buf : Buffer = sha1.read();
		return buf.toString( 'base64' );

		#end
	}

	static function hex2data( hex : String ) : String {
		var buf = new StringBuf();
		for( i in 0...Std.int( hex.length / 2 ) )
			buf.add( String.fromCharCode( Std.parseInt( "0x" + hex.substr( i * 2, 2 ) ) ) );
		return buf.toString();
	}

	#if sys

	public static function readFrame( inp : Input ) : String {
		switch inp.readByte() {
		case 0x00 :
			var buf = new StringBuf();
			var byte : Int;
			while( (byte= inp.readByte()) != 0xFF )
				buf.add( String.fromCharCode( byte ) );
			return buf.toString();
		case 0x81 :
			var len = inp.readByte();
			if( len & 0x80 != 0 ) { // mask
				len &= 0x7F;
				if( len == 126 ) {
					var b2 = inp.readByte();
					var b3 = inp.readByte();
					len = (b2 << 8) + b3;
				} else if( len == 127 ) {
					var b2 = inp.readByte();
					var b3 = inp.readByte();
					var b4 = inp.readByte();
					var b5 = inp.readByte();
					len = ( b2 << 24 ) + ( b3 << 16 ) + ( b4 << 8 ) + b5;
				}
				var mask = [];
				mask.push( inp.readByte() );
				mask.push( inp.readByte() );
				mask.push( inp.readByte() );
				mask.push( inp.readByte() );
				var buf = new StringBuf();
				for( n in 0...len )
					buf.addChar( inp.readByte() ^ mask[n % 4] );
				return buf.toString();
			}
		}
		return null;
	}

	public static function writeFrame( out : Output, str : String ) {
		out.writeByte( 0x81 );
		var len = if( str.length < 126 ) str.length else if( str.length < 65536 ) 126 else 127;
		out.writeByte( len | 0x00 );
		if( str.length >= 126 ) {
			if( str.length < 65536 ) {
				out.writeByte( (str.length >> 8) & 0xFF );
				out.writeByte( str.length & 0xFF );
			} else {
				out.writeByte( (str.length >> 24) & 0xFF );
				out.writeByte( (str.length >> 16) & 0xFF );
				out.writeByte( (str.length >> 8) & 0xFF );
				out.writeByte( str.length & 0xFF );
			}
		}
		out.writeString( str );
	}

	#elseif nodejs

	public static function readFrame( inp : Buffer ) : String {
		switch inp[0] {
		case 0x00:
			var buf = new StringBuf();
			var byte : Int;
			var i = 1;
			while( (byte = inp[i] ) != 0xFF ) {
				buf.add( String.fromCharCode( byte ) );
				i++;
			}
			return buf.toString();
		case 0x81:
			var i = 1;
			var len = inp[i++];
			if( len & 0x80 != 0 ) { // mask
				len &= 0x7F;
				if( len == 126 ) {
					var b2 = inp[i++];
					var b3 = inp[i++];
					len = (b2 << 8) + b3;
				} else if( len == 127 ) {
					var b2 = inp[i++];
					var b3 = inp[i++];
					var b4 = inp[i++];
					var b5 = inp[i++];
					len = ( b2 << 24 ) + ( b3 << 16 ) + ( b4 << 8 ) + b5;
				}
				var mask = [];
				mask.push( inp[i++] );
				mask.push( inp[i++] );
				mask.push( inp[i++] );
				mask.push( inp[i++] );
				var buf = new StringBuf();
				for( n in 0...len )
					buf.addChar( inp[i++] ^ mask[n % 4] );
				return buf.toString();
			}
		}
		return null;
	}

	public static function writeFrame( payload : Buffer, fin = true, opcode = 1, masked = false ) : Buffer {

		var len = payload.length;

		var meta = new Buffer( 2 + (len < 126 ? 0 : (len < 65536 ? 2 : 8)) + (masked ? 4 : 0 ) );
		meta[0] = (fin ? 128 : 0) + opcode;
		meta[1] = masked ? 128 : 0;

		var start = 2;
		if( len < 126 ) {
			meta[1] += len;
		} else if( len < 65536 ) {
			meta[1] += 126;
			meta.writeUInt16BE( len, 2 );
			start += 2;
		} else {
			// Warning: JS doesn't support integers greater than 2^53
			meta[1] += 127;
			meta.writeUInt32BE( Math.floor(len / Math.pow( 2, 32 ) ), 2 );
			meta.writeUInt32BE( len % Std.int( Math.pow( 2, 32 ) ), 6 );
			start += 8;
		}

		if( masked ) {
			var mask = new Buffer( 4 );
			for( i in 0...4 )
				meta[start + i] = mask[i] = Math.floor( Math.random() * 256 );
			for( i in 0...payload.length )
				payload[i] ^= mask[i % 4];
			start += 4;
		}

		return Buffer.concat( [meta,payload] );
	}

	#end

}
