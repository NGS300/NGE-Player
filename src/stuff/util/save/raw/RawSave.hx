package stuff.util.save.raw;

import stuff.util.debug.Log;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.crypto.Base64;
import haxe.zip.Compress;
import haxe.zip.Uncompress;
import haxe.io.Bytes;

// Define the structure for storing different types of data
typedef DataVar = {
    var string:Map<String, String>; // Map to store string values
    var bool:Map<String, Bool>;  // Map to store boolean values
    var int:Map<String, Int>;     // Map to store integer values
    var float:Map<String, Float>;  // Map to store float values
}

/**
 * [GameSave data-Raw]
 */
class RawSave{
    static final jsonFormat:Bool = true; // Flag to determine if data should be saved in JSON format

    // Initialize the data variable with maps for boolean, integer, and float values
    public static var data:DataVar = {
        string: new Map<String, String>(),
        bool: new Map<String, Bool>(),
        int: new Map<String, Int>(),
        float: new Map<String, Float>()
    };


    /**
     * Reflect a nested field in the data structure
     * @param field The string representing the field path
     * @return The dynamic value of the field
     */
    public static function reflect(field:String){
        var fields = field.split("."); // Split the field path into parts
        var result:Dynamic = data;      // Start with the main data structure
        for (f in fields)
            result = Reflect.field(result, f); // Navigate through the fields
        return result; // Return the final value found
    }


    /**
     * Retrieve data from a specific field
     * @param nameData The name of the data field
     * @return The data value
     */
    public inline static function pushData(nameData:String):Dynamic
        return reflect(nameData); // Use reflect to get the value


    /**
     * Set default data if it doesn't exist, with optional conditions
     * @param nameData The name of the data field
     * @param value The default value to set
     * @param ifCondition Optional conditions for setting the value
     */
    public inline static function defaultData(nameData: String, value: Dynamic, ?ifCondition: Null<Array<Dynamic>> = null):Void{
        var fields = nameData.split("."); // Split the field path
        var fieldName = fields.pop();       // Get the last field name
        var target = data;                  // Start with the main data structure

        // Navigate through fields and create maps if necessary
        for (f in fields){
            if (!Reflect.hasField(target, f)){
                Reflect.setField(target, f, new Map<String, Dynamic>());
                Log.info("Created field: " + f); // Log creation of new field
            }
            target = Reflect.field(target, f); // Move deeper into the structure
        }

        // Check if the field already exists
        if (!Reflect.hasField(target, fieldName)){
            Reflect.setField(target, fieldName, value); // Set the default value
            Log.info("Field created: " + fieldName + " with value: " + value);
        }else{ // If the field exists, check if ifCondition is not null
            if (ifCondition != null){
                var operation:String = ifCondition[0];
                var valueType:String = ifCondition[1];
                var customValue:Dynamic = ifCondition[2];
                var currentValue:Dynamic = Reflect.field(target, fieldName);
                var compareValue:Dynamic = (valueType == "init" ? Std.int(customValue) : customValue);
                checkValue(operation, currentValue, compareValue, target, fieldName, value, Reflect.setField);
            }else
                Log.info("Field already exists: " + fieldName);
        }
    }


    /**
     * Check value based on condition and set if condition is met
     * @param operation The comparison operation
     * @param currentValue The current value of the field
     * @param compareValue The value to compare against
     * @param targetData The target data structure
     * @param nameData The name of the data field
     * @param value The value to set if condition is met
     * @param result The function to set the value
     */
    static function checkValue(operation:String, currentValue:Dynamic, compareValue:Dynamic,
                        targetData:Dynamic, nameData:String, value:Dynamic, result:Dynamic){
        var i = result;
        switch (operation){
            case "==":
                if (currentValue == compareValue){
                    i(targetData, nameData, value);
                    Log.info("Condition met: " + nameData + " == " + compareValue + ". Set value to " + value);
                }
            case "!=":
                if (currentValue != compareValue){
                    i(targetData, nameData, value);
                    Log.info("Condition met: " + nameData + " != " + compareValue + ". Set value to " + value);
                }
            case "<":
                if (currentValue < compareValue){
                    i(targetData, nameData, value);
                    Log.info("Condition met: " + nameData + " < " + compareValue + ". Set value to " + value);
                }
            case ">":
                if (currentValue > compareValue){
                    i(targetData, nameData, value);
                    Log.info("Condition met: " + nameData + " > " + compareValue + ". Set value to " + value);
                }
            case "<=":
                if (currentValue <= compareValue){
                    i(targetData, nameData, value);
                    Log.info("Condition met: " + nameData + " <= " + compareValue + ". Set value to " + value);
                }
            case ">=":
                if (currentValue >= compareValue){
                    i(targetData, nameData, value);
                    Log.info("Condition met: " + nameData + " >= " + compareValue + ". Set value to " + value);
                }
            default:
                Log.info("Unknown operation: " + operation);
        }

        // Log that the field already exists and is being evaluated
        Log.info("Evaluating condition for field: " + nameData);
    }


