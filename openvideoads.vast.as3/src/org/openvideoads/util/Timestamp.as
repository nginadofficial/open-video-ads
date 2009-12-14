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

	/**
	 * @author Paul Schulz
	 */
	public class Timestamp extends Debuggable {
		public function Timestamp() {
		}
		
		static public function secondsToTimestamp(duration:int):String {
			if(duration != 0) {
				var seconds:int;
				var mins:int;
				var hours:int;
				seconds = duration % 60;
				mins = duration / 60;
				if(mins > 59) {
					hours = (duration / 60) / 360;
					mins = duration % 360;
				}
				return hours + ":" + mins + ":" + seconds;
			}
			else return "00:00:00";			
		}
		
		static public function timestampToSeconds(timestamp:String):int {
			var parts:Array = timestamp.split(":");
			if(parts.length == 3) {
				return (parseInt(parts[0]) * 3600) + (parseInt(parts[1]) * 60) + parseInt(parts[2]);
			}
			return 0;
		}
		
		static public function timestampToSecondsString(timestamp:String):String {
			return new String(Timestamp.timestampToSeconds(timestamp));
		}
	}
}