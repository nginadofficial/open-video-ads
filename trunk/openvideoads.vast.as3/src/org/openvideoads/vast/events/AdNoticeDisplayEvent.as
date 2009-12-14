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
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the Lesser GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.vast.events {
	import flash.events.Event;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdNoticeDisplayEvent extends Event {
		public static const DISPLAY:String = "display-notice";
		public static const HIDE:String = "hide-notice";
		
		protected var _notice:Object = null;
		protected var _newText:String = null;
		
		public function AdNoticeDisplayEvent(type:String, notice:Object = null, newText:String=null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			if(notice != null) _notice = notice;
			if(newText != null) _newText = newText;
		}

 		public function hasNotice():Boolean {
 			return (_notice != null);
 		}		
 		
		public function set notice(notice:Object):void {
			_notice = notice;
		}
		
		public function get notice():Object {
			return _notice;
		}
		
		public function get textToDisplay():String {
			if(_newText != null) {
				return _newText;
			}
			else return _notice.text;
		}

		public override function clone():Event {
			return new AdNoticeDisplayEvent(type, _notice, _newText, bubbles, cancelable);
		}
	}
}