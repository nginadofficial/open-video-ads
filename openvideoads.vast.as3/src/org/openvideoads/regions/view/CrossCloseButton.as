/*    
 *    Copyright (c) 2009 Open Video Ads - Option 3 Ventures Limited
 *
 *    This file is part of the Open Video Ads VAST framework.
 *
 *    The VAST framework is free software: you can redistribute it 
 *    and/or modify it under the terms of the Lesser GNU General Public License 
 *    as published by the Free Software Foundation, either version 3 of 
 *    the License, or (at your option) any later version.
 *
 *    The VAST framework is distributed in the hope that it will be 
 *    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    Lesser GNU General Public License for more details.
 *
 *    You should have received a copy of the Lesser GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.regions.view {
	import org.openvideoads.base.Debuggable;
    import org.openvideoads.util.GraphicsUtils;
    	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.BlendMode;

	/**
	 * @author Paul Schulz
	 */
	public class CrossCloseButton extends Sprite {
		private var _id:String;
		private var _parentView:RegionView=null;
		
		public function CrossCloseButton(id:String=null, parentView:RegionView=null) {
			_id = id;
			_parentView = parentView;
            drawButton();
            addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			addEventListener(MouseEvent.CLICK, onMouseClick);
            buttonMode = true;
            this.mouseChildren = true;
		}
          
        private function drawButton():void {
            this.graphics.clear();
			this.graphics.beginFill(0,0);
			this.graphics.drawCircle(0,0,10);
			this.graphics.endFill();
			var _text:TextField = GraphicsUtils.createFlashTextField(false, null, 14, true);
			_text.blendMode = BlendMode.LAYER;
			_text.autoSize = TextFieldAutoSize.CENTER;
			_text.wordWrap = false;
			_text.multiline = false;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.condenseWhite = true;
			_text.mouseEnabled = false;
            _text.text = "+";
            _text.x = -9;
            _text.y = -10;
            _text.selectable = false;
            _text.mouseEnabled = true;
//			_text.rotation = 90;
            this.addChild(_text)
        }
 
		private function onMouseOut(event:MouseEvent):void {
			doLog("CROSS button out", Debuggable.DEBUG_MOUSE_EVENTS);
			this.alpha = 0.7;
		}

		private function onMouseOver(event:MouseEvent):void {
			doLog("CROSS button over", Debuggable.DEBUG_MOUSE_EVENTS);
			this.alpha = 1;
		}

		private function onMouseClick(event:MouseEvent):void {
			doLog("CROSS button clicked to close", Debuggable.DEBUG_MOUSE_EVENTS);
			event.stopPropagation();
			if(_parentView != null) _parentView.onCloseClicked();
		}
		
		// DEBUG METHODS
		
		protected function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		protected function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
		
		protected function doLogAndTrace(data:String, o:Object, level:int=1):void {
			Debuggable.getInstance().doLogAndTrace(data, o, level);
		}		
	}
}