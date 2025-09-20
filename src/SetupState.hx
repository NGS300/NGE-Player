package;

import core.BeatState;
import flixel.text.FlxText;
import stuff.Paths;
import flixel.FlxSprite;

/**
 * Modern "BIOS" for the advanced config shit
 */
class SetupState extends BeatState{
    var clock:FlxText;
    override function create(){
        super.create();
        var set = function(key:String):String{
            return Paths.image(key + '_config', 'shared');
        };
        var bg = new FlxSprite().loadGraphic(set('bg'));
        bg.screenCenter();
        add(bg);

        var sidebar = new FlxSprite().loadGraphic(set('sidebar'));
        sidebar.screenCenter(Y);
        add(sidebar);

        var header = new FlxSprite().loadGraphic(set('header'));
        header.screenCenter(X);
        add(header);

        clock = new FlxText(1000, 40, '');
        clock.font = Paths.font('segoe_ui');
        clock.size = 24;
        add(clock);

        var bios = new FlxText(0, 16,'Game Configuration');
        bios.x = ((flixel.FlxG.width - bios.width) / 2) - 70;
        bios.font = Paths.font('segoe_ui');
        bios.size = 20;
        add(bios);
    }

    override function update(elapsed: Float){
        clock.text = systemClock;
        super.update(elapsed);
    }
}