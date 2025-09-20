package stuff.setup.ui;

import flixel.text.FlxText;
import flixel.addons.ui.FlxUISpriteButton;
import flixel.FlxSprite;

class Slider extends FlxUISpriteButton
{
    //private var sliderSprite: FlxSprite
    public var sliderActive: Bool = false;
    public var displayText: String = "";

    public function new(x: Float = 0, y: Float = 0, ?initialState: Null<Bool> = false): Void
    {
        super(x, y);
        label = loadGraphic(Paths.image("slider", "shared"));

        this.onDown.callback = onCliked;
        
        if (displayText.length <= 0)
            return;

        var text: FlxText = new FlxText(x + width, 0, 24);
        text.y = (y - text.height) / 2;
        text.text = displayText;
        text.scrollFactor.set(0, 0);
        text.font = Paths.font("segoe_ui");
    }
   
    private function onCliked() 
    {
        
    }
}