package stuff.util.debug;
import haxe.CallStack;

/**
 * The CrashHandler class is responsible for handling uncaught errors in the application.
 * It captures the call stack, logs the error details, saves a crash report to a file,
 * and displays an alert to the user. This helps in diagnosing and reporting issues
 * that occur during runtime.
 */
class CrashHandler{
    public static function onCrash(e:openfl.events.UncaughtErrorEvent):Void{
        var errMsg:String = "";
        var callStack:Array<StackItem> = CallStack.exceptionStack(true);
        var folder = "assets/crash/";
        var path = '$folder/${DateUtil.getFormattedDate().replace(" ", "_").replace(":", "-")}.crash';
        for (stackItem in callStack){
            switch (stackItem){
                case FilePos(s, file, line, column):
                    errMsg += file + " (line " + line + ")\n";
                default:
                    Log.info(stackItem);
            }
        }
        errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/NGS300/NGE-Player";
    
        Paths.folderSystem(folder);
        sys.io.File.saveContent(path, errMsg + "\n");

        Log.error(errMsg);
        Log.error("Crash dump saved in " + haxe.io.Path.normalize(path));
    
        lime.app.Application.current.window.alert(errMsg, "Error!");
        Sys.exit(1);
    }
}