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
package org.openvideoads.regions.events {
	import org.openvideoads.regions.view.RegionView;
	
	import flash.events.Event;

	/**
	 * @author Paul Schulz
	 */
	public class RegionMouseEvent extends Event {
		public static const REGION_CLICKED:String = "region-clicked";

		protected var _regionView:RegionView;
		
		public function RegionMouseEvent(type:String, regionView:RegionView, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_regionView = regionView;
		}
		
		public function get regionView():RegionView {
			return _regionView;
		}
		
		public function get regionID():String {
			return _regionView.id;
		}
		
		public override function clone():Event {
			return new RegionMouseEvent(type, regionView, bubbles, cancelable);
		}
	}
}