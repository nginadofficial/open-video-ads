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
package org.openvideoads.vast.model {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;

	import flash.external.ExternalInterface;
	
	/**
	 * @author Paul Schulz
	 */
	public class VideoAd extends Debuggable {
		protected var _id:String;
		protected var _adSystem:String;
		protected var _adTitle:String;
		protected var _description:String;
		protected var _survey:String;
		protected var _error:String;
		protected var _impressions:Array = new Array();			
		protected var _trackingEvents:Array = new Array();		
		protected var _linearVideoAd:LinearVideoAd = null;
		protected var _nonLinearVideoAds:Array  = new Array();
		protected var _companionAds:Array  = new Array();
		protected var _forceImpressionServing:Boolean = false;

		public function VideoAd() {
		}
		
        public function parseImpressions(ad:XML):void {
			doLog("Parsing impression data...", Debuggable.DEBUG_VAST_TEMPLATE);
			if(ad.Impression != null && ad.Impression.children() != null) {
				var impressions:XMLList = ad.Impression.children();
				for(var i:int = 0; i < impressions.length(); i++) {
					this.addImpression(new NetworkResource(impressions[i].id, impressions[i].text()));
				}
			}
			doLog(_impressions.length + " impressions recorded", Debuggable.DEBUG_VAST_TEMPLATE);        	
        }        
        	
        public function parseTrackingEvents(ad:XML):void {
			doLog("Parsing TrackingEvent data...", Debuggable.DEBUG_VAST_TEMPLATE);
			if(ad.TrackingEvents != null && ad.TrackingEvents.children() != null) {
				var trackingEvents:XMLList = ad.TrackingEvents.children();
				doLog(trackingEvents.length() + " tracking events specified", Debuggable.DEBUG_VAST_TEMPLATE);
				for(var i:int = 0; i < trackingEvents.length(); i++) {
					var trackingEventXML:XML = trackingEvents[i];
					var trackingEvent:TrackingEvent = new TrackingEvent(trackingEventXML.@event);
					var trackingEventURLs:XMLList = trackingEventXML.children();
					for(var j:int = 0; j < trackingEventURLs.length(); j++) {
						var trackingEventURL:XML = trackingEventURLs[j];
						trackingEvent.addURL(new NetworkResource(trackingEventURL.@id, trackingEventURL.text()));
					}
					this.addTrackingEvent(trackingEvent);				
				}
			} 
        }
        	
        public function parseLinear(ad:XML):void {
			doLog("Parsing Video data...", Debuggable.DEBUG_VAST_TEMPLATE);
			var linearVideoAd:LinearVideoAd = new LinearVideoAd();
			linearVideoAd.adID = ad.Video.AdID;
			linearVideoAd.duration = ad.Video.Duration;
			if(ad.Video.VideoClicks != undefined) {
				var clickList:XMLList;
				var clickURL:XML;
				var i:int=0;
				if(ad.Video.VideoClicks.ClickThrough.children().length() > 0) {
					doLog("Parsing VideoClicks ClickThrough data...", Debuggable.DEBUG_VAST_TEMPLATE);
					clickList = ad.Video.VideoClicks.ClickThrough.children();
					for(i = 0; i < clickList.length(); i++) {
						clickURL = clickList[i];
						linearVideoAd.addClickThrough(new NetworkResource(clickURL.@id, clickURL.text()));
					}
				}
				if(ad.Video.VideoClicks.ClickTracking.children().length() > 0) {
					doLog("Parsing VideoClicks ClickTracking data...", Debuggable.DEBUG_VAST_TEMPLATE);
					clickList = ad.Video.VideoClicks.ClickTracking.children();
					for(i = 0; i < clickList.length(); i++) {
						clickURL = clickList[i];
						linearVideoAd.addClickTrack(new NetworkResource(clickURL.@id, clickURL.text()));
					}
				}
				if(ad.Video.VideoClicks.CustomClick.children().length() > 0) {
					doLog("Parsing VideoClicks CustomClick...", Debuggable.DEBUG_VAST_TEMPLATE);
					clickList = ad.Video.CustomClick.ClickTracking.children();
					for(i = 0; i < clickList.length(); i++) {
						clickURL = clickList[i];
						linearVideoAd.addCustomClick(new NetworkResource(clickURL.@id, clickURL.text()));
					}
				}
			}
			if(ad.Video.MediaFiles != undefined) {
				doLog("Parsing MediaFiles data...", Debuggable.DEBUG_VAST_TEMPLATE);
				var mediaFiles:XMLList = ad.Video.MediaFiles.children();
				for(i = 0; i < mediaFiles.length(); i++) {
					var mediaFileXML:XML = mediaFiles[i];
					var mediaFile:MediaFile = new MediaFile();
					mediaFile.id = mediaFileXML.@id; 
					mediaFile.bandwidth = mediaFileXML.@bandwidth; 
					mediaFile.delivery = mediaFileXML.@delivery; 
					mediaFile.mimeType = mediaFileXML.@type; 
					mediaFile.bitRate = mediaFileXML.@bitrate; 
					mediaFile.width = mediaFileXML.@width; 
					mediaFile.height = mediaFileXML.@height; 
					if(mediaFileXML.children().length() > 0) {
						var mediaFileURLXML:XML = mediaFileXML.children()[0];
						mediaFile.url = new NetworkResource(mediaFileURLXML.@id, mediaFileURLXML.text());
					}
					linearVideoAd.addMediaFile(mediaFile);
				}					
			}
			this.linearVideoAd = linearVideoAd;
        }	
        
        public function parseNonLinear(ad:XML):void {
			doLog("Parsing NonLinearAd data...", Debuggable.DEBUG_VAST_TEMPLATE);
			var nonLinearAds:XMLList = ad.NonLinearAds.children();
			var i:int=0;
			doLog(nonLinearAds.length() + " non-linear ads specified", Debuggable.DEBUG_VAST_TEMPLATE);
			for(i = 0; i < nonLinearAds.length(); i++) {
				var nonLinearAdXML:XML = nonLinearAds[i];
				var nonLinearAd:NonLinearVideoAd = null;
				switch(nonLinearAdXML.@resourceType.toUpperCase()) {
					case "HTML":
						nonLinearAd = new NonLinearHtmlAd();
						break;
					case "TEXT":
						nonLinearAd = new NonLinearTextAd();
						break;
					case "STATIC":
						if(nonLinearAdXML.@creativeType != undefined && nonLinearAdXML.@creativeType != null) {
							switch(nonLinearAdXML.@creativeType.toUpperCase()) {
								case "IMAGE/JPEG":
								case "JPEG":
								case "IMAGE/GIF":
								case "GIF":
								case "IMAGE/PNG":
								case "PNG":
									nonLinearAd = new NonLinearImageAd();
									break;
								case "APPLICATION/X-SHOCKWAVE-FLASH":
								case "SWF":
									nonLinearAd = new NonLinearFlashAd();
									break;
								default:
									nonLinearAd = new NonLinearVideoAd();
							}									
						}
						else nonLinearAd = new NonLinearVideoAd();
						break;
					default:
						nonLinearAd = new NonLinearVideoAd();
				}
				nonLinearAd.id = nonLinearAdXML.@id;
				nonLinearAd.width = nonLinearAdXML.@width;
				nonLinearAd.height = nonLinearAdXML.@height; 
				nonLinearAd.resourceType = nonLinearAdXML.@resourceType; 
				nonLinearAd.creativeType = nonLinearAdXML.@creativeType; 
				nonLinearAd.apiFramework = nonLinearAdXML.@apiFramework; 
				if(nonLinearAdXML.URL != undefined) nonLinearAd.url = new NetworkResource(null, nonLinearAdXML.URL.text());
				if(nonLinearAdXML.Code != undefined) {
					nonLinearAd.codeBlock = nonLinearAdXML.Code.text();
				}
				if(nonLinearAdXML.NonLinearClickThrough != undefined) {
					var nlClickList:XMLList = nonLinearAdXML.NonLinearClickThrough.children();
					var nlClickURL:XML;
					for(i = 0; i < nlClickList.length(); i++) {
						nlClickURL = nlClickList[i];
						nonLinearAd.addClickThrough(new NetworkResource(nlClickURL.@id, nlClickURL.text()));
					}							
				}
				this.addNonLinearVideoAd(nonLinearAd);
			}
        }
        
        public function parseCompanions(ad:XML):void {
			doLog("Parsing CompanionAd data...", Debuggable.DEBUG_VAST_TEMPLATE);
			var companionAds:XMLList = ad.CompanionAds.children();
			var i:int=0;
			doLog(companionAds.length() + " companions specified", Debuggable.DEBUG_VAST_TEMPLATE);
			for(i = 0; i < companionAds.length(); i++) {
				var companionAdXML:XML = companionAds[i];
				var companionAd:CompanionAd = new CompanionAd(this);
				companionAd.id = companionAdXML.@id;
				companionAd.width = companionAdXML.@width;
				companionAd.height = companionAdXML.@height; 
				companionAd.resourceType = companionAdXML.@resourceType; 
				companionAd.creativeType = companionAdXML.@creativeType;
				if(companionAdXML.URL != undefined) companionAd.url = new NetworkResource(null, companionAdXML.URL.text());
				if(companionAdXML.Code != undefined) {
					companionAd.codeBlock = companionAdXML.Code.text();							
				}
				if(companionAdXML.CompanionClickThrough != undefined) {
					var caClickList:XMLList = companionAdXML.CompanionClickThrough.children();
					var caClickURL:XML;
					for(i = 0; i < caClickList.length(); i++) {
						caClickURL = caClickList[i];
						companionAd.addClickThrough(new NetworkResource(caClickURL.@id, caClickURL.text()));
					}							
				}
				this.addCompanionAd(companionAd);						 						
			}					
        }
        
		public function set id(id:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function set adSystem(adSystem:String):void {
			_adSystem = adSystem;
		}
		
		public function get adSystem():String {
			return _adSystem;
		}
		
		public function get duration():int {
			if(_linearVideoAd != null) {
				return Timestamp.timestampToSeconds(_linearVideoAd.duration);
			}
			else return 0;
		}
		
		public function set adTitle(adTitle:String):void {
			_adTitle = adTitle;
		}
		
		public function get adTitle():String {
			return _adTitle;
		}
		
		public function set description(description:String):void {
			_description = description;
		}
		
		public function get description():String {
			return _description;
		}
		
		public function set survey(survey:String):void {
			_survey = survey;
		}
		
		public function get survey():String {
			return _survey;
		}
		
		public function set error(error:String):void {
			_error = error;
		}
		
		public function get error():String {
			return _error;
		}
		
		public function set impressions(impressions:Array):void {
			_impressions = impressions;
		}
		
		public function get impressions():Array {
			return _impressions;
		}
		
		public function addImpression(impression:NetworkResource):void {
			_impressions.push(impression);
		}
		
		public function set forceImpressionServing(forceImpressionServing:Boolean):void {
			_forceImpressionServing = forceImpressionServing;
		}
		
		public function get forceImpressionServing():Boolean {
			return _forceImpressionServing;
		}		
		
		public function set trackingEvents(trackingEvents:Array):void {
			_trackingEvents = trackingEvents;
		}
		
		public function get trackingEvents():Array {
			return _trackingEvents;
		}
		
		public function addTrackingEvent(trackEvent:TrackingEvent):void {
			_trackingEvents.push(trackEvent);
		}
		
		public function set linearVideoAd(linearVideoAd:LinearVideoAd):void {
			linearVideoAd.parentAdContainer = this;
			_linearVideoAd = linearVideoAd;
		}
		
		public function get linearVideoAd():LinearVideoAd {
			return _linearVideoAd;
		}
		
		public function set nonLinearVideoAds(nonLinearVideoAds:Array):void {
			_nonLinearVideoAds = nonLinearVideoAds;
		}
		
		public function get nonLinearVideoAds():Array {
			return _nonLinearVideoAds;
		}
		
		public function get firstNonLinearVideoAd():NonLinearVideoAd {
			if(hasNonLinearAds()) {
				return _nonLinearVideoAds[0];
			}
			else return null;
		}
		
		public function addNonLinearVideoAd(nonLinearVideoAd:NonLinearVideoAd):void {
			nonLinearVideoAd.parentAdContainer = this;
			_nonLinearVideoAds.push(nonLinearVideoAd);
		}
		
		public function hasNonLinearAds():Boolean {
			return (_nonLinearVideoAds.length > 0);
		}
		
		public function hasLinearAd():Boolean {
			return (_linearVideoAd != null);
		}
		
		public function set companionAds(companionAds:Array):void {
			_companionAds = companionAds;
		}
		
		public function get companionAds():Array {
			return _companionAds;
		}
		
		public function addCompanionAd(companionAd:CompanionAd):void {
			_companionAds.push(companionAd);
		}
		
		public function hasCompanionAds():Boolean {
			return (_companionAds.length > 0);
		}

		public function isLinear():Boolean {
			return (_linearVideoAd != null);	
		}
		
		public function isNonLinear():Boolean {
			return (_linearVideoAd == null && (_nonLinearVideoAds.length > 0));	
		}
		
		public function getStreamToPlay(deliveryType:String, mimeType:String, bitrate:String="any"):NetworkResource {
			if(isLinear() || (isNonLinear() && hasLinearAd())) {
				return _linearVideoAd.getStreamToPlay(deliveryType, mimeType, bitrate);
			}
			return null;
		}
		
		public function triggerTrackingEvent(eventType:String):void {
			for(var i:int = 0; i < _trackingEvents.length; i++) {
				var trackingEvent:TrackingEvent = _trackingEvents[i];
				if(trackingEvent.eventType == eventType) {
					trackingEvent.execute();
				}				
			}
		}
		
		public function triggerImpressionConfirmations():void {
			for(var i:int = 0; i < _impressions.length; i++) {
				var impression:NetworkResource = _impressions[i];
				impression.call();
			}	
		}

		public function triggerForcedImpressionConfirmations():void {
			for(var i:int = 0; i < _impressions.length; i++) {
				var impression:NetworkResource = _impressions[i];
				impression.call();
			}	
		}
		
		protected function makeJavascriptAPICall(jsFunction:String):void {
			ExternalInterface.call(jsFunction);			
		}
		
		public function processStartAdEvent():void {
			// call the impression tracking urls
			if(hasNonLinearAds() == false) triggerImpressionConfirmations();
			
			// now call the start click tracking urls
			triggerTrackingEvent(TrackingEvent.EVENT_START);
			makeJavascriptAPICall("onLinearAdStart()");
		}

		public function processStopAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_STOP);
		}
		
		public function processPauseAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_PAUSE);
		}

		public function processResumeAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_RESUME);
		}

		public function processFullScreenAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_FULLSCREEN);
		}

		public function processMuteAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_MUTE);
		}

		public function processUnmuteAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_UNMUTE);
		}

		public function processReplayAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_REPLAY);
		}

		public function processHitMidpointAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_MIDPOINT);
			makeJavascriptAPICall("onLinearAdMidPointComplete()");
		}

		public function processFirstQuartileCompleteAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_1STQUARTILE);
			makeJavascriptAPICall("onLinearAdFirstQuartileComplete()");
		}

		public function processThirdQuartileCompleteAdEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_3RDQUARTILE);
			makeJavascriptAPICall("onLinearAdThirdQuartileComplete()");
		}

		public function processAdCompleteEvent():void {
			triggerTrackingEvent(TrackingEvent.EVENT_COMPLETE);
			makeJavascriptAPICall("onLinearAdFinish()");
		}
		
		public function processStartNonLinearOverlayAdEvent(event:VideoAdDisplayEvent):void {
			var matched:Boolean = false;
			for(var i:int = 0; i < _nonLinearVideoAds.length; i++) {
				if(_nonLinearVideoAds[i].matchesSize(event.width, event.height)) {
					matched = true;
					_nonLinearVideoAds[i].start(event);
			        triggerImpressionConfirmations();
				}
			}
			if(!matched) doLog("No matching size found for Ad " + id + " - size required is (" + event.width + "," + event.height + ")", Debuggable.DEBUG_DATA_ERROR);
		}
		
		public function processStopNonLinearOverlayAdEvent(event:VideoAdDisplayEvent):void { 
			for(var i:int = 0; i < _nonLinearVideoAds.length; i++) {
				if(event.width > -1 && event.height > -1) {
					if(_nonLinearVideoAds[i].matchesSize(event.width, event.height)) {
						_nonLinearVideoAds[i].stop(event); 
					}					
				}
				else _nonLinearVideoAds[i].stop(event);
			}
		}
		
		public function processStartCompanionAdEvent(displayEvent:VideoAdDisplayEvent):void {
			if(displayEvent.controller.displayingCompanions()) {
				for(var i:int = 0; i < _companionAds.length; i++) {
					_companionAds[i].start(displayEvent); 
				}
			}
			else doLog("Ignoring request to start a companion - no companions are configured on this page", Debuggable.DEBUG_CUEPOINT_EVENTS);
		}
		
		public function processStopCompanionAdEvent(displayEvent:VideoAdDisplayEvent):void {
			if(displayEvent.controller.displayingCompanions()) {
				for(var i:int = 0; i < _companionAds.length; i++) {
					_companionAds[i].stop(displayEvent);
				}
			}
			else doLog("Ignoring request to stop a companion - no companions are configured on this page", Debuggable.DEBUG_CUEPOINT_EVENTS);
		}
	}
}