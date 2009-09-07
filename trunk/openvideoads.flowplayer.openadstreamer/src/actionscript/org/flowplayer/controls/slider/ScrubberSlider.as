/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.slider {
	import org.flowplayer.controls.Config;
	import org.flowplayer.controls.slider.AbstractSlider;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Playlist;
	import org.flowplayer.util.GraphicsUtil;
	import org.flowplayer.view.AnimationEngine;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;	

	/**
	 * @author api
	 */
	public class ScrubberSlider extends AbstractSlider {
		
		private var _bufferEnd:Number;
		private var _bufferBar:Sprite;
		private var _allowRandomSeek:Boolean;
		private var _seekInProgress:Boolean;
		private var _progressBar:Sprite;
		private var _bufferStart:Number;
		private var _enabled:Boolean = true;

		public function ScrubberSlider(config:Config, animationEngine:AnimationEngine, controlbar:DisplayObject) {
			super(config, animationEngine, controlbar);
			createBars();
		}

		public function set playlist(playlist:Playlist):void {
			playlist.onStart(onSeekDone);
            playlist.onBeforeSeek(onBeforeSeek);
			playlist.onSeek(onSeekDone);
		}
		
		override protected function get dispatchOnDrag():Boolean {
			return false;
		}

		override protected function getClickTargets(enabled:Boolean):Array {
			_enabled = enabled;
			var targets:Array = [_bufferBar, _progressBar];
			if (! enabled || _allowRandomSeek) {
				targets.push(this);
			}
			return targets;
		}
		
		override protected function isToolTipEnabled():Boolean {
			return _config.tooltips.scrubber;
		}

		private function drawBufferBar(leftEdge:Number, rightEdge:Number):void {
			drawBar(_bufferBar, _config.style.bufferColor, _config.style.bufferGradient, leftEdge, rightEdge);
		}

		private function createBars():void {
			_progressBar = new Sprite();
			addChild(_progressBar);
			
			_bufferBar = new Sprite();
			addChild(_bufferBar);
			swapChildren(_dragger, _bufferBar);
		}

		private function drawBar(bar:Sprite, color:Number, gradientAlphas:Array, leftEdge:Number, rightEdge:Number):void {
			bar.graphics.clear();
			if (leftEdge > rightEdge) return;
			bar.scaleX = 1;
			bar.graphics.beginFill(color);
			bar.graphics.drawRoundRect(leftEdge, height/2 - barHeight/2, rightEdge - leftEdge, barHeight, barCornerRadius, barCornerRadius);
			bar.graphics.endFill();
			
			if (gradientAlphas) {
				GraphicsUtil.addGradient(bar, 0, gradientAlphas, height/1.5, leftEdge);
			} else {
				GraphicsUtil.removeGradient(bar);
			}
		}

		override protected function onSetValue():void {
			if (_seekInProgress) return;
			drawProgressBar(_bufferStart * width);
		}

		private function drawProgressBar(leftEdge:Number):void {
			drawBar(_progressBar, _config.style.progressColor, _config.style.progressGradient, leftEdge || 0, value/100 * (width - _dragger.width) + _dragger.width/2);
		}

		public function set allowRandomSeek(value:Boolean):void {
			_allowRandomSeek = value;
			if (_enabled) {
				if (value) {
					addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				} else {
					removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				buttonMode = _allowRandomSeek;
			}
		}

		override protected function get maxDrag():Number {
			if (_allowRandomSeek) return width;
			return _bufferEnd * width;
		}

		public function setBufferRange(start:Number, end:Number):void {
			_bufferStart = start;
			_bufferEnd = Math.min(end, 1);
			drawBars();
		}
		
		override protected function canDragTo(xPos:Number):Boolean {
			if (_allowRandomSeek) return true;
			return xPos < _bufferBar.x + _bufferBar.width;
		}

		override protected function onDispatchDrag():void {
			drawBars();
			_seekInProgress = true;
		}
		
		private function drawBars():void {
			if (_seekInProgress) return;
			if (_dragger.x + _dragger.width / 2 > _bufferStart * width) {
				drawBufferBar(_bufferStart * width, _bufferEnd * width);
				drawProgressBar(_bufferStart * width);
			} else {
				_bufferBar.graphics.clear();
				GraphicsUtil.removeGradient(_bufferBar);
				_progressBar.graphics.clear();
				GraphicsUtil.removeGradient(_progressBar);
			}
		}

        private function onBeforeSeek(event:ClipEvent):void {
            log.debug("onBeforeSeek");
            _seekInProgress = ! event.isDefaultPrevented();
        }

		private function onSeekDone(event:ClipEvent):void {
			log.debug("seek done!");
			_seekInProgress = false;
		}

		override protected function get allowSetValue():Boolean {
			return ! _seekInProgress;
		}
		
		override public function redraw(config:Config):void {
			super.redraw(config);
			drawBar(_progressBar, _config.style.progressColor, _config.style.progressGradient, _progressBar.x, _progressBar.width);
			drawBar(_bufferBar, _config.style.bufferColor, _config.style.bufferGradient, _bufferBar.x, _bufferBar.width);
		}

        override protected function get barHeight():Number {
            return Math.ceil(height * _config.style.scrubberBarHeightRatio);

        }

        override protected function get sliderGradient():Array {
            return _config.style.sliderGradient;
        }

        override protected function get sliderColor():Number {
            return _config.style.sliderColor;
        }

        override protected function get barCornerRadius():Number {
            if (isNaN(_config.style.scrubberBorderRadius)) return super.barCornerRadius;
            return _config.style.scrubberBorderRadius;
        }
	}
}
