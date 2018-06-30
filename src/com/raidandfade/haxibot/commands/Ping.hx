package com.raidandfade.haxibot.commands;

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;

class Ping extends Command{
    override public function call(_msg:Message,_bot:DiscordClient){
        _msg.react("✅",function(a,e){
            trace("REACTED");
            if(e!=null) trace(e);
        });
    }
}  