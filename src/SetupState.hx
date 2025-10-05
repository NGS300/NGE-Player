package;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import openfl.events.MouseEvent;
import flixel.math.FlxPoint;
import stuff.Paths;
import core.BeatState;

// Defines the structure for a settings category
typedef CatalogEntry = {
	var name:String;
	var options:Array<CatalogOptionEntry>;
}

// Defines the structure for a single setting option
typedef CatalogOptionEntry = {
	var groupName:Null<String>;
	var name:String;
	var value:Dynamic; // Can be Bool, String, Int, or Float
}

/**
 * SetupState.hx - A state for managing game settings.
 */
class SetupState extends BeatState{
    private static inline var data = stuff.util.save.SaveData;
	private static inline var key = stuff.util.save.SaveKeys;
	// --- Constants ---
	private static inline var NUMS_KEYS:String = 'ONETWOTHREEFOURFIVESIXSEVENEIGHTNINEZERO';
	private static inline var ALPHABET_KEYS:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	private static inline var MISC_KEYS:String = 'ENTERSPACEBACKSPACEPLUSMINUSSLASHBACKSLASHQUOTELBRACKETRBRACKETCOMMAPERIODGRAVEACCENTSEMICOLONESCAPE';
	private var enabledKeys:String = NUMS_KEYS + ALPHABET_KEYS + MISC_KEYS;
    private static inline var HIGHLIGHT_COLOR:Int = 0xFFFFFF00;
	private static inline var DEFAULT_COLOR:Int = 0xFFFFFFFF; 
	private static inline var DEFAULT_DESCRIPTION:String = "No description available.";

	// --- UI Groups & Elements ---
	private var optionGroup:FlxTypedGroup<FlxSprite>;
	private var textGroup:FlxTypedGroup<FlxText>;
	private var valueTextGroup:FlxTypedGroup<FlxText>;
	private var groupNameGroup:FlxTypedGroup<FlxText>;
	private var descriptionBox:FlxTypedGroup<FlxBasic>; // Groups all description elements for easy visibility toggle
	private var clock:FlxText;
	private var leftBracket:FlxText;
	private var rightBracket:FlxText;
	private var overIcon:FlxSprite;

	// --- Catalog Management ---
	private var selectedBarGroup:FlxSprite;
	private var catalogIconGroup:FlxTypedGroup<FlxSprite>;
	private var catalogs:Array<CatalogEntry>;
	private var catalogList:Array<FlxText>;
	private var catalogIconList:Array<FlxSprite>;
	private var optionEntryByID:Array<CatalogOptionEntry>; // Maps UI element ID to its data
	private var currentCatalogName:String;

	// --- State Variables ---
	private var scrollY:Float = 0;
	private var scrollLimitMax:Float = 0;
	private var activeText:FlxText = null;
	private var activeOption:CatalogOptionEntry = null;
	private var lastValue:String = "";
	private var lastColor:Int = 0;
	private var capsLocked:Bool = false;

