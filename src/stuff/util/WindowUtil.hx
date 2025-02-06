package stuff.util;
import openfl.Lib;
//import stuff.network.api.Gamejolt;
//import stuff.network.api.Discord;
import openfl.Lib;
import lime.app.Application;
import flixel.util.FlxSignal.FlxTypedSignal;
using StringTools;

/**
 * Utilities for operating on the current window, such as changing the title.
 */
#if (cpp && windows)
  @:cppFileCode('
  #include <iostream>
  #include <windows.h>
  #include <psapi.h>
  ')
#end
class WindowUtil{
  /**
   * Runs platform-specific code to open a URL in a web browser.
   * @param targetUrl The URL to open.
   */
  public static function openURL(targetUrl:String):Void{
    #if CAN_OPEN_LINKS
      #if linux
        Sys.command('/usr/bin/xdg-open', [targetUrl, '&']);
      #else
        FlxG.openURL(targetUrl); // This should work on Windows and HTML5.
      #end
      Log.info('Url: ' + targetUrl);
    #else
      var name = 'Cannot open URLs on this platform.'; 
      Log.warn(name);
      throw name;
    #end
  }


  /**
   * Runs platform-specific code to open a path in the file explorer.
   * @param targetPath The path to open.
   */
  public static function openFolder(targetPath:String):Void{
    #if CAN_OPEN_LINKS
      #if windows
        Sys.command('explorer', [targetPath.replace('/', '\\')]);
      #elseif mac
        Sys.command('open', [targetPath]);
      #elseif linux
        Sys.command('open', [targetPath]);
      #end
      Log.info('Folder: ' + targetPath);
    #else
      var name = 'Cannot open URLs on this platform.'; 
      Log.warn(name);
      throw name;
    #end
  }
    /*inline public static function folder(folder:String, absolute = false){
      #if sys
        if (!absolute)
                  folder =  Sys.getCwd() + '$folder';
  
        folder = folder.replace('/', '\\');
        if (folder.endsWith('/'))
                  folder.substr(0, folder.length - 1);
  
        #if linux
            var command:String = '/usr/bin/xdg-open';
        #else
            var command:String = 'explorer.exe';
        #end
        Sys.command(command, [folder]);
        Log.print('$command $folder');
      #else
        Log.print("Platform is not supported for CoolUtil.folder", 'error');
      #end
    }*/


  /**
   * Runs platform-specific code to open a file explorer and select a specific file.
   * @param targetPath The path of the file to select.
   */
  public static function openSelectFile(targetPath:String):Void{
    #if CAN_OPEN_LINKS
      #if windows
        Sys.command('explorer', ['/select,' + targetPath.replace('/', '\\')]);
      #elseif mac
        Sys.command('open', ['-R', targetPath]);
      #elseif linux
        // TODO: unsure of the linux equivalent to opening a folder and then "selecting" a file.
        Sys.command('open', [targetPath]);
      #end
      Log.info('Select: ' + targetPath);
    #else
      var name = 'Cannot open URLs on this platform.'; 
      Log.warn(name);
      throw name;
    #end
  }


  /**
   * Dispatched when the game window is closed.
   */
  public static final winExit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();


  /**
   * Wires up FlxSignals that happen based on window activity.
   * For example, we can run a callback when the window is closed.
   */
  public static function init():Void{
    // onUpdate is called every frame just before rendering.
    // onExit is called when the game window is closed.
    //Debug.initialize();
    //Gamejolt.initialize();
		//Discord.initialize();
    Lib.current.stage.application.onExit.add(function(exit:Int){
      //Discord.shutdown();
      winExit.dispatch(exit);
    });

    /*openfl.Lib.current.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e:openfl.events.KeyboardEvent) ->{
      for (key in PlayerSettings.player1.controls.getKeysForAction(FULLSCREEN)){
        if (e.keyCode == key)
          openfl.Lib.application.window.fullscreen = !openfl.Lib.application.window.fullscreen;
      }
    });*/

    Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, stuff.util.debug.CrashHandler.onCrash);
  }


  /**
   * Turns off that annoying "Report to Microsoft" dialog that pops up when the game crashes.
   */
  public static function disableCrashHandler():Void{
    #if (cpp && windows)
      untyped __cpp__('SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX);');
    #else
      // Do nothing.
    #end
  }


  /**
   * Sets the title of the application window.
   * @param value The title to use.
   */
  public static function setWindowTitle(?name:String, isCustom = true){
    var engi = MainCore.info;
    var result:String = '';
    if (isCustom)
      result = (engi.title = name);
    else
      result = engi.title;

    Log.info('New Title: ${result}');
    return Application.current.window.title = result;
  }

  
  public static function windowMove(xy:Array<Null<Int>>){
    var result = [xy[0], (xy[1] > 0 ? - xy[1] : - xy[1])];
    var ignore:Array<Bool> = [false, false];
    if (xy[0] == null)
      ignore[0] = true;
    else if (xy[1] == null)
      ignore[1] = true;

    var win = Application.current.window;
    var lastX = win.x;
    var lastY = win.y;
    if (!ignore[0]) win.x += result[0];

    if (!ignore[1]) win.y += result[1];

    var noreX = ignore[0];
    var noreY = ignore[1];
    var colide = (noreX && noreY ? '' : ', ');
    var showX = (noreX ? '' : 'x: (last: $lastX --> new: ${result[0]})');
    var showY = (noreY ? '' : 'y: (last: $lastY --> new: ${result[1]}');
    Log.info('Moving to: ${showX}${colide}${showY}');
  }


  public static function windowPos(xy:Array<Null<Int>>){
    var result = xy;
    var ignore:Array<Bool> = [false, false];
    if (xy[0] == null)
      ignore[0] = true;
    else if (xy[1] == null)
      ignore[1] = true;

    var win = Application.current.window;
    if (!ignore[0]) win.x = result[0];

    if (!ignore[1]) win.y = result[1];

    var noreX = ignore[0];
    var noreY = ignore[1];
    var colide = (noreX && noreY ? '' : ', ');
    var showX = (noreX ? '' : 'x: ${result[0]}');
    var showY = (noreY ? '' : 'y: ${result[1]}');
    Log.info('New Position: ${showX}${colide}${showY}');
  }


  /**
   * [Application meta name]
   * @param get Meta Name
   */
  public static function getWindowMeta(getName:String):Null<String>{
    var result = switch (getName){
      case 'version' | 'ver': 'version';
      case 'title': 'title';
      default: getName;
    }
    Log.info('New Get: $result');
    return Application.current.meta.get(result);
  }
}