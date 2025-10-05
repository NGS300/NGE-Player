package stuff;

/**
 * The Base Core Class is The Core of Engine Stuffs
 */
class CoreData{
    //* Extesion files
    public static final EXT_SOUND:String = #if web "mp3" #else "ogg" #end; // The file extension used when loading audio files.
    public static final EXT_VIDEO:String = "mp4"; // The file extension used when loading video files.
    public static final EXT_IMAGE:String = "png"; // The file extension used when loading image files.
    public static final EXT_DATA:String = "json"; // The file extension used when loading data files.
}