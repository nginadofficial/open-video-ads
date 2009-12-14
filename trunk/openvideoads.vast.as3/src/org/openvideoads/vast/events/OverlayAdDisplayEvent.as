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
	import org.openvideoads.vast.overlay.OverlayView;
	import org.openvideoads.vast.model.NonLinearVideoAd;
	
	import flash.events.Event;
	
	/**
	 * @author Paul Schulz
	 */
	public class OverlayAdDisplayEvent extends NonLinearAdDisplayEvent {
		public static const DISPLAY:String = "display-overlay";
		public static const HIDE:String = "hide-overlay";
		public static const DISPLAY_NON_OVERLAY:String = "display-non-overlay";
		public static const HIDE_NON_OVERLAY:String = "hide-non-overlay";
		public static const CLICKED:String = "overlay-clicked";
		public static const CLOSE_CLICKED:String = "overlay-close-clicked";
		
		protected var _adSlotPosition:String = null;
		protected var _adSlotKey:int = -1;
		protected var _adSlotAssociatedStreamIndex:int = -1;
		protected var _overlayView:OverlayView = null;

		public function OverlayAdDisplayEvent(type:String, nonLinearVideoAd:NonLinearVideoAd, adSlotPosition:String, adSlotKey:int, adSlotAssociatedStreamIndex:int,  overlayView:OverlayView=null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, nonLinearVideoAd, bubbles, cancelable);
			_adSlotPosition = adSlotPosition;
			_adSlotKey = adSlotKey;
			_adSlotAssociatedStreamIndex = adSlotAssociatedStreamIndex;
			_overlayView = overlayView;
		}
		
		public function get adSlotPosition():String {
			return _adSlotPosition;
		}
		
		public function get adSlotKey():int {
			return _adSlotKey;
		}
		
		public function get adSlotAssociatedStreamIndex():int {
			return _adSlotAssociatedStreamIndex;
		}
		
		public function get overlayView():OverlayView {
			return _overlayView;
		}
		
		public function get regionID():String {
			return _overlayView.id;			
		}
		
		public override function clone():Event {
			return new OverlayAdDisplayEvent(type, nonLinearVideoAd, _adSlotPosition, _adSlotKey, _adSlotAssociatedStreamIndex, _overlayView, bubbles, cancelable);
		}
	}
}