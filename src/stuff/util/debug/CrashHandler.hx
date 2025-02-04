package stuff.util.debug;
import haxe.CallStack;

/**
 * The Crash Handler
 */
class CrashHandler{
    public static function onCrash(e:openfl.events.UncaughtErrorEvent):Void{
        var errMsg:String = "";
        var folder:String;
        var path:String;
        var callStack:Array<StackItem> = CallStack.exceptionStack(true);

        var name:String = MainCore.NAME == null ? 'Unknown' : MainCore.NAME.replace("'", "");
        var nameSub:String = name.replace(" ", "");
        var timeStamp:String = stuff.util.DateUtil.getFormattedCustomDate(true);
        folder = "assets/crash/";
        path = folder + '${nameSub}_' + timeStamp + ".txt";
    
        for (stackItem in callStack){
            switch (stackItem){
                case FilePos(s, file, line, column):
                    errMsg += file + " (line " + line + ")\n";
                default:
                    Log.print(stackItem);
            }
        }
        errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/NGS300/NGE-Player";
    
        Paths.folderSystem(folder);
        sys.io.File.saveContent(path, errMsg + "\n");

        Log.print(errMsg);
        Log.print("Crash dump saved in " + haxe.io.Path.normalize(path));
    
        lime.app.Application.current.window.alert(errMsg, "Error!");
        Sys.exit(1);
    }
}