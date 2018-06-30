package com.raidandfade.haxibot.rssfeeds;

import Xml;
import haxe.Timer;

class RSSFeed{
    var url:String;

    var feedCache:Array<String>;
    var timer:Timer;

    var firstRun:Bool = true;

    public var items:Array<Item>;

    public function new(_url:String,_interval:Int=15000){
        url = _url;
        feedCache = new Array<String>();
        items = new Array<Item>();
        timer = new Timer(_interval); //every minute
        timer.run = tick;
        tick();
    }
    
    function tick(){
        haxe.Https.makeRequest(url,"GET",parseItems,null,null,true,false);
    }
    
    function parseItems(res,extra){
        items = new Array<Item>();
        
        var feed = Xml.parse(res.data).firstElement();

        var curCache = new Array<String>();

        if(feed.get("version") == "2.0"){
            var channel = feed.firstElement();
            for(x in channel.elementsNamed("item")){
                curCache.push(x.toString());
                if(feedCache.indexOf(x.toString())==-1){
                    parseNewItem(x);
                }else{
                    parseItem(x);
                }
            }
        }else{
            //todo 1.0 (eventually lol)
        }

        for(cf in feedCache){
            if(curCache.indexOf(cf)==-1){
                feedCache.remove(cf);
            }
        }
        for(f in curCache){
            if(feedCache.indexOf(f)==-1){
                feedCache.push(f);
            }
        }

        firstRun = false;
    }

    function parseItem(el:Xml){
        var item:Item = {};

        var t:Iterator<Xml>;

        t = el.elementsNamed("title");
        if(t.hasNext())     item.title = t.next().firstChild().nodeValue;

        t = el.elementsNamed("link");
        if(t.hasNext())     item.link = t.next().firstChild().nodeValue;
        
        t = el.elementsNamed("description");
        if(t.hasNext())     item.description = t.next().firstChild().nodeValue;
        
        t = el.elementsNamed("author");
        if(t.hasNext())     item.author = t.next().firstChild().nodeValue;
        
        t = el.elementsNamed("category");
        if(t.hasNext())     item.category = t.next().firstChild().nodeValue;
        
        t = el.elementsNamed("comments");
        if(t.hasNext())     item.comments = t.next().firstChild().nodeValue;
        
        t = el.elementsNamed("enclosure");
        if(t.hasNext())     item.enclosure = t.next().firstChild().nodeValue;
        
        t = el.elementsNamed("guid");
        if(t.hasNext())     item.guid = t.next().firstChild().nodeValue;
        
        t = el.elementsNamed("pubDate");
        if(t.hasNext())     item.pubDate = t.next().firstChild().nodeValue;
        
        t = el.elementsNamed("source");
        if(t.hasNext())     item.source = t.next().firstChild().nodeValue;

        items.push(item);
        return item;
    }

    function parseNewItem(el:Xml){
        var item = parseItem(el);

        if(!firstRun) onNewItem(item);
    }

    public dynamic function onNewItem(item:Item){}

}

typedef Item = {
    @:optional var title:String;
    @:optional var link:String;
    @:optional var description:String;
    @:optional var author:String;
    @:optional var category:String;
    @:optional var comments:String;
    @:optional var enclosure:String;
    @:optional var guid:String;
    @:optional var pubDate:String;
    @:optional var source:String;
}