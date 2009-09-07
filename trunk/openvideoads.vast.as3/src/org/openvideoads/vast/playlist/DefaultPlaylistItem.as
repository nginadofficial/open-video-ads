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
 package org.openvideoads.vast.playlist {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class DefaultPlaylistItem extends Debuggable implements PlaylistItem {
		protected var _stream:Stream;
		protected var _played:Boolean = false;
		protected var _overrideStartTimeSeconds:int = -1;	
		protected var _httpStreamerType:String = DefaultPlaylist.HTTP_STREAMER_TYPE_DEFAULT;
		
		public function DefaultPlaylistItem() {
		}
		
		public function reset():void {
			_played = false;	
		}
		
		public function rewind():void {
			if(playOnce == false) played = false;
		}
		
		public function get playOnce():Boolean {
			if(_stream != null) {
				return _stream.playOnce;				
			}
			return false;
		}
		
		public function canPlay():Boolean {
			if(playOnce) {
				return !played;
			}	
			else return true;
		}
		
		public function markAsPlayed():void {
			played = true;
		}

		public function set httpStreamerType(httpStreamerType:String):void {
			_httpStreamerType = httpStreamerType;
		}
		
		public function get httpStreamerType():String {
			return _httpStreamerType;
		}
				
		public function set played(played:Boolean):void {
			_played = played;
		}
		
		public function get played():Boolean {
			return _played;
		}

		public function set stream(stream:Stream):void {
			_stream = stream;
		}
		
		public function getTitle():String {
			return "Title not available";
		}
		
		public function getLink():String {
			return "Link not available";
		}
		
		public function getDescription():String {
			return "Description not available";
		}
		
		public function getDuration():String {
			if(_stream != null) {
				return _stream.durationToTimestamp();
			}
			else return "00:00:00";
		}
		
		public function getDurationAsSeconds():int {
			if(_stream != null) {
				if(_stream is AdSlot) {
					return (_stream as AdSlot).getAttachedLinearAdDurationAsInt();
				}
				else return _stream.getDurationAsInt();
			}
			else return 0;
		}

		public function hasOverridingStartTime():Boolean {
			return _overrideStartTimeSeconds > -1;
		}
		
        public function set overrideStartTimeSeconds(overrideStartTimeSeconds:int):void {
        	_overrideStartTimeSeconds = overrideStartTimeSeconds;	
        }
        
		public function getStartTime():String {
			if(_stream != null) {
				if(_stream is AdSlot) {
					if(hasOverridingStartTime()) {
						return Timestamp.secondsToTimestamp(_overrideStartTimeSeconds);					
					}
					return "00:00:00";
				}
				else {
					if(hasOverridingStartTime()) {
						return Timestamp.secondsToTimestamp(_overrideStartTimeSeconds);					
					}
					return _stream.startTime;
				}					
			}
			if(hasOverridingStartTime()) {
				return Timestamp.secondsToTimestamp(_overrideStartTimeSeconds);					
			}
			return "00:00:00";
		}
		
		public function getStartTimeAsSeconds():int {
			if(_stream != null) {
				if(_stream is AdSlot) {
					if(hasOverridingStartTime()) {
						return _overrideStartTimeSeconds;
					}
					return 0;
				}
				else {
					if(hasOverridingStartTime()) {
						return _overrideStartTimeSeconds;
					}
					return _stream.getStartTimeAsSeconds();
				}
			}
			if(hasOverridingStartTime()) {
				return _overrideStartTimeSeconds;
			}
			return 0;			
		}
		
		public function getAuthor():String {
			return "Author not available";
		}

		public function getType():String {
			return (isRTMP() ? "rtmp" : _httpStreamerType);
		}
		
		public function getStreamer():String {
			if(_stream != null) {
				return _stream.baseURL;
			}
			else return null;
		}

		public function getFilename(retainPrefix:Boolean=true):String {
			if(_stream != null) {
				if(retainPrefix) {
				   return _stream.streamName; 
				}
				else return _stream.streamNameWithoutPrefix;
			}
			else return null;
		}
		
		public function url():String {
			if(_stream != null) {
				return _stream.url;
			}
			return null;
		}
		
		public function getQualifiedStreamAddress():String {
			if(_stream != null) {
				return _stream.getQualifiedStreamAddress();	
			}
			else return null;
		}

		public function isRTMP():Boolean {
			if(_stream != null) {
				return _stream.isRTMP();
			}
			return false;
        }

		public function toString():String {
			return "not implemented";
		}
	}
}