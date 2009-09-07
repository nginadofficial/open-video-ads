/*    
 *    Copyright (c) 2009 Open Video Ads - Option 3 Ventures Limited
 *
 *    This file is part of the Open Video Ads Flowplayer Open Ad Streamer.
 *
 *    The Open Ad Streamer is free software: you can redistribute it 
 *    and/or modify it under the terms of the GNU General Public License 
 *    as published by the Free Software Foundation, either version 3 of 
 *    the License, or (at your option) any later version.
 *
 *    The Open Ad Streamer is distributed in the hope that it will be 
 *    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.plugin.flowplayer.streamer {
	import org.flowplayer.model.Clip;
	
	/**
	 * @author Paul Schulz
	 */
	public class ScheduledClip extends Clip {
		protected var _originalDuration:int = 0;
		protected var _marked:Boolean = false;
		
		public function ScheduledClip() {
			super();
		}
		
		public function set originalDuration(duration:int):void {
			_originalDuration = duration;
		}
		
		public function get originalDuration():int {
			return _originalDuration;
		}
		
		public function set marked(marked:Boolean):void {
			_marked = marked;
		}
		
		public function get marked():Boolean {
			return _marked;
		}
	}
}