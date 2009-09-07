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
 package org.openvideoads.vast.overlay {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.RegionController;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.regions.view.TextSign;
	import org.openvideoads.vast.config.groupings.ClickSignConfig;
	import org.openvideoads.util.DisplayProperties;
	
//	import fl.transitions.*;
//	import fl.transitions.easing.*;

	import flash.events.MouseEvent;	
	
	/**
	 * @author Paul Schulz
	 */
	public class ClickThroughCallToActionView extends OverlayView {
		protected var _callToActionSign:TextSign;
		protected var _timeout:Number = 3000;
		
		
		public function ClickThroughCallToActionView(controller:RegionController, regionConfig:RegionViewConfig, clickSignConfig:ClickSignConfig, displayProperties:DisplayProperties) {
			super(controller, regionConfig, displayProperties, false);
			_callToActionSign = new TextSign(clickSignConfig, displayProperties);
            _callToActionSign.visible = false;
			addChild(_callToActionSign);
			setChildIndex(_callToActionSign, 0);
		}

		protected override function onMouseOver(event:MouseEvent):void {
			doLog("ClickableMouseOverOverlayView: MOUSE OVER!", Debuggable.DEBUG_MOUSE_EVENTS);
			_callToActionSign.visible = true;
		}

		protected override function onMouseOut(event:MouseEvent):void {
			doLog("ClickableMouseOverOverlayView: MOUSE OUT!", Debuggable.DEBUG_MOUSE_EVENTS);
			_callToActionSign.visible = false;
		}

		protected override function onClick(event:MouseEvent):void {
			doLog("ClickableMouseOverOverlayView: ON CLICK", Debuggable.DEBUG_MOUSE_EVENTS);
			hide();
			(_controller as OverlayController).onLinearAdClickThroughCallToActionViewClicked(activeAdSlotKey);
		}
	}
}