	// --- Configurable Properties ---
	private var optionsStartY:Float = 120;
	private var spacing:Float = 50;
	private static var optionsLimits:Map<String, {min:Dynamic, max:Dynamic, maxChars:Int}> = [
		"FrameRate"     => {min: 0,   max: 360, maxChars: 3},
		"Engine Volume" => {min: 0.0, max: 1.0, maxChars: 3}
	];
	override function create(){
        super.create();
        var getImagePath = (key:String) -> Paths.image('bios/$key' + "_bios", "shared");

        add(new FlxSprite().loadGraphic(getImagePath("bg")).screenCenter());
        add(new FlxSprite(-49).loadGraphic(getImagePath("sidebg")).screenCenter(Y));

        var rightSidebg = new FlxSprite(951, -364).loadGraphic(getImagePath("sidebg"));
        rightSidebg.color = 0xFF333333;
        descriptionBox = new FlxTypedGroup<FlxBasic>();
        descriptionBox.add(rightSidebg);

        var descText = new FlxText(rightSidebg.x + 24, rightSidebg.y + 550, 290).setFormat(Paths.font("segoe_ui"), 16, "left");
        descText.wordWrap = true;
        var descHeader = new FlxText(0, descText.y - 42).setFormat(Paths.font("segoe_ui"), 20, "center");
        var descLine = new FlxSprite(0, descHeader.y + descHeader.height + 4).makeGraphic(Std.int(descHeader.width), 1);

        descriptionBox.add(descHeader);
        descriptionBox.add(descLine);
        descriptionBox.add(descText);
        descriptionBox.visible = false;
        add(descriptionBox);

		leftBracket = new FlxText(">").setFormat(Paths.font("segoe_ui"), 20, HIGHLIGHT_COLOR);
		rightBracket = new FlxText("<").setFormat(Paths.font("segoe_ui"), 20, HIGHLIGHT_COLOR);
		leftBracket.visible = false;
		rightBracket.visible = false;
		add(leftBracket);
		add(rightBracket);

		selectedBarGroup = new FlxSprite().makeGraphic(200, 2);
        add(selectedBarGroup);

		overIcon = new FlxSprite().loadGraphic(getImagePath("icon/arrow"));
		overIcon.scale.set(.056, .056);
		overIcon.antialiasing = data.get("bool.antialiasing");
        add(overIcon);

        optionGroup = new FlxTypedGroup<FlxSprite>();
        textGroup = new FlxTypedGroup<FlxText>();
        valueTextGroup = new FlxTypedGroup<FlxText>();
        groupNameGroup = new FlxTypedGroup<FlxText>();
        add(groupNameGroup);
        add(textGroup);
        add(optionGroup);
        add(valueTextGroup);

		catalogIconGroup = new FlxTypedGroup<FlxSprite>();
		var id = ["info", "account", "main", "advanced", "audio", "storage", "boot", "exit"];
		for (i in id) catalogIconGroup.add(new FlxSprite().loadGraphic(getImagePath('icon/$i')));
		add(catalogIconGroup);

        var header = new FlxSprite().loadGraphic(getImagePath("header")).screenCenter(X);
        add(header);

        clock = new FlxText(1000, 40).setFormat(Paths.font("segoe_ui"), 24);
        add(clock);

        var bios = new FlxText(0, 16, "Game Configuration").setFormat(Paths.font("segoe_ui"), 20);
        bios.x = (FlxG.width - bios.width) / 2 - 34;
        add(bios);

        catalogs = [
            { name: 'Information', options: [
                {groupName: 'Engine', name: 'Version', value: MainCore.engine.get('version')},
                {groupName: null, name: "Build", value: MainCore.engine.get('date')},
                {groupName: null, name: "State", value: MainCore.engine.get('state')}
            ]},
            { name: "Account", options: [
                {groupName: 'Client', name:"UserName", value: data.get("string.userName")},
            ]},
            { name: "Main", options: [
                {groupName:null, name: "Cell A", value: false},
                {groupName: null, name: "Cell B", value: true}
            ]},
            { name: "Advanced", options: [
                {groupName: null, name: "AutoPause", value: data.get("bool.autoPause")},
				{groupName: null, name: "FrameRate", value: data.get("int.frameRate")}
            ]},
            { name: "Audio", options: [
				{groupName: null, name: "Mute Volume", value: data.get("bool.muteVolume")},
                {groupName: null, name: "Engine Volume", value: data.get("float.engineVolume")}
            ]},
            { name: "Storage", options: [
                {groupName:null, name:"Storage", value: true}
            ]},
			{ name: "Boot", options: []},
            { name: "Exit", options: []} 
        ];

		// Catalog Futa :P
        catalogList = [];
		catalogIconList = [];
		var catY:Float = 180;
		var iconIndex:Int = 0;
		for (cat in catalogs){
			var txt = new FlxText(88, catY, 0, cat.name).setFormat(Paths.font("segoe_ui"), 22, DEFAULT_COLOR);
			add(txt);
			catalogList.push(txt);
			if (iconIndex < catalogIconGroup.length){
				var icon = catalogIconGroup.members[iconIndex];
				icon.scale.set(.056, .056);
				icon.antialiasing = data.get("bool.antialiasing");
				icon.color = DEFAULT_COLOR;
				catalogIconList.push(icon);
				icon.x = txt.x - ((cat.name == 'Account') ? 228 : 284);
				icon.y = txt.y - ((cat.name == 'Account') ? 190 : 238);
				iconIndex++;
			}
			catY += 40;
		}
        selectCatalog("Information");
        FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }
	override function update(elapsed:Float){
		super.update(elapsed);
		clock.text = systemClock;
		if (activeText != null){
			leftBracket.x = activeText.x - leftBracket.width - 4;
			leftBracket.y = activeText.y;
			rightBracket.x = activeText.x + activeText.textField.textWidth + 6;
			rightBracket.y = activeText.y;

			// HandleKeyboardShit
			if (key.justPressed("board.capslock")) capsLocked = !capsLocked;
			var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
			if (keyPressed == FlxKey.NONE) return;
			var keyString:String = Std.string(keyPressed);
			if (enabledKeys.indexOf(keyString) == -1) return;
			switch (keyString){
				case "ESCAPE": exitEditing(false);
				case "ENTER": exitEditing(true);
				case "BACKSPACE":
					if (activeText.text.length > 0)
						activeText.text = activeText.text.substr(0, activeText.text.length - 1);
				default:
					if (activeOption != null){
						var limit = optionsLimits.exists(activeOption.name) ? optionsLimits[activeOption.name] : null;
						var maxLen = (limit != null) ? limit.maxChars : 16;
						if (activeText.text.length < maxLen){
							var charToAdd = (key.justPressed("board.shift") || capsLocked) ? keyAltTranslator(keyString) : keyTranslator(keyString);
							if (charToAdd != null && charToAdd.length > 0){
								var potentialText = activeText.text + charToAdd;
								if (Std.isOfType(activeOption.value, Int)){
									var val:Null<Int> = Std.parseInt(potentialText);
									if (val != null && (limit == null || val <= limit.max)) activeText.text = potentialText;
								}else if (Std.isOfType(activeOption.value, Float)){
									var val:Null<Float> = Std.parseFloat(potentialText);
									if (val != null && (limit == null || val <= limit.max)) activeText.text = potentialText;
								}else
									activeText.text = potentialText;
							}
						}
					}
			}
		}else{
			// HandleMouseDick
			var mousePos = FlxG.mouse.getWorldPosition();
			var hoveredOption:CatalogOptionEntry = null;
			var hoveredSomething:Bool = false;
			if (!hoveredSomething){
				var dX = 275;
				for (txt in catalogList){ // Catalog List
					if (isMouseOver(txt, mousePos)){
						overIcon.visible = true;
						overIcon.x = txt.x - (dX * 1.16);
						overIcon.y = txt.y + (txt.height - overIcon.height) / 2;
						hoveredSomething = true;
						break;
					}
				}
				for (txt in textGroup){ // Options Name
					if (txt.alive && isMouseOver(txt, mousePos)){
						hoveredOption = getOptionEntryByID(txt.ID);
						overIcon.visible = true;
						overIcon.x = txt.x - dX + .75;
						overIcon.y = txt.y + (txt.height - overIcon.height) / 2;
						hoveredSomething = true;
						break;
					}
				}
				for (txt in valueTextGroup){ // Options Value
					if (txt.alive && isMouseOver(txt, mousePos)){
						hoveredOption = getOptionEntryByID(txt.ID);
						overIcon.visible = true;
						overIcon.x = txt.x - (dX * 1.87);
						overIcon.y = txt.y + (txt.height - overIcon.height) / 2;
						hoveredSomething = true;
						break;
					}
				}
				for (slider in optionGroup){ // Boolers & sliders
					if (slider.alive && isMouseOver(slider, mousePos)){
						hoveredOption = getOptionEntryByID(slider.ID);
						overIcon.visible = true;
						overIcon.x = slider.x - (275 * 1.87); 
						overIcon.y = slider.y + (slider.height - overIcon.height) / 2;
						hoveredSomething = true;
						break;
					}
				}
			}
			if (!hoveredSomething)
				overIcon.visible = false;
			updateDescription(hoveredOption);

			// Click Check
			if (FlxG.mouse.justPressed){
				for (slider in optionGroup){
					if (slider.alive && isMouseOver(slider, mousePos)){
						var entry = getOptionEntryByID(slider.ID);
						if (entry != null || Std.isOfType(entry.value, Bool)){
							entry.value = !entry.value;
							slider.animation.play(entry.value ? "right_move" : "left_move", true, false, 1);
						}
						return;
					}
				}
				for (txt in catalogList){
					if (isMouseOver(txt, mousePos)){
						switch (txt.text){
							case "Exit":
								saveExit(true);
								return;
							case "Boot":
								trace("Ação de Boot/Get será executada.");
						}
						selectCatalog(txt.text);
						return;
					}
				}
				if (currentCatalogName != "Information"){
					for (txt in valueTextGroup){
						if (txt.alive && isMouseOver(txt, mousePos)){
							var entry = getOptionEntryByID(txt.ID);
							if (entry != null){
								activeText = txt;
								activeOption = entry;
								lastValue = txt.text;
								lastColor = txt.color;
								txt.color = HIGHLIGHT_COLOR;
								leftBracket.visible = true;
								rightBracket.visible = true;
							}
							return;
						}
					}
				}
			}
			saveExit(false);
		}
	}
	override function destroy(){
		FlxG.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		super.destroy();
	}

