package com.raidandfade.haxibot.commands;

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.structs.Embed;

class WoWCommand extends Command{

    var commands:Map<String,Command> = new Map<String,Command>();
    
    var getTypes:Array<String> = ["item","mount","spell","faction","skill","achieve","achievement","title"];

    public function new(){
        super();
        for(type in getTypes){
            commands.set("get "+type,new WoWGetCommand(type));
            commands.set("search "+type,new WoWSearchCommand(type));
        }
    }

    public override function call(_msg:Message,_bot:DiscordClient){
        for(coms in commands.keys()){
            if(_msg.content.substr(_msg.content.indexOf(" ")+1,coms.length) == coms){
                commands.get(coms).call(_msg,_bot);
            }
        }
    }
}

class WoWDBUtils{
    static function makeRequest(url,_cb){
        var cb = function(data,extra){
            if(data.status < 200 || data.status>=300){
                _cb(null,data.error,data);
            }else{
                _cb(data.data,null,data);
            }
        }
        trace(url);
        haxe.Https.makeRequest(url,"GET",cb,null,null);
    }

    public static function get(type:String,id:Int,cb){
        trace("Getting "+type+" "+id);
        makeRequest("https://api.gocode.it/wowdb/"+type+"/"+id,cb);
    }

    public static function search(type:String,field:String,val:String,cb){
        trace("Searching "+type+" "+field+"="+val);
        makeRequest("https://api.gocode.it/wowdb/search/"+type+"/"+field+"/"+StringTools.urlEncode(val),cb);
    }

    static function msToTime(ms){
        var s = Std.parseInt(ms)/1000; 
        var sign = s/Math.abs(s);
        s = Math.abs(s);
        if(s>3600) return sign*Std.int(s/3600)+"h";
        if(s>60000) return sign*Std.int(s/60)+"m";
        if(s<0&&s!=0) return sign*(Math.round(s*100)/100)+"s";
        return sign*Std.int(s)+"s";
    }

    static function cleanString(str:String):String{
        return (~/(\|[c][0-9a-f]{0,8})|(\|[r])|(\|T(.*):[0-9]*\|t)/ig).replace(str,"");
    }

    static function getWoWHeadLink(type:String,data:Dynamic):String{
        var l = "http://wowhead.com/";

        l += switch(type){
            case "mount":
                "spell";
            case "achieve":
                "achievement";
            case _:
                type;
        }

        l += "="+switch(type){
            case "mount":
                data.Spell;
            case _:
                data.Id;
        }

        return l;
    }

    static function embedifyGet(id:Int,type:String,data:Dynamic):Embed{
        var em:Embed = {};
        em.title = data.Name;
        em.url = getWoWHeadLink(type,data);
        em.footer = {text:"GCT WoWDB\t Query: `"+type+" id` = `"+id+"`"};
        if(type=="item"){
            em.color = Std.int((data.QualityColor[0]<<16)+(data.QualityColor[1]<<8)+(data.QualityColor[2]));
            em.image = {url:"https://api.gocode.it/wowdb/img/"+type+"/"+id};
        }else{
            em.thumbnail = {url:"https://api.gocode.it/wowdb/icon/"+type+"/"+id};
            if(type=="spell"){
                em.description = data.Desc;
                var effects="";
                var effs:Array<Dynamic> = data.Effects;
                for(eff in effs){
                    effects += eff.effectType;
                    if(eff.effectAura) 
                        if(eff.aura == null) 
                            effects += " - Unknown Aura #"+eff.auraId;
                        else 
                            effects += " - "+eff.aura;

                    effects += "\n";
                }
                em.fields = new Array<EmbedField>();
                em.fields.push({name:"Effects",value:effects});
                var extras = "";
                //extras += "Cost: "+"\n"; //Cost
                extras += "Duration: "+msToTime(data.Duration)+"\n"; //Duration
                extras += "Cast Time: "+msToTime(data.CastTime.Base)+"\n"; //Cast Time
                if(data.Range.Range_1[0] == data.Range.Range_1[1])
                    extras += "Range: "+(data.Range.Range_1[0])+" Yards\n"; //Range
                else
                    extras += "Range: "+(data.Range.Range_1[0])+" - "+(data.Range.Range_1[1])+" Yards\n"; //Range

                em.fields.push({name:"Extra",value:extras});
            }
            if(type=="mount"){
                em.fields = new Array<EmbedField>();
                em.fields.push({name:"Description:",value:cleanString(data.Desc)});
                em.fields.push({name:"Source:",value:cleanString(data.Source)});
            }
            if(type == "achievement" || type == "achieve"){
                em.description = data.Desc + "\n";
                em.description += "**"+data.Points+"** Achievement Points";
                em.fields = new Array<EmbedField>();
                var cris = "";
                var cria:Array<Dynamic> = data.Criteria;
                for(cri in cria){
                    cris += "- "+cri.Description + "\n";
                }
                var cat:Dynamic = data.Category;
                while(cat.Parent != null){
                    cat = cat.Parent;
                }
                em.fields.push({name:"Category:",value:cat.Name});
                if(cris!="")em.fields.push({name:"Criteria:",value:cris});
                if(data.Parent!=null){
                    em.fields.push({name:"Previous:",value:"["+data.Parent.Name+"]("+getWoWHeadLink("achievement",data.Parent)+") (**Id: **"+data.Parent.Id+")"});
                }
                if(data.Reward!="")em.fields.push({name:"Reward:",value:data.Reward});
            }
            if(type=="title"){
                em.description = data.Desc;
            }
            if(type=="skill"){
                em.description = data.OriginalDesc;
                em.fields = new Array<EmbedField>();
                em.fields.push({name:"Category:",value:data.Category});
                if(data.CategoryID == 9 || data.CategoryID == 11){
                    em.fields.push({name:"Recipes:",value:data.Abilities.length + " recipes found in database."});
                }
            }
            if(type=="faction"){
                em.description = data.Desc;
            }
        }
        return em;
    }

