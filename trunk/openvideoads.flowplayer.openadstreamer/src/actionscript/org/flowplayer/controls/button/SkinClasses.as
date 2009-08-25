package org.flowplayer.controls.button {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
import flash.system.ApplicationDomain;
import flash.utils.getDefinitionByName;
import org.flowplayer.controls.flash.FullScreenOnButton;
    import org.flowplayer.controls.flash.FullScreenOffButton;
    import org.flowplayer.controls.flash.Dragger;
    import org.flowplayer.controls.flash.NextButton;
    import org.flowplayer.controls.flash.PauseButton;
    import org.flowplayer.controls.flash.PlayButton;
    import org.flowplayer.controls.flash.PrevButton;
    import org.flowplayer.controls.flash.StopButton;
    import org.flowplayer.controls.flash.MuteButton;
    import org.flowplayer.controls.flash.UnMuteButton;
    import org.flowplayer.controls.flash.ScrubberLeftEdge;
    import org.flowplayer.util.Log;


    /**
     * Holds references to classes contained in the buttons.swc lib.
     * These are needed here because the classes are instantiated dynamically and without these
     * the compiler will not include thse classes into the controls.swf
     */
    public class SkinClasses {
        private static var log:Log = new Log("org.flowplayer.controls.button::SkinClasses");
        private static var _skinClasses:ApplicationDomain;

        CONFIG::skin {
            private var foo:org.flowplayer.controls.flash.FullScreenOnButton;
            private var bar:org.flowplayer.controls.flash.FullScreenOffButton;
            private var next:org.flowplayer.controls.flash.NextButton;
            private var prev:org.flowplayer.controls.flash.PrevButton;
            private var dr:org.flowplayer.controls.flash.Dragger;
            private var pause:org.flowplayer.controls.flash.PauseButton;
            private var play:org.flowplayer.controls.flash.PlayButton;
            private var stop:org.flowplayer.controls.flash.StopButton;
            private var vol:org.flowplayer.controls.flash.MuteButton;
            private var volOff:org.flowplayer.controls.flash.UnMuteButton;
            private var scrubberLeft:org.flowplayer.controls.flash.ScrubberLeftEdge;
            private var scrubberRight:org.flowplayer.controls.flash.ScrubberRightEdge;
            private var scrubberTop:org.flowplayer.controls.flash.ScrubberTopEdge;
            private var scrubberBottom:org.flowplayer.controls.flash.ScrubberBottomEdge;
            private var buttonLeft:org.flowplayer.controls.flash.ButtonLeftEdge;
            private var buttomRight:org.flowplayer.controls.flash.ButtonRightEdge;
            private var buttomTop:org.flowplayer.controls.flash.ButtonTopEdge;
            private var buttonBottom:org.flowplayer.controls.flash.ButtonBottomEdge;
            private var timeLeft:org.flowplayer.controls.flash.TimeLeftEdge;
            private var timeRight:org.flowplayer.controls.flash.TimeRightEdge;
            private var timeTop:org.flowplayer.controls.flash.TimeTopEdge;
            private var timeBottom:org.flowplayer.controls.flash.TimeBottomEdge;
            private var volumeLeft:org.flowplayer.controls.flash.VolumeLeftEdge;
            private var volumeRight:org.flowplayer.controls.flash.VolumeRightEdge;
            private var volumeTop:org.flowplayer.controls.flash.VolumeTopEdge;
            private var volumeBottom:org.flowplayer.controls.flash.VolumeBottomEdge;
            private var defaults:SkinDefaults;
        }

        public static function getDisplayObject(name:String):DisplayObject {
            var clazz:Class = getClass(name);
            return new clazz() as DisplayObject;
        }

        public static function getClass(name:String):Class {
            log.debug("creating skin class " + name + (_skinClasses ? "from skin swf" : ""));
            if (_skinClasses) {
                return _skinClasses.getDefinition(name) as Class;
            }
            return getDefinitionByName(name) as Class;
        }

        public static function get defaults():Object {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["values"];
            } catch (e:Error) {
            }
            return null;
        }

        public static function get margins():Array {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["margins"];
            } catch (e:Error) {
            }
            return [0,0,0,0];
        }

        public static function getSpaceAfterWidget(widget:DisplayObject, lastOnRight:Boolean):Number {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["getSpaceAfterWidget"](widget, lastOnRight);
            } catch (e:Error) {
            }
            return 0;            
        }

        public static function set skinClasses(val:ApplicationDomain):void {
            log.debug("received skin classes " + val);
            _skinClasses = val;
        }

        public static function getScrubberLeftEdge():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.ScrubberLeftEdge");
        }

        public static function getScrubberRightEdge():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.ScrubberRightEdge");
        }

        public static function getScrubberTopEdge():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.ScrubberTopEdge");
        }

        public static function getScrubberBottomEdge():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.ScrubberBottomEdge");
        }

        public static function getFullScreenOnButton():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.FullScreenOnButton");
        }

        public static function getFullScreenOffButton():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.FullScreenOffButton");
        }

        public static function getPlayButton():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.PlayButton");
        }

        public static function getPauseButton():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.PauseButton");
        }

        public static function getMuteButton():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.MuteButton");
        }

        public static function getUnmuteButton():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.UnMuteButton");
        }

        public static function getNextButton():DisplayObjectContainer {
            return DisplayObjectContainer(getDisplayObject("org.flowplayer.controls.flash.NextButton"));
        }

        public static function getPrevButton():DisplayObjectContainer {
            return DisplayObjectContainer(getDisplayObject("org.flowplayer.controls.flash.PrevButton"));
        }

        public static function getStopButton():DisplayObjectContainer {
            return DisplayObjectContainer(getDisplayObject("org.flowplayer.controls.flash.StopButton"));
        }

        public static function getButtonLeft():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.ButtonLeftEdge");
        }

        public static function getButtonRight():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.ButtonRightEdge");
        }

        public static function getButtonTop():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.ButtonTopEdge");
        }

        public static function getButtonBottom():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.ButtonBottomEdge");
        }

        public static function getTimeLeft():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.TimeLeftEdge");
        }

        public static function getTimeRight():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.TimeRightEdge");
        }

        public static function getTimeTop():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.TimeTopEdge");
        }

        public static function getTimeBottom():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.TimeBottomEdge");
        }

        public static function getVolumeLeft():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.VolumeLeftEdge");
        }

        public static function getVolumeRight():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.VolumeRightEdge");
        }

        public static function getVolumeTop():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.VolumeTopEdge");
        }

        public static function getVolumeBottom():DisplayObject {
            return getDisplayObject("org.flowplayer.controls.flash.VolumeBottomEdge");
        }

        public static function getDragger():DisplayObjectContainer {
            return getDisplayObject("org.flowplayer.controls.flash.Dragger") as DisplayObjectContainer;
        }
    }
}