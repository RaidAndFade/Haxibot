package com.raidandfade.haxibot.commands;

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;

class Debug extends Command{
    public override function call(m:Message,_bot:DiscordClient){
        if(m.author.id.id!="120308435639074816" && m.author.id.id!="85257659694993408") return;

        var cont = m.content.split(" ").slice(1).join(" ");//simple fix because lazy

        var re = ~/`(``([\w\d]+))?\n? ?([^`]+)[`]{1,3}/;
        if(!re.match(cont)){
            m.reply({content:"Bad content given. no!"});
            return;
        }


        var lang = re.matched(2);
        var code = re.matched(3);

        if(lang!="haxe" && lang!="hx"){
            m.reply({content:"haxe only pls!"});
            return;
        }

        try{
            var parser = new hscript.Parser();
            var pgm = parser.parseString(code);
            var int = new hscript.Interp();
            int.variables.set("client",_bot);
            int.variables.set("message",m);
            var res = Std.string(int.execute(pgm));
            m.reply({content:res},function(_,e){
                if(e!=null){
                    m.reply({content:"Something went wrong... "+e});
                }
            });
            
        }catch(e:Dynamic){
            m.reply({content:"Something went wrong... "+e});
        }
    }
    
}