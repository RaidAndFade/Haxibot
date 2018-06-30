package com.raidandfade.haxibot.commands;

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.structs.Embed;

import com.raidandfade.haxibot.Bot;

class Hackernews extends Command{
    override public function call(_msg:Message,_bot:DiscordClient){
        if(Bot.hnFeed.items.length>0){
            var el = Bot.hnFeed.items[0];

            var em:Embed = {};
            em.title = el.title;
            em.url = el.link;
            em.description = "New Hackernews article. Check it out!";

            _msg.reply({embed:em});
        }else{
            _msg.reply({content:"No items found, perhaps it's reloading?"});
        }
    }
}  