	private function saveExit(can:Bool){
        if (key.justPressed("board.f10") || can){
            /*for (catalog in catalogs){
                if (catalog.name == "Information" || catalog.name == "Exit") continue;
                for (option in catalog.options){
                    // SWITCH DO OPTION NAME
                    switch (option.name){
                        case "UserName":
                            data.save("string.username", option.value); 
                        
                        default:
                            var saveKey = option.name.toLowerCase().split(" ").join("");
                            if (Std.isOfType(option.value, Bool))
                                data.save("bool." + saveKey, option.value);
                            else if (Std.isOfType(option.value, Int))
                                data.save("int." + saveKey, option.value);
                            else if (Std.isOfType(option.value, Float))
                                data.save("float." + saveKey, option.value);
                            else if (Std.isOfType(option.value, String))
                                data.save("string." + saveKey, option.value);
                            else
                                data.save("string." + saveKey, Std.string(option.value));
                    }
                }
            }*/
            trace('saveexit fuction executable');
        }
    }

	/**
	 * Clears and repopulates the central options list for a given catalog.
	 */
	private function selectCatalog(catalogName:String):Void{
		optionGroup.clear();
		textGroup.clear();
		valueTextGroup.clear();
		groupNameGroup.clear();
		scrollY = 0;
		currentCatalogName = catalogName;
		optionEntryByID = [];

		var optionsForCatalog:Array<CatalogOptionEntry> = null;
		selectedBarGroup.visible = false;
		for (i in 0...catalogList.length){
			var text:FlxText = catalogList[i];
			var icon:FlxSprite = catalogIconList[i];
			var isSelected:Bool = (text.text == catalogName);
			var color:Int = isSelected ? HIGHLIGHT_COLOR : DEFAULT_COLOR;
			text.color = color;
			icon.color = color;
			if (isSelected){
				selectedBarGroup.x = text.x + (text.width - selectedBarGroup.width) / 2;
				selectedBarGroup.scale.x = (text.width + 10) / selectedBarGroup.width;
				selectedBarGroup.y = text.y + text.height + 2;
				selectedBarGroup.color = HIGHLIGHT_COLOR;
				selectedBarGroup.visible = true;
				for (cat in catalogs) if (cat.name == catalogName) optionsForCatalog = cat.options;
			}
		}
		if (optionsForCatalog == null) return;

		var visualIndex:Int = 0;
		var lastGroupName:String = null;
		for (entry in optionsForCatalog){
			if (entry.groupName != null && entry.groupName != lastGroupName){ // Add a group name header if it's new
				var groupTxt = new FlxText(454, 0, 0, entry.groupName).setFormat(Paths.font("segoe_ui"), 18, 0xFFAAAAAA);
				groupTxt.ID = visualIndex++;
				groupNameGroup.add(groupTxt);
				lastGroupName = entry.groupName;
			}
			
			var nameTxt = new FlxText(454, 0, 0, entry.name).setFormat(Paths.font("segoe_ui"), 20);
			nameTxt.ID = visualIndex;
			textGroup.add(nameTxt);
			if (Std.isOfType(entry.value, Bool)){
				var slider = new FlxSprite(454 + 240);
				slider.frames = Paths.getSparrowAtlas("bios/slider_bios", "shared");
				slider.animation.addByPrefix("left_move", "left_move", 24, false);
				slider.animation.addByPrefix("right_move", "right_move", 24, false);
				slider.animation.addByPrefix("left_stop", "left_move0004");
				slider.animation.addByPrefix("right_stop", "right_move0004");
				slider.animation.play(entry.value ? "right_stop" : "left_stop");
				slider.ID = visualIndex;
				optionGroup.add(slider);
			}else{
				var valueTxt = new FlxText(454 + 240, 0, 320, entry.value).setFormat(Paths.font("segoe_ui"), 20, 0xFFAAAAAA);
				valueTxt.ID = visualIndex;
				valueTextGroup.add(valueTxt);
			}
			optionEntryByID[visualIndex] = entry;
			visualIndex++;
		}
		scrollLimitMax = Math.max(0, visualIndex * spacing - (FlxG.height - optionsStartY - 50));
		updateOptionPositions();
		updateDescription();
	}

