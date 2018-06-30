package com.raidandfade.haxibot.commands.haxeboard;

import com.raidandfade.haxicord.DiscordClient;

import com.raidandfade.haxicord.types.Message;

import orm.Db;

import haxe.Timer;

//This is an L. do it again but better tomorrow.
//store CHANGES and calculate them on tick rather than trying to be a magician

class Haxeboard{
    public static var boardId = "350092521243934742";

    var waiting:Map<String,Array<Dynamic>> = new Map<String,Array<Dynamic>>();
    var ticker:Timer;

    var cache:Map<String,Int> = new Map<String,Int>();
    var boardMessageContent:Map<String,Int> = new Map<String,Int>();

    var boardMessages:Map<String,String> = new Map<String,String>();

    var loadsPending:Array<String> = new Array<String>();

    var client:DiscordClient;
    var db:Db;

    public function new(_cl,_db){
        client = _cl;
        db = _db;
        ticker = new Timer(5000);
        ticker.run = tick;

        db.query("CREATE TABLE IF NOT EXISTS `haxeboard` (`id` TEXT,`boardId` TEXT,`starcount` INTEGER, PRIMARY KEY(`id`));");
    }

    public function onReactionAdd(m:Message,u,e){
        if(e.name=="⭐" && u.id.id != m.author.id.id && !m.author.bot)
            addStarToMessage(m);
    }

    public function onReactionRemove(m:Message,u,e){
        if(e.name=="⭐" && u.id.id != m.author.id.id)
            delStarFromMessage(m);
    }

    public function addStarToMessage(m:Message){ 
        if(cache.exists(m.id.id)){
            cache.set(m.id.id,cache.get(m.id.id)+1);
        }else{
            loadsPending.push(m.id.id);
            loadFromTable(m.id.id);
            cache.set(m.id.id,cache.get(m.id.id)+1);
        }
    }
    
    public function delStarFromMessage(m:Message){
        if(cache.exists(m.id.id)){
            cache.set(m.id.id,cache.get(m.id.id)-1);
        }else{
            loadsPending.push(m.id.id);
            loadFromTable(m.id.id);
            cache.set(m.id.id,cache.get(m.id.id)-1);
        }
    }

    public function tick(){ //calc stars, save to db, flush cache, and output on tick
        var i = cache.keys();
        while(i.hasNext()){
            var k = i.next();
            var m = cache.get(k);
            //trace(k+"-"+m+": "+boardMessageContent.exists(k));
            if(loadsPending.indexOf(k)!=-1) //don't update a message we haven't loaded.
                continue;
            if(!boardMessageContent.exists(k))
                updateBoardMessage(client.getMessageUnsafe(k));
            if((boardMessageContent.exists(k)&&boardMessageContent.get(k)!=m))
                updateBoardMessage(client.getMessageUnsafe(k));
        }
        saveTable();
    }

    public function saveTable(){
        var i = cache.keys();
        while(i.hasNext()){
            var id = i.next();
            var count = cache.get(id);
            var boardId = boardMessages.get(id);
            db.query("INSERT OR REPLACE INTO `haxeboard` VALUES ('"+id+"','"+boardId+"','"+count+"');");
        }
    }

    public function loadFromTable(id){
        var rowCount = db.query("SELECT COUNT(*) FROM `haxeboard` WHERE `id` = '"+id+"';").getIntResult(0);
        if(rowCount!=0) 
        {
            var q = db.query("SELECT `boardId`,`starcount` from `haxeboard` where `id` = '"+id+"';");
            boardMessages.set(id,q.getResult(0));
            cache.set(id,q.getIntResult(1));
        }else{
            cache.set(id,0);
        }
        loadsPending.remove(id);
    }

    //fix this up.
    public function updateBoardMessage(m:Message){
        var embed:com.raidandfade.haxicord.types.structs.Embed = {
            author:{
                name:m.author.username,
                icon_url:m.author.avatarUrl
            },
            footer:{
                text:Date.fromTime(m.id.timestamp).toString()+" | Msg: "+m.id.id
            },
            color:0xffffff //TODO make this based on starcount later :^)
        };
        if( m.content.length > 0 )
            embed.description = m.content;
        if( m.attachments.length > 0 ) //this should work probably maybe /shrug
            embed.image.url = m.attachments[0].url; 
        var chanTag = m.getChannel().getTag();

        var count=cache.get(m.id.id);
        var message = {
            content:"⭐ "+count+" in "+chanTag,
            embed:embed
        }
        boardMessageContent.set(m.id.id,count);

        if(boardMessages.exists(m.id.id)){
            client.getMessage(boardMessages.get(m.id.id),boardId,function(m2){
                if(count>0)
                    m2.edit(message);
                else
                    m2.delete(function(_,e){boardMessages.remove(m.id.id);});
            });
        }else if(count>0){
            client.sendMessage(boardId,message,function(m2,e){
                if(e!=null)return;
                boardMessages.set(m.id.id,m2.id.id);
            });
        }
    }
}