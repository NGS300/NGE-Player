package stuff.util;

class SongUtil{
    public static var difficulty:Map<String, Int> = [
		'easy' => 0, // Skiped this shit
		'normal' => 1,
		'hard' => 2
	];

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
}