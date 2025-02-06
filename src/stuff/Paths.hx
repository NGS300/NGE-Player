package stuff;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

/**
 ** A core class which handles determining asset paths.
 */
class Paths{
    static var currentLevel:Null<String> = null;
    public static function setCurrentLevel(name:String):Void
        currentLevel = name.toLowerCase();


    public static function stripLibrary(path:String):String{
        var parts:Array<String> = path.split(':');
        if (parts.length < 2) return path;
        return parts[1];
    }


    public static function getLibrary(path:String):String{
        var parts:Array<String> = path.split(':');
        if (parts.length < 2) return 'mods';
        return parts[0];
    }


    /**
     * Checks if a directory exists, and if not, creates it.
     * Returns the path of the directory.
     *
     * @param path The path of the directory to check/create.
     * @return The path of the directory.
     */
    public static function folderSystem(path:String):String{
        if (!FileSystem.exists(path))
            FileSystem.createDirectory(path);
        return path;
    }


    /**
     * Ensures that the directory of a given file path exists.
     * If the directory does not exist, creates it.
     * Also ensures the file exists by creating an empty file if it doesn't.
     * Returns the path of the file.
     *
     * @param file The path of the file.
     * @return The path of the file.
     */
    public static function fileSystem(file:String):String{
        folderSystem(Path.directory(file));
        if (!FileSystem.exists(file))
            File.saveContent(file, "");
        return file;
    }


    static function getPath(file:String, type:AssetType, ?lib:String):String{
        if (lib != null) return getLibraryPath(file, lib);
        if (currentLevel != null){
            var levelPath:String = getLibraryPathForce(file, currentLevel);
            if (OpenFlAssets.exists(levelPath, type))
                return levelPath;
        }
        var levelPath:String = getLibraryPathForce(file, 'shared');
        if (OpenFlAssets.exists(levelPath, type)) return levelPath;
        return getModsPath(file);
    }


    public static function getLibraryPath(file:String, lib = 'mods'):String
        return if (lib == 'preload' || lib == 'default') getModsPath(file); else getLibraryPathForce(file, lib);


    static inline function getLibraryPathForce(file:String, lib:String):String
        return '$lib:assets/$lib/$file';


    static inline function getModsPath(file:String):String
        return 'assets/mods/$file';


    public static function file(file:String, type:AssetType = TEXT, ?lib:String):String
        return getPath(file, type, lib);


    /**
     * [Extesion file]
     * @param key Extesion name
     */
    public static function e(key:String):String{
        var i = '';
        switch (key){
            case 'p': i = 'png';
            case 'x': i = 'xml';
            case 't': i = 'txt';
            case 'j': i = 'json';
            case 'f': i = 'ttf';
            case 'o': i = 'otf';
            case 'm': i = 'tmx';
        }
        return (i != null ? '.$i' : '.$key');
    }


    //! File Paths
    /**
     * [Fonts file]
     * @param key Font Name
     * @param tff Is tff file ?
     */
    public static function font(key:String, ?tff = true):String{
        var ext = '';
        ext = (tff ? e('f') : e('o'));
        return 'assets/shared/fonts/$key' + ext;
    }


    /**
     * [Text file]
     * @param key File name
     * @param lib Library name
     * @param isData Is Data Folder?
     */
    public static function txt(key:String, ?lib:String, ?isData = true):String{
        var i = '';
        if (isData)
            i = 'data';
        else
            i = 'images';
        return getPath('$i/$key' + e('t'), TEXT, lib);
    }


    /**
     * [XML file]
     * @param key File name
     * @param lib Library name
     * @param isData Is Data Folder?
     */
    public static function xml(key:String, ?lib:String, ?isData = true):String{
        var i = '';
        if (isData)
            i = 'data';
        else
            i = 'images';
        return getPath('$i/$key' + e('x'), TEXT, lib);
    }


    /**
     * [Json file]
     * @param key Json name
     * @param lib Library name
     * @param isData Is Data Folder?
     */
    public static function json(key:String, ?lib:String, ?isData = true):String{
        var i = '';
        if (isData)
            i = 'data';
        else
            i = 'images';
        return getPath('i$/$key' + e('j'), TEXT, lib);
    }


    //! (Sound / Music) Paths
    /**
     * [Sound file]
     * @param key Sound name
     * @param lib Library name
     */
    public static function sound(key:String, ?lib:String):String
        return getPath('sounds/$key.${CoreData.EXT_SOUND}', SOUND, lib);


    /**
     * [Sound random]
     * @param key Sound name
     * @param min Minimum to random Sounds
     * @param max Maximum to random Sounds
     * @param lib Library Name
     */
    public static function soundRandom(key:String, min:Int, max:Int, ?lib:String):String
        return sound(key + FlxG.random.int(min, max), lib);


    /**
     * [Music file]
     * @param key Music name
     * @param lib Library name
     */
    public static function music(key:String, ?lib:String):String
        return getPath('musics/$key.${CoreData.EXT_SOUND}', MUSIC, lib);
    

    //public static function vocals(song:String, ?suffix:String = ''):String{
       // if (suffix == null) suffix = ''; // no suffix, for a sorta backwards compatibility with older-ish voice files
        //return 'songs:assets/songs/${song.toLowerCase()}/Vocals$suffix.${CoreData.EXT_SOUND}';
    //}


    //public static function inst(song:String, ?suffix:String = ''):String
        //return 'songs:assets/songs/${song.toLowerCase()}/Inst$suffix.${CoreData.EXT_SOUND}';


    //! Images Paths
    /**
     * [Image file]
     * @param key Image name
     * @param lib Library name
     */
    public static function image(key:String, ?lib:String):String
        return getPath('images/$key' + e('p'), IMAGE, lib);


    public static function animateAtlas(path:String, ?library:String):String
        return getLibraryPath('images/$path', library);


    /*public static function ui(key:String, ?library:String):String{
        return xml('ui/$key', library);
    }*/


    public static function getSparrowAtlas(key:String, ?lib:String):FlxAtlasFrames
        return FlxAtlasFrames.fromSparrow(image(key, lib), xml(key, lib, false));


    public static function getPackerAtlas(key:String, ?lib:String):FlxAtlasFrames
        return FlxAtlasFrames.fromSpriteSheetPacker(image(key, lib), txt(key, lib, false));


    public static function videos(key:String, ?library:String):String
        return getPath('videos/$key.${CoreData.EXT_VIDEO}', BINARY, library ?? 'videos');


    //! Shaders Paths
    public static function frag(key:String, ?library:String):String
        return getPath('shaders/$key.frag', TEXT, library);


    public static function vert(key:String, ?library:String):String
        return getPath('shaders/$key.vert', TEXT, library);
}