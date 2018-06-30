package com.raidandfade.haxibot.commands.tags;

import com.raidandfade.haxicord.DiscordClient;

import orm.Db;

class Tags{
    var client:DiscordClient;
    var db:Db;
    public function new(_cl,_db){
        client = _cl;
        db = _db;

        db.query("CREATE TABLE IF NOT EXISTS `tags` (`name` CHARACTER(50),`content` TEXT, `owner` UNSIGNED BIGINT, `usecount` INTEGER, `created` DATE, PRIMARY KEY(`name`));");
    }
}