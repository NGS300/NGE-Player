package stuff.util.debug;
import haxe.PosInfos;
import lime.app.Application;
import sys.io.FileOutput;
import stuff.util.DateUtil;
import sys.io.File;
using StringTools;
// import flixel.FlxG;

/**
 * Engine Debug
 */
class Log{
    static var output:sys.io.FileOutput = null;
    static var logFile:Null<String> = null;
    static final MAX_LOG_FOLDER_SIZE:Int = 50 * 1024 * 1024; // 50MB
    static var currentLogCount:Int = 0;
    static final logSystem:Bool = true;
 
    public static function init(){
        FlxG.watch.addMouse();
 
        if (!logSystem) return;
 
        var name:String = MainCore.NAME == null ? 'Unknown' : MainCore.NAME.replace("'", "");
        var nameSub:String = name.replace(" ", "");
        var timestamp:String = DateUtil.getFormattedCustomDate(true);
        logFile = 'assets/logs/${nameSub}_${timestamp}.txt';
        try{
            output = File.write(logFile, true);
            if (output != null){
                haxe.Log.trace = function(data:Dynamic, ?info:PosInfos){
                    var paramArray:Array<Dynamic> = [data];
                    if (info != null && info.customParams != null)
                        paramArray = paramArray.concat(info.customParams);
                    print(paramArray, true, info);
                };
            }
        }catch (e:Dynamic)
            trace('Error initializing log file: ${Std.string(e)}');
    }
 
    public inline static function print(msg:Dynamic, ?method = 'add', ?canPrint:Bool, ?pos:haxe.PosInfos):Void{
        trace(msg);
        if (logSystem && (canPrint || canPrint != null)){
            var level = switch (method){
                case 'add': 'info';
                case 'warn': 'warning';
                case 'error': 'critical';
                default: method;
            };
            var paddedLevel = StringTools.rpad(level.toUpperCase(), ' ', 5);
            var msg0 = Std.string(msg).endsWith(']') ? "" : "]";
            var msg1 = Std.string('[' + msg + msg0);
            var logPrint = '${paddedLevel} => ${msg1}';
            overwrite(logPrint, pos);
        }
    }
 
    inline static function overwrite(message:Dynamic, ?pos:haxe.PosInfos):Void{
        try{
            var inArray:Array<Dynamic> = message != null ? (Std.isOfType(message, Array) ? message : [message]) : ['<NULL>'];
            var outputMessage:Array<Dynamic> = pos != null ? [' (${pos.className}/${pos.methodName}#${pos.lineNumber}): '] : [];
            outputMessage = outputMessage.concat(inArray);
 
            var date = DateUtil.getFormattedDateOnly();
            var sec = DateUtil.getFormattedTimeWithMilliseconds();
            var timeStamp = '[${date} ${sec}]';
            var id = outputMessage.join("");
 
            if (output != null){
                output.writeString(timeStamp + id + '\n');
                output.flush();
            }else
                trace("Output file not initialized.");
        }catch (e:Dynamic)
            trace('Error writing to log file: ${Std.string(e)}');
    }
}