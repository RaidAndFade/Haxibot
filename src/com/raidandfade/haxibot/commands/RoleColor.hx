package com.raidandfade.haxibot.commands;

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.Role;

class RoleColorAdd extends Command{
    override public function call(_msg:Message,_bot:DiscordClient){
        if(!_msg.inGuild() || _msg.getGuild().id.id != "313211953252139009") return;
        var g = _msg.getGuild();
        var color = _msg.content.split(" ")[1];
        color = StringTools.replace(color,"0x","");
        color = StringTools.replace(color,"#","");
        color = color.toUpperCase();
        if(!~/^[0-9a-f]{6}$/i.match(color))
            return _msg.react("❌");
        g.getRoles(function(rs,e){
            g.getMember(_msg.author.id.id,function(gm){
                for(role in gm.roles){
                    for(ro in [for (r in rs) if(r.id.id == role && ~/^[0-9a-f]{6}$/i.match(r.name))r]){
                        gm.removeRole(ro.id.id);
                        var isUsed=false;
                        for(m in g.members){
                            if(m.roles.indexOf(ro.id.id)!=-1){
                                isUsed=true;
                                break;
                            }
                        }
                        if(!isUsed){
                            ro.delete();
                        }
                    }
                }
            });
            var exists = false;
            for(ro in rs){
                if(ro.name == color){
                    addRole(_msg,ro);
                    exists=true;
                }
            }
            var colNum = hexToInt(color);
            if(!exists)
            g.createRole({name:color,color:colNum},function(r,e){
                addRole(_msg,r);
            });
        });
    }

    public static function hexToInt(hex:String){
        return Std.parseInt("0x"+hex);
    }

    public function addRole(_m:Message,_r:Role){
        _m.getGuild().getMember(_m.author.id.id,function(gm){
            gm.addRole(_r.id.id);
            _m.react("✅");
        });
    }
}  


class RoleColorClear extends Command{
    override public function call(_msg:Message,_bot:DiscordClient){
        if(!_msg.inGuild() || _msg.getGuild().id.id != "313211953252139009") return;
        if(_msg.author.id.id != "120308435639074816") return;
        var g = _msg.getGuild();
        g.getRoles(function(rs,e){
            if(e!=null)throw e;
            for(ro in [for (r in rs) if( ~/^[0-9a-f]{6}$/i.match(r.name)) r]){
                ro.delete();
            }
            _msg.react("✅");
        }); 
    }
}
 