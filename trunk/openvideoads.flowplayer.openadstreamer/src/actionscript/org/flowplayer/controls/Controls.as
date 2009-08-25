/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.system.ApplicationDomain;
import flash.utils.Timer;

    import org.flowplayer.controls.button.AbstractButton;
    import org.flowplayer.controls.button.AbstractToggleButton;
    import org.flowplayer.controls.button.ButtonEvent;
    import org.flowplayer.controls.button.NextButton;
    import org.flowplayer.controls.button.PrevButton;
    import org.flowplayer.controls.button.SkinClasses;
import org.flowplayer.controls.button.StopButton;
    import org.flowplayer.controls.button.ToggleFullScreenButton;
    import org.flowplayer.controls.button.TogglePlayButton;
    import org.flowplayer.controls.button.ToggleVolumeMuteButton;
    import org.flowplayer.controls.slider.Scrubber;
    import org.flowplayer.controls.slider.ScrubberSlider;
    import org.flowplayer.controls.slider.VolumeScrubber;
import org.flowplayer.controls.slider.VolumeSlider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.DisplayPluginModel;
import org.flowplayer.model.DisplayProperties;
import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.PlayerEventType;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.model.Status;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    /**
	 * @author anssi
	 */
	public class Controls extends StyleableSprite implements Plugin {

		private static const DEFAULT_HEIGHT:Number = 28;

		private var _playButton:AbstractToggleButton;
		private var _fullScreenButton:AbstractToggleButton;
		private var _muteVolumeButton:AbstractToggleButton;
		private var _volumeSlider:VolumeScrubber;
		private var _progressTracker:DisplayObject;
		private var _prevButton:DisplayObject;
		private var _nextButton:DisplayObject;
		private var _stopButton:DisplayObject;
		private var _scrubber:Scrubber;
		private var _timeView:TimeView;
//		private var _tallestWidget:DisplayObject;

		private var _widgetMaxHeight:Number = 0;
//        private var _margins:Array = [2, 6, 2, 6];
		private var _config:Config;
		private var _timeUpdateTimer:Timer;
		private var _floating:Boolean = false;
		private var _controlBarMover:ControlsAutoHide;
		private var _immediatePositioning:Boolean = true;
		private var _animationTimer:Timer;
		private var _player:Flowplayer;
		private var _pluginModel:PluginModel;
		private var _initialized:Boolean;

		public function Controls() {
			log.debug("creating ControlBar");
			this.visible = false;
			height = DEFAULT_HEIGHT;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		

		/**
		 * Makes buttons and other widgets visible/hidden.
		 * @param enabledWidgets the buttons visibilies, for example { all: true, volume: false, time: false }
		 */		
		[External]
		public function widgets(visibleWidgets:Object):void {
			log.debug("enable()");
			if (_animationTimer && _animationTimer.running) return;
			setConfigBooleanStates("visible", visibleWidgets);
			immediatePositioning = false;
			createChildren();
			onResize();
			immediatePositioning = true;
		}

		/**
		 * Enables and disables buttons and other widgets.
		 */
		[External]
		 public function enable(enabledWidgets:Object):void {
			log.debug("enable()");
			if (_animationTimer && _animationTimer.running) return;
			setConfigBooleanStates("enabled", enabledWidgets);
			enableWidgets();
			enableFullscreenButton(_player.playlist.current);
		}

		private function enableWidgets():void {
			var index:int = 0;
			while (index < numChildren) {
				var child:DisplayObject = getChildAt(index);
				log.debug("enabledWidget " + child.name + ":");
				if (child.hasOwnProperty("enabled") && _config.enabled.hasOwnProperty(child.name)) {
					log.debug("enabled " + _config.enabled[child.name]);
					child["enabled"] = _config.enabled[child.name];
				}
				index++;
			}
		}

		private function setConfigBooleanStates(propertyName:String, values:Object):void {
			if (values.hasOwnProperty("all")) {
				_config[propertyName].reset();
			}
			new PropertyBinder(_config[propertyName]).copyProperties(values);
		}
		
		private function set immediatePositioning(enable:Boolean):void {
			_immediatePositioning = enable;
			if (! enable) return;
			_animationTimer = new Timer(500, 1);
			_animationTimer.start();
		}

		/**
		 * @inheritDoc
		 */
		override public function css(styleProps:Object = null):Object {
			var result:Object = super.css(styleProps);
			var newStyleProps:Object = _config.style.addStyleProps(result);
			
			initTooltipConfig(_config, styleProps);
			newStyleProps["tooltips"] = _config.tooltips.props;
			
			redraw(styleProps);
			return newStyleProps;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function animate(styleProps:Object):Object {
			var result:Object = super.animate(styleProps);
			return _config.style.addStyleProps(result);
		}
		
		/**
		 * Rearranges the buttons when size changes.
		 */
		override protected function onResize():void {
			if (! _initialized) return;
			log.debug("arranging, width is " + width);
//			resizeTallestWidget();
			var leftEdge:Number = arrangeLeftEdgeControls();
			arrangeRightEdgeControls(leftEdge);		
			initializeVolume();
			log.debug("arranged to x " + this.x + ", y " + this.y);
		}
//
//		private function resizeTallestWidget():void {
//			_tallestWidget.height = height - _margins[0] - _margins[2];
//		}

		/**
		 * Makes this visible when the superclass has been drawn.
		 */
		override protected function onRedraw():void {
			log.debug("onRedraw, making controls visible");
			this.visible = true;
		}
		
		/**
		 * Default properties for the controls.
		 */		
		public function getDefaultConfig():Object {
            // skinless controlbar does not have defaults
            if (! SkinClasses.defaults) return null;
            return SkinClasses.defaults;
		}
		
		private function initTooltipConfig(config:Config, styleProps:Object):void {
			new PropertyBinder(config.tooltips).copyProperties(styleProps["tooltips"]);
		}
		
		private function redraw(styleProps:Object):void {
			_config.addStyleProps(styleProps);
			if (_scrubber) {
				_scrubber.redraw(_config);
			}
			if (_volumeSlider) {
				_volumeSlider.redraw(_config);
			}
			if (_timeView) {
				_timeView.redraw(_config);
			}
			for (var j:int = 0; j < numChildren; j++) {
				var child:DisplayObject = getChildAt(j);
				if (child is AbstractButton) {
					AbstractButton(child).redraw(_config);
				}
			}
		}
		private function onAddedToStage(event:Event):void {
			log.debug("addedToStage, config is " + _config);
			if (_pluginModel.name == "controls" && _config.autoHide != 'never' && ! _controlBarMover) {
				_controlBarMover = new ControlsAutoHide(_config, _player, stage, this);
			}
			enableWidgets();
		}

		public function onLoad(player:Flowplayer):void {
			log.info("received player API! autohide == " + _config.autoHide);
			_player = player;
            if (_config.skin) {
                var skin:PluginModel = player.pluginRegistry.getPlugin(_config.skin) as PluginModel;
                log.debug("using skin " + skin);
                SkinClasses.skinClasses = skin.pluginObject as ApplicationDomain;
                log.debug("skin has defaults", SkinClasses.defaults);
                fixPositionSettings(_pluginModel as DisplayPluginModel, SkinClasses.defaults);
                new PropertyBinder(_pluginModel, "config").copyProperties(SkinClasses.defaults, false);
                _config = createConfig(_pluginModel);
            }
            createChildren();
            loader = player.createLoader();
            createTimeView();
            addListeners(player.playlist);
            if (_scrubber) {
                _scrubber.playlist = player.playlist;
            }
            enableFullscreenButton(player.playlist.current);
            if (_playButton) {
                _playButton.down = player.isPlaying();
            }
            log.debug("setting root style to " + _config.style.bgStyle);
            rootStyle = _config.style.bgStyle;
            if (_muteVolumeButton) {
                _muteVolumeButton.down = player.muted;
            }
			_pluginModel.dispatchOnLoad();
		}

        private function fixPositionSettings(props:DisplayProperties, defaults:Object):void {
            clearOpposite("bottom", "top", props, defaults);
            clearOpposite("left", "right", props, defaults);
        }

        private function clearOpposite(prop1:String, prop2:String, props:DisplayProperties, defaults:Object):void {
            if (props.position[prop1].hasValue() && defaults.hasOwnProperty(prop2)) {
                delete defaults[prop2];
            } else if (props.position[prop2].hasValue() && defaults.hasOwnProperty(prop1)) {
                delete defaults[prop1];
            }
        }

		public function onConfig(model:PluginModel):void {
			log.info("received my plugin config ", model.config);
			_pluginModel = model;
			log.debug("-");
			_config = createConfig(model);
			log.debug("config created");
		}
		
		private function createConfig(plugin:PluginModel):Config {
			var config:Config = new PropertyBinder(new Config()).copyProperties(plugin.config) as Config;
			new PropertyBinder(config.visible).copyProperties(plugin.config);
			new PropertyBinder(config.enabled).copyProperties(plugin.config.enabled);
			config.addStyleProps(plugin.config);
			initTooltipConfig(config, plugin.config);
			return config;
		}
		
		public function set floating(float:Boolean):void {
			_floating = float;
		}

		private function createChildren():void {
			log.debug("creating fullscren ", _config );
			var animationEngine:AnimationEngine = _player.animationEngine;
			_fullScreenButton = addChildWidget(createWidget(_fullScreenButton, "fullscreen", ToggleFullScreenButton, _config, animationEngine)) as AbstractToggleButton;
			log.debug("creating play");
			_playButton = addChildWidget(createWidget(_playButton, "play", TogglePlayButton, _config, animationEngine), ButtonEvent.CLICK, onPlayClicked) as AbstractToggleButton;
			log.debug("creating stop");
			_stopButton = addChildWidget(createWidget(_stopButton, "stop", StopButton, _config, animationEngine), ButtonEvent.CLICK, onStopClicked);
			_nextButton = addChildWidget(createWidget(_nextButton, "playlist", NextButton, _config, animationEngine), ButtonEvent.CLICK, "next");
			_prevButton = addChildWidget(createWidget(_prevButton, "playlist", PrevButton, _config, animationEngine), ButtonEvent.CLICK, "previous");
			_muteVolumeButton = addChildWidget(createWidget(_muteVolumeButton, "mute", ToggleVolumeMuteButton, _config, animationEngine), ButtonEvent.CLICK, onMuteVolumeClicked) as AbstractToggleButton;
			_volumeSlider = addChildWidget(createWidget(_volumeSlider, "volume", VolumeScrubber, _config, animationEngine, this), VolumeSlider.DRAG_EVENT, onVolumeSlider) as VolumeScrubber;
			_scrubber = addChildWidget(createWidget(_scrubber, "scrubber", Scrubber, _config, animationEngine, this), Scrubber.DRAG_EVENT, onScrubbed) as Scrubber;
			createTimeView();
			createScrubberUpdateTimer();
			log.debug("created all buttons");
			_initialized = true;
		}
		
		private function createTimeView():void {
			if (! _player) return;
			if (_config.visible.time) {
				if (_timeView) return;
				_timeView = addChildWidget(new TimeView(_config, _player), TimeView.EVENT_REARRANGE, onTimeViewRearranged) as TimeView;
				_timeView.visible = false;
			} else if (_timeView) {
				removeChildAnimate(_timeView);
				_timeView = null;
			}
		}

		private function onTimeViewRearranged(event:Event):void {
			onResize();
		}

		private function createWidget(existing:DisplayObject, name:String, Widget:Class, constructorArg:Object, constructorArg2:Object = null, constructorArg3:Object = null):DisplayObject {
			var doAdd:Boolean = _config.visible[name];
			if (!doAdd) {
				log.debug("not showing widget " + Widget);
				if (existing) {
					removeChildAnimate(existing);
				}
				return null;
			}
			if (existing) return existing;
			log.debug("creating " + Widget);
			var widget:DisplayObject;

            if (constructorArg3) {
                widget = new Widget(constructorArg, constructorArg2, constructorArg3);			
            } else if (constructorArg2) {
				widget = new Widget(constructorArg, constructorArg2);
			} else {
				widget = constructorArg ? new Widget(constructorArg) : new Widget();
			}
			
			_widgetMaxHeight = Math.max(_widgetMaxHeight, widget.height);
//			if (widget.height == _widgetMaxHeight) {
//				_tallestWidget = widget;
//			}
			
			widget.visible = false;
			widget.name = name;
			return widget;
		}

		private function removeChildAnimate(child:DisplayObject):DisplayObject {
			if (! _player || _immediatePositioning) {
				removeChild(child);
				return child;
			}
			_player.animationEngine.fadeOut(child, 1000, function():void { removeChild(child); 
			});
			return child;
		}

		private function addChildWidget(widget:DisplayObject, eventType:String = null, listener:Object = null):DisplayObject {
			if (!widget) return null;
			addChild(widget as DisplayObject);
			if (eventType) {
				widget.addEventListener(eventType, listener is Function ? listener as Function : function():void { _player[listener](); });
			}
			log.debug("added control bar child widget  " + widget);
			return widget;
		}
		
		private function createScrubberUpdateTimer():void {
			_timeUpdateTimer = new Timer(500);
			_timeUpdateTimer.addEventListener(TimerEvent.TIMER, onTimeUpdate);
			_timeUpdateTimer.start();
		}
		
		private function initializeVolume():void {
			if (!_volumeSlider) return;
			var volume:Number = _player.volume;
			log.info("initializing volume to " + volume);
			_volumeSlider.value = volume;
		}

		private function onTimeUpdate(event:TimerEvent):void {
			if (! (_scrubber || _timeView)) return;
			if (! _player) return;
			var status:Status = getPlayerStatus();
			if (! status) return;
			var duration:Number = status.clip ? status.clip.duration : 0;
//			log.debug("duration " + duration + ", bufferStart " + status.bufferStart + ", bufferEnd " + status.bufferEnd + ", clip " + status.clip);
			if (_scrubber) {
				if (duration > 0) { 
					_scrubber.value = (status.time / duration) * 100;
					_scrubber.setBufferRange(status.bufferStart / duration, status.bufferEnd / duration);
					_scrubber.allowRandomSeek = status.allowRandomSeek;
				} else {
					_scrubber.value = 0;
					_scrubber.setBufferRange(0, 0);
					_scrubber.allowRandomSeek = false;
				}
				if (status.clip) {
					_scrubber.tooltipTextFunc = function(percentage:Number):String {
						return TimeUtil.formatSeconds(percentage / 100 * duration);
					};
				}
			}
			if (_timeView) {
				_timeView.duration = status.clip.live ? -1 : duration;
				_timeView.time = status.time;
			}
		}
		
		private function getPlayerStatus():Status {
			try {
				return _player.status;
			} catch (e:Error) {
				log.error("error querying player status, will stop query timer, error message: " + e.message);
				_timeUpdateTimer.stop();
				throw e;
			}
			return null;
		}

		private function addListeners(playlist:Playlist):void {
			playlist.onConnect(onPlayStarted);
			playlist.onBeforeBegin(onPlayStarted);
			playlist.onMetaData(onPlayStarted);
			playlist.onPause(onPlayPaused);
			playlist.onResume(onPlayResumed);
			playlist.onStop(onPlayStopped);
			playlist.onBufferStop(onPlayStopped);
			playlist.onFinish(onPlayStopped);
			_player.onFullscreen(onPlayerFullscreenEvent);
			_player.onFullscreenExit(onPlayerFullscreenEvent);
			_player.onMute(onPlayerMuteEvent);
			_player.onUnmute(onPlayerMuteEvent);
			_player.onVolume(onPlayerVolumeEvent);
		}
				
		private function onPlayerVolumeEvent(event:PlayerEvent):void {
			if (! _volumeSlider) return;
			_volumeSlider.value = event.info as Number;
		}

		private function onPlayerMuteEvent(event:PlayerEvent):void {
			log.info("onPlayerMuteEvent, _muteButton " + _muteVolumeButton);
			if (! _muteVolumeButton) return;
			_muteVolumeButton.down = event.eventType == PlayerEventType.MUTE;
		}

		private function onPlayStarted(event:ClipEvent):void {
			log.debug("received " + event);
			if (_playButton) {
				_playButton.down = ! event.isDefaultPrevented();
			}
			enableFullscreenButton(event.target as Clip);
		}
		
		private function enableFullscreenButton(clip:Clip):void {
			if (!_fullScreenButton) return;
			var enabled:Boolean = clip && (clip.originalWidth > 0 || ! clip.accelerated) && _config.enabled.fullscreen;
			_fullScreenButton.enabled = enabled;
			if (enabled) {
				_fullScreenButton.addEventListener(ButtonEvent.CLICK, toggleFullscreen);
			} else {
				_fullScreenButton.removeEventListener(ButtonEvent.CLICK, toggleFullscreen);
			}
		}
		
		private function toggleFullscreen(event:ButtonEvent):void  {
			_player.toggleFullscreen();
		}

		private function onMetaData(event:ClipEvent):void {
			if (!_fullScreenButton) return;
			enableFullscreenButton(event.target as Clip);
		}

		private function onPlayPaused(event:ClipEvent):void {
			log.info("received " + event);
			if (!_playButton) return;
			_playButton.down = false;
		}

		private function onPlayStopped(event:ClipEvent):void {
			log.debug("received " + event);
			if (!_playButton) return;
			log.debug("setting playButton to up state");
			_playButton.down = false;
		}

		private function onPlayResumed(event:ClipEvent):void {
			log.info("received " + event);
			if (!_playButton) return;
			_playButton.down = true;
		}
		
		private function onPlayerFullscreenEvent(event:PlayerEvent):void {
			log.debug("onPlayerFullscreenEvent");
			if (!_fullScreenButton) return;
			_fullScreenButton.down = event.eventType == PlayerEventType.FULLSCREEN;
		}

		private function onPlayClicked(event:ButtonEvent):void {
			_player.toggle();
		}

		private function onStopClicked(event:ButtonEvent):void {
			_player.stop();
		}

		private function onMuteVolumeClicked(event:ButtonEvent):void {
			_player.muted = ! _player.muted;
		}

		private function onVolumeSlider(event:Event):void {
			log.debug("volume slider changed to pos " + VolumeSlider(event.target).value);
			_player.volume = VolumeSlider(event.target).value;
		}
		
		private function onScrubbed(event:Event):void {
			_player.seekRelative(ScrubberSlider(event.target).value);
		}

		private function arrangeLeftEdgeControls():Number {
			var leftEdge:Number = margins[3];
			var leftControls:Array = [_stopButton, _playButton, _prevButton, _nextButton];
			leftEdge = arrangeControls(leftEdge, leftControls, arrangeToLeftEdge);
			return leftEdge;
		}

		private function arrangeRightEdgeControls(leftEdge:Number):void {
			var edge:Number =  _config.visible.scrubber ? (width - margins[1]) : leftEdge;
			var rightControls:Array;

			// set volume slider width first so that we know how to arrange the other controls
			if (_volumeSlider) {
				_volumeSlider.width = 40;
			}
			if (_config.visible.scrubber) {
				// arrange from right to left (scrubber takes the remaining space)
				rightControls = [_fullScreenButton, _volumeSlider, _muteVolumeButton, _timeView];
				edge = arrangeControls(edge, rightControls, arrangeToRightEdge);
				edge = arrangeScrubber(leftEdge, edge);
			} else {
				// no scrubber --> stack from left to right
				rightControls = [_timeView, _muteVolumeButton, _volumeSlider, _fullScreenButton];
				edge = arrangeControls(edge, rightControls, arrangeToLeftEdge);
			}

			arrangeVolumeControl();
		}
		
		private function arrangeControls(edge:Number, controls:Array, arrangeFunc:Function):Number {
			for (var i:Number = 0; i < controls.length; i++) {
				if (controls[i]) {
					var control:DisplayObject = controls[i] as DisplayObject;
					arrangeYCentered(control);
					edge = arrangeFunc(edge, getSpaceAfterWidget(control), control) as Number;
				}
			}
			return edge;
		}

        private function get margins():Array {
            return SkinClasses.margins;
        }

		private function arrangeVolumeControl():void {
			if (! _config.visible.volume) return;
			_volumeSlider.height = height - margins[0] - margins[2];
            _volumeSlider.y = margins[0];
		}

//		private function arrangeMuteVolumeButton():void {
//			if (! _config.visible.mute) return;
//			Arrange.center(_muteVolumeButton, 0, height);
//			return;
//		}
		
		private function arrangeScrubber(leftEdge:Number, rightEdge:Number):Number {
			if (! _config.visible.scrubber) return rightEdge;
			arrangeX(_scrubber, leftEdge);
			var scrubberWidth:Number = rightEdge - leftEdge - 2 * getSpaceAfterWidget(_scrubber); 
			if (! _player || _immediatePositioning) { 
				_scrubber.width = scrubberWidth;
			} else {
				_player.animationEngine.animateProperty(_scrubber, "width", scrubberWidth);
			}
            _scrubber.height = height - margins[0] - margins[2];
            _scrubber.y = _height - margins[2] - _scrubber.height;
			return rightEdge - getSpaceAfterWidget(_scrubber) - scrubberWidth;
		}
	
		private function arrangeToRightEdge(rightEdgePos:Number, spaceBetweenClips:Number, clip:DisplayObject):Number {
			if (! clip) return rightEdgePos;
			rightEdgePos = rightEdgePos - clip.width - spaceBetweenClips;
			arrangeX(clip, rightEdgePos);
			return rightEdgePos;
		}
		
		private function arrangeX(clip:DisplayObject, pos:Number):void {
			clip.visible = true;
			if (! _player || _immediatePositioning) {
				clip.x = pos;
				return;
			}
			if (clip.x == 0) {
				// we are arranging a newly created widget, fade it in
				clip.x = pos;
				fadeIn(clip);
			}
			// rearrange a previously arrange widget
			_player.animationEngine.animateProperty(clip, "x", pos);
		}
		
		private function fadeIn(clip:DisplayObject):void {
			var currentAlpha:Number = clip.alpha;
			clip.alpha = 0;
			_player.animationEngine.animateProperty(clip, "alpha", currentAlpha);
		}

		private function arrangeToLeftEdge(leftEdgePos:Number, spaceBetween:Number, clip:DisplayObject):int {
			if (! clip) return leftEdgePos;
			arrangeX(clip, leftEdgePos);
			return leftEdgePos + clip.width + spaceBetween;
		}
		
		private function arrangeYCentered(clip:DisplayObject):void {
			clip.y = margins[0];
            clip.height = height - margins[0] - margins[2];
			clip.scaleX = clip.scaleY;

			Arrange.center(clip, 0, height);
		}
	
		private function getSpaceAfterWidget(widget:DisplayObject):int {
            return SkinClasses.getSpaceAfterWidget(widget, widget == lastOnRight);
		}
		
		private function get lastOnRight():DisplayObject {
			if (_fullScreenButton) return _fullScreenButton;
			if (_volumeSlider) return _volumeSlider;
			if (_muteVolumeButton) return _muteVolumeButton;
			if (_timeView) return _timeView;
			return null;
		}

//		private function setWidgetHeight(widget:DisplayObject):int {
//			if (widget == _timeView)
//				return height/1.7;
//			if (widget == _muteVolumeButton)
//				return height/3;
//			if (widget == _fullScreenButton)
//				return height - _margins[0] - _margins[2] - height/6;
//			return height - _margins[0] - _margins[2];
//		}
	}
}
