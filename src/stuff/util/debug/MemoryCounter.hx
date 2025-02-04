package stuff.util.debug;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
    The MemoryCounter class provides an easy-to-use monitor to display
    the current memory megabytes of an OpenFL project
 */
class MemoryCounter extends TextField{
    /**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	 */
    public var memoryMegas(get, never):Float;
    static final BYTES_PER_MEG:Float = 1024 * 1024;
    static final ROUND_TO:Float = 0.1; // Round to 1 or 2 decimal places
    var memPeak:Float = 0;
    public function new(y:Float = 10, color:Int = 0x000000){
        super();
        this.x = 8; // 10
        this.y = y;
        selectable = false;
        mouseEnabled = false;
        defaultTextFormat = new TextFormat("_sans", 12, color);
        autoSize = LEFT;
        multiline = true;
        text = "RAM: ";
    }
    

    override function __enterFrame(deltaTime:Float):Void{
        var mem:Float = 0;
        #if debug // Convert total memory from bytes to megabytes and round to 1 decimal places
            mem = Math.round(memoryMegas / BYTES_PER_MEG / ROUND_TO) * ROUND_TO;
        #else // Convert total memory from bytes to megabytes
            mem = Math.round(memoryMegas / BYTES_PER_MEG);
        #end
        if (mem > memPeak) memPeak = mem; // Update the peak memory usage
    
        // Change text color based on memory usage
        if (mem > 3500)
            textColor = 0xFFFF0000; // Red for high memory usage
        else if (mem > 2500)
            textColor = 0xFFFFA500; // Orange for moderate to high memory usage
        else if (mem > 1500)
            textColor = 0xFFFFFF00; // Yellow for moderate memory usage
        else if (mem > 500)
            textColor = 0xFFFFFFFF; // White for low memory usage
        else
            textColor = 0xFF00FF00; // Green for below normal memory usage

        // Update the display text with current and peak memory usage
        text = 'RAM: ' + mem + 'MB';
        #if debug
            text += ' / ' + memPeak + 'MB';
        #end
    }
    inline function get_memoryMegas():Float
		return cast(stuff.util.MemoryUtil.getMemoryUsed(), UInt);
}