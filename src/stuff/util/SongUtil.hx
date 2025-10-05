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
    public static function diffToInt(diff:String):Int
        return difficulty.get(diff);

    /**
     * Convert difficulty int to string
     */
    public static function intToDiff(value:Int):String
        return difficultyInv.get(value);

    /**
     * Convert Float to String
     */
    public static function floatToString(f:Float):String{
        var s = Std.string(f);
        if (Math.floor(f) == f && s.indexOf(".") == -1) s += ".0";
        return s;
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

    /**
     * Wraps a string to a new line based on a max character length per line.
     * 1. Forces a line break when a semicolon followed by a space ("; ") is found.
     * 2. Implements mandatory word break/hyphenation ('c-') if needed to fit maxLineLength.
     */
    public static function wrapCharText(text:String, maxLineLength:Int):String{
        if (text == null || text.length == 0) return "";
        
        var chunks = text.split("; ");
        var finalLines:Array<String> = [];
        for (chunk in chunks){
            if (chunk.length == 0) continue;

            var words = chunk.split(" ");
            var currentLine = "";
            for (word in words){
                var currentLength = currentLine.length + (currentLine.length > 0 ? 1 : 0); 
                if (currentLength + word.length > maxLineLength){
                    var remainingWord = word;
                    
                    var availableSpace = maxLineLength - currentLength;
                    if (currentLine.length > 0 && availableSpace >= 2){ 
                        var charsToBreak = availableSpace - 1;
                        if (charsToBreak >= 1){ 
                            var part1 = word.substr(0, charsToBreak) + "-";
                            remainingWord = word.substr(charsToBreak);
                            
                            currentLine += " " + part1;
                            finalLines.push(currentLine);
                            currentLine = "";
                        }
                    }
                    
                    if (currentLine.length > 0){
                        finalLines.push(currentLine);
                        currentLine = "";
                    }
                    while (remainingWord.length > maxLineLength){
                         var segment = remainingWord.substr(0, maxLineLength);
                         finalLines.push(segment);
                         remainingWord = remainingWord.substr(maxLineLength);
                    }
                    currentLine = remainingWord;
                    continue;
                }
                if (currentLine.length > 0) currentLine += " ";
                currentLine += word;
            }
            if (currentLine.length > 0) finalLines.push(currentLine);
        }
        return finalLines.join("\n");
    }

    public static function fancyOpenURL(schmancy:String){
		#if linux
		    Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		    FlxG.openURL(schmancy);
		#end
	}
}