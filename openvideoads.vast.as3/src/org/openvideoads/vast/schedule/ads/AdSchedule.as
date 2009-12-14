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
package org.openvideoads.vast.schedule.ads {
	import flash.events.Event;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.model.TemplateLoadListener;
	import org.openvideoads.vast.model.VideoAdServingTemplate;
	import org.openvideoads.vast.schedule.StreamConfig;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.server.AdServerRequestProcessor;
	import org.openvideoads.vast.tracking.TimeEvent;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdSchedule extends Debuggable implements TemplateLoadListener {
		protected var _adSlots:Array = new Array(); 
		protected var _vastController:VASTController = null;
		protected var _lastTrackedStreamIndex:int = -1;
		protected var _adServerRequestProcessor:AdServerRequestProcessor = null;
		protected var _templateLoadListener:TemplateLoadListener = null;
		
		public function AdSchedule(vastController:VASTController, relatedStreamSequence:StreamSequence, config:Config=null, vastData:VideoAdServingTemplate=null) {
			_vastController = vastController;
			if(config != null) {
//				build(config, relatedStreamSequence, -1, calculateShowStreamCount(config.streams), true);
				build(config, relatedStreamSequence, -1, true);
				if(vastData) mapVASTDataToAdSlots(vastData);
			}
		}
		
		protected function calculateShowStreamCount(streams:Array):int {
			// exclude everything that isn't a stream
			var count:int = 0;
			for(var i:int=0; i < streams.length; i++) {
				if(streams[i].isStream()) ++count;
			}
			return count;
		}
		
		public function get adSlots():Array {
			return _adSlots;
		}
		
		public function set adSlots(adSlots:Array):void {
			_adSlots = adSlots;
		}
		
		public function addAdSlot(adSlot:AdSlot):void {
			_adSlots.push(adSlot);
		}
		
		public function hasAdSlots():Boolean {
			return (_adSlots && _adSlots.length > 0);
		}
		
		public function haveAdSlotsToSchedule():Boolean {
			return (_adSlots.length > 0);
		}
		
		public function hasLinearAds():Boolean {
			if(haveAdSlotsToSchedule()) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					if(_adSlots[i].isLinear()) {
						return true;
					}
				}
			}	
			return false;	
		}

		public function hasSlot(index:int):Boolean {
			return (index < length);	
		}
		
		public function getSlot(index:int):AdSlot {
			if(hasSlot(index)) {
				return _adSlots[index];
			}
			return null; 
		}
		
		public function setAdSlotIDAtIndex(index:int, id:String):void {
			if(hasAdSlots() && index < _adSlots.length) {
				_adSlots[index].id = id;
			}
		}
		
		public function get length():int {
			return _adSlots.length;
		}
		
		private function getNoticeConfig(defaultNoticeConfig:Object, overridingConfig:Object):Object {
			var result:Object = new Object();
			if(defaultNoticeConfig != null) {
				if(defaultNoticeConfig.show != undefined) result.show = defaultNoticeConfig.show;
				if(defaultNoticeConfig.region != undefined) result.region = defaultNoticeConfig.region;
				if(defaultNoticeConfig.message != undefined) result.message = defaultNoticeConfig.message;
			}
			if(overridingConfig != null) {
				if(overridingConfig.show != undefined) result.show = overridingConfig.show;
				if(overridingConfig.region != undefined) result.region = overridingConfig.region;
				if(overridingConfig.message != undefined) result.message = overridingConfig.message;
			}
			return result;
		}
		
		private function getDisableControls(defaultSetting:*, overridingSetting:*):Boolean {
			if(overridingSetting != undefined) {
				return overridingSetting;
			}
			else if(defaultSetting != undefined) {
				return defaultSetting;
			}
			return false;
		}
		
		// Forced Impression Firing for blank VAST Ad Responses
		public function processImpressionsToForceFire():void {
			if(haveAdSlotsToSchedule()) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					if(_adSlots[i].isEmpty()) {
						_adSlots[i].processForcedImpression();
					}
				}
			}	
		}	

		
		private function checkApplicability(adSpot:Object, currentPart:int, excludePopupPosition:Boolean=false, streamCount:int=1, relatedStream:StreamConfig=null):Boolean {
			if(relatedStream != null) {
				if(!relatedStream.isStream()) return false;
			}
			if(adSpot.applyToParts != undefined) {
				if(adSpot.applyToParts is String) {
					if(adSpot.applyToParts.toUpperCase() == "LAST") {
						return ((currentPart + 1) == streamCount);
					}
					else return false;
				}
				else if(adSpot.applyToParts is Array) {
					return (adSpot.applyToParts.indexOf(currentPart) > -1);
				}
				else return false;
			}
			else return true;
		}
		
		public function createAdSpotID(overridingID:String, position:String, uniqueTag:int):String {
			if(overridingID != null) {
				return overridingID;
			}	
			else {
				if(position == null) {
					return "overlay" + uniqueTag;					
				}
				return position + uniqueTag;
			}
		}
		
		//-----------------------------------------------------------------------------------------------------------------
		
		public function loadAdsFromAdServers(templateLoadListener:TemplateLoadListener):void {
			_templateLoadListener = templateLoadListener;
			_adServerRequestProcessor = new AdServerRequestProcessor(this, _adSlots);
			_adServerRequestProcessor.start();			
		}
		
		public function onTemplateLoaded(template:VideoAdServingTemplate):void {
			doLog("AdSchedule: notified that template has been loaded", Debuggable.DEBUG_VAST_TEMPLATE)
			if(_templateLoadListener) _templateLoadListener.onTemplateLoaded(template);
		}
		
		public function onTemplateLoadError(event:Event):void {
			doLog("AdSchedule: FAILURE loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL);
			if(_templateLoadListener) _templateLoadListener.onTemplateLoadError(event);
		}
		
		//-----------------------------------------------------------------------------------------------------------------
				
		public function build(config:Config, relatedStreamSequence:StreamSequence, maxSpots:int=-1, excludePopupPosition:Boolean=false):void {
			if(config.adSchedule) {
				var numberOfStreams:int = ((config.streams.length == 0) ? 1 : config.streams.length);
				doLog("Building the ad schedule - " + config.adSchedule.length + " ad slots defined, stream count is " + config.streams.length + ", maxspots " + maxSpots, Debuggable.DEBUG_CONFIG);
				for(var j:int = 0; j < numberOfStreams; j++) {
					if(maxSpots == -1) maxSpots = config.adSchedule.length;
					for(var i:int = 0; i < config.adSchedule.length && i <= maxSpots; i++) {
						var relatedStream:StreamConfig = ((j < config.streams.length) ? config.streams[j] : null);
						if(checkApplicability(config.adSchedule[i], j, excludePopupPosition, numberOfStreams, relatedStream)) {
							var adSpot:Object = config.adSchedule[i];
							var originalAdSlot:AdSlot;
							if(adSpot.zone && adSpot.zone.toUpperCase() == "STATIC") {
								originalAdSlot = new StaticAdSlot(relatedStreamSequence,
								                         this,
								                         _vastController,
														 _adSlots.length,
														 j,
														 createAdSpotID(adSpot.id, adSpot.position, i),
														 adSpot.zone,
													  	 adSpot.position,
													  	 ((adSpot.applyToParts == undefined) ? null : adSpot.applyToParts),
														 adSpot.duration, 
														 ((adSpot.startTime == undefined) ? "00:00:00" : adSpot.startTime),
														 getNoticeConfig(config.notice, adSpot.notice),
														 getDisableControls(config.disableControls, adSpot.disableControls),
														 adSpot.width,
														 adSpot.height,
														 new Array(),	
														 ((adSpot.companionDivIDs == undefined) ? 
													 			config.companionDivIDs : 
										  					    adSpot.companionDivIDs),
											  	 		 ((adSpot.startPoint == undefined) ? null : adSpot.startPoint),
											  	 		 ((adSpot.html == undefined) ? null : adSpot.html));
							}
							else {
								doLog("Creating new ad slot: " + createAdSpotID(adSpot.id, adSpot.position, i) + " tied to stream index " + j, Debuggable.DEBUG_CONFIG);
								originalAdSlot = new AdSlot(relatedStreamSequence,
								                     this,
								                     _vastController,
													 _adSlots.length,
													 j,
												     createAdSpotID(adSpot.id, adSpot.position, i),
													 adSpot.zone,
												  	 adSpot.position,
												  	 ((adSpot.applyToParts == undefined) ? null : adSpot.applyToParts),
													 adSpot.duration, 
													 adSpot.duration,
													 ((adSpot.startTime == undefined) ? "00:00:00" : adSpot.startTime),
													 getNoticeConfig(config.notice, adSpot.notice),
													 getDisableControls(config.disableControls, adSpot.disableControls),	
													 ((adSpot.width != undefined) ? adSpot.width : -1),
													 ((adSpot.height != undefined) ? adSpot.height : -1),
													 new Array(), 	
													 ((adSpot.companionDivIDs == undefined) ? 
												 			config.companionDivIDs : 
									  					    adSpot.companionDivIDs),
										  	 		 ((adSpot.streamType != undefined) ? adSpot.streamType : config.streamType),
										  	 		 ((adSpot.deliveryType != undefined) ? adSpot.deliveryType : config.deliveryType),
										  	 		 ((adSpot.bitrate != undefined) ? adSpot.bitrate : config.bitrate),
										  	 		 ((adSpot.playOnce != undefined) ? adSpot.playOnce : config.playOnce),
										  	 		 config.metaData,
										  	 		 ((adSpot.autoPlay != undefined) ? adSpot.autoPlay : config.autoPlay),
										  	 		 ((adSpot.regions != undefined) ? adSpot.regions : null),
										  	 		 ((adSpot.templates != undefined) ? adSpot.templates : null),
										  	 		 ((adSpot.player != undefined) ? adSpot.player : config.adsConfig.player),
										  	 		 config.clickSignEnabled,
										  	 		 ((adSpot.server != undefined) ? adSpot.server : null));
							}
							var repeatCount:int = ((adSpot.repeat == undefined) ? 1 : adSpot.repeat);
							if(repeatCount > 1) {
								var adSlot:AdSlot = originalAdSlot;
								for(var r:int=0; r < repeatCount; r++) {
									addAdSlot(adSlot);
									adSlot = adSlot.clone();
									adSlot.key = _adSlots.length;
								}								
							}
							else addAdSlot(originalAdSlot);
						}
					}		
				}
				doLog("Ad schedule constructed - " + _adSlots.length + " ad positions created and slotted", Debuggable.DEBUG_CONFIG);
			}
		}

        public function fireNonLinearSchedulingEvents():void {
			for(var i:int = 0; i < _adSlots.length; i++) {
				if(!_adSlots[i].isLinear() && _adSlots[i].hasNonLinearAds()) {
					if(_vastController != null) _vastController.onScheduleNonLinear(_adSlots[i]);			
				}
   			}
        }
        
		public function addNonLinearAdTrackingPoints(zeroStartTime:Boolean=true, overrideSetFlag:Boolean=false):void {
			doLogAndTrace("Setting up non-linear cuepoints", _adSlots, Debuggable.DEBUG_CUEPOINT_FORMATION);
			if(hasAdSlots()) {
				for(var i:int; i < _adSlots.length; i++) {
					if(_adSlots[i].isNonLinear()) {
						_adSlots[i].addNonLinearAdTrackingPoints(i, zeroStartTime, true, overrideSetFlag); 							
					}
				}
			}
		}
		
		public function getAdIds():Array {
			var result:Array = new Array();
			for(var i:int = 0; i < _adSlots.length; i++) {
				if(_adSlots[i].id && _adSlots[i].id != "popup") {
					result.push(_adSlots[i].id + "-" + _adSlots[i].associatedStreamIndex);
				}
			}
			return result;
		}
		
		public function get zones():Array {
			var zones:Array = new Array();
			for(var i:int = 0; i < _adSlots.length; i++) {
				if(_adSlots[i].id && _adSlots[i].id != "popup") {
					var zone:Object = new Object();
					zone.id = _adSlots[i].id + "-" + _adSlots[i].associatedStreamIndex;
					zone.zone = _adSlots[i].zone;
					zones.push(zone);
				}
			}		
			return zones;	
		}
		
		public function mapVASTDataToAdSlots(vast:VideoAdServingTemplate):void {
			if(hasAdSlots()) {
				for(var i:int = 0; i < adSlots.length; i++) {
					if(_adSlots[i].id != null) { 
						_adSlots[i].videoAd = vast.getVideoAdWithID(_adSlots[i].id + "-" + _adSlots[i].associatedStreamIndex);
					}
				}
			}
		}
			
		public function mapVastDataForAdToAllAdSlots(vast:VideoAdServingTemplate, adId:String):void {
			if(hasAdSlots()) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					_adSlots[i].videoAd = vast.getVideoAdWithID(adId);
				}
			}			
		}
		
		public function recordCompanionClickThrough(adSlotIndex:int, companionID:int):void {
			if(_adSlots.length < adSlotIndex) {
				_adSlots[adSlotIndex].registerCompanionClickThrough(companionID);
			}
		}
		
        public function processTimeEvent(associatedStreamIndex:int, timeEvent:TimeEvent, includeChildLinearPoints:Boolean=true):void {
        	// for every non-stream ad slot attached to the active stream, fire off the time event
			if(hasAdSlots()) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					if(_adSlots[i].associatedStreamIndex == associatedStreamIndex && !_adSlots[i].isLinear()) {
//						if(_lastTrackedStreamIndex != associatedStreamIndex) _adSlots[i].resetRepeatableTrackingPoints();
						_adSlots[i].processTimeEvent(timeEvent, includeChildLinearPoints);					
					}
				}
				_lastTrackedStreamIndex = associatedStreamIndex;
			}	
        }
	}
}