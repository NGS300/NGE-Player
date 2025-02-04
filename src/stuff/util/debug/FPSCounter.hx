package stuff.util.debug;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;

/**
    The FPSCounter class provides an easy-to-use monitor to display
    the current frame rate of an OpenFL project
 */
class FPSCounter extends TextField{
	/**
		The current frame rate, expressed using frames-per-second
	*/
	public var currentFPS(default, null):Int;
	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
	@:noCompletion private var smoothedFPS:Float;
	public function new(y:Float = 10, color:Int = 0x000000){
		super();
		this.x = 8;
		this.y = y;
		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";
		times = [];
	}
	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void{
		if (deltaTimeout > 1000){ // prevents the overlay from updating every frame, why would you need to anyways
			deltaTimeout = 0.0;
			return;
		}
		
		#if !debug
			final now:Float = haxe.Timer.stamp() * 1000;
			times.push(now);
			while (times[0] < now - 1000)
				times.shift();

			currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
			updateText(false);
			deltaTimeout += deltaTime;
		#else
			currentTime += deltaTime;
			times.push(currentTime);
			while (times[0] < currentTime - 1000)
				times.shift();
	
			var currentCount = times.length;
			var calculatedFPS = (currentCount + cacheCount) / 2;
	
			// Apply smoothing to the FPS value
			smoothedFPS = (smoothedFPS * 0.9) + (calculatedFPS * 0.1);
			currentFPS = Math.round(smoothedFPS);
			if (currentCount != cacheCount)
				updateText(true);
			cacheCount = currentCount;
			deltaTimeout += deltaTime;
		#end
	}
	public dynamic function updateText(isDebug:Bool):Void{ // Allows overriding in HScript
		text = 'FPS: ${currentFPS}';
		textColor = 0xFFFFFFFF; // Default color (white)
		if (!isDebug){
			// Change text color based on FPS thresholds
			if (currentFPS < FlxG.drawFramerate * 0.5)
				textColor = 0xFFFF0000; // Red for very low FPS
			else if (currentFPS < FlxG.drawFramerate * 0.75)
				textColor = 0xFFFFFF00; // Yellow for moderate FPS
			else if (currentFPS < FlxG.drawFramerate)
				textColor = 0xFFFFFFFF; // White for slightly below normal
			else
				textColor = 0xFF00FF00; // Green for normal FPS and above
		}else{
			// Get the frame rate value from the Lib object
			var libFps = (cast (Lib.current.getChildAt(0), Main)).config.rate;
			text += ' (Cap: $libFps)';

			// Update text color based on currentFPS
			if (currentFPS > libFps * 0.9)
				textColor = 0xFF00FF00; // Green for high FPS
			else if (currentFPS > libFps * 0.7)
				textColor = 0xFFFFFF00; // Yellow for moderate FPS
			else if (currentFPS > libFps * 0.5)
				textColor = 0xFFFFA500; // Orange for low FPS
			else
				textColor = 0xFFFF0000; // Red for very low FPS	
		}
	}
}