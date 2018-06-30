package com.raidandfade.haxibot;

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;

import com.raidandfade.haxibot.commands.Command;
import com.raidandfade.haxibot.commands.*;

class CommandHandler{
    var bot:DiscordClient;

    var commands:Map<String,Command> = new Map<String,Command>();

    public function new(_bot){
        bot = _bot;

        //init and add commands
        addCommand("ping",new Ping());
        
        addCommand("color",new RoleColor.RoleColorAdd());

        addCommand("wow",new WoWCommand());

        addCommand("exec",new Eval());
        
        addCommand("test",new Test());
        addCommand("debug",new Debug());

        addCommand("xkcd",new XKCD());
        addCommand("hackernews",new Hackernews());
        //addCommand("clearcolors",new RoleColor.RoleColorClear());
    }

    private function addCommand(cname:String,cclass){
        cname = cname.toLowerCase();
        if(commands.exists(cname))
            throw "Command "+cname+" set twice";
        commands.set(cname,cclass); 
    }

    public function handle(m:Message){
        if(m.content.substring(0,Bot.prefix.length) == Bot.prefix){
            
            for(coms in commands.keys()){
                if(m.content.substr(Bot.prefix.length,coms.length) == coms){
                    commands.get(coms).call(m,bot);
                }
            }
        }
    }
}