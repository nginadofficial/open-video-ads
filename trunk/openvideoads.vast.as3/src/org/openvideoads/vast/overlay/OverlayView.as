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
 package org.openvideoads.vast.overlay {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.RegionController;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.regions.view.RegionView;
	import org.openvideoads.util.DisplayProperties;
	import flash.events.MouseEvent;
	
	/**
	 * @author Paul Schulz
	 */
	public class OverlayView extends RegionView {
		protected var _activeAdSlotKey:int = -1;
		
		public function OverlayView(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties, showCloseButton:Boolean=false) {
			super(controller, regionConfig, displayProperties, showCloseButton);
		}
		
		public function set activeAdSlotKey(activeAdSlotKey:int):void {
			_activeAdSlotKey = activeAdSlotKey;
		}
		
		public function get activeAdSlotKey():int {
			return _activeAdSlotKey;
		}
		
		public function clearActiveAdSlotKey():void {
			_activeAdSlotKey = -1;
		}
	}
}