package om;

#if nodejs
import js.node.Os;
#end

class Network {

    #if nodejs

    public static function getLocalIP() : Array<String> {
        var found = new Array<String>();
        var interfaces = Os.networkInterfaces();
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

    #end
    
}
