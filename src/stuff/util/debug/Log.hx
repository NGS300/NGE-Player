package stuff.util.debug;

import lime.app.Application;
import flixel.system.debug.log.LogStyle;
import haxe.PosInfos;
using StringTools;

/**
 * Utility class for logging and debugging.
 * Integrates with the HaxeFlixel debugger to enhance development efficiency.
 * Provides methods to log messages with different severity levels and to interact with the debugger.
 * 
 * @see https://haxeflixel.com/documentation/debugger/
 */
class Log{
	static final STYLE_ERROR:LogStyle = new LogStyle('[ERROR] ', 'FF8888', 12, true, false, false, 'flixel/sounds/beep', true);
	static final STYLE_WARN:LogStyle = new LogStyle('[WARN] ', 'D9F85C', 12, true, false, false, 'flixel/sounds/beep', true);
	static final STYLE_INFO:LogStyle = new LogStyle('[INFO] ', '5CF878', 12, false);
	static final STYLE_TRACE:LogStyle = new LogStyle('[TRACE] ', '5CF878', 12, false);
	static var fileWriter:DebugLogWriter = null;
	public static var canPrintLog:Bool = true;

	/**
	 * Logs an error message to the console and file.
	 * @param input The message to log.
	 */
	public static inline function error(input:Dynamic, ?pos:haxe.PosInfos):Void{
		if (input == null)
			return;
		var path = outputer(input, pos);
		writeFlxG(path, STYLE_ERROR);
		writeFile(path, 'ERROR');
	}

	/**
	 * Logs a warning message to the console and file.
	 * @param input The message to log.
	 */
	public static inline function warn(input:Dynamic, ?pos:haxe.PosInfos):Void{
		if (input == null)
			return;
		var path = outputer(input, pos);
		writeFlxG(path, STYLE_WARN);
		writeFile(path, 'WARN');
	}

	/**
	 * Logs an info message to the console and file.
	 * Only visible in debug builds.
	 * @param input The message to log.
	 */
	public static inline function info(input:Dynamic, ?pos:haxe.PosInfos):Void{
		if (input == null)
			return;
		var path = outputer(input, pos);
		writeFlxG(path, STYLE_INFO);
		writeFile(path, 'INFO');
	}

	/**
	 * Logs a debug message to the console and file.
	 * Redirects all Haxe `trace()` calls to this function.
	 * @param input The message to log.
	 */
	public static function tracer(input:Dynamic, ?pos:haxe.PosInfos):Void{
		if (input == null)
			return;
		var path = outputer(input, pos);
		writeFlxG(path, STYLE_TRACE);
		writeFile(path, 'TRACE');
	}

	/**
	 * Displays a popup with the provided text.
	 * @param title The title of the popup.
	 * @param description The description of the popup.
	 */
	public static function showAlert(title:String, description:String):Void
		Application.current.window.alert(description, title);

	/**
	 * Watches a variable in the Debug watch window.
	 * Updates continuously.
	 * @param object The object to watch.
	 * @param field The field name of the object.
	 * @param name The display name in the watch window.
	 */
	public static inline function watchVar(object:Dynamic, field:String, name:String):Void{
		#if debug
			if (object == null){
				Log.error("Tried to watch a variable on a null object!");
				return;
			}
			FlxG.watch.add(object, field, name == null ? field : name);
		#end
	}

	/**
	 * Adds a value to the Debug Watch window.
	 * Does not update until called again.
	 * @param value The value to watch.
	 * @param name The display name in the watch window.
	 */
	public inline static function quickWatch(value:Dynamic, name:String){
		#if debug
			FlxG.watch.addQuick(name == null ? "QuickWatch" : name, value);
		#end
	}

	/**
	 * Registers a custom command in the console.
	 * @param name The command name.
	 * @param callbackFn The function to execute.
	 */
	public inline static function addCommand(name:String, callbackFn:Dynamic)
		FlxG.console.registerFunction(name, callbackFn);

	/**
	 * Registers an object with a custom alias in the console.
	 * @param name The alias name.
	 * @param object The object to register.
	 */
	public inline static function addObj(name:String, object:Dynamic)
		FlxG.console.registerObject(name, object);

	/**
	 * Creates a tracker window for an object.
	 * Displays the properties of the object in a draggable window.
	 * @param obj The object to track.
	 */
	public inline static function trackObj(obj:Dynamic){
		if (obj == null){
			Log.error("Tried to track a null object!");
			return;
		}
		FlxG.debugger.track(obj);
	}

