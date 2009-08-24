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
package org.openvideoads.vast.schedule {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.schedule.ads.AdSchedule;
	import org.openvideoads.vast.tracking.TimeEvent;

	/**
	 * @author Paul Schulz
	 */
	public class StreamSequence extends Debuggable {
		protected var _vastController:VASTController = null;
		protected var _sequence:Array = new Array();
		protected var _totalDuration:int = 0;
		protected var _lastPauseTime:int = 0;
		protected var _bitrate:String = null;
		protected var _baseURL:String = null;
		protected var _timerFactor:int = 1;
		
		public function StreamSequence():void {
		}
		
		public function initialise(vastController:VASTController, streams:Array=null, adSequence:AdSchedule=null, bitrate:String=null, baseURL:String=null, timerFactor:int=1):void {
			_vastController = vastController;
			_timerFactor = timerFactor;
						
			if(bitrate != null) {
				_bitrate = bitrate;
			}
			if(baseURL != null) {
				_baseURL = baseURL;
			}
			if(streams != null && adSequence != null) {
				_totalDuration = build(streams, adSequence);			
			}
		}

		public function get vastController():VASTController {
			return _vastController;
		}
		
		public function get length():int {
			return _sequence.length;
		}
		
		public function streamAt(index:int):Stream {
			return _sequence[index];
		}
		
		public function get totalDuration():int {
			return _totalDuration;
		}
		
		public function hasBitRate():Boolean {
			return _bitrate != null;
		}
		
		public function get bitrate():String {
			return _bitrate;
		}
		
		public function hasBaseURL():Boolean {
			return _baseURL != null;
		}
		
		public function get baseURL():String {
			return _baseURL;
		}

		public function markPaused(timeInSeconds:int):void {
			_lastPauseTime = timeInSeconds;
		}
		
		public function get lastPauseTime():int {
			return _lastPauseTime;
		}
		
		public function resetPauseMarker():void {
			_lastPauseTime = -1;
		}
		
		private function createNewMetricsTracker():Object {
			var currentMetrics:Object = new Object();
			currentMetrics.usedAdDuration = 0;		
			currentMetrics.remainingActiveShowDuration = 0;	
			currentMetrics.usedActiveShowDuration = 0;
			currentMetrics.totalActiveShowDuration = 0;
			currentMetrics.associatedStreamIndex = 0;			
			return currentMetrics;
		}

		private function addStream(stream:Stream):void {
			stream.declareTrackingPoints(0);
			_sequence.push(stream);
			_vastController.onScheduleStream(_sequence.length-1, stream);
		}

		public function build(streams:Array, adSequence:AdSchedule):int {
			doLogAndTrace("*** START BUILDING THE SEGMENT SEQUENCE FROM MULTIPLE SHOW PARTS (" + streams.length + ")", adSequence, Debuggable.DEBUG_SEGMENT_FORMATION);
			var adSlots:Array = adSequence.adSlots;
			var trackingInfo:Array = new Array();
			var totalDuration:int = 0;
			
				var currentMetrics:Object = createNewMetricsTracker();
				currentMetrics.associatedStreamIndex = 0;
				var previousMetrics:Object = currentMetrics;
				
				if(adSequence.hasLinearAds()) {
					for(var i:int = 0; i < adSlots.length; i++) {
						if(currentMetrics.associatedStreamIndex != adSlots[i].associatedStreamIndex) {
							trackingInfo.push(currentMetrics);
							previousMetrics = currentMetrics;
							currentMetrics = createNewMetricsTracker();
							currentMetrics.associatedStreamIndex = adSlots[i].associatedStreamIndex;
						}
						if(streams.length > 0) {
							currentMetrics.totalActiveShowDuration = Timestamp.timestampToSeconds(streams[adSlots[i].associatedStreamIndex].duration);						
						}
						if(!adSlots[i].isLinear() && adSlots[i].isActive()) {
							// deal with it as an overlay that goes over the current stream
							adSlots[i].associatedStreamIndex = _sequence.length;
						}
						else if(adSlots[i].isLinear() && adSlots[i].isActive()) {
							if(adSlots[i].isPreRoll()) {
								doLog("Slotting in a pre-roll ad with id: " + adSlots[i].id, Debuggable.DEBUG_SEGMENT_FORMATION);
								if(currentMetrics.associatedStreamIndex != previousMetrics.associatedStreamIndex) {
									if(previousMetrics.usedActiveShowDuration < previousMetrics.totalActiveShowDuration) {
										// we still have some of the previous show stream to schedule before we do a pre-roll ad for the next stream
										previousMetrics.remainingActiveShowDuration = previousMetrics.totalActiveShowDuration - previousMetrics.usedActiveShowDuration;
										doLog("Slotting in the remaining (previous) show segment to play before pre-roll - segment duration is " + previousMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION);
										addStream(new Stream(this,
										                     _vastController,
										                     _sequence.length,
										                     "show-" + _sequence.length+1,
										                     streams[previousMetrics.associatedStreamIndex].filename,
														     Timestamp.secondsToTimestamp(previousMetrics.usedActiveShowDuration),
														     new String(previousMetrics.remainingActiveShowDuration),
														     new String(previousMetrics.totalActiveShowDuration),
														     true,
														     _baseURL,
															 streams[previousMetrics.associatedStreamIndex].playOnce,
															 streams[previousMetrics.associatedStreamIndex].metaData)); 
										previousMetrics.usedActiveShowDuration += previousMetrics.remainingActiveShowDuration;
										totalDuration += previousMetrics.remainingActiveShowDuration;
										doLog("Total stream duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION);								
									}
								}
							}
							else if(adSlots[i].isMidRoll()) {
								doLog("Slotting in a mid-roll ad with id: " + adSlots[i].id, Debuggable.DEBUG_SEGMENT_FORMATION);
								if(!adSlots[i].isCopy()) {
									if(previousMetrics != currentMetrics && (previousMetrics.usedActiveShowDuration < previousMetrics.totalActiveShowDuration)) {
										// we still have some of the previous show stream to schedule before we do a pre-roll ad for the next stream
										previousMetrics.remainingActiveShowDuration = previousMetrics.totalActiveShowDuration - previousMetrics.usedActiveShowDuration;
										doLog("But first we are slotting in the remaining (previous) show segment to play before mid-roll - segment duration is " + previousMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION);
										addStream(new Stream(this,
										                     _vastController,
										                     _sequence.length,
										                     "show-" + _sequence.length+1,
										                     streams[previousMetrics.associatedStreamIndex].filename,
														     Timestamp.secondsToTimestamp(previousMetrics.usedActiveShowDuration),
														     new String(previousMetrics.remainingActiveShowDuration),
														     new String(previousMetrics.totalActiveShowDuration),
														     true,
															 _baseURL,
															 streams[previousMetrics.associatedStreamIndex].playOnce, 
															 streams[previousMetrics.associatedStreamIndex].metaData)); 
										previousMetrics.usedActiveShowDuration += previousMetrics.remainingActiveShowDuration;
										totalDuration += previousMetrics.remainingActiveShowDuration;
										doLog("Total stream duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION);								
									}

									if(streams.length > 0) {
	                                	// Slice in the portion of the current program up to the mid-roll ad
										var showSliceDuration:int = adSlots[i].getStartTimeAsSeconds() - currentMetrics.usedActiveShowDuration;
										doLog("Slicing in a segment from the show starting at " + Timestamp.secondsToTimestamp(currentMetrics.usedActiveShowDuration) + " running for " + showSliceDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION);
										addStream(new Stream(this,
										                     _vastController,
										                     _sequence.length,
										                     "show-" + _sequence.length+1,
										                     streams[adSlots[i].associatedStreamIndex].filename, 
														     Timestamp.secondsToTimestamp(currentMetrics.usedActiveShowDuration),
															 new String(showSliceDuration),
														     new String(currentMetrics.totalActiveShowDuration),
															 true,
															 _baseURL,
															 streams[adSlots[i].associatedStreamIndex].playOnce,
															 streams[previousMetrics.associatedStreamIndex].metaData)); 
										currentMetrics.usedActiveShowDuration += showSliceDuration;
										totalDuration += showSliceDuration;
										doLog("Total stream duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION);
									}
								}
							}
							else { // it's post-roll 
								doLog("Slotting in a post-roll ad with id: " + adSlots[i].id, Debuggable.DEBUG_SEGMENT_FORMATION);
								if(streams.length > 0) {
										currentMetrics.remainingActiveShowDuration = currentMetrics.totalActiveShowDuration - currentMetrics.usedActiveShowDuration;
										doLog("Slotting in the remaining show segment to play before post-roll - start point is " + Timestamp.secondsToTimestamp(currentMetrics.usedActiveShowDuration) + ", segment duration is " + currentMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION);
										addStream(new Stream(this,
										                     _vastController,
										                     _sequence.length,
										                     "show-" + _sequence.length+1,
										                     streams[adSlots[i].associatedStreamIndex].filename,
														     Timestamp.secondsToTimestamp(currentMetrics.usedActiveShowDuration),
															 new String(currentMetrics.remainingActiveShowDuration),
														     new String(currentMetrics.totalActiveShowDuration),
															 true,
															 _baseURL,
															 streams[adSlots[i].associatedStreamIndex].playOnce, 
															 streams[previousMetrics.associatedStreamIndex].metaData)); 
										currentMetrics.usedActiveShowDuration += currentMetrics.remainingActiveShowDuration;
										totalDuration += currentMetrics.remainingActiveShowDuration;
										doLog("Total stream duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION);	
									}
							}

							doLog("Inserting ad to play for " + adSlots[i].duration + " seconds from " + totalDuration + " seconds into the stream", Debuggable.DEBUG_SEGMENT_FORMATION);
							adSlots[i].streamStartTime = 0;
							adSlots[i].parent = this;
							addStream(adSlots[i]);
							currentMetrics.usedAdDuration += adSlots[i].getDurationAsInt();
							doLog("Have slotted in the ad with id " + adSlots[i].id, Debuggable.DEBUG_SEGMENT_FORMATION);
							totalDuration += adSlots[i].getDurationAsInt();
							doLog("Total stream duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION);
						}
						else {
							doLog("Ad slot " + adSlots[i].id + " is not linear/pop or is not active - active is " + adSlots[i].isActive());
							adSequence.adSlots[i].associatedStreamStartTime = totalDuration;
						}					
					}
					if(currentMetrics.usedActiveShowDuration < currentMetrics.totalActiveShowDuration) { 
						// After looping through all the ads, we still have some show to play, so add it in
						currentMetrics.remainingActiveShowDuration = currentMetrics.totalActiveShowDuration - currentMetrics.usedActiveShowDuration;
						doLog("Slotting in the remaining show segment right at the end - segment duration is " + currentMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION);
			  			addStream(new Stream(this,
			  			                     _vastController,
						                     _sequence.length,
						                     "show-" + _sequence.length+1,
			  			                     streams[currentMetrics.associatedStreamIndex].filename,
				  					         Timestamp.secondsToTimestamp(currentMetrics.usedActiveShowDuration),
				  					         new String(currentMetrics.remainingActiveShowDuration),
										     new String(currentMetrics.totalActiveShowDuration),
				  					         true,
				  					         _baseURL,
				  					         streams[currentMetrics.associatedStreamIndex].playOnce,
											 streams[previousMetrics.associatedStreamIndex].metaData)); 
						totalDuration += currentMetrics.remainingActiveShowDuration;
						doLog("Total stream duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION);
						if(currentMetrics.associatedStreamIndex+1 < streams.length) {
							// there are still some streams to sequence after all the ads have been slotted in
							for(var x:int=currentMetrics.associatedStreamIndex+1; x < streams.length; x++) {
								doLog("Sequencing remaining stream " + streams[x].filename + " without any advertising at all", Debuggable.DEBUG_SEGMENT_FORMATION);
								addStream(new Stream(this, 
								                     _vastController, 
								                     x, 
								                     "show-" + x, 
								                     streams[x].filename, 
								                     "00:00:00", 
								                     Timestamp.timestampToSecondsString(streams[x].duration), 
								                     Timestamp.timestampToSecondsString(streams[x].duration), 
								                     streams[x].reduceLength, 
								                     _baseURL, 
								                     streams[x].playOnce,					
											 		 streams[previousMetrics.associatedStreamIndex].metaData)); 
								totalDuration += Timestamp.timestampToSeconds(streams[x].duration);
								doLog("Total stream duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION);
							}
						}
					}
				}
				else { // we don't have any ads, so just stream the main show
					doLog("No video ad streams to schedule, just scheduling the main stream(s)", Debuggable.DEBUG_SEGMENT_FORMATION);
					for(var j:int=0; j < streams.length; j++) {
						doLog("Sequencing stream " + streams[j].filename + " without any advertising at all", Debuggable.DEBUG_SEGMENT_FORMATION);
						addStream(new Stream(this, 
						                     _vastController, 
						                     j, 
						                     "show-" + j, 
						                     streams[j].filename, 
						                     "00:00:00", 
						                     Timestamp.timestampToSecondsString(streams[j].duration), 
						                     Timestamp.timestampToSecondsString(streams[j].duration), 
						                     streams[j].reduceLength, 
						                     _baseURL, 
						                     streams[j].playOnce,					
									 		 streams[previousMetrics.associatedStreamIndex].metaData)); 
						totalDuration += Timestamp.timestampToSeconds(streams[j].duration);
					}
				}
            
			doLog("Total (Final) stream duration is  " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION);
			doLogAndTrace("*** SEGMENT SEQUENCE BUILT - sequence follows:", _sequence, Debuggable.DEBUG_SEGMENT_FORMATION);
			return totalDuration;
		}				

        public function processTimeEvent(associatedStreamIndex:int, timeEvent:TimeEvent, includeChildLinearPoints:Boolean=true):void {
        	if(associatedStreamIndex < _sequence.length) {
        		_sequence[associatedStreamIndex].processTimeEvent(timeEvent, includeChildLinearPoints);
        	}
        }
        	
        public function findSegmentRunningAtTime(time:Number):Stream {
        	var timeSpent:int = 0;
			for(var i:int = 0; i < _sequence.length; i++) {
				timeSpent += _sequence[i].getDurationAsInt();
				if(timeSpent > time) {
					return _sequence[i];
				}
			}
			return null; 	
        }

        public function processPauseEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processPauseStream();	
        	}
        }

        public function processPauseEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processPauseStream();
        	}
        }
		
        public function processResumeEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processResumeStream();
        	}
        }

        public function processResumeEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processResumeStream();
        	}
        }

        public function processStopEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processStopStream();
        	}
        }

        public function processStopEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processStopStream();
        	}
        }

        public function processFullScreenEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processFullScreenEvent();
        	}
        }

        public function processFullScreenEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processFullScreenEvent();
        	}
        }

        public function processMuteEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processMuteEvent();
        	}
        }

        public function processMuteEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processMuteEvent();
        	}
        }        
	}
}