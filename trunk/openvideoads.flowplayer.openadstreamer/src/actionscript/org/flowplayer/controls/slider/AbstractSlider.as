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
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import org.flowplayer.controls.Config;
    import org.flowplayer.controls.DefaultToolTip;
    import org.flowplayer.controls.NullToolTip;
    import org.flowplayer.controls.ToolTip;
    import org.flowplayer.controls.button.DraggerButton;
import org.flowplayer.util.GraphicsUtil;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.AnimationEngine;

    /**
	 * @author api
	 */
	public class AbstractSlider extends AbstractSprite {
		public static const DRAG_EVENT:String = "onDrag";
		
		protected var _dragger:DraggerButton;
		private var _dragTimer:Timer;
		private var _previousDragEventPos:Number;
		protected var _config:Config;
		private var _animationEngine:AnimationEngine;
		private var _currentPos:Number;
		private var _tooltip:ToolTip;
		private var _tooltipTextFunc:Function;
        private var _controlbar:DisplayObject;

        public function AbstractSlider(config:Config, animationEngine:AnimationEngine, controlbar:DisplayObject) {
            _config = config;
            _animationEngine = animationEngine;
            _controlbar = controlbar;
            _dragTimer = new Timer(50);
            createDragger();
            toggleTooltip();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }


		private function toggleTooltip():void {
			if (isToolTipEnabled()) {
				if (_tooltip && _tooltip is DefaultToolTip) return;
				log.debug("enabling tooltip");
				_tooltip = new DefaultToolTip(_config, _animationEngine);
			} else {
				log.debug("tooltip disabled");
				_tooltip = new NullToolTip();
			}
		}
		
		protected function isToolTipEnabled():Boolean {
			return false;
		}

		public function set enabled(value:Boolean) :void {
			log.debug("setting enabled to " + value);
			_dragTimer.addEventListener(TimerEvent.TIMER, onDrag);
			var func:String = value ? "addEventListener" : "removeEventListener";

			this[func](MouseEvent.MOUSE_UP, onMouseUp);
			_dragger[func](MouseEvent.MOUSE_DOWN, onMouseDown);
			_dragger[func](MouseEvent.MOUSE_UP, onMouseUp);
			stage[func](MouseEvent.MOUSE_UP, onMouseUpStage);
			toggleClickListeners(value);

			alpha = value ? 1 : 0.5;
			_dragger.buttonMode = value;
		}
		
		private function onAddedToStage(event:Event):void {
			enabled = true;
		}

		private function toggleClickListeners(add:Boolean):void {
			var targets:Array = getClickTargets(add);
			log.debug("click targets", targets);
			for (var i:Number = 0; i < targets.length; i++) {
				if (add) {
					EventDispatcher(targets[i]).addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				} else {
					EventDispatcher(targets[i]).removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				if (targets[i].hasOwnProperty("buttonMode")) {
					targets[i]["buttonMode"] = add;
				}
			}
		}
		
		protected function getClickTargets(enabled:Boolean):Array {
			return [this];
		}

		protected function createDragger():void {
 			_dragger = new DraggerButton(_config, _animationEngine);
			_dragger.buttonMode = true;
			addChild(_dragger);
		}
		
		private function onMouseUpStage(event:MouseEvent):void {
			if (_dragTimer.running) {
				onMouseUp();
			}
		}
		
		private function onMouseUp(event:MouseEvent = null):void {
			log.debug("onMouseUp");
			_tooltip.hide();
			if (event && event.target != this) return;
			if (! canDragTo(mouseX) && _dragger.x > 0) return;
			_dragTimer.stop();
			onDrag();
			updateCurrentPosFromDragger();
			
			if (! dispatchOnDrag) {
				dispatchDragEvent();
			}
		}
		protected function canDragTo(xPos:Number):Boolean {
			return true;
		}

		private function updateCurrentPosFromDragger():void {
			_currentPos = (_dragger.x / (width - _dragger.width)) * 100;
		}

		protected final function get isDragging():Boolean {
			return _dragTimer.running;
		}

		protected function onMouseDown(event:MouseEvent):void {
			if (! event.target == this) return;
			_dragTimer.start();
			if (_tooltipTextFunc != null) { 
				_tooltip.show(_dragger, _tooltipTextFunc(value) as String, true);
			}
		}

		private function onDrag(event:TimerEvent = null):void {
			var pos:Number = mouseX - _dragger.width / 2;
			if (pos < 0)
				pos = 0;
			if (pos > maxDrag) {
				pos = maxDrag;
			}
			
			_dragger.x = pos;
			_tooltip.text = _tooltipTextFunc((_dragger.x / (width - _dragger.width)) * 100) as String;

			// do not dispatch several times from almost the same pos
			if (Math.abs(_previousDragEventPos - _dragger.x) < 1) return;
			_previousDragEventPos = _dragger.x;
			
			if (dispatchOnDrag) {
				updateCurrentPosFromDragger();
				dispatchDragEvent();
			}
		}

		private function dispatchDragEvent():void {
			log.debug("dispatching drag event");
			onDispatchDrag();
			dispatchEvent(new Event(DRAG_EVENT));
		}
		
		protected function get dispatchOnDrag():Boolean {
			return true;
		}

		protected function onDispatchDrag():void {
			// can be overridden in subclasses
		}

		protected function get maxDrag():Number {
			return width - _dragger.width;
		}
		
		/**
		 * Gets the curent value of the slider.
		 * @return the value that is between 0 and 100
		 */
		public function get value():Number {
			return _currentPos;
		}

		/**
		 * Sets the slider's current value.
		 * @param value the value between 0 and 100
		 */
		public final function set value(value:Number):void {
			if (value > 100) {
				value = 100;
			}
			_currentPos = value;
			if (_dragTimer && _dragTimer.running || ! allowSetValue) {
				log.debug("drag in progress");
				return;
			}
			var pos:Number = value/100 * (width - _dragger.width);
			_dragger.x = pos;
			onSetValue();
		}
		
		protected function onSetValue():void {
		}

		protected function get allowSetValue():Boolean {
			// can be overridden in sucbclasses
			return true;
		}

		protected override function onResize():void {
			_dragger.height = height;
            _dragger.scaleX = _dragger.scaleY;
            drawBackground();
        }

		private function drawBackground():void {
			graphics.clear();
			graphics.beginFill(sliderColor, 1);
			graphics.drawRoundRect(0, height/2 - barHeight/2, width, barHeight, barCornerRadius, barCornerRadius);
            graphics.endFill();
                                                                                                                     
            if (sliderGradient) {
                GraphicsUtil.addGradient(this, 0, sliderGradient, barCornerRadius);
            }
        }

        protected function get barCornerRadius():Number {
            return barHeight/1.5;
        }

        protected function get sliderGradient():Array {
            return null;
        }

        protected function get sliderColor():Number {
            return 0x000000;
        }

        protected function get barHeight():Number {
            return height;

        }

		public function redraw(config:Config):void {
			_config = config;
			drawBackground();
			toggleTooltip();
			_tooltip.redraw(config);
		}

		public function set tooltipTextFunc(tooltipTextFunc:Function):void {
			_tooltipTextFunc=tooltipTextFunc;
		}
	}
}
