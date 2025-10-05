package;

/**
 * The Base Core Class is The Core of Engine Stuffs
 */
class MainCore{
    // Engine info
    public static var engine: Map<String, Dynamic> = [
		'title' => 'Unknown',
        'engine' => 'Unknown',
		'name' => 'Unknown',
		'version' => 'v0.0.0',
        'state' => 'Unknown',
        'number' => 0,
        'date' => '????-??-??'
	];

    // Game Info
    public static var game: Map<String, Dynamic> = [
        'name' => "Friday Night Funkin'",
        'version' => 'v0.0.0'
    ];

    // API data
    public static var api: Map<String, Dynamic> = [
        'discord_id' => 'Unknown',
        'jolt_key' => 'Unknown',
        'jolt_id' => 'Unknown'
    ];
}