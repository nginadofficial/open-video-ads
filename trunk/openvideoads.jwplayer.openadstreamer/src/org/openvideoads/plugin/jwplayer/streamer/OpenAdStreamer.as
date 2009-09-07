/*    
 *    Copyright (c) 2009 Open Video Ads - Option 3 Ventures Limited
 *
 *    This file is part of the Open Video Ads JW Player Open Ad Streamer.
 *
 *    The Open Ad Streamer is free software: you can redistribute it 
 *    and/or modify it under the terms of the GNU General Public License 
 *    as published by the Free Software Foundation, either version 3 of 
 *    the License, or (at your option) any later version.
 *
 *    The Open Ad Streamer is distributed in the hope that it will be 
 *    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.plugin.jwplayer.streamer {
	import com.jeroenwijering.events.*;
	import com.jeroenwijering.parsers.XSPFParser;
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	
	import json.*;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
	import org.openvideoads.vast.events.CompanionAdDisplayEvent;
	import org.openvideoads.vast.events.LinearAdDisplayEvent;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.SeekerBarEvent;
	import org.openvideoads.vast.events.TemplateEvent;
	import org.openvideoads.vast.events.TrackingPointEvent;
	import org.openvideoads.vast.model.CompanionAd;
	import org.openvideoads.vast.playlist.Playlist;
	import org.openvideoads.vast.playlist.xspf.XSPFPlaylist;
	import org.openvideoads.vast.tracking.TimeEvent;	
	    
	public class OpenAdStreamer extends MovieClip implements PluginInterface {
        protected var _activeStreamIndex:Number = 0;
        protected var _vastController:VASTController;
        protected var _playlist:XSPFPlaylist;
        protected var _playingOverlayLinearVideoAd:Boolean = false;
        protected var _timeOverlayLinearVideoAdTriggered:int = -1;
        protected var _lastTimeTick:Number = 0;
        protected var _previousDivContent:Array = new Array();
	    protected var _view:AbstractView;

		public var config:Object = {
			title: "Open Ad Streamer",
			json: null
		};
                
		public function OpenAdStreamer():void {
			doLog("JWPlayer Open Ad Streamer plug-in constructed - build 0.3.0", Debuggable.DEBUG_ALL);
		}

		public function initializePlugin(view:AbstractView):void {	
			doLog("Initialising plugin...", Debuggable.DEBUG_ALL);
			_view = view;
				
			// Load up the config and configure the debugger
			_vastController = new VASTController();
			_vastController.endStreamSafetyMargin = 300;
			_vastController.setTimeBaseline(VASTController.RELATIVE_TO_CLIP);
			doLog("Raw config loaded as " + config.json, Debuggable.DEBUG_CONFIG);
			_vastController.initialise(JParser.decode(config.json));
			
			// Config the player to autostart based on the config setting for "autoPlay"
			_view.config['autostart'] = _vastController.autoPlay();
   			            
            // Setup the playlist tracking events
			_view.addControllerListener(ControllerEvent.ITEM, playlistSelectionHandler);			
			_view.addModelListener(ModelEvent.STATE, streamStateHandler);
			_view.addModelListener(ModelEvent.TIME, timeHandler);

			// Setup the player tracking events
			_view.addViewListener(ViewEvent.MUTE, onMuteEvent);	
			_view.addViewListener(ViewEvent.PLAY, onPlayEvent);		
			_view.addViewListener(ViewEvent.STOP, onStopEvent);		
			_view.addViewListener(ViewEvent.FULLSCREEN, onFullScreenEvent);
			_view.addControllerListener(ControllerEvent.RESIZE, onResizeEvent);
			// MISSING PAUSE, RESUME, REPLAY, UNMUTE - NOT SUPPORTED BY PLAYER
            
            // Setup the critical listeners for the template loading process
            _vastController.addEventListener(TemplateEvent.LOADED, onTemplateLoaded);
            _vastController.addEventListener(TemplateEvent.LOAD_FAILED, onTemplateLoadError);
          
           // Setup the companion display listeners
            _vastController.addEventListener(CompanionAdDisplayEvent.DISPLAY, onDisplayCompanionAd);
            _vastController.addEventListener(CompanionAdDisplayEvent.HIDE, onHideCompanionAd);

            // Decide how to handle overlay displays - if through the framework, turn it on, otherwise register the event callbacks
            _vastController.enableNonLinearAdDisplay(new DisplayProperties(this, _view.config["width"], _view.config["height"], 25)); 
            _vastController.addEventListener(OverlayAdDisplayEvent.DISPLAY, onDisplayOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.HIDE, onHideOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.DISPLAY_NON_OVERLAY, onDisplayNonOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.HIDE_NON_OVERLAY, onHideNonOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.CLICKED, onOverlayClicked);
            _vastController.addEventListener(AdNoticeDisplayEvent.DISPLAY, onDisplayNotice);
            _vastController.addEventListener(AdNoticeDisplayEvent.HIDE, onHideNotice);
          
            // Setup linear tracking events
            _vastController.addEventListener(LinearAdDisplayEvent.CLICK_THROUGH, onLinearAdClickThrough);           
            
            // Setup the hander for tracking point set events
            _vastController.addEventListener(TrackingPointEvent.SET, onSetTrackingPoint);
            _vastController.addEventListener(TrackingPointEvent.FIRED, onTrackingPointFired);
            
            // Setup the hander for display events on the seeker bar
            _vastController.addEventListener(SeekerBarEvent.TOGGLE, onToggleSeekerBar);
            
            // Ok, let's load up the VAST data from our Ad Server
            _vastController.load();
			doLog("Initialisation complete.", Debuggable.DEBUG_ALL);
		}

		// Time point handler
		
		private function timeHandler(evt:ModelEvent):void {
			if(!_playingOverlayLinearVideoAd) {
				_lastTimeTick = evt.data.position;
				_vastController.processTimeEvent(_playlist.playingTrackIndex, new TimeEvent(evt.data.position * 1000, evt.data.duration));		
			}
//			else _vastController.processOverlayLinearVideoAdTimeEvent(0, new TimeEvent(evt.data.position * 1000, evt.data.duration));
		}
				
		// Tracking Point event callbacks
		
		protected function onSetTrackingPoint(event:TrackingPointEvent):void {
			// Not required for JW Player because we are constantly checking the 1/10th second timed events
			// by firing them directly through to the stream sequence to process.
			doLog("NOTIFICATION: Request received to set a tracking point (" + event.trackingPoint.label + ") at " + event.trackingPoint.milliseconds + " milliseconds", Debuggable.DEBUG_TRACKING_EVENTS);
		}

		protected function onTrackingPointFired(event:TrackingPointEvent):void {
			// Not required for JW Player because we are constantly checking the 1/10th second timed events
			// by firing them directly through to the stream sequence to process.
			doLog("NOTIFICATION: Request received that a tracking point was fired (" + event.trackingPoint.label + ") at " + event.trackingPoint.milliseconds + " milliseconds", Debuggable.DEBUG_TRACKING_EVENTS);
		}
		
		// VAST data event callbacks
		
		protected function onTemplateLoaded(event:TemplateEvent):void {
			doLogAndTrace("NOTIFICATION: VAST data loaded - ", event.template, Debuggable.DEBUG_VAST_TEMPLATE);
        
			_playlist = _vastController.createXSPFPlaylist(XSPFPlaylist.HTTP_STREAMER_TYPE_LIGHTTPD);
			doLogAndTrace("XSPF playlist created: " + _playlist.toString(), Debuggable.DEBUG_PLAYLIST, Debuggable.DEBUG_PLAYLIST);

			if(_vastController.allowPlaylistControl) {
				// load up the full playlist and play as a list
				_view.config.repeat="list";
				_view.sendEvent(ViewEvent.LOAD, XSPFParser.parse(_playlist.toXML()));
			}
			else { 
				// iterate through the playlist one clip at time, so just up the first
                var playlistXML:XML = _playlist.nextTrackAsPlaylistXML();
                doLog("Loading first playlist track " + playlistXML, Debuggable.DEBUG_PLAYLIST);
				_view.sendEvent(ViewEvent.LOAD, XSPFParser.parse(playlistXML));
			}
		}
		
		protected function onTemplateLoadError(event:TemplateEvent):void {
			doLog("NOTIFICATION: FAILURE loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL);
		}

        // Linear ad tracking callbacks
        
		public function onLinearAdClickThrough(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received that linear ad click through activated", Debuggable.DEBUG_DISPLAY_EVENTS);			
			if(_vastController.pauseOnClickThrough) _view.sendEvent(ControllerEvent.PLAY, false);
		}

        // Seekbar callbacks

		public function onToggleSeekerBar(event:SeekerBarEvent):void {
			if(_vastController.disableControls) {
 			    doLog("NOTIFICATION: Request received to change the control bar state to " + ((event.turnOff()) ? "BLOCKED" : "ON"), Debuggable.DEBUG_DISPLAY_EVENTS);
				var controlbar:Object = _view.getPlugin('controlbar');
				controlbar.block(event.turnOff());
			}
			else doLog("NOTIFICATION: Ignoring request to change control bar state", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

        // VAST display callbacks

		public function onDisplayNotice(displayEvent:AdNoticeDisplayEvent):void {	
			doLog("NOTIFICATION: Event received to display ad notice", Debuggable.DEBUG_DISPLAY_EVENTS);
		}
				
		public function onHideNotice(displayEvent:AdNoticeDisplayEvent):void {	
			doLog("NOTIFICATION: Event received to hide ad notice", Debuggable.DEBUG_DISPLAY_EVENTS);
		}
				
		public function onDisplayOverlay(displayEvent:OverlayAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received to display non-linear overlay ad", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

		public function onOverlayClicked(displayEvent:OverlayAdDisplayEvent):void {
			doLog("NOTIFICATION: Event received - overlay has been clicked - time is " + _lastTimeTick, Debuggable.DEBUG_DISPLAY_EVENTS);

            if(displayEvent.ad.hasAccompanyingVideoAd()) {
				_playingOverlayLinearVideoAd = true;
            	var playlist:XSPFPlaylist = _vastController.getActiveOverlayXSPFPlaylist(XSPFPlaylist.HTTP_STREAMER_TYPE_LIGHTTPD);
				if(playlist != null) {			 	        
					doLog("Loading the overlay linear ad track as playlist " + playlist, Debuggable.DEBUG_PLAYLIST);
				    _view.sendEvent(ControllerEvent.PLAY, false);				
					_view.sendEvent(ViewEvent.LOAD, XSPFParser.parse(playlist.toXML()));
					_view.sendEvent(ViewEvent.PLAY);   	        											
				}
				else {
					_playingOverlayLinearVideoAd = false;
					doLog("Cannot play the linear ad - playlist is empty: " + playlist, Debuggable.DEBUG_PLAYLIST);
				}
            }
			else {
				if(displayEvent.ad.hasClickThroughURL()) {
					// it's a website click through overlay so stop the video stream
			        _view.sendEvent(ControllerEvent.PLAY, false);				
			 	}
			}
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
        		//TO IMPLEMENT contentIsImage(), contentIsSWF()
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

        private function onSeekEvent(evt:ViewEvent):void {
        	if(_vastController != null) _vastController.onPlayerSeek(_playlist.playingTrackIndex);
        }
        
		private function onMuteEvent(evt:ViewEvent):void {
        	if(_vastController != null) _vastController.onPlayerMute(_playlist.playingTrackIndex);
		}

		private function onPlayEvent(evt:ViewEvent):void {
        	if(_vastController != null) _vastController.onPlayerPlay(_playlist.playingTrackIndex);			
		}

		private function onStopEvent(evt:ViewEvent):void {
        	if(_vastController != null) _vastController.onPlayerStop(_playlist.playingTrackIndex);
		}
		
		private function onFullScreenEvent(evt:ViewEvent):void {
        	if(_vastController != null) _vastController.onPlayerResize(_playlist.playingTrackIndex);        			
		}
		
		private function onResizeEvent(evt:ControllerEvent):void {
			// Do any regions need to be resized?
			if(_vastController != null) {
                doLog("**** RESIZING - NEW SIZE IS " + evt.data.width + " " + evt.data.height);
				_vastController.resizeOverlays(
						new DisplayProperties(
								this, 
								evt.data.width, 
								evt.data.height, 
								25, 
								_view.config["width"], 
								_view.config["height"]							
						)
				);
			}
		}

		private function playlistSelectionHandler(evt:ControllerEvent):void {
			_activeStreamIndex = evt.data.index;
            doLog("Active playlist stream index changed to " + _activeStreamIndex, Debuggable.DEBUG_PLAYLIST);
		}

		private function resumeMainPlaylistPlayback():void {
			doLog("Restoring the last active main playlist clip	- seeking forward to time " + _lastTimeTick, Debuggable.DEBUG_PLAYLIST);
	        var playlistXML:XML = _playlist.currentTrackAsPlaylistXML(_lastTimeTick);
	        if(playlistXML != null) {
	            doLog("Reloading main playlist track at " + _lastTimeTick + " which was interrupted by an overlay linear video ad " + playlistXML, Debuggable.DEBUG_PLAYLIST);
				_playingOverlayLinearVideoAd = false;
	            _view.sendEvent(ViewEvent.LOAD, XSPFParser.parse(playlistXML));
	            _view.sendEvent(ViewEvent.PLAY, true);
	        }
	        else doLog("Oops, no main playlist stream in the playlist to load", Debuggable.DEBUG_FATAL);
		}
		
		private function streamStateHandler(evt:ModelEvent):void {
			if(_playingOverlayLinearVideoAd == false) {
				// We are handling a state change on the main playlist
				switch(evt.data.newstate) {
					case "COMPLETED":
					    if(!_vastController.allowPlaylistControl) {
	                        var playlistXML:XML = _playlist.nextTrackAsPlaylistXML();
	                        if(playlistXML != null) {
	                            doLog("Loading next playlist track " + playlistXML, Debuggable.DEBUG_PLAYLIST);
	                        	_view.sendEvent(ViewEvent.LOAD, XSPFParser.parse(playlistXML));
	                        	_view.sendEvent(ViewEvent.PLAY);
	                        }
	                        else {
	                            doLog("Rewinding and reloading the entire playlist", Debuggable.DEBUG_PLAYLIST);
	                        	_playlist.rewind();
	                        	_view.sendEvent(ViewEvent.LOAD, XSPFParser.parse(_playlist.nextTrackAsPlaylistXML()));
	                        }
					    }
						break;
				}						
			}
			else {
				// We are handling the state change of an overlay linear video ad
				switch(evt.data.newstate) {
					case "COMPLETED":
						doLog("Overlay linear video ad complete - resuming normal stream", Debuggable.DEBUG_PLAYLIST);
						resumeMainPlaylistPlayback();
						break;				
				}
			}
		}
		
		// DEBUG METHODS
		
		protected static function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		protected static function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
		
		protected static function doLogAndTrace(data:String, o:Object, level:int=1):void {
			Debuggable.getInstance().doLogAndTrace(data, o, level);
		}
	}
}