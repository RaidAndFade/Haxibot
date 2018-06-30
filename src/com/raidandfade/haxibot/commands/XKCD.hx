package com.raidandfade.haxibot.commands;

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.structs.Embed;

import com.raidandfade.haxibot.Bot;

import haxe.DateUtils;

class XKCD extends Command{
    override public function call(_msg:Message,_bot:DiscordClient){
        if(Bot.xkcdFeed.items.length>0){
            var el = Bot.xkcdFeed.items[0];

            var em:Embed = {};
            em.title = el.title;
            em.url = el.link;
            em.timestamp = DateUtils.utcNow();
            em.image = {};
            em.image.url = "https://imgs.xkcd.com/comics/" + StringTools.replace(StringTools.replace(em.title.toLowerCase()," ","_"),"-","_") + "_2x.png?1";

            var descel = Xml.parse(el.description).firstElement();
            var altText = descel.get("title");
            em.footer = {};
            em.footer.text = altText;

            _msg.reply({embed:em});
        }else{
            _msg.reply({content:"No items found, perhaps it's reloading?"});
        }
    }
}  