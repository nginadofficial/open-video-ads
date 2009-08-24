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
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class DefaultPlaylistItem extends Debuggable implements PlaylistItem {
		protected var _stream:Stream;
		protected var _played:Boolean = false;
		
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
				return _stream.getDurationAsInt();
			}
			else return 0;
		}

		public function getStartTime():String {
			if(_stream != null) {
				if(_stream is AdSlot) {
					return "00:00:00";
				}
				else return _stream.startTime;				
			}
			else return "00:00:00";
		}
		
		public function getStartTimeAsSeconds():int {
			if(_stream != null) {
				if(_stream is AdSlot) {
					return 0;
				}
				else return _stream.getStartTimeAsSeconds();
			}
			else return 0;			
		}
		
		public function getAuthor():String {
			return "Author not available";
		}
		
		public function getType():String {
			return (isRTMP() ? "rtmp" : "http");
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