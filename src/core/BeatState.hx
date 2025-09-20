package core;

import core.Conductor.BPMChangeEvent;
import flixel.addons.ui.FlxUIState;

/**
 * Handles beat/step timing updates for the current song
 */
class BeatState extends FlxUIState{
    private var systemClock:String = '';
    private var lastBeat:Float = 0;
    private var lastStep:Float = 0;

    private var curStep:Int = 0;
    private var curBeat:Int = 0;
    private var curDecimalBeat:Float = 0;

    override function create(){
        TimingStruct.clearTimings(); // Clear old timings
        super.create();
    }

    override function update(elapsed:Float){
        if (Conductor.songPosition < 0)
            curDecimalBeat = 0;
        else{
            if (TimingStruct.AllTimings.length > 0){
                var data = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
                if(data != null){
                    Conductor.crochet = ((60 / data.bpm) * 1000);
                    var stepMS = Conductor.crochet / 4;
                    var startInMS = data.startTime * 1000;

                    curDecimalBeat = data.startBeat + ((Conductor.songPosition / 1000 - data.startTime) * (data.bpm / 60));
                    var ste:Int = Math.floor(data.startStep + ((Conductor.songPosition - startInMS) / stepMS));
                    if (ste >= 0){
                        if (ste > curStep){
                            for (_ in curStep...ste){
                                curStep++;
                                updateBeat();
                                stepHit();
                            }
                        }else if (ste < curStep){
                            curStep = ste;
                            updateBeat();
                            // optional: skip stepHit to prevent duplicates
                        }
                    }
                }
            }else{
                // Fallback if no timings
                curDecimalBeat = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
                var nextStep:Int = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
                if (nextStep >= 0){
                    if (nextStep > curStep){
                        for (_ in curStep...nextStep){
                            curStep++;
                            updateBeat();
                            stepHit();
                        }
                    }else if (nextStep < curStep){
                        curStep = nextStep;
                        updateBeat();
                        // optional: skip stepHit
                    }
                }
                Conductor.crochet = ((60 / Conductor.bpm) * 1000);
            }
        }
        systemClock = (Date.now().getDate() < 10 ? "0" : "") + Date.now().getDate() + "/" + (Date.now().getMonth() < 10 ? "0" : "") + (Date.now().getMonth() + 1) + "/" + Date.now().getFullYear() + 
		' - ' + (Date.now().getHours() < 10 ? "0" : "") + Date.now().getHours() + ":" + (Date.now().getMinutes() < 10 ? "0" : "") + Date.now().getMinutes() + ":" + (Date.now().getSeconds() < 10 ? "0" : "")  + Date.now().getSeconds();
        super.update(elapsed);
    }

    /**
     * Update current beat from steps
     */
    private function updateBeat():Void{
        lastBeat = curBeat;
        curBeat = Math.floor(curStep / 4);
    }

    /**
     * Calculates the current step using BPM changes
     */
    private function updateCurStep():Int{
        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: 0
        }
        for (change in Conductor.bpmChangeMap){
            if (Conductor.songPosition >= change.songTime)
                lastChange = change;
        }
        return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
    }

    /**
     * Called every step
     */
    public function stepHit():Void{
        if (curStep % 4 == 0)
            beatHit();
    }

    /**
     * Called every beat (4 steps)
     */
    public function beatHit():Void{
        // intentionally empty
    }
}