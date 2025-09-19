package core;

import core.Song.SwagSong;
import core.Song.SwagDifficulty;
import flixel.FlxG;

// Represents a BPM change event during playback
typedef BPMChangeEvent = {
	var stepTime:Int;   // Step index when the BPM change occurs
	var songTime:Float; // Time in ms when the BPM change occurs
	var bpm:Float;      // BPM value at this step
}

class Conductor{
	// --------------------------
	// Timing settings
	// --------------------------
	public static var safeFrames:Int = 10; 
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // Safe zone in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;            // Scale for timing adjustments

	public static var bpmChangeMap:Array<BPMChangeEvent> = []; // Holds all BPM changes for the song

	// --------------------------
	// Current song state
	// --------------------------
	public static var bpm:Float = 100;                            // Current BPM
	public static var crochet:Float = ((60 / bpm) * 1000);        // Duration of a beat in ms
	public static var stepCrochet:Float = crochet / 4;            // Duration of a step in ms
	public static var songPosition:Float;                         // Current song position in ms
	public static var lastSongPos:Float;                          // Last song position (for tracking delta)
	public static var offset:Float = 0;                           // Global offset applied to the song

	// --------------------------
	// Recalculate timing values based on safe frames
	// --------------------------
	public static function recalculateTimings(){
		Conductor.safeFrames = FlxG.save.data.frames;                          // Read safe frames from save data
		Conductor.safeZoneOffset = Math.floor((Conductor.safeFrames / 60) * 1000); 
		Conductor.timeScale = Conductor.safeZoneOffset / 166;                  // Recalculate time scale
	}

	/**
	 * Maps BPM changes from a song difficulty.
	 * Populates bpmChangeMap with stepTime, songTime, and bpm at each BPM change.
	 * @param song The SwagSong object containing metadata and difficulties.
	 * @param difficulty The difficulty key to use (default "normal").
	 */
	public static function mapBPMChanges(song:SwagSong, ?difficulty:String = "normal"){
		bpmChangeMap = [];

		// Base BPM from metadata
		var curBPM:Float = cast song.id.get("bpm");
		if (curBPM == null) curBPM = 100;

		// Get notes for the chosen difficulty
		var diffData:SwagDifficulty = song.diff.get(difficulty);
		if (diffData == null){
			trace("Conductor: Difficulty '" + difficulty + "' not found.");
			return;
		}

		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		// Create a map for quick BPM lookups by note index
		var bpmChangesMap:Map<Int, Float> = new Map();
		if (diffData.bpmChanges != null){
			for(change in diffData.bpmChanges)
				bpmChangesMap.set(change.noteIndex, change.newBpm);
		}

		// Iterate through all notes and apply BPM changes
		for (i in 0...diffData.notes.length){
			// Apply BPM change if exists for this note
			if (bpmChangesMap.exists(i)){
				curBPM = bpmChangesMap.get(i);
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			// Increment steps and song position
			var deltaSteps:Int = 1; // Could be adjusted by sustainTime if needed
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps; 
		}
		trace('Conductor BPM map: $bpmChangeMap');
	}

	// --------------------------
	// Change global BPM
	// --------------------------
	/**
	 * Changes the global BPM and recalculates beat durations.
	 * @param newBpm New BPM value.
	 * @param recalcLength Whether to recalculate lengths (default true, optional use).
	 */
	public static function changeBPM(newBpm:Float, ?recalcLength:Bool = true){
		bpm = newBpm;
		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}