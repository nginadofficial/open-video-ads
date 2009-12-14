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
package org.openvideoads.util {
	import org.openvideoads.base.Debuggable;
	
	import flash.display.DisplayObjectContainer;	

	/**
	 * @author Paul Schulz
	 */
	public class DisplayProperties extends Debuggable { 
		protected var _displayObjectContainer:DisplayObjectContainer;
		protected var _displayWidth:int = 0;
		protected var _displayHeight:int = 0;
		protected var _bottomMargin:int = 0;
		protected var _originalWidth:int = 0;
		protected var _originalHeight:int = 0;
		
		public function DisplayProperties(displayObjectContainer:DisplayObjectContainer=null, displayWidth:int=0, displayHeight:int=0, bottomMargin:int=0, originalWidth:int=-1, originalHeight:int=-1) {
			_displayObjectContainer = displayObjectContainer;
			_displayWidth = displayWidth;
			_displayHeight = displayHeight;
			_bottomMargin = bottomMargin;
			if(_originalWidth == -1) {
				_originalWidth = displayWidth;
			}
			else _originalWidth = originalWidth;
			if(_originalHeight == -1) {
				_originalHeight = displayHeight;
			}
			else _originalHeight = originalHeight;
		}
		
		public function get displayWidth():Number {
			return _displayWidth;
		}
		
		public function get displayHeight():Number {
			return _displayHeight;
		}

        public function set bottomMargin(margin:int):void {
        	_bottomMargin = margin;
        }		
        
		public function get bottomMargin():int {
			return _bottomMargin;
		}
		
		public function get originalHeight():int {
			return _originalHeight;
		}
		
		public function get originalWidth():int {
			return _originalWidth;
		}
		
		public function get scaleX():Number {
			return displayWidth / originalWidth;
		}
		
		public function get scaleY():Number {
			return displayHeight / originalHeight;			
		}
		
		public function get displayObjectContainer():DisplayObjectContainer {
			return _displayObjectContainer;
		}
		
		public function set displayObjectContainer(displayObjectContainer:DisplayObjectContainer):void {
			_displayObjectContainer = displayObjectContainer;
		}
	}
}
