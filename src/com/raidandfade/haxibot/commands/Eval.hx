package com.raidandfade.haxibot.commands;

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.structs.Embed;

class Eval extends Command{
    static var gctToken = "<token>";

    public override function call(_msg:Message,_bot:DiscordClient){
        _msg.reply({content:"Please wait while your code executes"},function(m,e){
            if(e!=null)return trace(e);
            var reg = ~/```(\S+)\n?([\s\S]+)```/g;

            reg.match(_msg.content);

            var lang = reg.matched(1);
            var code = reg.matched(2);

            var headers:Map<String,String> = new Map<String,String>();
            headers.set("Authorization", gctToken);
            haxe.Https.makeRequest("https://api.gocode.it/exec/"+lang,"POST",function(r,h){
                if(r.error!=null){
                    trace(r.data.error);
                    m.edit({content:"Something went wrong when reading result. :("});
                }else{
                    var d = r.data.data;
                    var em:Embed = {};
                    em.footer = {text:"GCT Exec: `"+lang+"` | Took "+Math.round(Std.parseInt(d.comp)/10)/100+"s"};
                    em.title = "Code Execution";
                    var res:String = d.res;

                    var resl = res.split("\n");
                    resl = resl.slice(-15);

                    res = resl.join("\n");

                    res = res.length>1000?res.substr(res.length-1000,1000):res;

                    em.description = res;
                    m.edit({content:"",embed:em});
                }
            },code,headers);
        });
    }
}