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
package org.openvideoads.vast {
	import flash.display.DisplayObjectContainer;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.base.EventController;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
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
//		protected var _openXAdServer:OpenXAdServer = null;
		protected var _timeBaseline:String = VASTController.RELATIVE_TO_CLIP;
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
		
		public function setupFlashContextMenu(displayContainer:DisplayObjectContainer):void { 
			var ova_menu:ContextMenu = new ContextMenu();
			var aboutMenuItem:ContextMenuItem = new ContextMenuItem("About OpenVideoAds.org");
			var debugMenuItem:ContextMenuItem = new ContextMenuItem("Debug OVA Ad Streamer");
 
			aboutMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,  
					function visit_ova(e:Event):void {
						var ova_link:URLRequest = new URLRequest("http://www.openvideoads.org");
						navigateToURL(ova_link, "_parent");
					}
			);
			aboutMenuItem.separatorBefore = false;
 
			ova_menu.hideBuiltInItems();
			ova_menu.customItems.push(aboutMenuItem, debugMenuItem);
			displayContainer.contextMenu = ova_menu; 
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
		
		public function getStreamSequenceIndexGivenOriginatingIndex(originalIndex:int, excludeSlices:Boolean=false, excludeMidRolls:Boolean=false):int {
			if(_streamSequence != null) {
				return _streamSequence.getStreamSequenceIndexGivenOriginatingIndex(originalIndex, excludeSlices, excludeMidRolls);
			}
			return -1;
		}
		public function load():void {
			this.config.ensureProvidersAreSet();
			_adSchedule.loadAdsFromAdServers(this);
//            _openXAdServer.loadVideoAdData(this, _adSchedule);			
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
//            _openXAdServer = AdServerRequestFactory.getAdServer(AdServerRequestFactory.AD_SERVER_OPENX) as OpenXAdServer;
//            _openXAdServer.initialise(_config);
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
//            setupFlashContextMenu(displayProperties.displayObjectContainer);
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
		
		public function getProvider(providerType:String):String {
			return _config.getProvider(providerType);
		}
		
		public function getProviders():ProvidersConfigGroup {
			return _config.providersConfig;
		}

		// Overlay linear video ad playlist API
		
		public function getActiveOverlayXSPFPlaylist():XSPFPlaylist {
			if(!allowPlaylistControl) {
				if(_overlayLinearVideoAdSlot != null) {
					var adStreamSequence:StreamSequence = new StreamSequence(this);
					adStreamSequence.addStream(_overlayLinearVideoAdSlot, false);
					return PlaylistController.createPlaylist(adStreamSequence, PlaylistController.PLAYLIST_FORMAT_XSPF, _config.providersForShows(), _config.providersForAds()) as XSPFPlaylist;			
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
		
		public function createXSPFPlaylist():XSPFPlaylist {
			return PlaylistController.createPlaylist(_streamSequence, PlaylistController.PLAYLIST_FORMAT_XSPF, _config.providersForShows(), _config.providersForAds()) as XSPFPlaylist;
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

		public function processOverlayLinearVideoAdTimeEvent(overlayAdSlotKey:int, timeEvent:TimeEvent, playingOverlayVideo:Boolean=false):void {
			if(overlayAdSlotKey != -1) {
				if(overlayAdSlotKey < _adSchedule.length) {
					_adSchedule.getSlot(overlayAdSlotKey).processTimeEvent(timeEvent, true);
				}
			}
		}
		
		public function resetRepeatableTrackingPoints(streamIndex:int):void {
			if(_streamSequence != null && streamIndex > -1) {
				_streamSequence.resetRepeatableTrackingPoints(streamIndex);
			}
		}	
		
		// Javascript API support
		
		protected function makeJavascriptAPICall(jsFunction:String):void {
			ExternalInterface.call(jsFunction);			
		}
		
		// Regions API support
		
		public function setRegionStyle(regionID:String, cssText:String):String {
			if(_overlayController != null) {
				return _overlayController.setRegionStyle(regionID, cssText);
			}
			else return "-1, Overlay Controller is not active";
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
			doLog("VASTController: notified that template has been fully loaded", Debuggable.DEBUG_VAST_TEMPLATE)
			_template = template;
			_adSchedule.mapVASTDataToAdSlots(template);
			_streamSequence.initialise(this, _config.streams, _adSchedule, _config.bitrate, _config.baseURL, 100, _config.previewImage);
			_adSchedule.addNonLinearAdTrackingPoints(timeRelativeToClip(), true);
			_adSchedule.fireNonLinearSchedulingEvents();
			dispatchEvent(new TemplateEvent(TemplateEvent.LOADED, _template));
			makeJavascriptAPICall("onVASTLoadComplete()");
		}
		
		public function onTemplateLoadError(event:Event):void {
			doLog("VASTController: FAILURE loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL);
			dispatchEvent(new TemplateEvent(TemplateEvent.LOAD_FAILED, event));
			makeJavascriptAPICall("onVASTLoadFailure()");
		}
		
		// Player tracking control API
		
		public function onPlayerSeek(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {
		}

		public function onPlayerMute(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processMuteEvent();					
				}
			}
			else if(_streamSequence != null) _streamSequence.processMuteEventForStream(activeStreamIndex);
		}

		public function onPlayerUnmute(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {			
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processUnmuteEvent();					
				}				
			}
			else if(_streamSequence != null) _streamSequence.processUnmuteEventForStream(activeStreamIndex);
		}

		public function onPlayerPlay(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {
			// TO IMPLEMENT
		}

		public function onPlayerStop(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processStopStream();					
				}																
			}
			else {
				if(_streamSequence != null) _streamSequence.processStopEventForStream(activeStreamIndex);
				if(handlingNonLinearAdDisplay()) _overlayController.hideAllOverlays();		
			}
		}

		public function onPlayerResize(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processFullScreenEvent();					
				}								
			}
			else if(_streamSequence != null) _streamSequence.processFullScreenEventForStream(activeStreamIndex);
		}

		public function onPlayerPause(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {			
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processPauseStream();					
				}												
			}
			else if(_streamSequence != null) _streamSequence.processPauseEventForStream(activeStreamIndex);
		}

		public function onPlayerResume(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {			
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processResumeStream();					
				}												
			}
			else if(_streamSequence != null) _streamSequence.processResumeEventForStream(activeStreamIndex);
		}

		public function onPlayerReplay(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {			
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
			makeJavascriptAPICall("onNonLinearAdShow()");
		}
		
		public function onHideNonLinearOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			_overlayLinearVideoAdSlot = null;
			if(handlingNonLinearAdDisplay()) _overlayController.hideNonLinearOverlayAd(overlayAdDisplayEvent);
			dispatchEvent(overlayAdDisplayEvent);			
			makeJavascriptAPICall("onNonLinearAdHide()");
		}
		
		public function onDisplayNonLinearNonOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.displayNonLinearNonOverlayAd(overlayAdDisplayEvent);
			dispatchEvent(overlayAdDisplayEvent);			
			makeJavascriptAPICall("onNonLinearAdShow()");
		}
		
		public function onHideNonLinearNonOverlayAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.hideNonLinearNonOverlayAd(overlayAdDisplayEvent);
			dispatchEvent(overlayAdDisplayEvent);			
			makeJavascriptAPICall("onNonLinearAdHide()");
		}
		
		public function onShowAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.showAdNotice(adNoticeDisplayEvent);
			dispatchEvent(adNoticeDisplayEvent);				
			makeJavascriptAPICall("onAdNoticeShow()");		
		}
		
		public function onHideAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.hideAdNotice(adNoticeDisplayEvent);
			dispatchEvent(adNoticeDisplayEvent);			
			makeJavascriptAPICall("onAdNoticeHide()");
		}

		public function onOverlayCloseClicked(overlayView:OverlayView):void {
			if(overlayView.activeAdSlotKey > -1) {
				var ad:AdSlot = _adSchedule.getSlot(overlayView.activeAdSlotKey);
				var nonLinearVideoAd:NonLinearVideoAd = _adSchedule.getSlot(overlayView.activeAdSlotKey).getNonLinearVideoAd();
				var event:NonLinearAdDisplayEvent = new OverlayAdDisplayEvent(
									OverlayAdDisplayEvent.CLOSE_CLICKED, 
									nonLinearVideoAd, 
									null, 
									overlayView.activeAdSlotKey, 
									-1, 
									overlayView);									
				dispatchEvent(event);					
			}
			makeJavascriptAPICall("onRegionCloseClicked()");
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
			makeJavascriptAPICall("onRegionClicked()");
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
			makeJavascriptAPICall("onLinearAdClick()");
		}
		
		// Forced Impression Firing for blank VAST Ad Responses
		public function processImpressionsToForceFire():void {
			if(_adSchedule != null) {
				_adSchedule.processImpressionsToForceFire();
			}
		}	
			
		// CompanionDisplayController APIs

		public function displayingCompanions():Boolean {
			return _config.displayCompanions;
		}

		public function onDisplayCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
           doLogAndTrace("Request received to display companion ad", companionEvent, Debuggable.DEBUG_DISPLAY_EVENTS);
           
			var companionAd:CompanionAd = companionEvent.ad as CompanionAd;
			if(companionAd.isScriptResourceType() && companionAd.hasUrl()) {
				doLog("Skipping script based companion ads - not supported at present", Debuggable.DEBUG_CUEPOINT_EVENTS);
			}
			else {
				if(_config.hasCompanionDivs()) {
					var companionDivIDs:Array = _config.companionDivIDs;
					doLog("Event trigger received by companion Ad with ID " + companionAd.id + " - looking for a div to match the sizing (" + companionAd.width + "," + companionAd.height + ")", Debuggable.DEBUG_CUEPOINT_EVENTS);
					var matchFound:Boolean = false;
					var matched:Boolean = false;
					for(var i:int=0; i < companionDivIDs.length; i++) {
						matched = false;
						if(companionDivIDs[i].activeAdID != undefined && companionDivIDs[i].activeAdID == companionAd.parentAdContainer.id) {
							doLog("Skipping display of matched companion with ID " + companionAd.id + " - DIV is already full with another companion", Debuggable.DEBUG_CUEPOINT_EVENTS);
						}
						else {
							if(companionDivIDs[i].resourceType != undefined) {
								doLog("Refining companion matching to creativeType: " + companionDivIDs[i].creativeType + " resourceType:" + companionDivIDs[i].resourceType);
								matched = companionAd.matchesSizeAndType(companionDivIDs[i].width, companionDivIDs[i].height, companionDivIDs[i].creativeType, companionDivIDs[i].resourceType);						
							}
							else {
								matched = companionAd.matchesSize(companionDivIDs[i].width, companionDivIDs[i].height);
							}
						}
						if(matched) {
							matchFound = true;
							doLog("Found a match for " + companionDivIDs[i].width + "," + companionDivIDs[i].height + " - id of matching DIV is " + companionDivIDs[i].id, Debuggable.DEBUG_CUEPOINT_EVENTS);
							var newHtml:String = companionAd.getMarkup();
							if(newHtml != null) {
								var cde:CompanionAdDisplayEvent = new CompanionAdDisplayEvent(CompanionAdDisplayEvent.DISPLAY, companionAd);
								cde.divID = companionDivIDs[i].id;
								cde.content = newHtml;
								companionDivIDs[i].activeAdID = companionAd.parentAdContainer.id;
								dispatchEvent(cde);
								makeJavascriptAPICall("onCompanionAdShow()");
							}
						}
					}
					if(!matchFound) doLog("No DIV match found for sizing (" + companionAd.width + "," + companionAd.height + ")", Debuggable.DEBUG_CUEPOINT_EVENTS);				
				}
				else doLog("No DIVS specified for companion ads to be displayed", Debuggable.DEBUG_CUEPOINT_EVENTS);           				
			}
		}
		
		public function onHideCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
			if(_config.restoreCompanions) {
				dispatchEvent(new CompanionAdDisplayEvent(CompanionAdDisplayEvent.HIDE, companionEvent.ad as CompanionAd));				
  				makeJavascriptAPICall("onCompanionAdHide()");
			}
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