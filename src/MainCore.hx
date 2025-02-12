package;

/**
 * The Base Core Class is The Core of Engine Stuffs
 */
class MainCore{
    //* API data
    public static final dc_api:String = "";
    public static final jolt_api = {
        id: "702509",
        key: "6f75075ef73ee34a21e39e0128e3e297"
    };

    //* Engine info
    public static final ENGINE:String = "NG's Engine";
    public static final APP:String = "Player";
    public static final NAME:String = '$ENGINE - $APP';
    public static var info = {
        title: NAME,
        name: NAME,
        version: "v0.0.1",
        state: "Beta",
        num: 0,
        date: "2025-0?-??"
    }

    //* FNF info
    public static var fnfInfo = {
        name: "Friday Night Funkin'",
        version: "v0.5.3"
    }
}