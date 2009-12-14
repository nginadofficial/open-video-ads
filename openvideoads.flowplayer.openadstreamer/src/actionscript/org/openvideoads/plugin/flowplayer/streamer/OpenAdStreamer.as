/*    
 *    Copyright (c) 2009 Open Video Ads - Option 3 Ventures Limited
 *
 *    This file is part of the Open Video Ads Flowplayer Open Ad Streamer.
 *
 *    The Open Ad Streamer is free software: you can redistribute it 
 *    and/or modify it under the terms of the Lesser GNU General Public License 
 *    as published by the Free Software Foundation, either version 3 of 
 *    the License, or (at your option) any later version.
 *
 *    The Open Ad Streamer is distributed in the hope that it will be 
 *    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the Lesser GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.plugin.flowplayer.streamer {
	import flash.display.DisplayObject;
	import flash.external.ExternalInterface;
	
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.ClipType;
	import org.flowplayer.model.Cuepoint;
	import org.flowplayer.model.DisplayPluginModel;
	import org.flowplayer.model.PlayerEvent;
	import org.flowplayer.model.Plugin;
	import org.flowplayer.model.PluginModel;
	import org.flowplayer.util.PropertyBinder;
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.view.Flowplayer;
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
	import org.openvideoads.vast.events.CompanionAdDisplayEvent;
	import org.openvideoads.vast.events.LinearAdDisplayEvent;
	import org.openvideoads.vast.events.NonLinearSchedulingEvent;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.SeekerBarEvent;
	import org.openvideoads.vast.events.StreamSchedulingEvent;
	import org.openvideoads.vast.events.TemplateEvent;
	import org.openvideoads.vast.events.TrackingPointEvent;
	import org.openvideoads.vast.model.CompanionAd;
	import org.openvideoads.vast.playlist.Playlist;
	import org.openvideoads.vast.schedule.StreamConfig;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.tracking.TimeEvent;
	import org.openvideoads.vast.tracking.TrackingPoint;
	import org.openvideoads.vast.tracking.TrackingTable;
    	
	/**
	 * @author Paul Schulz
	 */
	public class OpenAdStreamer extends AbstractSprite implements Plugin {
		protected var _player:Flowplayer;
		protected var _model:PluginModel;
       	protected var _vastController:VASTController;
		protected var _wasZeroVolume:Boolean = false;
		protected var _activeStreamIndex:int = -1;
        protected var _playlist:Playlist;
        protected var _previousDivContent:Array = new Array();
        protected var _clipList:Array = new Array();
        protected var _activeShowClip:Clip = null;
        protected var _originalHeight:Number = 360;
        protected var _originalWidth:Number = 640;
        protected var _prependedClipCount:int = 0;
        
        public static var OAS_VERSION:String = "v0.4.0.3";
        
        protected static var STREAMING_PROVIDERS:Object = {
            rtmp: "flowplayer.rtmp-3.1.2.swf"
        };

		public function OpenAdStreamer() {
		}

		public function onConfig(model:PluginModel):void {
			_model = model;
		}
						
		public function onLoad(player:Flowplayer):void {
			_player = player;
			/*
			getControlsHandle().addEventListener("onShowed", 
				function processPluginEvent(pluginEvent:PluginEvent):void {
					doLog("**** ON PLUGIN EVENT *****");			
				}
			);
			*/
			_originalWidth = _player.screen.getDisplayObject().width;
			_originalHeight = _player.screen.getDisplayObject().height;
            initialiseVASTFramework();
            registerPlayOnceHandlers();
		}
	
		public function getDefaultConfig():Object {
			return { top: 0, left: 0, width: "100%", height: "100%" };
		}

		override protected function onResize():void {
			super.onResize();
			if(_vastController != null) {
				doLog("Resizing to w:" + width + " h:" + height, Debuggable.DEBUG_DISPLAY_EVENTS);
				_vastController.resizeOverlays(
						new DisplayProperties(
								this, 
								width, 
								height, 
								25, 
	            				_originalWidth, 
    	        				_originalHeight
						)
				);
			}
		}

/*
		private function getControlsHandle():Controls {
			var controlProps:org.flowplayer.model.DisplayProperties = _player.pluginRegistry.getPlugin("controls") as org.flowplayer.model.DisplayProperties;
			return controlProps.getDisplayObject() as Controls;
		}	
*/
			        				
		protected function initialiseVASTFramework():void {
			// load up the Open Ad Stream JSON config
			var config:Config = (new PropertyBinder(new Config(), null).copyProperties(_model.config) as Config);
			
			// preserve the playlist if one has been specified and set that as the "shows" config before initialising
			// the VASTControlller - there is always 1 clip in the flowplayer playlist
			// even if no clips have been specified in the config - if there isn't a URL in the first clip, then
			// it's empty in the config - this is a bit of a hack - is there a better way to determine this?
			
			if(_player.playlist.clips[0].url != null) {
				doLog("Shows configuration include items from the Flowplayer playlist " + _player.playlist.toString(), Debuggable.DEBUG_CONFIG);
				if(config.hasStreams()) {
					config.prependStreams(convertFlowplayerPlaylistToShowStreamConfig());
				}
				else config.streams = convertFlowplayerPlaylistToShowStreamConfig();
				
				doLog("Total show configuration is: " + config.streams.length + " (length)", Debuggable.DEBUG_CONFIG);
				for(var i:int=0; i < config.streams.length; i++) {
					doLog("- clip " + i + ": " + config.streams[i].file, Debuggable.DEBUG_CONFIG);
				}

				/*
				if(config.hasShowsDefined()) {
					_clipList = _player.playlist.clips;
					_activeShowClip = _clipList[_clipList.length - 1];
					_prependedClipCount = _clipList.length;			
				}
				else {
					doLog("Shows configuration will be taken directly from the Flowplayer playlist " + _player.playlist.toString(), Debuggable.DEBUG_CONFIG);
					config.streams = convertFlowplayerPlaylistToShowStreamConfig();
				}
				*/
			}
			else doLog("No Flowplayer playlist defined - relying on internal show stream configuration", Debuggable.DEBUG_CONFIG);
			
			// Initialise the VAST Controller
			_vastController = new VASTController();
			_vastController.trackStreamSlices = false;     // we will use the flowplayer instream API
			_vastController.startStreamSafetyMargin = 300; // needed because cuepoints at 0 for FLVs don't fire		
			_vastController.initialise(config);
			
			doLog("Flowplayer Open Video Ad Streamer constructed - " + OAS_VERSION, Debuggable.DEBUG_ALL);
            			
			// Setup the player tracking events
			_player.onFullscreen(onFullScreen);
			_player.onFullscreenExit(onFullScreenExit);
			_player.onMute(onMuteEvent);
			_player.onUnmute(onUnmuteEvent);
			_player.onVolume(onProcessVolumeEvent);  
			_player.playlist.onPause(onPauseEvent);
			_player.playlist.onResume(onResumeEvent);
			_player.playlist.onBeforeBegin(onPlaylistStart);

            // Setup the critical listeners for the template loading process
            _vastController.addEventListener(TemplateEvent.LOADED, onTemplateLoaded);
            _vastController.addEventListener(TemplateEvent.LOAD_FAILED, onTemplateLoadError);

            // Setup the linear ad listeners
            _vastController.addEventListener(LinearAdDisplayEvent.STARTED, onLinearAdStarted);
            _vastController.addEventListener(LinearAdDisplayEvent.COMPLETE, onLinearAdComplete); 
            _vastController.addEventListener(LinearAdDisplayEvent.CLICK_THROUGH, onLinearAdClickThrough);           
           
           // Setup the companion display listeners
            _vastController.addEventListener(CompanionAdDisplayEvent.DISPLAY, onDisplayCompanionAd);
            _vastController.addEventListener(CompanionAdDisplayEvent.HIDE, onHideCompanionAd);

            // Decide how to handle overlay displays - if through the framework, turn it on, otherwise register the event callbacks
            _vastController.enableNonLinearAdDisplay(
            		new DisplayProperties(
            				this, 
            				_originalWidth, 
            				_originalHeight, 
            				25
            		)
            );
            _vastController.addEventListener(OverlayAdDisplayEvent.DISPLAY, onDisplayOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.HIDE, onHideOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.DISPLAY_NON_OVERLAY, onDisplayNonOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.HIDE_NON_OVERLAY, onHideNonOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.CLICKED, onOverlayClicked);
            _vastController.addEventListener(OverlayAdDisplayEvent.CLOSE_CLICKED, onOverlayCloseClicked);
            _vastController.addEventListener(AdNoticeDisplayEvent.DISPLAY, onDisplayNotice);
            _vastController.addEventListener(AdNoticeDisplayEvent.HIDE, onHideNotice);
          
            // Setup the hander for tracking point set events
            _vastController.addEventListener(TrackingPointEvent.SET, onSetTrackingPoint);
            _vastController.addEventListener(TrackingPointEvent.FIRED, onTrackingPointFired);
            
            // Setup the hander for display events on the seeker bar
            _vastController.addEventListener(SeekerBarEvent.TOGGLE, onToggleSeekerBar);
            
            // Ok, let's load up the VAST data from our Ad Server - when the stream sequence is constructed, register for callbacks
            _vastController.addEventListener(StreamSchedulingEvent.SCHEDULE, onStreamSchedule);
            _vastController.addEventListener(NonLinearSchedulingEvent.SCHEDULE, onNonLinearSchedule);
            _vastController.load();	
		}
				
		protected function convertFlowplayerPlaylistToShowStreamConfig():Array {
			var showStreams:Array = new Array();
			for(var index:int=0; index < _player.playlist.clips.length; index++) {
				
				showStreams.push(
				     new StreamConfig(
				     		"marker-clip:" + index, 
				     		_player.playlist.clips[index].url, 
				     		Timestamp.secondsToTimestamp(_player.playlist.clips[index].duration),
				     		false, 
				     		"any", 
				     		false, 
				     		_player.playlist.clips[index].metaData, 
				     		_player.playlist.clips[index].autoPlay, 
				     		_player.playlist.clips[index].provider,
			     			{
								"customProperties": _player.playlist.clips[index].customProperties,
								"accelerated": _player.playlist.clips[index].accelerated,
								"autoBuffering": _player.playlist.clips[index].autoBuffering,
								"bufferLength": _player.playlist.clips[index].bufferLength,
								"fadeInSpeed": _player.playlist.clips[index].fadeInSpeed,
								"fadeOutSpeed": _player.playlist.clips[index].fadeOutSpeed,
								"image": _player.playlist.clips[index].image,
								"linkUrl": _player.playlist.clips[index].linkUrl,
								"linkWindow": _player.playlist.clips[index].linkWindow,
								"live": _player.playlist.clips[index].live,
								"position": _player.playlist.clips[index].position,
								"scaling": _player.playlist.clips[index].scaling,
								"seekableOnBegin": _player.playlist.clips[index].seekableOnBegin,
								"baseUrl": _player.playlist.clips[index].baseUrl,
								"autoPlay": _player.playlist.clips[index].autoPlay,
								"isOriginallyPlaylistClip": true,
								"originalPlaylistIndex": index				     				
			     			}
				     )
				); 
			}
			return showStreams;
		}
		
	    protected function registerPlayOnceHandlers():void {
            // Before the clip plays, check if it has already been played and reset the repeatable tracking points
            _player.playlist.onBegin(
            		function(clipevent:ClipEvent):void { 
						if(_player.playlist.clips[_player.playlist.currentIndex] is ScheduledClip) {
	            			_vastController.resetRepeatableTrackingPoints(getActiveStreamIndex()); //_player.playlist.currentIndex);
	            			if(_vastController.playOnce) {
					        	var currentClip:ScheduledClip = _player.playlist.clips[_player.playlist.currentIndex] as ScheduledClip;
					        	if(currentClip.marked) {
					        		doLog("Skipped clip at schedule index " + getActiveStreamIndex() + " as it's already been played", Debuggable.DEBUG_PLAYLIST);
					        		_player.next();		        			
					        	}  
	            			}							
						}
      					else doLog("Not assessing marked (playOnce) state on clip at playlist index " + _player.playlist.currentIndex + " - it's not a scheduled clip", Debuggable.DEBUG_PLAYLIST);
            		} 
            );

            // Before the clip finishes, mark is as having been played
            _player.playlist.onFinish(
            		function(clipevent:ClipEvent):void { 
						if(_player.playlist.clips[_player.playlist.currentIndex] is ScheduledClip) {
	            			if(_vastController.playOnce) {
					        	var currentClip:ScheduledClip = _player.playlist.clips[_player.playlist.currentIndex] as ScheduledClip;
		 						if(_vastController.streamSequence.streamAt(getActiveStreamIndex()) is AdSlot) {
					        		currentClip.marked = true;
		 							doLog("Marking the current clip (schedule index " + getActiveStreamIndex() + ") - it's an ad that has been played once", Debuggable.DEBUG_PLAYLIST);
		 						}
	            			}
      					}
      					else doLog("Not setting marked state on clip at playlist index " + _player.playlist.currentIndex + " - it's not a scheduled clip", Debuggable.DEBUG_PLAYLIST);
            		}
            );
	    }		
		
		// Stream scheduling callbacks
		
		private function clipIsSplashImage(clipName:String):Boolean {
        	if(clipName != null) {
        		var pattern:RegExp = new RegExp('.jpg|.png|.gif|.JPG|.PNG|.GIF');
        		return (clipName.match(pattern) != null);
        	}
        	return false;			
		}
		
		private function getClipNameFromEvent(event:StreamSchedulingEvent):String {
            if(event.stream.playerConfig.isOriginallyPlaylistClip == true) {
            	return event.stream.streamName;
            }    
            else { 
	            if(event.stream.isRTMP()) {
					return event.stream.streamName;  
	            }
	            else return event.stream.url;
            }       			
		}
						
		protected function onStreamSchedule(event:StreamSchedulingEvent):void {				
			doLogAndTrace("NOTIFICATION: Scheduling stream '" + event.stream.id + "' ('" + event.stream.streamName + "') at index " + event.scheduleIndex, event, Debuggable.DEBUG_CONFIG);

			var clip:Clip = new ScheduledClip();
			clip.type = ClipType.fromMimeType(event.stream.mimeType); 
			clip.start = event.stream.getStartTimeAsSeconds();
			clip.duration = event.stream.getDurationAsInt();
			(clip as ScheduledClip).originalDuration = event.stream.getOriginalDurationAsInt();
            PlayerConfig.setClipConfig(clip, event.stream.playerConfig);

		    // we need to set the autoPlay
		    if(_clipList.length == 0) {
		    	if(clipIsSplashImage(getClipNameFromEvent(event))) {
		    		// don't do anything this time around, we'll set it on the next round
		    	}
		    	else {
		    		clip.autoPlay = _vastController.autoPlay();
		    	}	
		    }
		    else if(_clipList.length == 1) {
		    	// we just have 1 pre-pended clip, so if it's an image, set autoplay on our clip, otherwise
		    	// set it on the pre-pended stream
		    	if(clipIsSplashImage(_clipList[0])) { 
		    		clip.autoPlay = _vastController.autoPlay();
					doLog("clipList == 1: clip[0] is an image so autoPlay set on clip[1] to: " + clip.autoPlay, Debuggable.DEBUG_CONFIG);
		    	}
		    	else {
		    		_clipList[0].autoPlay = _vastController.autoPlay();
					doLog("clipList == 1: autoPlay set on clip[0] to: " + _clipList[0].autoPlay, Debuggable.DEBUG_CONFIG);
		    	}
		    }

			(clip as ScheduledClip).key = event.scheduleIndex;

            if(event.stream.playerConfig.isOriginallyPlaylistClip == true) {
            	clip.url = event.stream.streamName;
            	clip.setCustomProperty("netConnectionUrl", event.stream.playerConfig.baseUrl);
	           	clip.provider = event.stream.provider;
            }    
            else { 
	            if(event.stream.isRTMP()) {
					clip.url = event.stream.streamName;  
					clip.setCustomProperty("netConnectionUrl", event.stream.baseURL);
		            clip.provider = _vastController.getProvider("rtmp");
	            }
	            else {
					clip.url = event.stream.url;
					doLog("Clip provider set to " + _vastController.getProvider("http"), Debuggable.DEBUG_CONFIG);
		            clip.provider = _vastController.getProvider("http");
	            }					            	
            }       
            
			clip.setCustomProperty("metaData", event.stream.metaData);

			if(event.stream is AdSlot) {
				var adSlot:AdSlot = event.stream as AdSlot;
			}
			else {
				_activeShowClip = clip;
			}

            // Setup the flowplayer cuepoints based on the tracking points defined for this stream 
            // (including companions attached to linear ads)
            
			var trackingTable:TrackingTable = event.stream.getTrackingTable();
			for(var i:int=0; i < trackingTable.length; i++) {
				var trackingPoint:TrackingPoint = trackingTable.pointAt(i);
				if(trackingPoint.isLinear()) {
		            clip.addCuepoint(new Cuepoint(trackingPoint.milliseconds, trackingPoint.label + ":" + event.scheduleIndex));
					doLog("Flowplayer Linear CUEPOINT set at " + trackingPoint.milliseconds + " with label " + trackingPoint.label + ":" + event.scheduleIndex, Debuggable.DEBUG_CUEPOINT_FORMATION);
				}
			}

            clip.onCuepoint(processCuepoint);
			
			if(event.stream is AdSlot) {
            	if(adSlot.isMidRoll()) {
					// If it's a mid-roll, insert the clip as a child of the current show stream
            		if(_activeShowClip != null) {
	    	   			doLog("Adding mid-roll ad as child (running time " + clip.duration + ") " + clip.provider + " - " + clip.baseUrl + ", " + clip.url, Debuggable.DEBUG_SEGMENT_FORMATION);
    	                if(_activeShowClip is ScheduledClip) {
	    	                _activeShowClip.duration = (_activeShowClip as ScheduledClip).originalDuration;	                	
    	                }
    	                clip.position = event.stream.getStartTimeAsSeconds(); 
    	                clip.start = 0;   	 
						_activeShowClip.addChild(clip);
            		}
            		else doLog("Cannot insert mid-roll ad - there is no active show clip to insert it into", Debuggable.DEBUG_SEGMENT_FORMATION);
           			return;            		            			
            	}	
			}
			else {
				_activeShowClip = clip;
				
	            if(event.stream.isSlicedStream() && (event.stream.getStartTimeAsSeconds() > 0)) {
	            	// because we are using the Flowplayer in-stream API, we don't sequence parts of the original show stream
	            	// as separate clips in the playlist - so ignore any subsequent streams in the sequence that are spliced
	            	return;
	            }
			}
            
	        // It's not a mid-roll ad so add in the clip to the end of the clip list
    	    doLog("Adding clip " + clip.provider + " - " + clip.baseUrl + ", " + clip.url, Debuggable.DEBUG_SEGMENT_FORMATION);
        	_clipList.push(clip);
		}

		protected function onNonLinearSchedule(event:NonLinearSchedulingEvent):void {
			var adjustedStreamIndex:int = _vastController.getStreamSequenceIndexGivenOriginatingIndex(event.adSlot.originatingAssociatedStreamIndex, true, true);
			doLogAndTrace("NOTIFICATION: Scheduling non-linear ad '" + event.adSlot.id + "' against stream at index " + adjustedStreamIndex + " ad slot is " + event.adSlot.key, event, Debuggable.DEBUG_SEGMENT_FORMATION);

            // setup the flowplayer cuepoints for non-linear ads (including companions attached to non-linear ads)
			var trackingTable:TrackingTable = event.adSlot.getTrackingTable();
			for(var i:int=0; i < trackingTable.length; i++) {
				var trackingPoint:TrackingPoint = trackingTable.pointAt(i);
				if(trackingPoint.isNonLinear() && !trackingPoint.isForLinearChild) {
					if(adjustedStreamIndex > -1) {
						if(adjustedStreamIndex <= _clipList.length) {
//				            _clipList[adjustedStreamIndex].addCuepoint(new Cuepoint(trackingPoint.milliseconds, trackingPoint.label + ":" + event.adSlot.originatingAssociatedStreamIndex)); 
				            _clipList[adjustedStreamIndex].addCuepoint(new Cuepoint(trackingPoint.milliseconds, trackingPoint.label + ":" + event.adSlot.associatedStreamIndex)); 
							doLog("Flowplayer NonLinear CUEPOINT set at " + trackingPoint.milliseconds + " with label " + trackingPoint.label + ":" + event.adSlot.associatedStreamIndex, Debuggable.DEBUG_CUEPOINT_FORMATION);			
						}
						else doLog("FATAL: Adjusted stream index (" + adjustedStreamIndex + ") to map overlay is greater than length of clip list (" + _clipList.length + ")", Debuggable.DEBUG_FATAL);
					}
					else doLog("FATAL: Cannot map non-linear ad to a valid stream index", Debuggable.DEBUG_FATAL);
				}
			}
		}			

		// Tracking Point event callbacks

		protected function onSetTrackingPoint(event:TrackingPointEvent):void {
			// Not using this callback as the flowplayer cuepoints must be set on the clip when the clip is added to the playlist (see onStreamSchedule)
			doLog("NOTIFICATION: Request received to set a tracking point (" + event.trackingPoint.label + ") at " + event.trackingPoint.milliseconds + " milliseconds", Debuggable.DEBUG_TRACKING_EVENTS);
		}

		protected function onTrackingPointFired(event:TrackingPointEvent):void {
			doLog("NOTIFICATION: Request received that a tracking point was fired (" + event.trackingPoint.label + ") at " + event.trackingPoint.milliseconds + " milliseconds", Debuggable.DEBUG_TRACKING_EVENTS);
			/*			
				switch(event.eventType) {
					case TrackingPointEvent.LINEAR_AD_STARTED:
					case TrackingPointEvent.LINEAR_AD_COMPLETE:
				}
			*/
		}

		protected function processCuepoint(clipevent:ClipEvent):void {
			var cuepoint:Cuepoint = clipevent.info as Cuepoint;
	    	var streamIndex:int = parseInt(cuepoint.callbackId.substr(3));
    	    var eventCode:String = cuepoint.callbackId.substr(0,2);
			doLog("Cuepoint triggered " + clipevent.toString() + " - id: " + cuepoint.callbackId, Debuggable.DEBUG_CUEPOINT_EVENTS);
	       	_vastController.processTimeEvent(streamIndex, new TimeEvent(clipevent.info.time, 0, eventCode));            	            
		}

		protected function processOverlayVideoAdCuepoint(clipevent:ClipEvent):void {
			var cuepoint:Cuepoint = clipevent.info as Cuepoint;
	    	var streamIndex:int = parseInt(cuepoint.callbackId.substr(3));
	        var eventCode:String = cuepoint.callbackId.substr(0,2);
			doLog("Overlay cuepoint triggered " + clipevent.toString() + " - id: " + cuepoint.callbackId, Debuggable.DEBUG_CUEPOINT_EVENTS);
	        _vastController.processOverlayLinearVideoAdTimeEvent(streamIndex, new TimeEvent(clipevent.info.time, 0, eventCode));            	            
		}
		
		// VAST data event callbacks
		
		protected function onTemplateLoaded(event:TemplateEvent):void {
			doLogAndTrace("NOTIFICATION: VAST data loaded - ", event.template, Debuggable.DEBUG_VAST_TEMPLATE);
            _player.playlist.replaceClips2(_clipList);
            _model.dispatchOnLoad();
		}

		protected function onTemplateLoadError(event:TemplateEvent):void {
			doLog("NOTIFICATION: FAILURE loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL);
		}

        // Seekbar callbacks

		public function onToggleSeekerBar(event:SeekerBarEvent):void {
			if(_vastController.disableControls) {
 			    doLog("NOTIFICATION: Request received to change the control bar state to " + ((event.turnOff()) ? "BLOCKED" : "ON"), Debuggable.DEBUG_DISPLAY_EVENTS);
				var model:DisplayPluginModel = _player.pluginRegistry.getPlugin("controls") as DisplayPluginModel;
				if(model != null) {
					var controls:DisplayObject = model.getDisplayObject();
					if(!event.turnOff()) {
						doLog("Turning the scrubber on", Debuggable.DEBUG_TRACKING_EVENTS);
						controls["enable"]({ scrubber: true });					
					}	
					else {
						doLog("Turning the scrubber off", Debuggable.DEBUG_TRACKING_EVENTS);
						controls["enable"]({ scrubber: false });					
					}					
				}
				else doLog("Failed to get a handle to the control bar - change of control bar state ignored", Debuggable.DEBUG_FATAL);
			}
			else doLog("NOTIFICATION: Ignoring request to change control bar state", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

        // Linear Ad callbacks

		public function onLinearAdStarted(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received that linear ad has started", Debuggable.DEBUG_DISPLAY_EVENTS);
		}	

		public function onLinearAdComplete(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received that linear ad is complete", Debuggable.DEBUG_DISPLAY_EVENTS);
		}	

		public function onLinearAdClickThrough(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received that linear ad click through activated", Debuggable.DEBUG_DISPLAY_EVENTS);			
			if(_vastController.pauseOnClickThrough) _player.pause();
		}

        // Ad Notice callbacks

		public function onDisplayNotice(displayEvent:AdNoticeDisplayEvent):void {	
			doLog("NOTIFICATION: Event received to display ad notice", Debuggable.DEBUG_DISPLAY_EVENTS);
		}
				
		public function onHideNotice(displayEvent:AdNoticeDisplayEvent):void {	
			doLog("NOTIFICATION: Event received to hide ad notice", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

        // Overlay callbacks
				
		public function onOverlayCloseClicked(displayEvent:OverlayAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received - overlay close has been clicked", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

		public function onDisplayOverlay(displayEvent:OverlayAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received to display non-linear overlay ad", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

		public function onOverlayClicked(displayEvent:OverlayAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received - overlay has been clicked!", Debuggable.DEBUG_DISPLAY_EVENTS);
			if(displayEvent.ad.hasAccompanyingVideoAd()) {
				var clip:ScheduledClip = new ScheduledClip();
				var overlayAdSlot:AdSlot = _vastController.adSchedule.getSlot(displayEvent.adSlotKey);
				
				clip.type = ClipType.fromMimeType(overlayAdSlot.mimeType);
				clip.start = 0;
				clip.originalDuration = overlayAdSlot.getAttachedLinearAdDurationAsInt();
				clip.duration = clip.originalDuration;
  			    clip.key = displayEvent.adSlotKey;
  			    clip.isOverlayLinear = true; 
				clip.setCustomProperty("metaData", overlayAdSlot.metaData);
	            if(overlayAdSlot.isRTMP()) {
					clip.url = overlayAdSlot.streamName;
					clip.setCustomProperty("netConnectionUrl", overlayAdSlot.baseURL);
		            clip.provider = _vastController.getProvider("rtmp");
            	}
            	else {
					clip.url = overlayAdSlot.url;
		            clip.provider = _vastController.getProvider("http");
            	}
	            PlayerConfig.setClipConfig(clip, overlayAdSlot.playerConfig);

            	// Setup the flowplayer cuepoints based on the tracking points defined for this 
            	// linear ad (including companions attached to linear ads)

            	clip.onCuepoint(processOverlayVideoAdCuepoint);
				var trackingTable:TrackingTable = overlayAdSlot.getTrackingTable();
				for(var i:int=0; i < trackingTable.length; i++) {
					var trackingPoint:TrackingPoint = trackingTable.pointAt(i);
					if(trackingPoint.isLinear() && trackingPoint.isForLinearChild) {
			            clip.addCuepoint(new Cuepoint(trackingPoint.milliseconds, trackingPoint.label + ":" + displayEvent.adSlotKey));
						doLog("Flowplayer CUEPOINT set for attached linear ad at " + trackingPoint.milliseconds + " with label " + trackingPoint.label + ":" + displayEvent.adSlotKey, Debuggable.DEBUG_CUEPOINT_FORMATION);
					}
				}

				_player.playInstream(clip);
			}
			else _player.pause();
		}
		
		public function onHideOverlay(displayEvent:OverlayAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received to hide non-linear overlay ad", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

		public function onDisplayNonOverlay(displayEvent:OverlayAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received to display non-linear non-overlay ad", Debuggable.DEBUG_DISPLAY_EVENTS);
		}
		
		public function onHideNonOverlay(displayEvent:OverlayAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received to hide non-linear non-overlay ad", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

        // Companion Ad Display Events
        
        public function onDisplayCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
			doLogAndTrace("NOTIFICATION: Event received to display companion ad", companionEvent, Debuggable.DEBUG_DISPLAY_EVENTS);
        	_previousDivContent = new Array();
        	if(companionEvent.contentIsHTML()) {
				var previousContent:String = ExternalInterface.call("function(){ return document.getElementById('" + companionEvent.divID + "').innerHTML; }");
				_previousDivContent.push({ divId: companionEvent.divID, content: previousContent } );
				ExternalInterface.call("function(){ document.getElementById('" + companionEvent.divID + "').innerHTML='" + StringUtils.replaceSingleWithDoubleQuotes(companionEvent.content) + "'; }");
        	}
        	else {
        		//TO IMPLEMENT isImage(), isFlash(), isText()
        	}
        }

        public function onDisplayCompanionSWF(companionEvent:CompanionAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received to display companion ad (SWF)", Debuggable.DEBUG_DISPLAY_EVENTS);
        	// NOT IMPLEMENTED
        }

        public function onDisplayCompanionText(companionEvent:CompanionAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received to display companion ad (Text)", Debuggable.DEBUG_DISPLAY_EVENTS);
        	// NOT IMPLEMENTED
        }
        
		public function onHideCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
            doLogAndTrace("NOTIFICATION: Request received to hide companion ad", companionEvent, Debuggable.DEBUG_DISPLAY_EVENTS);
            
			var companionAd:CompanionAd = companionEvent.ad as CompanionAd;
			doLog("Event trigger received to hide the companion Ad with ID " + companionAd.id, Debuggable.DEBUG_CUEPOINT_EVENTS);
			for(var i:int=0; i < _previousDivContent.length; i++) {
				ExternalInterface.call("function(){ document.getElementById('" + _previousDivContent[i].divId + "').innerHTML='" + StringUtils.removeControlChars(_previousDivContent[i].content) + "'; }");				
			}
			_previousDivContent = new Array();            
		}

        // VAST tracking actions

        private function getActiveStreamIndex():int {
        	if(_player.currentClip.isInStream) {
        		// we need to treat instream clips differently as "currentIndex" on the playlist is -1
        		doLog("Returning stream index as " + (_player.currentClip as ScheduledClip).key);
        		return (_player.currentClip as ScheduledClip).key;
        	}
        	return _player.playlist.currentIndex - _prependedClipCount;
        }
        
        private function isActiveLinearClipOverlay():Boolean {
			var activeClip:ScheduledClip = _player.currentClip as ScheduledClip;
			return activeClip.isOverlayLinear;        	
        }
        
        
		private function onPlaylistStart(event:ClipEvent):void {
			if(_vastController != null && _player.playlist.currentIndex == 0) {
				_vastController.processImpressionsToForceFire();
			}
		}
        
		private function onPauseEvent(playlistEvent:ClipEvent):void {
        	if(_vastController != null) _vastController.onPlayerPause(getActiveStreamIndex(), isActiveLinearClipOverlay());
		}

		private function onResumeEvent(playlistEvent:ClipEvent):void {
        	if(_vastController != null) _vastController.onPlayerResume(getActiveStreamIndex(), isActiveLinearClipOverlay());
		}

        private function onSeekEvent(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerSeek(getActiveStreamIndex(), isActiveLinearClipOverlay());
        }

		private function onMuteEvent(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerMute(getActiveStreamIndex(), isActiveLinearClipOverlay());
		}

		private function onUnmuteEvent(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerUnmute(getActiveStreamIndex(), isActiveLinearClipOverlay());
		}

		private function onPlayEvent(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerPlay(getActiveStreamIndex(), isActiveLinearClipOverlay());			
		}

		private function onStopEvent(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerStop(getActiveStreamIndex(), isActiveLinearClipOverlay());
		}
		
		private function onFullScreen(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerResize(getActiveStreamIndex(), isActiveLinearClipOverlay());
		}

		private function onFullScreenExit(playerEvent:PlayerEvent):void {
			// We are not doing anything with this event
		}

        private function onProcessVolumeEvent(playerEvent:PlayerEvent):void {
        	if(_player.volume == 0) {
        		_wasZeroVolume = true;
        		onMuteEvent(playerEvent);
        	}
        	else {
        		if(_wasZeroVolume) {
        			onUnmuteEvent(playerEvent);
        		}
        		_wasZeroVolume = false;
        	}
        }

		// EXTERNAL API
		
		[External]
		public function getVastTemplateAsString():String {	
			doLog("OpenAdStreamer: External request received to get VAST template as string", Debuggable.DEBUG_JAVASCRIPT);
			return "not implemented";
		}

		[External]
		public function defineRegion(regionID:String, properties:Object):String {
			return "not implemented";
		}

		[External]
		public function hideRegion(regionID:String):String {
			return "not implemented";
		}

		[External]
		public function showRegion(regionID:String):String {
			return "not implemented";
		}

		[External]
		public function setRegionStyle(regionID:String, cssText:String):String {
			doLog("OpenAdStreamer: External trigger to set style for region: " + regionID + " to " + cssText, Debuggable.DEBUG_JAVASCRIPT);
			return _vastController.setRegionStyle(regionID, cssText);
		}

		[External]
		public function setRegionHTML(regionID:String, html:String):String {
			return "not implemented";
		}
		
		[External]
		public function setRegionHeight(regionID:String, height:String):String {
			return "not implemented";
		}

		[External]
		public function setRegionWidth(regionID:String, height:String):String {
			return "not implemented";
		}

		[External]
		public function setRegionDimensions(regionID:String, height:String, width:String):String {
			return "not implemented";
		}
										
		[External]
		public function setRegionVerticalAlign(regionID:String, verticalAlign:Boolean):String {
			return "not implemented";
		}

		[External]
		public function setRegionHorizontalAlign(regionID:String, horizontalAlign:Boolean):String {
			return "not implemented";
		}

		[External]
		public function setRegionBackgroundColor(regionID:String, color:String):String {
			return "not implemented";
		}
		
		[External]
		public function setRegionOpacity(regionID:String, opacity:String):String {
			return "not implemented";
		}
		
		[External]
		public function setRegionPadding(regionID:String, height:String):String {
			return "not implemented";
		}
		
		[External]
		public function setRegionCloseButtonVisible(regionID:String, visible:Boolean):String {
			return "not implemented";
		}

		[External]
		public function setRegionKeepAfterClick(regionID:String, keepAfterClick:Boolean):String {
			return "not implemented";
		}

		[External]
		public function setDebugLevel(level:int):void {
			doLog("OpenAdStreamer: External trigger to set debug level to: " + level, Debuggable.DEBUG_JAVASCRIPT);
			Debuggable.getInstance().level = level;
		}

		// DEBUG METHODS
	
		protected function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		protected function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
		
		protected function doLogAndTrace(data:String, o:Object, level:int=1):void {
			Debuggable.getInstance().doLogAndTrace(data, o, level);
		}
	}
}
