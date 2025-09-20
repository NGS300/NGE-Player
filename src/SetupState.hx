package;

import stuff.setup.ui.Slider;
import stuff.util.DateUtil;
import haxe.io.Path;
import flixel.FlxG;
import flixel.text.FlxText;
import stuff.Paths;
import flixel.FlxState;
import flixel.FlxSprite;

/**
 * TV State of Setup Game
 */
class SetupState extends FlxState
{
    static var dateText:FlxText;


    override function create() 
    {

        //bg = new FlxSprite().loadGraphic("assets/shared/images/bg_config.png");
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("bg_config", "shared"));
        var bg_sidebar:FlxSprite = new FlxSprite().loadGraphic(Paths.image("sidebar_config", "shared"));
        var bg_header:FlxSprite = new FlxSprite().loadGraphic(Paths.image("header_config", "shared"));
        
        var titleText:FlxText = new FlxText(0, 18);
        titleText.text = "Game configuration";
        titleText.font = Paths.font("segoe_ui");
        titleText.size = 28;
        titleText.alignment = FlxTextAlign.CENTER;
        titleText.x = (FlxG.width - titleText.width) / 2;

        dateText = new FlxText(0, 18);
        dateText.text = DateUtil.getFormattedDate();
        dateText.font = Paths.font("segoe_ui");
        dateText.size = 24;
        dateText.alignment = FlxTextAlign.CENTER;
        dateText.x = (FlxG.width - titleText.width) / 2;

        var sliderTest: Slider = new Slider(512, 300);
        sliderTest.displayText = "Disdhjad";

        add(bg);
        add(bg_sidebar);
        add(bg_header);
        add(titleText);
        add(dateText);

        add(sliderTest);
    }

    override function update(elapsed:Float) 
    {
        dateText.text = DateUtil.getFormattedDate();
    }
}