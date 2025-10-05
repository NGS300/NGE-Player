package stuff.util;
//import stuff.network.api.Gamejolt;
//import stuff.network.api.Discord;
import sys.FileSystem;
import openfl.Lib;
import sys.io.File;
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
    var path = "engine.json";
    if (!FileSystem.exists(path)){
      trace('File $path NOT Exist!');
      return;
    }
    var data:Dynamic = haxe.Json.parse(File.getContent(path));

    // --- Engine ---
    if (data.engine != null){
      var eng = data.engine;
      MainCore.engine.set('title', eng.Engine + " - " + eng.App);
      MainCore.engine.set('engine', eng.Engine);
      MainCore.engine.set('name', eng.App);
      MainCore.engine.set('version', 'v' + eng.Version);
      MainCore.engine.set('state', eng.State);
      MainCore.engine.set('number', eng.Number);
      MainCore.engine.set('date', eng.Date);
    }

    // --- Game ---
    if (data.game != null){
      var g = data.game;
      MainCore.game.set('name', g.Name);
      MainCore.game.set('version', 'v' + g.Version);
    }

    // --- API ---
    if (data.api != null){
      var a = data.api;
      MainCore.api.set('discord_id', a.Discord);
      MainCore.api.set('jolt_key', a.GameJolt_Key);
      MainCore.api.set('jolt_id', a.GameJolt_ID);
    }

    // Handler de erros
    Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(
      openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, 
      stuff.util.debug.CrashHandler.onCrash
    );
    Lib.current.stage.application.onExit.add(function(exit:Int){
      winExit.dispatch(exit);
    });
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
  public static function setWindowTitle(?name:String, isCustom = true):String{
    var title = MainCore.engine;
    var result:String = '';
    if (isCustom){
        title.set('title', name);
        result = title.get('title');
    }else
        result = title.get('title');

    Log.info('New Title: ${result}');
    Application.current.window.title = result;
    return result;
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