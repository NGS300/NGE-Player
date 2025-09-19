	package core;

	typedef SwagSection = { // Notes Shits
		var startTime:Float;
		var endTime:Float;
		var sectionNotes:Array<Array<Dynamic>>;
		var lengthInSteps:Int;
		var typeOfSection:Int;
		var bpm:Float;
	}

	typedef SectionEvents = {
		var playerTurn:Bool; // ChangeCameraTurn
		var p3Turn:Bool; // ChangeCamera on Player3
		var newBPM:Bool; // Change BPM Event
		var gAltAnim:Bool; // Global ALT Animtion
		var p1AltAnim:Bool; // P1 ALT Animations
		var p2AltAnim:Bool; // P2 ALT Animations
	}

	class Section{
		public var startTime:Float = 0;
		public var endTime:Float = 0;
		public var sectionNotes:Array<Array<Dynamic>> = [];
		public var lengthInSteps:Int = 16;
		public var typeOfSection:Int = 0;
		public var bpm:Float = 0;
		public var type:Map<String, Bool> = [
			'newBPM' => false, // Can Change to New  BPM
			'playerTurn' => false, // Player Camera Turn
			'altTurn' => false // Alternate Turn
		];

		/**
		 *	Copies the first section into the second section!
		*/
		public static var COPYCAT:Int = 0;

		public function new(lengthInSteps:Int = 16){
			this.lengthInSteps = lengthInSteps;
		}
	}