    /**
     * Save data to a file
     */
    public inline static function saveData():Void{
        try{
            var filePath = getFilePath(); // Get the path for saving
            if (jsonFormat){ // Convert data to JSON
                var jsonData:String = haxe.Json.stringify(data, null, "\t");
                sys.io.File.saveContent(filePath, jsonData); // Save formatted JSON to file
            }else{
                var jsonData:String = Json.stringify(data);
                var base64Data:String = Base64.encode(Bytes.ofString(jsonData)); // Encode to Base64
                
                // Format Base64 output with line breaks
                var formattedBase64:String = "";
                for (i in 0...base64Data.length){
                    formattedBase64 += base64Data.charAt(i);
                    var customLimit:Int = 0;
                    var sevenSix:Bool = false;
                    var lengthBreak:Int = (customLimit != 0 ? customLimit : (sevenSix ? 76 : 64));
                    if ((i + 1) % lengthBreak == 0) // Insert line break every lengthBreak characters
                        formattedBase64 += "\n";
                }
    
                var compressedData:Bytes = Compress.run(Bytes.ofString(formattedBase64), 9); // Compress data
                File.saveBytes(filePath, compressedData); // Save compressed data to file
            }
            Log.info("Data saved to " + filePath);
        }catch (error:Dynamic)
            Log.info("Error saving data: " + error); // Log any errors that occur
    }


    /**
     * Load data from a file
     */
    public static function loadData():Void{
        try{
            var filePath = getFilePath(); // Get the path for loading
            if (!FileSystem.exists(filePath)){
                Log.info("Save file does not exist. Initializing default data.");
                loadDefaultData(); // Load default data if the file is missing
                return;
            }
    
            var maxWhile:Int = 1;
            if (jsonFormat){
                var jsonData:String = sys.io.File.getContent(filePath); // Read JSON data
                // Clean up the JSON string
                var attempts:Int = 0;
                while (!jsonData.endsWith("}") && attempts < maxWhile){
                    jsonData = jsonData.substr(0, jsonData.length - 1);
                    Log.info("Attempting to clean JSON, current length: " + jsonData.length);
                    attempts++;
                }
            
                if (attempts >= maxWhile)
                    Log.info("Warning: Exceeded maximum attempts to clean JSON. {" + maxWhile + "}");
            
                data = haxe.Json.parse(jsonData); // Parse JSON into data
            }else{
                var compressedData:Bytes = File.getBytes(filePath); // Read compressed data
                var uncompressedData:Bytes = Uncompress.run(compressedData); // Decompress data
                var base64Data:String = uncompressedData.toString();
            
                // Remove line breaks from the Base64 data
                base64Data = base64Data.split("\n").join("");
            
                var jsonData:String = Base64.decode(base64Data).toString(); // Decode Base64
                // Clean up the JSON string
                var attempts:Int = 0;
                while (!jsonData.endsWith("}") && attempts < maxWhile){
                    jsonData = jsonData.substr(0, jsonData.length - 1);
                    Log.info("Attempting to clean JSON, current length: " + jsonData.length);
                    attempts++;
                }
            
                if (attempts >= maxWhile)
                    Log.info("Warning: Exceeded maximum attempts to clean JSON. {" + maxWhile + "}");
            
                data = Json.parse(jsonData); // Parse JSON into data
            }
            Log.info("Data loaded from " + filePath);
        }catch (error:Dynamic){
            Log.info("Error loading data: " + error);
            loadDefaultData(); // Load default data on error
        }
    }


    /**
     * Load default data and save it
     */
    public static function loadDefaultData():Void{
        saveData(); // Save default data
        loadData(); // Load it back into the structure
        Log.info("Data initialized as it was null.");
    }


    /**
     * Construct the appropriate save path based on the operating system
     * @return The file path as a string
     */
    inline static function getFilePath():String{
        final local = FlxG.stage.application.meta.get('company') + "/" + (MainCore.ENGINE == null ? 'Unknown' : (MainCore.ENGINE.replace("'", "").replace(" ", "-"))) + '/${MainCore.APP}';
        final user:String = Sys.getEnv("USER") != null ? Sys.getEnv("USER") : Sys.getEnv("USERNAME");
        final file = "data.svd"; // SaveFile
        var path:String;

        // Define paths for different operating systems
        #if windows
            path = "C:\\Users\\" + user + "\\AppData\\Roaming\\" + local.replace("/", "\\") + "\\" + file;
        #elseif linux
            path = "/home/" + user + "/.local/share/" + local + "/" + file;
        #elseif mac
            path = "/Users/" + user + "/Library/Application Support/" + local + "/" + file;
        #elseif android
            path = "/storage/emulated/0/Android/data/" + local + "/" + file;
        #elseif ios
            path = Sys.getCwd() + "/" + local + "/" + file;
        #elseif html5
            path = Sys.getCwd() + "/" + local + "/" + file;
        #elseif flash
            path = Sys.getCwd() + "/" + local + "/" + file;
        #elseif tizen
            path = "/opt/usr/apps/" + local + "/" + file;
        #elseif tvos
            path = Sys.getCwd() + "/" + local + "/" + file;
        #elseif switch
            path = Sys.getCwd() + "/" + local + "/" + file;
        #else
            throw "Unsupported OS!";
        #end

        // Ensure the path exists
        Paths.fileSystem(path);
        Log.info('Diretory: ' + path.substr(0, path.lastIndexOf("\\")));
        return path; // Return the constructed path
    }
}