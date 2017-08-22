package om.net;

/**
	Incomplete list of internet socket tcp port numbers.

	Well-known ports
	The port numbers in the range from 0 to 1023 are the well-known ports or system ports.
	They are used by system processes that provide widely used types of network services.
	On Unix-like operating systems, a process must execute with superuser privileges to be able to bind a network socket to an IP address using one of the well-known ports.

	The range of port numbers from 1024 to 49151 are the registered ports.
	They are assigned by IANA for specific service upon application by a requesting entity.
	On most systems, registered ports can be used by ordinary users.
*/
@:enum abstract Port(UInt) from UInt to UInt {

	var ftp = 21;
    var ssh = 22;
	var telnet = 23;
	var smtp = 25;
	var whois = 43;
	var dns = 53;
	var http = 80;
	var rtelnet = 107;
	var pop3 = 110;
	var nntp = 119;
	var ntp = 123;
	var netbios_ssn = 139;
	var imap = 143;
	var sql = 156;
	var snmp = 161;
	var xdmcp = 177; // X Display Manager
	var irc = 194;
	var https = 443;
	var smb = 445; // Microsoft-DS SMB file sharing
	var rtsp = 554; // Real Time Streaming Protocol
	//var doom = 666; // FPS
	//var doom = 694; // Linux-HA high-availability heartbeat
	//var rsync = 873; // File synchronization protocol

	//var rsync = 1080; // SOCKS proxy
	var rtp = 5004; // Real-time Transport Protocol (RFC 3551, RFC 4571)
	var rtcp = 5005; // Real-time Transport Protocol Control Protocol (RFC 3551, RFC 4571)
	var sip = 5060; // Session Initiation Protocol
	var sip_tls = 5061; // Session Initiation Protocol over TLS
	var xmpp_c2s = 5222; // Extensible Messaging and Presence Protocol client connection
	var xmpp_c2s_ssl = 5223; // Extensible Messaging and Presence Protocol client connection over SSL
	var xmpp_s2s = 5269; // Extensible Messaging and Presence Protocol server-to-server connection
	var xmpp_bosh = 5280; // Extensible Messaging and Presence Protocol XEP-0124: Bidirectional-streams Over Synchronous HTTP
	//var stun = 5349; // STUN (TLS over TCP), a protocol for NAT traversal
	//var turn = 5349; // TURN (TLS over TCP), a protocol for NAT traversal
	var mdns = 5353; // Multicast DNS (mDNS)
	var postgresql = 5432; // PostgreSQL database system
	var vnc = 5500; // VNC remote desktop protocol—for incoming listening viewer
	var bittorrent = 6901; // BitTorrent
	var bittorrent_tracker = 6969; // BitTorrent tracker

}
