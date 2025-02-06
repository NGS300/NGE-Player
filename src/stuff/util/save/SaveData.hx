package stuff.util.save;

import stuff.util.save.raw.RawSave;

class SaveData extends RawSave{
    static final raw = RawSave;
    /**
     * Retrieve data from the raw data structure using a field name.
     * @param name The name of the data field.
     * @return The data value associated with the field name.
     */
    public static function get(name:String):Dynamic
        return raw.pushData(name); // Use the pushData method to retrieve the value.


    /**
     * Save data to the raw data structure using a field name and value.
     * @param name The name of the data field.
     * @param value The value to be saved.
     */
    public static function save(name:String, value:Dynamic){
        var fields = name.split("."); // Split the field name into parts.
        var fieldName = fields.pop(); // Get the last part of the field name.
        var target = raw.data; // Start with the main data structure.

        // Navigate through fields and create maps if necessary.
        for (f in fields){
            if (!Reflect.hasField(target, f))
                Reflect.setField(target, f, new Map<String, Dynamic>()); // Create a new map if the field doesn't exist.
            target = Reflect.field(target, f); // Move deeper into the structure.
        }

        // Set the final field with the provided value.
        Reflect.setField(target, fieldName, value);
    }

    /**
     * Save or load data based on the save parameter.
     * @param save A boolean flag indicating whether to save or load data.
     * @return Void if saving, otherwise the loaded data.
     */
    public static function dataFile(save = true){
        if (save)
            return raw.saveData(); // Save data if the save flag is true.
        return raw.loadData(); // Load data if the save flag is false.
    }

    public static function init():Void{
		var data = raw.defaultData;
		dataFile(false);

        // String data
        data("string.language", 'english');
	
		// Bool data
        data("bool.antialiasing", true);
        data("bool.autoPause", true);
        data("bool.showMemory", true);
        data("bool.showFPS", true);
        data("bool.volumeMute", false);

        // Int data
		data("int.fpsCap", (cast(openfl.Lib.current.getChildAt(0), Main)).config.rate, ['>', 'int', 360]);

        // Float data
        data("float.volume", 1.0);

        // ReSaved File
		dataFile();
	}
}