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
//						            	width: 250,
//						            	height: 40, 
//						            	opacity: 0.2,
//						            	borderRadius: 20,
//						            	backgroundColor: '#000000'
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
			doLog("Attempting to display overlay ad " + overlayAdDisplayEvent.adSlotPosition, Debuggable.DEBUG_CUEPOINT_EVENTS);
			var nonLinearVideoAd:NonLinearVideoAd = overlayAdDisplayEvent.ad as NonLinearVideoAd;

			if(overlayAdDisplayEvent.adSlotPosition != null) {
				var oid:String = overlayAdDisplayEvent.adSlotPosition;
				doLog("Attempting to send HTML to overlay with ID " + oid, Debuggable.DEBUG_CUEPOINT_EVENTS);
				var overlay:OverlayView = getRegionMatchingContentType(oid, nonLinearVideoAd.resourceType) as OverlayView;
				var html:String = null;
				if(nonLinearVideoAd.isHtml()) {
					if(nonLinearVideoAd.hasAccompanyingVideoAd()) {
						html = "<p align='left'>" + nonLinearVideoAd.codeBlock + "</p>";
					}
					else if(nonLinearVideoAd.hasClickThroughURL()) {
						html = "<a href=\"" + nonLinearVideoAd.clickThroughs[0].url + "\" target=\"_blank\">" + nonLinearVideoAd.codeBlock + "</a>";
					}
					else html = nonLinearVideoAd.codeBlock;
				}
				else if(nonLinearVideoAd.isImage()) {
					if(nonLinearVideoAd.hasAccompanyingVideoAd()) {
						html = "<img src=\"" + nonLinearVideoAd.url.url + "\" border=\"0\"/>";
					}
					else if(nonLinearVideoAd.hasClickThroughURL()) {
						html = "<a href=\"" + nonLinearVideoAd.clickThroughs[0].url + "\" target=\"_blank\">" + nonLinearVideoAd.codeBlock + "</a>";
						html += "<img src=\"" + nonLinearVideoAd.url.url + "\" border=\"0\"/>";
						html += "</a>";
					}
					else html = "<img src=\"" + nonLinearVideoAd.url.url + "\" border=\"0\"/>";
				}
				else {
					doLog("Could not work out how to place content into region " + oid + "", Debuggable.DEBUG_CUEPOINT_EVENTS);	
				}
				if(html != null) {
					if(overlay != null) {
						overlay.visible = false;
						overlay.html = html;
						overlay.activeAdSlotKey = overlayAdDisplayEvent.adSlotKey;
						overlay.visible = true;			
					}	
					else doLog("Could not find a region with the id - " + oid);			
				}
			}
			else doLog("Cannot show the non linear ad - no regionID specified!", Debuggable.DEBUG_CUEPOINT_EVENTS);
		}
		
		public function hideNonLinearOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {	
			if(overlayAdDisplayEvent.adSlotPosition != null) {
				var oid:String = overlayAdDisplayEvent.adSlotPosition;
				doLog("Attempting to hide region with ID " + oid, Debuggable.DEBUG_CUEPOINT_EVENTS);
				var overlay:OverlayView = getRegion(oid) as OverlayView;
				if(overlay != null) {
					overlay.visible = false;
					overlay.clearActiveAdSlotKey();
				}				
			}
			else doLog("Cannot hide the non linear ad - no regionID specified!", Debuggable.DEBUG_DATA_ERROR);
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