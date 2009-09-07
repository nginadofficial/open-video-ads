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
	import org.flowplayer.model.DisplayProperties;
	import org.flowplayer.model.Playlist;
	import org.flowplayer.util.Assert;
	import org.flowplayer.util.Log;
	import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.view.Flowplayer;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;		
	/**
	 * @author api
	 */
	public class ControlsAutoHide {

		private var log:Log = new Log(this);
		private var _controlBar:DisplayObject;
		private var _hideTimer:Timer;
		private var _stage:Stage;
		private var _playList:Playlist;
		private var _config:Config;
		private var _player:Flowplayer;
		private var _originalPos:DisplayProperties;
		private var _mouseOver:Boolean = false;
		private var _hwFullScreen:Boolean;

		public function ControlsAutoHide(config:Config, player:Flowplayer, stage:Stage, controlBar:DisplayObject) {
			Assert.notNull(config, "config cannot be null");
			Assert.notNull(player, "player cannot be null");
			Assert.notNull(stage, "stage cannot be null");
			Assert.notNull(controlBar, "controlbar cannot be null");
			_config = config;
			_playList = player.playlist;
			_player = player;
			_stage = stage;
			_controlBar = controlBar;
			if (_config.autoHide != "fullscreen") {
				initTimerAndListeners();
			}
			_stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
		}

		private function get hiddenPos():DisplayProperties {
			_originalPos = DisplayProperties(_player.pluginRegistry.getPlugin("controls")).clone() as DisplayProperties;
			var hiddenPos:DisplayProperties = _originalPos.clone() as DisplayProperties;
			if (isHardwareScaledFullsreen()) {
				_hwFullScreen = true;
				hiddenPos.alpha = 0;
			} else {
				_hwFullScreen = false;
				hiddenPos.top = getControlBarHiddenTopPosition();
			}
			return hiddenPos;			
		}

		private function onFullScreen(event:FullScreenEvent):void {
			if (event.fullScreen) {
				initTimerAndListeners();
				showControlBar();
			} else {
				if (_config.autoHide != 'always') {
					removeTimerAndListeners();
				}
				_controlBar.alpha = 0;
				_player.animationEngine.cancel(_controlBar);
				showControlBar();
			}
		}
		
		private function removeTimerAndListeners():void {
			log.debug("removing autoHide timer");
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(Event.RESIZE, onStageResize);
			if (_hideTimer) {
				_hideTimer.stop();
				_hideTimer = null;
			}
		}

		private function initTimerAndListeners():void {
			createHideTimer();
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.addEventListener(Event.RESIZE, onStageResize);
			_controlBar.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			_controlBar.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		private function onMouseOver(event:MouseEvent):void {
			_mouseOver = true;
		}

		private function onMouseOut(event:MouseEvent):void {
			_mouseOver = false;
		}

		private function onMouseMove(event:MouseEvent):void {
			if (isShowing() && _hideTimer) {
				log.debug("controlbar already showing"); 
				_hideTimer.stop();
				_hideTimer.start();
				return;
			}
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			showControlBar();
		}
		
		private function isShowing():Boolean {
			return _controlBar.alpha > 0 && _controlBar.y < getControlBarHiddenTopPosition();
		}

		private function onStageResize(event:Event):void {
			_hideTimer.stop();
			_hideTimer.start();
		}

		private function createHideTimer():void {
			if (_config.autoHide == "fullscreen" &&  ! isInFullscreen()) return;
			if (! _hideTimer) {
				_hideTimer = new Timer(_config.hideDelay);
				_hideTimer.addEventListener(TimerEvent.TIMER, hideControlBar);
			}
			_hideTimer.start();
		}
		
		private function isInFullscreen():Boolean {
			return _stage.displayState == StageDisplayState.FULL_SCREEN;
		}

		private function hideControlBar(event:TimerEvent = null):void {
			if (! isShowing()) return;
			
			log.debug("mouse pos " + _stage.mouseX + "x" + _stage.mouseY + " mouse on stage " + _mouseOver);
			if (_mouseOver) return;
			_player.animationEngine.animate(_controlBar, hiddenPos, 1000);
			_hideTimer.stop();
		}

		private function showControlBar():void {
			// fetch the current props, they might have changed because of some
			var currentProps:DisplayProperties = _player.pluginRegistry.getPlugin("controls") as DisplayProperties;
			if (!_originalPos) {
				_originalPos = DisplayProperties(_player.pluginRegistry.getPlugin("controls")).clone() as DisplayProperties;
			}
			
			if (_hwFullScreen) {
				currentProps.alpha = _originalPos.alpha;
			} else {
				// restore top or bottom from our pre-hide position
				if (_originalPos.position.top.hasValue()) {
					currentProps.top = _originalPos.position.top;
				}
				if (_originalPos.position.bottom.hasValue()) {
					currentProps.bottom = _originalPos.position.bottom;
				}
			}
			
			_player.animationEngine.animate(_controlBar, currentProps, 400, onShowed);			
		}
		
		private function onShowed():void {
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			if (_hideTimer) {
				_hideTimer.start();
			}
		}

		private function isHardwareScaledFullsreen():Boolean {
			return isInFullscreen() && _stage.fullScreenSourceRect != null;
		}
		
		private function getControlBarHiddenTopPosition():Object {
			if (_stage.displayState == StageDisplayState.FULL_SCREEN) {
				var rect:Rectangle = _stage.fullScreenSourceRect;
				if (rect) {
					return rect.height;
				}
			}
			return _stage.stageHeight;
		}
	}
}