    public static function getAsEmbed(type:String,id:Int,cb){
        //use the image provider for items.
        get(type,id,function(d:Dynamic,e,a:Dynamic){
            var em:Embed = null;
            if(e!=null) em = {title:"Request Failed",description:a.data.data,footer:{text:"GCT WoWDB\t Query: `"+type+" id` = `"+id+"`"}};
            if(d!=null) em = embedifyGet(id,type,d.data); 
            if(em==null) return; //something is seriously wrong if this happens
            cb(em);
        });
    }

    static function embedifySearch(q:String,type:String,data:Dynamic):Embed{
        var em:Embed = {};
        em.footer = {text:"GCT WoWDB\t Query: `"+type+" name` like `"+q+"`"};
        em.title = "Search Results";
        em.fields = new Array<EmbedField>();
        var resString = "";

        var ress:Array<Dynamic> = data;
        for(res in ress){
            //consider linking these to wowhead.
            var name:String;
            if(type=="title") name = res.Name.Male;
            else name = res.Name;
            resString += "- ["+name+"]("+getWoWHeadLink(type,res)+") (**Id**: "+res.Id+")\n";
        }
        if(ress.length == 0)
            resString = "**No Results found**";

        em.fields.push({name:"Results:",value:resString});
        return em;
    }

    public static function searchAsEmbed(type:String,query:String,cb){
        //use the image provider for items.
        search(type,"name",query,function(d:Dynamic,e,a:Dynamic){
            var em:Embed = null;
            if(e!=null) em = {title:"Request Failed",description:a.data.data,footer:{text:"GCT WoWDB\t Query: `"+type+" name` = `"+query+"`"}};
            if(d!=null) em = embedifySearch(query,type,d.data); 
            if(em==null) return; //something is seriously wrong if this happens
            cb(em);
        });
    }
}

class WoWSearchCommand extends Command{
    var getType:String;

    public function new(_type){
        super();
        getType = _type;
    }
    
    public override function call(_msg:Message,_bot:DiscordClient){
        var q = StringTools.ltrim(_msg.content.substr(_msg.content.indexOf("search "+getType)+("search "+getType).length));
        WoWDBUtils.searchAsEmbed(getType,q,function(em){
            _msg.reply({embed:em});
        });
    }
}

class WoWGetCommand extends Command{

    var getType:String;

    public function new(_type){
        super();
        getType = _type;
    }
    
    public override function call(_msg:Message,_bot:DiscordClient){
        var id = Std.parseInt(_msg.content.substr(_msg.content.indexOf("get "+getType)+("get "+getType).length));
        WoWDBUtils.getAsEmbed(getType,id,function(em){
            _msg.reply({embed:em});
        });
    }
}