	/**
	 * Initializes the logging tools.
	 * Redirects Haxe `trace()` calls and sets up file logging.
	 */
	public static function init(){
		trace('Initializing Debug tools...'); // Initialize logging tools.
		haxe.Log.trace = function(data:Dynamic, ?info:PosInfos){
			var paramArray:Array<Dynamic> = [data];
			if (info != null){
				if (info.customParams != null){
					for (i in info.customParams)
						paramArray.push(i);
				}
			}
			tracer(paramArray, info);
		};
		fileWriter = new DebugLogWriter("TRACE");
		info("Debug logging initialized.");

		#if debug
		    info("This is a DEBUG build.");
		#else
		    info("This is a RELEASE build.");
		#end
		info('HaxeFlixel version: ${Std.string(FlxG.VERSION)}');
	}
	
	static function writeFlxG(data:Array<Dynamic>, logStyle:LogStyle){
		if (FlxG != null && FlxG.game != null && FlxG.log != null)
			FlxG.log.advanced(data, logStyle);
	}

	static function writeFile(data:Array<Dynamic>, logLevel:String = "TRACE"){
		if (fileWriter != null && fileWriter.isActive())
			fileWriter.write(data, logLevel);
	}

	static function outputer(input:Dynamic, pos:haxe.PosInfos):Array<Dynamic>{
		var inArray:Array<Dynamic> = null;
		if (input == null)
			inArray = ['<NULL>'];
		else if (!Std.isOfType(input, Array))
			inArray = [input];
		else
			inArray = input;
		if (pos == null)
			return inArray;
		var output:Array<Dynamic> = ['(${pos.className}/${pos.methodName}#${pos.lineNumber}): '];
		return output.concat(inArray);
	}
}

/**
 * Class responsible for writing debug logs to a file.
 * Manages log levels and ensures logs are written only if the file system is accessible.
 */
class DebugLogWriter{
    static final LOG_FOLDER = "assets/shared/logs";
    public static final LOG_LEVELS = ['ERROR', 'WARN', 'INFO', 'TRACE'];
    var logLevel:Int;
    var active = false;
    var file:sys.io.FileOutput;

	/**
	 * Constructor for DebugLogWriter.
	 * Initializes the log file based on the provided log level.
	 * @param logLevelParam The log level to use.
	 */
    public function new(logLevelParam:String){
        logLevel = LOG_LEVELS.indexOf(logLevelParam);
		if (Log.canPrintLog){
			debug("Initializing log file...");
			var logFilePath = '$LOG_FOLDER/${DateUtil.getFormattedDate().replace(" ", "_").replace(":", "-")}.log';
			if (logFilePath.indexOf("/") != -1){
				var lastIndex:Int = logFilePath.lastIndexOf("/");
				var logFolderPath:String = logFilePath.substr(0, lastIndex);
				debug('Creating log folder: $logFolderPath');
				Paths.folderSystem(logFolderPath);
			}
			debug('Creating log file: $logFilePath');
			file = sys.io.File.write(logFilePath, false);
			active = true;
		}else{
			debug("Won't create log file; no file system access.");
			active = false;
		}
    }

	/**
	 * Checks if the log writer is active.
	 * @return True if the log writer is active, false otherwise.
	 */
    public function isActive() return active;

	/**
	 * Determines if a message should be logged based on its level.
	 * @param input The log level of the message.
	 * @return True if the message should be logged, false otherwise.
	 */
    function shouldLog(input:String):Bool{
        var levelIndex = LOG_LEVELS.indexOf(input);
        if (levelIndex == -1)
            return false;
        return levelIndex <= logLevel;
    }

	/**
	 * Sets the log level for the writer.
	 * @param input The new log level.
	 */
    public function setLogLevel(input:String):Void{
        var levelIndex = LOG_LEVELS.indexOf(input);
        if (levelIndex == -1)
            return;
        logLevel = levelIndex;
    }

	/**
	 * Writes a log message to the file and console if applicable.
	 * @param input The message to log.
	 * @param level The log level of the message.
	 */
    public function write(input:Array<Dynamic>, level = 'TRACE'):Void{
        var ts = DateUtil.getFormattedTimeWithMilliseconds();
        var msg = '$ts [${level.rpad(' ', 4)}] ${input.join('')}';
        if (active && file != null){
            if (shouldLog(level)){
                file.writeString('$msg\n');
                file.flush();
                file.flush();
            }
        }
        if (shouldLog(level))
            debug(msg);
    }

	/**
	 * Logs a debug message to the console.
	 * @param msg The message to log.
	 */
    function debug(msg:String){
        #if sys
        	Sys.println(msg);
        #else
        	haxe.Log.trace(msg, null);
        #end
    }
}