	private function updateDescription(?entry:CatalogOptionEntry):Void{
        if (entry == null){
            descriptionBox.visible = false;
            return;
        }
        descriptionBox.visible = true;

        var header:FlxText = cast descriptionBox.members[1];
        var line:FlxSprite = cast descriptionBox.members[2];
        var text:FlxText   = cast descriptionBox.members[3];
        header.text = entry.name + ":";
        var desc_maxChars = 269;
        var desc:String = switch (entry.name){
            case "UserName": "The name used to identify you in the client.";
            case "AutoPause": "Automatically pause the game when losing focus.";
            case "Music Volume": "Set the music volume (0 to 100).";
            case "Mute Volume": "Mute all sounds.";
            default: DEFAULT_DESCRIPTION;
        };
        if (desc.length > desc_maxChars)
            desc = desc.substr(0, desc_maxChars);
        text.text = desc;
        header.x = text.x + (text.width - header.width) / 2;
        line.x = header.x + (header.width - line.width) / 2;
        line.scale.x = (header.width + 10) / line.width;
    }

    inline function isMouseOver(sprite:FlxSprite, mousePos:FlxPoint):Bool{
        return mousePos.x >= sprite.x && mousePos.x <= sprite.x + sprite.width
            && mousePos.y >= sprite.y && mousePos.y <= sprite.y + sprite.height;
    }

