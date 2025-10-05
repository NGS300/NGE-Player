package stuff.util.save;

import stuff.util.save.raw.RawKeys;

class SaveKeys extends RawKeys{
    static final raw = RawKeys;
    public static var pressed = RawKeys.pressed;
    public static var justPressed = RawKeys.justPressed;
    public static var justReleased = RawKeys.justReleased;

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
        Reflect.setField(target, fieldName, value);
    }

    /**
     * Save or load data based on the save parameter.
     * @param save A boolean flag indicating whether to save or load data.
     * @return Void if saving, otherwise the loaded data.
     */
    public static function dataFile(canSave:Bool){
        if (canSave)
            return raw.saveData(); // Save data if the canSave flag is true.
        return raw.loadData(); // Load data if the canSave flag is false.
    }
    
    public static function data(mode:String, name:String, value:Dynamic){
        var id = raw.defaultData;
        if (mode == 'keyboard' || mode == 'board')
            id('keyboard.$name', value);
        else if (mode == 'gamepad' || mode == 'pad')
            id('gamepad.$name', value);
    }

    public static function init():Void{
        // Loaded File
		dataFile(false);

        //* KeyBoard

        // Notes
        data('board', 'upNOTE', 74);
        data('board', 'downNOTE', 70);
        data('board', 'middleNOTE', 32);
        data('board', 'leftNOTE', 68);
        data('board', 'rightNOTE', 75);

        // UI
        data('board', 'exit', 27); //backspace(8)
        data('board', 'enter', 13); // space(32)
        data('board', 'up', 38);
        data('board', 'down', 40);
        data('board', 'left', 37);
        data('board', 'right', 39);

        // Alt's
        data('board', 'capslock', 20);
        data('board', 'shift', 16);

        // F*n
        data('board', 'f10', 121);
        

        // ReSaved File
		dataFile(true);
	}
}