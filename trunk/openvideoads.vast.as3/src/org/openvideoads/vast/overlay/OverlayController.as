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
	import org.openvideoads.regions.view.RegionView;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.config.groupings.OverlaysConfigGroup;
	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.model.NonLinearFlashAd;
	import org.openvideoads.vast.model.NonLinearVideoAd;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class OverlayController extends RegionController {				
		protected var _vastController:VASTController;
		protected var _mouseTrackerRegion:ClickThroughCallToActionView = null;
		
		public function OverlayController(vastController:VASTController, displayProperties:DisplayProperties, config:OverlaysConfigGroup) {
			_vastController = vastController;
			super(displayProperties, config);
		}

		protected override function newRegion(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties, showCloseButton:Boolean=false):RegionView {
			return new OverlayView(controller, regionConfig, displayProperties, showCloseButton);
		}
		
		protected override function createRegionViews():void {			
			if(_vastController.config.visuallyCueLinearAdClickThrough) {
				doLog("Have created a region to allow the mouse to be tracked over linear ads", Debuggable.DEBUG_REGION_FORMATION);
				_mouseTrackerRegion = 
						new ClickThroughCallToActionView(
								this,
							    new RegionViewConfig(
							         { 
							            id: 'reserved-clickable-click-through', 
						    	        verticalAlign: 0, 
						        	    horizontalAlign: 0, 
						        	    scaleRate: 0.75,
									    width: '100pct',
						            	height: _displayProperties.displayHeight - _displayProperties.bottomMargin,
						            	clickable: true,
						            	showCloseButton: false,
						            	backgroundColor: 'transparent' 
						         	 }
						    	),
						    	_vastController.config.adsConfig.clickSignConfig,
								_displayProperties); 
				_regionViews.push(_mouseTrackerRegion);
				addChild(_mouseTrackerRegion);
				setChildIndex(_mouseTrackerRegion, 0);				
			}
			super.createRegionViews();
		}
		
		public function hideAllOverlays():void {
			hideAllRegions();
		}		
		
		public function enableLinearAdMouseOverRegion(adSlot:AdSlot):void {
			_mouseTrackerRegion.activeAdSlotKey = adSlot.key;
			_mouseTrackerRegion.visible = true;
		}

		public function disableLinearAdMouseOverRegion():void {
			_mouseTrackerRegion.activeAdSlotKey = -1;
			_mouseTrackerRegion.visible = false;
		}
		
		public function displayNonLinearOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {	
			doLog("Attempting to display overlay ad at index " + overlayAdDisplayEvent.adSlotKey, Debuggable.DEBUG_CUEPOINT_EVENTS);
			var overlayAdSlot:AdSlot = _vastController.adSchedule.getSlot(overlayAdDisplayEvent.adSlotKey);

			if(overlayAdSlot != null) {
				var nonLinearVideoAd:NonLinearVideoAd = overlayAdDisplayEvent.ad as NonLinearVideoAd;
				var oid:String = null;
				if(overlayAdSlot.hasPositionDefined()) {
					doLog("Attempting to send HTML to overlay with ID " + overlayAdSlot.position, Debuggable.DEBUG_CUEPOINT_EVENTS);
					oid = overlayAdSlot.position;
				}
				else {
					// we can pull the region ID directly from the regions defined for the ad slot based on the overlay content type
					oid = overlayAdSlot.getRegionIDBasedOnResourceAndCreativeTypes(nonLinearVideoAd.resourceType, nonLinearVideoAd.creativeType);
				}
				var overlay:OverlayView = getRegion(oid) as OverlayView;					
				if(overlay != null) {
					overlay.activeAdSlotKey = overlayAdDisplayEvent.adSlotKey;
					overlay.visible = false;
					if(nonLinearVideoAd.isFlash()) {
						doLog("Displaying Flash overlay content in region " + oid, Debuggable.DEBUG_CUEPOINT_EVENTS);
						overlay.loadDisplayContent((nonLinearVideoAd as NonLinearFlashAd).swfURL, _vastController.config.adsConfig.allowDomains);
					}
					else {
						doLog("Displaying (" + nonLinearVideoAd.contentType() + ") overlay content in region " + oid, Debuggable.DEBUG_CUEPOINT_EVENTS);
						var html:String = null;
						var content:String = overlayAdSlot.getTemplate(nonLinearVideoAd.contentType()).getContent(nonLinearVideoAd);
						if(nonLinearVideoAd.hasClickThroughURL()) {
							html = "<a href=\"" + nonLinearVideoAd.clickThroughs[0].url + "\" target=\"_blank\">";
							html += content;
							html += "</a>";						
						}
						else html = content;
						overlay.html = html;
					}
					overlay.visible = true;														
				}
				else doLog("Could not find an appropriate region to use given oid " + oid, Debuggable.DEBUG_CUEPOINT_EVENTS);	
			}
			else doLog("Cannot show the non linear ad - no adslot at " + overlayAdDisplayEvent.adSlotKey, Debuggable.DEBUG_CUEPOINT_EVENTS);
		}
		
		public function hideNonLinearOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {	
			var overlayAdSlot:AdSlot = _vastController.adSchedule.getSlot(overlayAdDisplayEvent.adSlotKey);			
			var oid:String = null;
			if(overlayAdSlot.hasPositionDefined()) {					
				doLog("Attempting to send HTML to overlay with ID " + overlayAdSlot.position, Debuggable.DEBUG_CUEPOINT_EVENTS);
				oid = overlayAdSlot.position;
			}
			else {
				// we can pull the region ID directly from the regions defined for the ad slot based on the overlay content type
				var nonLinearVideoAd:NonLinearVideoAd = overlayAdDisplayEvent.ad as NonLinearVideoAd;
				oid = overlayAdSlot.getRegionIDBasedOnResourceAndCreativeTypes(nonLinearVideoAd.resourceType, nonLinearVideoAd.creativeType);
			}
			var overlay:OverlayView = getRegion(oid) as OverlayView;					
			doLog("Attempting to hide region with ID " + oid, Debuggable.DEBUG_CUEPOINT_EVENTS);
			if(overlay != null) {
				overlay.visible = false;
				overlay.clearDisplayContent();
				overlay.clearActiveAdSlotKey();
			}				
		}
				
		public function displayNonLinearNonOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {	
			doLog("displayNonLinearNonOverlayAd: NOT IMPLEMENTED");
		}
		
		public function hideNonLinearNonOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			doLog("hideNonLinearNonOverlayAd: NOT IMPLEMENTED");
		}

		public function showAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(adNoticeDisplayEvent != null) {
				if(adNoticeDisplayEvent.notice.region != undefined) {
					var noticeRegion:RegionView = getRegion(adNoticeDisplayEvent.notice.region);
					if(noticeRegion != null) {
						noticeRegion.html = adNoticeDisplayEvent.textToDisplay;
						noticeRegion.visible = true;
					}
					else doLog("Cannot find the region '" + adNoticeDisplayEvent.notice.region + "'");
				}				
			}	
		}
		
		public function hideAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(adNoticeDisplayEvent != null) {
				if(adNoticeDisplayEvent.notice.region != undefined) {
					var noticeRegion:RegionView = getRegion(adNoticeDisplayEvent.notice.region);
					if(noticeRegion != null) noticeRegion.hide();
				}
			}	
		}
		
		// Mouse events
		
		public override function onRegionClicked(regionView:RegionView):void {
			_vastController.onOverlayClicked(regionView as OverlayView);
		}	
		
		public function onLinearAdClickThroughCallToActionViewClicked(adSlotKey:int):void {
			_vastController.onLinearAdClickThroughCallToActionViewClicked(adSlotKey);
		}		
	}
}