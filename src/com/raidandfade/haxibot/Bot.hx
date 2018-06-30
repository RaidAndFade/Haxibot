package com.raidandfade.haxibot;

import com.raidandfade.haxibot.commands.haxeboard.Haxeboard;
import com.raidandfade.haxibot.commands.tags.Tags;
import com.raidandfade.haxibot.rssfeeds.RSSFeed;

import com.raidandfade.haxicord.DiscordClient;

import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.MessageChannel;
import com.raidandfade.haxicord.types.structs.Embed;

import orm.Db;

import haxe.DateUtils;

class Bot {
	static var discordBot:DiscordClient;

    static var commandHandler:CommandHandler;
    static var haxeBoard:Haxeboard;
    static var tagList:Tags;

    public static var xkcdFeed:RSSFeed;
    public static var hnFeed:RSSFeed;

    static var db:Db;

    public static var prefix = "`";

    public static function main(){
        try{
            discordBot = new DiscordClient("<token>");
            discordBot.onReady = onReady;
            discordBot.onMessage = onMessage;
            discordBot.onMemberJoin = onMemberJoin;

            db = new Db("sqlite://data.db");

            commandHandler = new CommandHandler(discordBot);
            haxeBoard = new Haxeboard(discordBot,db);

            discordBot.onReactionAdd = haxeBoard.onReactionAdd;
            discordBot.onReactionRemove = haxeBoard.onReactionRemove;

            xkcdFeed = new RSSFeed("https://xkcd.com/rss.xml",1000*60*10); //check every 15 mins because sex
            xkcdFeed.onNewItem = function(el){
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

                discordBot.getMessage("449355531107434496","445449630314921985",function(m){
                    m.edit({embed:em});
                    discordBot.sendMessage("445449630314921985",{content:"p"},function(m,e){
                        m.delete();
                    });
                });

            }


            hnFeed = new RSSFeed("https://hnrss.org/newest",1000*60); //check every 60s

            var hnFeedUpdater = new haxe.Timer(60000);
            hnFeedUpdater.run = function(){
                var em:Embed = {};

                var count = Math.min(12,hnFeed.items.length);

                em.title = "Hackernews Articles (last " + count + ")";
                em.timestamp = DateUtils.utcNow();
                em.description = "";
                var i = 0;
                for(item in hnFeed.items){
                    if(i++>=12) break;

                    em.description += (i) + ": [" + item.title + "]" + "(" + item.link + ")" + "\n\n";
                }
                
                discordBot.getMessage("446097768860221442","445449630314921985",function(m){
                    m.edit({embed:em});
                });
            }


            // tagList = new Tags(discordBot,db);

            discordBot.start();
        }catch(e:Dynamic){
            trace(haxe.CallStack.exceptionStack());
        }
    }

	public static function onMessage(m:Message){
        commandHandler.handle(m);

    }

	public static function onReady(){
        trace(discordBot.getInviteLink());
    }

	public static function onMemberJoin(g:Guild,m:GuildMember){}
}