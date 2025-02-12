package;

import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import stuff.util.debug.MemoryCounter;
import stuff.util.debug.FPSCounter;

/**
 * The Main class which initializes HaxeFlixel and starts the game in its initial state.
 */
class Main extends Sprite{
    private var data = stuff.util.save.SaveData;
    public static var memoryCounter:MemoryCounter;
    public static var fpsCounter:FPSCounter;
    public var config = {
        initialState: null,//stuff.state.Title,
        fullscreen: false,
        splash: false,
        width: 1280,
        height: 720,
        zoom: -1.0,
        #if web
            rate: 60
        #else
            rate: 144
        #end
    };
    public static function main():Void
        Lib.current.addChild(new Main());
    public function new(){
		super();
        stuff.util.debug.Log.init();
        stuff.util.WindowUtil.init();
		(stage != null ? init() : addEventListener(Event.ADDED_TO_STAGE, init));
	}
	private function init(?E:Event){
		if (hasEventListener(Event.ADDED_TO_STAGE))
            removeEventListener(Event.ADDED_TO_STAGE, init);
		setupGame();
	}

    /**
     * The Setup Function it Start of Game Windows.
     */
    function setupGame():Void{
        //! Calc Stage
        var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
        var i = config;
		if (i.zoom == -1.0){
			var ratioX:Float = stageWidth / i.width;
			var ratioY:Float = stageHeight / i.height;
			i.zoom = Math.min(ratioX, ratioY);
			i.width = Math.ceil(stageWidth / i.zoom);
			i.height = Math.ceil(stageHeight / i.zoom);
		}

        //! Main
        data.init();
        //Achievements.load();
        var game = new FlxGame(config.width, config.height, config.initialState, config.rate, config.rate, !config.splash, config.fullscreen);
        //@:privateAccess
        //game._customSoundTray = engine.internal.ui.SoundTray;
        addChild(game);
        //Volume.load();

        //! Stuff
        #if !mobile
            Lib.current.stage.align = "tl";
            Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
            var showfps = data.get("bool.showFPS");
            fpsCounter = new FPSCounter(14, 0xFFFFFF);
            fpsCounter.visible = showfps;
            memoryCounter = new MemoryCounter(2, 0xFFFFFF);
            memoryCounter.visible = (!showfps ? false : data.get("bool.showMemory"));
            addChild(fpsCounter);
            #if !html5
                addChild(memoryCounter);
            #else
                fpsCounter.y = 2;
            #end
            flixel.FlxG.autoPause = data.get("bool.autoPause");
        #end
        #if html5
            FlxG.autoPause = false;
            FlxG.mouse.visible = false;
        #end
    }
}