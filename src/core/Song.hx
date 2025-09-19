package core;

import stuff.util.SongUtil;
import stuff.Paths;
import core.Section.SwagSection;
import core.Section.SectionEvents;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
using StringTools;

class Event{
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
}

typedef SwagSong = {
	var id:Map<String, Dynamic>;
	var difficulty:Map<String, Int>;
	var notes:Map<String, Dynamic>;
	var players:Map<String, String>;
    var eventSections:Array<SectionEvents>;
	var eventObjects:Array<Event>;
}

class Song{
	public var id:Map<String, Dynamic> = [
		'stage' => '',
		'song' => '',
		'bpm' => '',
		'speed' => '1',
		'version' => '',
		'canVoices' => 'true',
		'validScore' => 'true'
	];

	public var notes:Map<String, Dynamic> = [
		'id' => new Array<SwagSection>(),
		'style' => '',
		'speed' => '1'
	];

	public var players:Map<String, String> = [
		'player1' => 'bf',
		'player2' => 'unknown',
		'player3' => '' // (gfVersion)
	];
    public var eventSections:Array<SectionEvents>;
	public var eventObjects:Array<Event>;

	public function new(song, notes, bpm){
		this.id.set('song', song);
		this.notes.set('id', notes);
		this.id.set('bpm', bpm);
	}

	public static function loadFromJsonRAW(rawJson:String){
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

		// Create SwagSong
		var swag:SwagSong = {
			id: cast metaData.id,
			players: cast metaData.players,
			eventSections: [],
			eventObjects: [],
			notes: new Map(),
			difficulty: cast metaData.difficulty
		};
		swag.notes.set(diff, cast notesData.notes[SongUtil.difficulty.get(diff)].notes); // Populate only the chosen difficulty

		trace("Successfully loaded song: " + swag.id.get("song") + " (" + diff + ")");
		return swag;
	}

	public static function conversionChecks(song:SwagSong):SwagSong{
		var ba = song.id.get('bpm');
		var index = 0;
		trace("conversion stuff " + song.id.get('song') + " " + song.id.get('notes').length);
		var convertedStuff:Array<Song.Event> = [];

		if (song.eventObjects == null)
			song.eventObjects = [new Song.Event("Init BPM", 0, song.id.get('bpm'), "BPM Change")];

		for (i in song.eventObjects){
			var name = Reflect.field(i,"name");
			var type = Reflect.field(i,"type");
			var pos = Reflect.field(i,"position");
			var value = Reflect.field(i,"value");
			convertedStuff.push(new Song.Event(name, pos, value, type));
		}

		song.eventObjects = convertedStuff;
		var arr:Array<SwagSection> = cast song.notes.get('id');
		for (i in arr){
			var currentBeat = 4 * index;
			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);
            var newBPM:Bool = false;
            for (i in song.eventSections){
                if (newBPM != false)
                    newBPM = i.newBPM;
            }
			if (currentSeg == null) continue;

			var beat:Float = currentSeg.startBeat + (currentBeat - currentSeg.startBeat);
			if (/*i.newBPM*/ newBPM && i.bpm != ba){
				trace("converting changebpm for section " + index);
				ba = i.bpm;
				song.eventObjects.push(new Song.Event("BPM Change " + index, beat, i.bpm, "New BPM"));
			}

			for(ii in i.sectionNotes){
				if (ii[3] == null)
					ii[3] = false;
			}
			index++;
		}
		return song;
	}

	public static function parseJSON(rawJson:String):SwagSong{
		var raw:Dynamic = Json.parse(rawJson);
		if (raw.song == null)
			throw "Invalid JSON: missing 'song' key";

		var swagShit:SwagSong = cast raw.song;
		var hasDiff:Bool = false;
		for (difficultyName in Reflect.fields(swagShit.notes)){ // Check for at least one valid difficulty (skip "easy")
			if (difficultyName.toLowerCase() == "easy") continue; // ignore easy

			var diffData:Dynamic = swagShit.notes[difficultyName];
			if (diffData != null && diffData.notes != null)
				hasDiff = true; // at least one difficulty exists
		}

		if (!hasDiff)
			throw "Invalid JSON: at least one difficulty must exist";

		swagShit.id.set("validScore", true);
		return swagShit;
	}
}