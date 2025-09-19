package stuff.util;

class SongUtil{
    // Map from difficulty name -> int
    public static var difficulty:Map<String, Int> = [
        'easy' => 0,
        'normal' => 1,
        'hard' => 2
    ];

    // Map from int -> difficulty name (inverse)
    public static var difficultyInv:Map<Int, String> = [
        0 => 'easy',
        1 => 'normal',
        2 => 'hard'
    ];

    /**
     * Convert difficulty string to int
     */
    public static function diffToInt(diff:String):Int{
        return difficulty.get(diff);
    }

    /**
     * Convert difficulty int to string
     */
    public static function intToDiff(value:Int):String{
        return difficultyInv.get(value);
    }

    /**
	 * Normalizes the folder name to be compatible with different naming variations.
	 * Converts spaces/hyphens, lowercase, and handles special cases.
	 */
	public static function normalizeFolderName(folder:String):String{
		if (folder == null) return "";
		folder = folder.trim(); // Remove leading and trailing spaces
		folder = StringTools.replace(folder, " ", "-"); // Replace spaces with hyphens
		folder = folder.split("--").join("-"); // Remove double hyphens if any
		folder = folder.toLowerCase(); // Convert to lowercase
		switch(folder){ // Handle special cases
			case "dad-battle", "dadbattle": folder = "dadbattle";
			case "philly-nice", "phillynice": folder = "philly";
			default: {} // do nothing
		}
		return folder;
	}

    public static function fancyOpenURL(schmancy:String){
		#if linux
		    Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		    FlxG.openURL(schmancy);
		#end
	}
}