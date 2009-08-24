/*    
 *    Copyright (c) 2009 Open Video Ads - Option 3 Ventures Limited
 *
 *    This file is part of the Open Video Ads VAST framework.
 *
 *    The VAST framework is free software: you can redistribute it 
 *    and/or modify it under the terms of the GNU General Public License 
 *    as published by the Free Software Foundation, either version 3 of 
 *    the License, or (at your option) any later version.
 *
 *    The VAST framework is distributed in the hope that it will be 
 *    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.vast.config.groupings {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdNoticeConfig extends Debuggable {
		protected var _show:Boolean = true;
		protected var _message:String = "<p class='smalltext' align='right'>This advertisement runs for _seconds_ seconds</p>";
		protected var _region:String = "reserved-system-message"; 
		
		public function AdNoticeConfig() {
		}
		
		public function set show(show:Boolean):void {
			_show = show;
		}
		
		public function get show():Boolean {
			return _show;
		}
		
		public function set message(message:String):void {
			_message = message;
		}
		
		public function get message():String {
			return _message;
		}
		
		public function set region(region:String):void {
			_region = region;
		}
		
		public function get region():String {
			return _region;
		}
	}
}