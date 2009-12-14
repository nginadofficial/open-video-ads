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
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.util.DisplayProperties;

	import flash.events.MouseEvent;

	/**
	 * @author Paul Schulz
	 */
	public class TextSign extends RegionView {
		
		public function TextSign(regionConfig:RegionViewConfig, displayProperties:DisplayProperties) {
			super(null, regionConfig, displayProperties, false);
		}

		protected override function onMouseOver(event:MouseEvent):void {
		}

		protected override function onMouseOut(event:MouseEvent):void {
		}

		protected override function onClick(event:MouseEvent):void {
		}
	}
}