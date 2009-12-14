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
	import org.openvideoads.vast.model.NonLinearVideoAd;
	
	import flash.events.Event;
	
	/**
	 * @author Paul Schulz
	 */
	public class NonLinearAdDisplayEvent extends Event {
		protected var _nonLinearVideoAd:NonLinearVideoAd = null;
		
		public function NonLinearAdDisplayEvent(type:String, nonLinearVideoAd:NonLinearVideoAd, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_nonLinearVideoAd = nonLinearVideoAd;
		}
		
		public function set nonLinearVideoAd(nonLinearAd:NonLinearVideoAd):void {
			_nonLinearVideoAd = nonLinearVideoAd;
		}
		
		public function get ad():NonLinearVideoAd {
			return this.nonLinearVideoAd;
		}
		
		public function get nonLinearVideoAd():NonLinearVideoAd {
			return _nonLinearVideoAd;
		}
	}
}