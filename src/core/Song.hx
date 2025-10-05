package core;

import stuff.util.SongUtil;
import stuff.Paths;
import haxe.Json;
import lime.utils.Assets;
using StringTools;

// Represents a single note in the chart
typedef SwagNote = {
	var dir: Int;            // Arrow/key direction index
	var time: Float;         // Time in milliseconds when the note should be hit
	var sustainTime: Float;  // Duration for which the note should be held
}

// Represents a BPM change event inside a difficulty
typedef BPMChange = {
	var noteIndex:Int;       // Index of the note where BPM changes
	var newBpm:Float;        // New BPM starting from this note
}

// Represents one difficulty of a song (e.g., normal, hard)
typedef SwagDifficulty = {
	var diffName: String;        // Name of the difficulty
	var notes: Array<SwagNote>;  // Notes in this difficulty
	var bpmChanges: Array<BPMChange>; // BPM changes in this difficulty
}

// Represents a full song with metadata and difficulties
typedef SwagSong = {
	var id: Map<String, Dynamic>;           // Song metadata (bpm, stage, version, etc.)
	var diff: Map<String, SwagDifficulty>;  // All available difficulties
}

/**
 * // this shit is same this
 * public static var actualNotes:Array<SwagNote> = new Array<SwagNote>(); --->
 * 
 * like this
 *  ---- >
 	var normalDiff:SwagDifficulty = Song.data.diff.get("normal");
	if (normalDiff != null){
		var notes:Array<SwagNote> = normalDiff.notes;
		trace(notes.length);
	}
 */

/**
 * Song Datas
 */
class Song{
	// Base template data for a song
	public static var data: SwagSong = {
		id: (function(){
			var m:Map<String, Dynamic> = new Map();
			m.set('stage', '');       // Stage background name
			m.set('song', '');        // Song name
			m.set('bpm', '');         // Base BPM of the song
			m.set('speed', 1.0);      // Scroll speed
			m.set('version', '');     // Chart version
			m.set('canVoices', true); // Whether voices are allowed
			m.set('validScore', true);// Score validity
			return m;
		})(),
		diff: new Map<String, SwagDifficulty>(), // Empty difficulty map
	};

	// Default playable characters
	public static var players: Map<String, String> = [
		'player1' => 'bf',       // Boyfriend
		'player2' => 'unknown',  // Opponent
		'player3' => ''          // Girlfriend (optional)
	];

	/**
	 * Loads a song from JSON files.
	 * @param folder The folder where the song JSON files are located.
	 * @param diff The difficulty to load (default "normal").
	 * @return A SwagSong object with metadata and difficulty data.
	 */
	public static function loadJson(folder:String, ?diff:String = "normal"):SwagSong{
		// Load meta.json
		var metaRaw = Assets.getText(Paths.json(SongUtil.normalizeFolderName(folder) + "/meta.json")).trim();
		while (!metaRaw.endsWith("}"))
			metaRaw = metaRaw.substr(0, metaRaw.length - 1);
		var metaData:Dynamic = Json.parse(metaRaw);

		if (metaData.song == null)
			throw "Invalid meta.json: missing 'song' key";
		var metaSong:Dynamic = metaData.song;

		// Load notes.json
		var notesRaw = Assets.getText(Paths.json(SongUtil.normalizeFolderName(folder) + "/notes.json")).trim();
		while (!notesRaw.endsWith("}"))
			notesRaw = notesRaw.substr(0, notesRaw.length - 1);
		var notesData:Dynamic = Json.parse(notesRaw);
		if (notesData.difficulty == null)
			throw "Invalid notes.json: missing 'difficulty' key";

		if (!Reflect.hasField(notesData.difficulty, diff))
			throw "Invalid notes.json: requested difficulty '" + diff + "' does not exist!";

		// Create difficulty map
		var diffs:Map<String, SwagDifficulty> = new Map();
		var diffData:Dynamic = Reflect.field(notesData.difficulty, diff);

		// Parse BPM changes if present
		var bpmChanges:Array<BPMChange> = [];
		if (diffData.bpmChanges != null){
			for (change in cast(diffData.bpmChanges, Array<Dynamic>)){
				bpmChanges.push({
					noteIndex: change.noteIndex,
					newBpm: change.newBpm
				});
			}
		}

		// Set difficulty
		diffs.set(diff, {
			diffName: diff,
			notes: cast diffData.notes,
			bpmChanges: bpmChanges
		});

		// Create SwagSong object
		var swag:SwagSong = {
			id: (function(){
				var m:Map<String, Dynamic> = new Map();
				m.set("song", metaSong.song);
				m.set("stage", metaSong.stage);
				m.set("bpm", metaSong.bpm);
				m.set("speed", metaSong.speed);
				m.set("version", metaSong.version);
				m.set("canVoices", metaSong.canVoices);
				m.set("validScore", true);
				return m;
			})(),
			diff: diffs
		};
		trace("Successfully loaded song: " + swag.id.get("song") + " (" + diff + ")");
		return swag;
	}

	/**
	 * Parses raw JSON into a SwagSong object.
	 * @param rawJson The raw JSON string containing song data.
	 * @return A SwagSong object with metadata and all difficulties.
	 */
	public static function parseJSON(rawJson:String):SwagSong{
		var raw:Dynamic = Json.parse(rawJson);
		if (raw.song == null)
			throw "Invalid JSON: missing 'song' key";
		var songData:Dynamic = raw.song;

		var diffs:Map<String, SwagDifficulty> = new Map();
		var hasDiff:Bool = false;

		// Parse difficulties (skip "easy")
		if (raw.difficulty != null){
			for (difficultyName in Reflect.fields(raw.difficulty)){
				if (difficultyName.toLowerCase() == "easy") continue;

				var diffData:Dynamic = Reflect.field(raw.difficulty, difficultyName);
				if (diffData != null && diffData.notes != null){
					hasDiff = true;

					// Parse BPM changes
					var bpmChanges:Array<BPMChange> = [];
					if (diffData.bpmChanges != null){
						for (change in cast(diffData.bpmChanges, Array<Dynamic>)){
							bpmChanges.push({
								noteIndex: change.noteIndex,
								newBpm: change.newBpm
							});
						}
					}

					// Set difficulty
					diffs.set(difficultyName, {
						diffName: difficultyName,
						notes: cast diffData.notes,
						bpmChanges: bpmChanges
					});
				}
			}
		}
		if (!hasDiff)
			throw "Invalid JSON: at least one difficulty must exist";

		// Build metadata
		var idMap:Map<String, Dynamic> = new Map();
		idMap.set("song", songData.song);
		idMap.set("stage", songData.stage);
		idMap.set("bpm", songData.bpm);
		idMap.set("speed", songData.speed);
		idMap.set("version", songData.version);
		idMap.set("canVoices", songData.canVoices);
		idMap.set("validScore", true);
		return {
			id: idMap,
			diff: diffs
		};
	}
}