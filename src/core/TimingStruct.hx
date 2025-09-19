package core;

/**
 * Represents a timing segment in a song (for BPM changes, beats, and steps)
 */
class TimingStruct{
    public static var AllTimings:Array<TimingStruct> = [];

    public var bpm:Float = 0;         // BPM in this segment
    public var startBeat:Float = 0;   // Starting beat of this segment
    public var startStep:Int = 0;     // Starting step index
    public var endBeat:Float = Math.POSITIVE_INFINITY; // Ending beat
    public var startTime:Float = 0;   // Start time in seconds
    public var length:Float = Math.POSITIVE_INFINITY; // Duration in seconds

    /**
     * Clears all stored timing segments
     */
    public static function clearTimings(){
        AllTimings = [];
    }

    /**
     * Adds a new timing segment
     * @param startBeat Starting beat
     * @param bpm BPM for this segment
     * @param endBeat Ending beat (-1 for infinity)
     * @param offset Start time in seconds
     */
    public static function addTiming(startBeat:Float, bpm:Float, endBeat:Float, offset:Float){
        var ts = new TimingStruct(startBeat, bpm, endBeat, offset);
        AllTimings.push(ts);
    }

    /**
     * Constructor
     */
    public function new(startBeat:Float, bpm:Float, endBeat:Float, offset:Float){
        this.bpm = bpm;
        this.startBeat = startBeat;
        if (endBeat != -1)
            this.endBeat = endBeat;
        this.startTime = offset;

        // Calculate length in seconds for this segment
        this.length = (this.endBeat - this.startBeat) * (60 / bpm);
    }

    /**
     * Returns the timing segment at a given timestamp in milliseconds
     */
    public static function getTimingAtTimestamp(msTime:Float):TimingStruct{
        for (ts in AllTimings){
            if (msTime >= ts.startTime * 1000 && msTime < (ts.startTime + ts.length) * 1000)
                return ts;
        }
        trace('Warning: ' + msTime + 'ms is outside any timing segment');
        return null;
    }

    /**
     * Returns the timing segment at a given beat
     */
    public static function getTimingAtBeat(beat:Float):TimingStruct{
        for (ts in AllTimings){
            if (ts.startBeat <= beat && ts.endBeat >= beat)
                return ts;
        }
        return null;
    }
}