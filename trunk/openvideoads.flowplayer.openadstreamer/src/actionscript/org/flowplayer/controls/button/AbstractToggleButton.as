/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.button {
	import org.flowplayer.view.AnimationEngine;	
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	
	import org.flowplayer.controls.Config;	
	/**
	 * @author api
	 */
	public class AbstractToggleButton extends AbstractButton {

		protected var _upStateFace:DisplayObjectContainer;
		protected var _downStateFace:DisplayObjectContainer;

		public function AbstractToggleButton(config:Config, animationEngine:AnimationEngine) {
            super(config, animationEngine);
            _downStateFace = createDownStateFace();
			_upStateFace = createUpStateFace();
			addChild(_upStateFace);
            clickListenerEnabled = true;
		}

        override protected function resizeFace():void {
            resize(_downStateFace);
            resize(_upStateFace);
        }

        override protected function get faceWidth():Number {
            return _upStateFace.width;
        }

        override protected function get faceHeight():Number {
            return _upStateFace.height;
        }

        private function resize(disp:DisplayObject):void {
            disp.x = leftEdge;
            disp.y = topEdge;
            disp.height = height - topEdge - bottomEdge;
            disp.scaleX = disp.scaleY;
        }
//
//        override public function set scaleX(value:Number):void {
//            _upStateFace.scaleX = value;
//            _downStateFace.scaleX = value;
//        }
//
//        override public function set scaleY(value:Number):void {
//            _upStateFace.scaleY = value;
//            _downStateFace.scaleY = value;
//        }

		protected override function onMouseOut(event:MouseEvent = null):void {
//            if (event && isParent(event.relatedObject as DisplayObject, this)) return;
            resetDispColor(_upStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
            resetDispColor(_downStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
            hideTooltip();
            showMouseOutState(_upStateFace);
            showMouseOutState(_downStateFace);
        }

        protected override function onMouseOver(event:MouseEvent):void {
			transformDispColor(_upStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
			transformDispColor(_downStateFace.getChildByName(HIGHLIGHT_INSTANCE_NAME));
			showTooltip();
            showMouseOverState(_upStateFace);
            showMouseOverState(_downStateFace);
		}
		
		public function get isDown():Boolean {
			return getChildByName(_downStateFace.name) != null;
		}

		public function set down(down:Boolean):void {
			if (isDown == down) return;
			removeChild(down ? _upStateFace : _downStateFace);
			addChild(down ? _downStateFace : _upStateFace);
            if (down) {
                log.error("downstateface grid " + _downStateFace.scale9Grid);
            } else {
                log.error("upStateFace grid " + _upStateFace.scale9Grid);                
            }
		}

		protected function createUpStateFace():DisplayObjectContainer {
            return null;
		}

		protected function createDownStateFace():DisplayObjectContainer {
            return null;
		}
		
        override protected function createFace():DisplayObjectContainer {
            return null;
        }

	}
}
