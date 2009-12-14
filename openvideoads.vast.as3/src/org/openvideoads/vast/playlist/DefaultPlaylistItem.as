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
 package org.openvideoads.vast.playlist {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class DefaultPlaylistItem extends Debuggable implements PlaylistItem {
		protected var _stream:Stream = null;
		protected var _played:Boolean = false;
		protected var _overrideStartTimeSeconds:int = -1;	
        protected var _provider:String = "http";
		protected var _description:String = "Not available";
		protected var _title:String = "Open Video Ads generated playlist";
		protected var _link:String = "Not available";
		protected var _guid:String = "Not available";
		protected var _publishDate:String = "Not available";
		protected var _duration:String = "00:00:00";
		protected var _startTime:String = "00:00:00";
		protected var _url:String = null;
		protected var _filename:String = null;
		protected var _mimeType:String = null;
		
		public function DefaultPlaylistItem() {
		}
		
		public function set guid(guid:String):void {
			_guid = guid;
		}
		
		public function get guid():String {
			return _guid;
		}
		
		public function set provider(provider:String):void {
			_provider = provider;
		}
		
		public function get provider():String {
			return _provider;
		}
		
		public function set publishDate(publishDate:String):void {
			_publishDate = publishDate;
		}
		
		public function get publishDate():String {
			return _publishDate;
		}
		
		public function getPreviewImage():String {
			if(_stream != null) {
				return _stream.previewImage;
			}
			return null;
		}
		
		public function hasPreviewImage():Boolean {
			return (getPreviewImage() != null);
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

        protected function hasStream():Boolean {
        	return _stream != null;
        }
        
		public function set stream(stream:Stream):void {
			_stream = stream;
		}
		
		public function get stream():Stream {
			return _stream;
		}
		
		public function set title(title:String):void {
			_title = title;
		}
		
		public function get title():String {
			return _title;
		}
		
		public function set link(link:String):void {
			_link = link;
		}
		
		public function get link():String {
			return _link;
		}
		
		public function set description(description:String):void {
			_description = description;
		}
		
		public function get description():String {
			return _description;
		}
		
		public function set duration(duration:String):void {
			_duration = duration;
		}
		
		public function get duration():String {
			if(_stream != null) {
				return _stream.durationToTimestamp();
			}
			else return _duration; 
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
			return _startTime; 
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
			return (isRTMP() ? "rtmp" : "http");
		}
		
		public function getStreamer():String {
			if(_stream != null) {
				return _stream.baseURL;
			}
			else return null;
		}

	    public function set filename(filename:String):void {
	    	_filename = filename;
	    }
	    
        public function get filename():String {
			return _filename;        	
        }
        
		public function getFilename(retainPrefix:Boolean=true):String {
			if(_stream != null) {
				if(retainPrefix) {
				   return _stream.streamName; 
				}
				else return _stream.streamNameWithoutPrefix;
			}
			else return _filename;        	
		}
		
		public function set url(url:String):void {
			_url = url;
		}
		
		public function get url():String {
			if(_stream != null) {
				return _stream.url;
			}
			return _url;
		}
		
		public function set mimeType(mimeType:String):void {
			_mimeType = mimeType;
		}
		
		public function get mimeType():String {
			return _mimeType;
		}
		
		public function getQualifiedStreamAddress():String {
			if(_stream != null) {
				return _stream.getQualifiedStreamAddress();	
			}
			else {
				if(url != null) {
					if(filename != null) {
						if(StringUtils.endsWith(StringUtils.trim(url), "/")) {
							if(!StringUtils.beginsWith(StringUtils.trim(filename), "/")) {
								return url + filename;
							}
							else return url + StringUtils.trim(filename).substr(1);
						}
						else {
							if(StringUtils.beginsWith(StringUtils.trim(filename), "/")) {
								return url + filename;
							}
							else return url + "/" + filename;
						}
					}
					return StringUtils.trim(url);
				}
				else if(filename != null) {
					return filename;
				}
			}
			return null;
		}

		public function isRTMP():Boolean {
			if(_stream != null) {
				return _stream.isRTMP();
			}
			return false;
        }
        
        public function toShowStreamConfigObject():Object {
        	var result:Object = new Object();
        	result.file = getQualifiedStreamAddress();
        	result.duration = duration;
        	return result;
        }

		public function toString():String {
			return "not implemented";
		}
	}
}