package com.raidandfade.haxibot.commands;

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;

class Test extends Command{
    override public function call(_msg:Message,_bot:DiscordClient){
        //_msg.reply({content:[for(x in _msg.getGuild().roles.iterator()) x.id+": "+x.name].join("\n")});
    }
}  