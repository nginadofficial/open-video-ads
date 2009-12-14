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
package org.openvideoads.vast.config.groupings {
	import org.openvideoads.util.NetworkResource;
	
	public class RemoteConfigGroup extends NetworkResource {
		protected var _trackerURL:String = "http://tracker.openvideoads.org/log-event.php";
		protected var _debugURL:String = "http://debug.openvideoads.org/log-debug.php";
		
		public function RemoteConfigGroup() {
			loadRemoteConfig();
		}
		
		private function loadRemoteConfig():void {	
			// Not doing this for now
		}
		
		public function get trackerURL():String {
			return _trackerURL;
		}
	}
}