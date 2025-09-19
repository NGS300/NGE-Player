package core;

import stuff.util.SongUtil;
import stuff.Paths;
import haxe.Json;
import lime.utils.Assets;
using StringTools;

/*class Event{
	public var name:String;
	public var position:Float;
	public var value:Float;
	public var type:String;
	public function new(name:String,pos:Float,value:Float,type:String){
		this.name = name;
		this.position = pos;
		this.value = value;
		this.type = type;
	}
}*/

typedef SwagEvent = {
	var time: Float;
	var name: String;
	var args: Map<String, Dynamic>;
}

// cameraZoom(zoom.get())

typedef SwagNote = {
	var dir: Int;
	var time: Float;
	var sustainTime: Float;
}

typedef SwagDifficulty = {
	var diffName: String;
	var notes: Array<SwagNote>;
}

typedef SwagSong = {
	var stage: String;
	var song: String;
	var bpm: Float;
	var speed: Float;
	var version: Int;
	var canVoices: Bool;
	var validScore: Bool;
	var diff: Map<String, SwagDifficulty>;
}

class Song{
	//public static var songData:Map<String, Dynamic> = [
	//	'stage' => '',
	//	'song' => '',
	//	'bpm' => 100,
	//	'speed' => 1.0,
	//	'version' => 0,
	//	'canVoices' => true,
	//	'validScore' => true,
	//	'notes' => new Array<SwagNote>(),
	//];

	/*
{
	diff: {
		normal: [
			{note, ntoew noijjkda}
		]
	}	
}
	*/

	public static var songData: SwagSong = {
		stage: '',
		song: '',
		bpm: 100,
		speed: 1.0,
		version: 0,
		canVoices: true,
		validScore: true,
		diff: new Map<String, SwagDifficulty>(),
	};

	public static var actualNotes:Array<SwagNote> = new Array<SwagNote>();

	public static var players:Map<String, String> = [
		'player1' => 'bf',
		'player2' => 'unknown',
		'player3' => '' // (gfVersion)
	];
    //public var eventSections:Array<SectionEvents>;
	//public var eventObjects:Array<Event>;

	//public function new(song: SwagSong, bpm: Float){
	//	this.id.set('song', song);
	//	this.id.set('bpm', bpm);
	//}

	public static function loadCurrentDiffculty(diffName: String) {
		
	}

	public static function parseJSON(rawJson:String):SwagSong{
		var raw:Dynamic = Json.parse(rawJson);
		if (raw.song == null)
			throw "Invalid JSON: missing 'song' key";

		var swagShit:SwagSong = cast raw.song;
		var hasDiff:Bool = false;
		for (difficultyName in Reflect.fields(swagShit.diff[])){ // Check for at least one valid difficulty (skip "easy")
			if (difficultyName.toLowerCase() == "easy") continue; // ignore easy, bc fuck easy playrs XDD

			var diffData:SwagDifficulty = swagShit.notes[difficultyName];
			if (diffData != null && diffData.notes != null)
				hasDiff = true; // at least one difficulty exists
		}

		if (!hasDiff)
			throw "Invalid JSON: at least one difficulty must exist";

		swagShit.validScore = true;
		//swagShit.id.set("validScore", true);
		return swagShit;
	}

	private static function loadFromJsonRAW(rawJson:String){
		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);
		return parseJSON(rawJson);
	}

	public static function loadFromJson(folder:String, ?diff:String = "normal"):SwagSong{
		// Load meta.json
		var metaRaw = Assets.getText(Paths.json(SongUtil.normalizeFolderName(folder) + "/meta.json")).trim();
		while (!metaRaw.endsWith("}"))
			metaRaw = metaRaw.substr(0, metaRaw.length - 1);
		var metaData:Dynamic = Json.parse(metaRaw);

		// Load notes.json
		var notesRaw = Assets.getText(Paths.json(SongUtil.normalizeFolderName(folder) + "/notes.json")).trim();
		while (!notesRaw.endsWith("}"))
			notesRaw = notesRaw.substr(0, notesRaw.length - 1);

		var notesData:Dynamic = Json.parse(notesRaw);
		if (notesData.notes == null)
			throw "Invalid notes.json: missing 'notes' key";

		// Ensure requested difficulty exists
		if (!Reflect.hasField(notesData.notes, diff))
			throw "Invalid notes.json: requested difficulty '" + diff + "' does not exist!";

		//var swag: SwagNote = {
		//	id: cast metaData.id,
		//}

		//swag.notes.set(diff, cast notesData.notes[SongUtil.difficulty.get(diff)].notes); // Populate only the chosen difficulty

		//trace("Successfully loaded song: " + swag.id.get("song") + " (" + diff + ")");

		//songData.set("notes");

		//return swag;
	}

}