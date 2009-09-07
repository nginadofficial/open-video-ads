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
package org.openvideoads.vast {
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.base.EventController;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
	import org.openvideoads.vast.events.CompanionAdDisplayEvent;
	import org.openvideoads.vast.events.LinearAdDisplayEvent;
	import org.openvideoads.vast.events.NonLinearAdDisplayEvent;
	import org.openvideoads.vast.events.NonLinearSchedulingEvent;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.SeekerBarEvent;
	import org.openvideoads.vast.events.StreamSchedulingEvent;
	import org.openvideoads.vast.events.TemplateEvent;
	import org.openvideoads.vast.events.TrackingPointEvent;
	import org.openvideoads.vast.model.CompanionAd;
	import org.openvideoads.vast.model.LinearVideoAd;
	import org.openvideoads.vast.model.NonLinearVideoAd;
	import org.openvideoads.vast.model.TemplateLoadListener;
	import org.openvideoads.vast.model.VideoAdServingTemplate;
	import org.openvideoads.vast.overlay.OverlayController;
	import org.openvideoads.vast.overlay.OverlayView;
	import org.openvideoads.vast.playlist.Playlist;
	import org.openvideoads.vast.playlist.PlaylistController;
	import org.openvideoads.vast.playlist.mrss.MediaRSSPlaylist;
	import org.openvideoads.vast.playlist.xspf.XSPFPlaylist;
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.schedule.ads.AdSchedule;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.server.AdServerFactory;
	import org.openvideoads.vast.server.openx.OpenXAdServer;
	import org.openvideoads.vast.tracking.TimeEvent;
	import org.openvideoads.vast.tracking.TrackingPoint;
	import org.openvideoads.vast.tracking.TrackingTable;
	
	/**
	 * @author Paul Schulz
	 */
	public class VASTController extends EventController implements TemplateLoadListener {
		public static const RELATIVE_TO_CLIP:String = "relative-to-clip";
		public static const CONTINUOUS:String = "continuous";
		
		protected var _streamSequence:StreamSequence = new StreamSequence();
		protected var _adSchedule:AdSchedule = null;
		protected var _overlayLinearVideoAdSlot:AdSlot = null;
		protected var _template:VideoAdServingTemplate = null;
		protected var _overlayController:OverlayController = null;
		protected var _config:Config = new Config();
		protected var _openXAdServer:OpenXAdServer = null;
		protected var _timeBaseline:String = VASTController.CONTINUOUS;
		protected var _trackStreamSlices:Boolean = true;
		protected var _visuallyCueingLinearAdClickthroughs:Boolean = true;
		protected var _startStreamSafetyMargin:int = 0;
		protected var _endStreamSafetyMargin:int = 0;	
		
		
		public function VASTController(config:Config=null, endStreamSafetyMargin:int=0) {
			super();
			if(config != null) initialise(config);
			_endStreamSafetyMargin = endStreamSafetyMargin;
		}
		
		public function initialise(config:Object, loadData:Boolean=false):void {
			// Load up the config
			if(config is Config) {
				this.config = config as Config;
			}
            else this.config = new Config(config);
            if(loadData) load();
		}
		
		public function set endStreamSafetyMargin(endStreamSafetyMargin:int):void {
			_endStreamSafetyMargin = endStreamSafetyMargin;
			doLog("Saftey margin for end of stream time tracking events set to " + _endStreamSafetyMargin + " milliseconds", Debuggable.DEBUG_CONFIG);
		}
		
		public function get endStreamSafetyMargin():int {
			return _endStreamSafetyMargin;
		}

		
		public function set startStreamSafetyMargin(startStreamSafetyMargin:int):void {
			_startStreamSafetyMargin = startStreamSafetyMargin;
			doLog("Saftey margin for start of stream time tracking events set to " + _startStreamSafetyMargin + " milliseconds", Debuggable.DEBUG_CONFIG);
		}
		
		public function get startStreamSafetyMargin():int {
			return _startStreamSafetyMargin;
		}
		
		public function get playOnce():Boolean {
			return config.playOnce;
		}
		
		public function set trackStreamSlices(trackStreamSlices:Boolean):void {
			_trackStreamSlices = trackStreamSlices;
		}
		
		public function get trackStreamSlices():Boolean {
			return _trackStreamSlices;
		}

		public function autoPlay():Boolean {
			return _config.autoPlay;	
		}
		
        public function get disableControls():Boolean {
        	return _config.disableControls;	
        }
        
        public function get allowPlaylistControl():Boolean {
        	return _config.allowPlaylistControl;
        }
        
		public function setTimeBaseline(timeBaseline:String):void {
			_timeBaseline = timeBaseline;
		}
		
		protected function timeRelativeToClip():Boolean {
			return (_timeBaseline == VASTController.RELATIVE_TO_CLIP);
		}
		
		public function load():void {
            _openXAdServer.loadVideoAdData(this, _adSchedule);			
		}
		
		public function set config(config:Config):void {
			_config = config;
			doLogAndTrace("Configuration loaded as: ", _config);

            // Configure the debug level
   			if(_config.debugLevelSpecified()) Debuggable.getInstance().setLevelFromString(_config.debugLevel);
   			if(_config.debuggersSpecified()) Debuggable.getInstance().activeDebuggers = _config.debugger;

            // Now formulate the ad schedule
			_adSchedule = new AdSchedule(this, _streamSequence, _config);  
			
   			// Fire up the ad server and load up the template data
            _openXAdServer = AdServerFactory.getAdServer(AdServerFactory.AD_SERVER_OPENX) as OpenXAdServer;
            _openXAdServer.initialise(_config);
		}
		
		public function get config():Config {
			return _config;
		}

        public function get template():VideoAdServingTemplate {
        	return _template;
        }		
        
		public function get adSchedule():AdSchedule {
			return _adSchedule;
		}
		
		public function get streamSequence():StreamSequence {
			return _streamSequence;
		}
		
		public function get overlayController():OverlayController {
			return _overlayController;
		}
		
		public function get pauseOnClickThrough():Boolean {
			return _config.pauseOnClickThrough;	
		}
		
		public function enableNonLinearAdDisplay(displayProperties:DisplayProperties):void {
			// Load up the overlay controller and pass in the regions that have been defined
			_overlayController = new OverlayController(this, displayProperties, _config.overlaysConfig);
			if(displayProperties.displayObjectContainer != null) displayProperties.displayObjectContainer.addChild(_overlayController);			
		}
		
		public function resizeOverlays(resizedProperties:DisplayProperties):void {
			if(_overlayController != null) {
				_overlayController.resize(resizedProperties);
			}
		}
		
		public function handlingNonLinearAdDisplay():Boolean {
			return (_overlayController != null);
		}
		
		public function getTrackingTableForStream(streamIndex:int):TrackingTable {
			if(streamIndex < _streamSequence.length) {
				return _streamSequence.streamAt(streamIndex).getTrackingTable();
			}
			return null;
		}
		
		public function hasUserSpecifiedProviders():Boolean {
			return hasProvider("rtmp") || hasProvider("http");	
		}
		
		public function needsProvider(providerID:String):Boolean {
			if(_config.deliveryType.toUpperCase() == "ANY") return true;

			switch(providerID.toUpperCase()) {
				case "RTMP":
					return (_config.deliveryType == "STREAMING");
				case "HTTP":
					return (_config.deliveryType == "PROGRESSIVE");
			}	
			
			return false;
		}
		
		public function hasProvider(providerID:String):Boolean {
			return _config.hasProviderUrl(providerID);
		}
		
		public function getProviderUrl(providerID:String):String {
			return _config.providerUrl(providerID);
		}
		
		// Overlay linear video ad playlist API
		
		public function getActiveOverlayXSPFPlaylist(httpStreamerType:String="video"):XSPFPlaylist {
			if(!allowPlaylistControl) {
				if(_overlayLinearVideoAdSlot != null) {
					var adStreamSequence:StreamSequence = new StreamSequence(this);
					adStreamSequence.addStream(_overlayLinearVideoAdSlot, false);
					return PlaylistController.createPlaylist(adStreamSequence, PlaylistController.PLAYLIST_FORMAT_XSPF, httpStreamerType) as XSPFPlaylist;			
				}
				else doLog("Cannot play the linear ad for this overlay - no adslot attached to the event - ignoring click", Debuggable.DEBUG_PLAYLIST);
			}
			else doLog("NOTIFICATION: Overlay clicked event ignored as playlistControl is turned on - this feature is not possible", Debuggable.DEBUG_DISPLAY_EVENTS);

			return null;
		}

		public function getActiveOverlayMediaRSSPlaylist():MediaRSSPlaylist {
			return null; // TO BE IMPLEMENTED
		}
		
		// Playlist API
		
		public function createPlaylist(type:int):Playlist {
			return null; // TO BE IMPLEMENTED
		}
		
		public function createXSPFPlaylist(httpStreamerType:String="video"):XSPFPlaylist {
			return PlaylistController.createPlaylist(_streamSequence, PlaylistController.PLAYLIST_FORMAT_XSPF, httpStreamerType) as XSPFPlaylist;
		}

		public function createMediaRSSPlaylist():MediaRSSPlaylist {
			return null; // TO BE IMPLEMENTED
		}
				
		// Time Event Handlers
		
		public function processTimeEvent(associatedStreamIndex:int, timeEvent:TimeEvent):void {
			// we're dealing with an event on the mainline streams and ad slots
			if(_adSchedule != null) {
				_adSchedule.processTimeEvent(associatedStreamIndex, timeEvent, false);												
			}
			if(_streamSequence != null) {
				_streamSequence.processTimeEvent(associatedStreamIndex, timeEvent, false);
			}
		}

		public function processOverlayLinearVideoAdTimeEvent(associatedStreamIndex:int, timeEvent:TimeEvent, playingOverlayVideo:Boolean=false):void {
			if(_overlayLinearVideoAdSlot != null) {
				// ok, we are processing time events within a video ad played as a result of a click on an overlay
				_overlayLinearVideoAdSlot.processTimeEvent(timeEvent, true);
			}
		}
		
		public function resetRepeatableTrackingPoints(streamIndex:int):void {
			if(_streamSequence != null && streamIndex > -1) {
				_streamSequence.resetRepeatableTrackingPoints(streamIndex);
			}
		}		

		// Stream scheduling callback
		
		public function onScheduleStream(scheduleIndex:int, stream:Stream):void {
			if((trackStreamSlices == false) && (stream.isSlicedStream()) && (!stream.isFirstSlice())) {
				// don't notify that this stream slice is to be scheduled
				doLog("Ignoring 'onScheduleStream' request for stream " + stream.url, Debuggable.DEBUG_SEGMENT_FORMATION);
			}	
			else dispatchEvent(new StreamSchedulingEvent(StreamSchedulingEvent.SCHEDULE, scheduleIndex, stream));
		}

		public function onScheduleNonLinear(adSlot:AdSlot):void {			
			dispatchEvent(new NonLinearSchedulingEvent(NonLinearSchedulingEvent.SCHEDULE, adSlot));
		}
		
		// Tracking Point callbacks
		
		public function onSetTrackingPoint(trackingPoint:TrackingPoint):void {
			dispatchEvent(new TrackingPointEvent(TrackingPointEvent.SET, trackingPoint));
		}

		public function onProcessTrackingPoint(trackingPoint:TrackingPoint):void {
			dispatchEvent(new TrackingPointEvent(TrackingPointEvent.FIRED, trackingPoint));
		}
		
		// Linear Ad events
		
		public function onLinearAdStart(adSlot:AdSlot):void {
			dispatchEvent(new LinearAdDisplayEvent(LinearAdDisplayEvent.STARTED, adSlot));	
		}

		public function onLinearAdComplete(adSlot:AdSlot):void {
			dispatchEvent(new LinearAdDisplayEvent(LinearAdDisplayEvent.COMPLETE, adSlot));
		}
		
		public function enableVisualLinearAdClickThroughCue(adSlot:AdSlot):void {
			if(_config.visuallyCueLinearAdClickThrough && adSlot.hasLinearClickThroughs()) {
				overlayController.enableLinearAdMouseOverRegion(adSlot);
			}			
		}
		
		public function disableVisualLinearAdClickThroughCue(adSlot:AdSlot):void {
			if(_config.visuallyCueLinearAdClickThrough) overlayController.disableLinearAdMouseOverRegion();			
		}
		
		// TemplateLoadListener callbacks
		
		public function onTemplateLoaded(template:VideoAdServingTemplate):void {
			_template = template;
			
			_adSchedule.mapVASTDataToAdSlots(template);
			_streamSequence.initialise(this, _config.streams, _adSchedule, _config.bitrate, _config.baseURL, 100);
			_adSchedule.addNonLinearAdTrackingPoints(timeRelativeToClip(), true);
			_adSchedule.fireNonLinearSchedulingEvents();
			
			dispatchEvent(new TemplateEvent(TemplateEvent.LOADED, _template));
		}
		
		public function onTemplateLoadError(event:Event):void {
			doLog("FAILURE loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL);
			dispatchEvent(new TemplateEvent(TemplateEvent.LOAD_FAILED, event));
		}
		
		// Player tracking control API
		
		public function onPlayerSeek(activeStreamIndex:int=-1):void {
		}

		public function onPlayerMute(activeStreamIndex:int=-1):void {
			if(_streamSequence != null) _streamSequence.processMuteEventForStream(activeStreamIndex);
		}

		public function onPlayerUnmute(activeStreamIndex:int=-1):void {			
			if(_streamSequence != null) _streamSequence.processUnmuteEventForStream(activeStreamIndex);
		}

		public function onPlayerPlay(activeStreamIndex:int=-1):void {
			// TO IMPLEMENT
		}

		public function onPlayerStop(activeStreamIndex:int=-1):void {
			if(_streamSequence != null) _streamSequence.processStopEventForStream(activeStreamIndex);
			if(handlingNonLinearAdDisplay()) _overlayController.hideAllOverlays();
		}

		public function onPlayerResize(activeStreamIndex:int=-1):void {
			if(_streamSequence != null) _streamSequence.processFullScreenEventForStream(activeStreamIndex);
		}

		public function onPlayerPause(activeStreamIndex:int=-1):void {			
			if(_streamSequence != null) _streamSequence.processPauseEventForStream(activeStreamIndex);
		}

		public function onPlayerResume(activeStreamIndex:int=-1):void {			
			if(_streamSequence != null) _streamSequence.processResumeEventForStream(activeStreamIndex);
		}

		public function onPlayerReplay(activeStreamIndex:int=-1):void {			
			// TO IMPLEMENT
		}

        // SeekerBarDisplayController callbacks
        
		public function onToggleSeekerBar(enable:Boolean):void {
			if(_config.disableControls) {
	 			doLog("Request received to change the control bar state to " + ((!enable) ? "BLOCKED" : "ON"), Debuggable.DEBUG_DISPLAY_EVENTS);
			    dispatchEvent(new SeekerBarEvent(SeekerBarEvent.TOGGLE, enable));			
			}
			else doLog("Ignoring request to change control bar state", Debuggable.DEBUG_DISPLAY_EVENTS);
		}        
        		
		// VideoAdDisplayController callbacks 

		public function onDisplayNonLinearOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			// if the overlay ad has a linear video ad stream attached, create it and have to ready to 
			// go if the overlay is clicked
			if(overlayAdDisplayEvent.ad.hasAccompanyingVideoAd()) {
				_overlayLinearVideoAdSlot = _adSchedule.getSlot(overlayAdDisplayEvent.adSlotKey);
			}
			
			// Now handle the display of the overlay
			if(handlingNonLinearAdDisplay()) _overlayController.displayNonLinearOverlayAd(overlayAdDisplayEvent);
			dispatchEvent(overlayAdDisplayEvent);
		}
		
		public function onHideNonLinearOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			_overlayLinearVideoAdSlot = null;
			if(handlingNonLinearAdDisplay()) _overlayController.hideNonLinearOverlayAd(overlayAdDisplayEvent);
			dispatchEvent(overlayAdDisplayEvent);			
		}
		
		public function onDisplayNonLinearNonOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.displayNonLinearNonOverlayAd(overlayAdDisplayEvent);
			dispatchEvent(overlayAdDisplayEvent);			
		}
		
		public function onHideNonLinearNonOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.hideNonLinearNonOverlayAd(overlayAdDisplayEvent);
			dispatchEvent(overlayAdDisplayEvent);			
		}
		
		public function onShowAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.showAdNotice(adNoticeDisplayEvent);
			dispatchEvent(adNoticeDisplayEvent);			
		}
		
		public function onHideAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.hideAdNotice(adNoticeDisplayEvent);
			dispatchEvent(adNoticeDisplayEvent);			
		}
		
		public function onOverlayClicked(overlayView:OverlayView):void {
			if(overlayView.activeAdSlotKey > -1) {
				var ad:AdSlot = _adSchedule.getSlot(overlayView.activeAdSlotKey);
				var nonLinearVideoAd:NonLinearVideoAd = _adSchedule.getSlot(overlayView.activeAdSlotKey).getNonLinearVideoAd();
				var event:NonLinearAdDisplayEvent = new OverlayAdDisplayEvent(
									OverlayAdDisplayEvent.CLICKED, 
									nonLinearVideoAd, 
									null, 
									overlayView.activeAdSlotKey, 
									-1, 
									overlayView);
									
				if(ad.hasLinearAd()) {
					dispatchEvent(event);					
				}
				else {
					if(nonLinearVideoAd.hasClickThroughs()) {
						navigateToURL(new URLRequest(nonLinearVideoAd.firstClickThrough()), "_blank");
					}
					dispatchEvent(event);
				}			
			}
		}
		
		public function onLinearAdClickThroughCallToActionViewClicked(adSlotKey:int):void {
			var ad:LinearVideoAd = _adSchedule.getSlot(adSlotKey).getLinearVideoAd();
			if(ad != null && ad.hasClickThroughs()) {
				navigateToURL(new URLRequest(ad.firstClickThrough()), "_blank");
				dispatchEvent(new LinearAdDisplayEvent(
									LinearAdDisplayEvent.CLICK_THROUGH, 
									_adSchedule.getSlot(adSlotKey))
				);
			}			
		}
		
		// CompanionDisplayController APIs

		public function displayingCompanions():Boolean {
			return _config.displayCompanions;
		}

		public function onDisplayCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
           doLogAndTrace("Request received to display companion ad", companionEvent, Debuggable.DEBUG_DISPLAY_EVENTS);
           
			var companionAd:CompanionAd = companionEvent.ad as CompanionAd;
			if(_config.hasCompanionDivs()) {
				var companionDivIDs:Array = _config.companionDivIDs;
				doLog("Event trigger received by companion Ad with ID " + companionAd.id + " - looking for a div to match the sizing (" + companionAd.width + "," + companionAd.height + ")", Debuggable.DEBUG_CUEPOINT_EVENTS);
				var matchFound:Boolean = false;
				for(var i:int=0; i < companionDivIDs.length; i++) {
					if(companionAd.matchesSize(companionDivIDs[i].width, companionDivIDs[i].height)) {
						matchFound = true;
						doLog("Found a match for that size - id of matching DIV is " + companionDivIDs[i].id, Debuggable.DEBUG_CUEPOINT_EVENTS);
						var newHtml:String = companionAd.getMarkup();
						if(newHtml != null) {
							var cde:CompanionAdDisplayEvent = new CompanionAdDisplayEvent(CompanionAdDisplayEvent.DISPLAY, companionAd);
							cde.divID = companionDivIDs[i].id;
							cde.content = newHtml;
							dispatchEvent(cde);
						}
					}
				}
				if(!matchFound) doLog("No DIV match found for sizing (" + companionAd.width + "," + companionAd.height + ")!", Debuggable.DEBUG_CUEPOINT_EVENTS);				
			}
			else doLog("No DIVS specified for companion ads to be displayed", Debuggable.DEBUG_CUEPOINT_EVENTS);           
		}
		
		public function onHideCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
			dispatchEvent(new CompanionAdDisplayEvent(CompanionAdDisplayEvent.HIDE, companionEvent.ad as CompanionAd));
		}
		
		// Event registration - region based events must be registered with the overlay(region) controller
		
        public override function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        	if(type.indexOf("region-") > -1) {
        		if(_overlayController != null) {
        			_overlayController.addEventListener(type, listener, useCapture, priority, useWeakReference);
        		}
        	}
        	else super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        public override function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        	if(type.indexOf("region-") > -1) {
        		if(_overlayController != null) {
        			_overlayController.addEventListener(type, listener, useCapture);
        		}
        	}
        	else super.removeEventListener(type, listener, useCapture);
        }		
	}
}