	private function exitEditing(applyChanges:Bool):Void{
		if (activeText == null) return;
		if (applyChanges && activeOption != null){
			activeOption.value = activeText.text.substr(0, getMaxLengthForOption(activeOption));
			activeText.text = Std.string(activeOption.value);
		}else
			activeText.text = lastValue;
		activeText.color = lastColor;
		activeText = null;
		activeOption = null;
		leftBracket.visible = false;
		rightBracket.visible = false;
		updateDescription();
	}
	
	private function positionOptionMember(member:FlxObject):Void{ member.y = optionsStartY + member.ID * spacing - scrollY; }
	private function getOptionEntryByID(id:Int):Null<CatalogOptionEntry>{ return (optionEntryByID != null && id >= 0 && id < optionEntryByID.length) ? optionEntryByID[id] : null; }
	private function updateOptionPositions():Void{
		optionGroup.forEachAlive(positionOptionMember);
		for (grp in [textGroup, valueTextGroup, groupNameGroup])
			grp.forEachAlive(positionOptionMember);
	}
	
	private function onMouseWheel(e:MouseEvent):Void{
		if (activeText != null) return;
		scrollY -= e.delta * 30;
		scrollY = Math.max(0, Math.min(scrollY, scrollLimitMax));
		updateOptionPositions();
	}

	private function getMaxLengthForOption(option:CatalogOptionEntry):Int{
		if (option == null) return 16;
		return switch (option.name){
			case "UserName": 12;
			case "Music Volume": 3;
			default:
				if (Std.isOfType(option.value, Int)) Std.string(1000).length;
				else if (Std.isOfType(option.value, Float)) 4;
				else 16;
		}
	}
	
	private function keyTranslator(key:String):String{
		return switch (key.toUpperCase()){
			case 'SPACE': ' '; case 'ONE': '1'; case 'TWO': '2'; case 'THREE': '3'; case 'FOUR': '4'; case 'FIVE': '5';
			case 'SIX': '6'; case 'SEVEN': '7'; case 'EIGHT': '8'; case 'NINE': '9'; case 'ZERO': '0';
			case 'SLASH': '/'; case 'MINUS': '-'; case 'PLUS': '='; case 'QUOTE': "'";
			case 'LBRACKET': '['; case 'RBRACKET': ']'; case 'COMMA': ','; case 'PERIOD': '.';
			case 'SEMICOLON': ';'; case 'GRAVEACCENT': "´"; default: key.toLowerCase();
		}
	}

	private function keyAltTranslator(key:String):String{
		return switch (key.toUpperCase()){
			case 'C': "Ç"; case 'ONE': '!'; case 'TWO': '@'; case 'THREE': '#'; case 'FOUR': '$'; case 'FIVE': '%';
			case 'SIX': '¨'; case 'SEVEN': '&'; case 'EIGHT': '*'; case 'NINE': '('; case 'ZERO': ')';
			case 'SLASH': "?"; case 'MINUS': '_'; case 'PLUS': '+'; case 'BACKSLASH': '|';
			case 'QUOTE': '"'; case 'LBRACKET': "{"; case 'RBRACKET': "}"; case 'COMMA': "<";
			case 'PERIOD': ">"; case 'SEMICOLON': ":"; case 'GRAVEACCENT': "`"; default: key.toUpperCase();
		}
	}
}