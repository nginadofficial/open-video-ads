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
	
	/**
	 * @author Paul Schulz
	 */
	public class TrackingEvent extends Debuggable {
		private var _urls:Array = new Array();
		private var _eventType:String;
		private var _lastFired:Number = -1;
		
		public static const EVENT_START:String = "start";
		public static const EVENT_STOP:String = "stop";
		public static const EVENT_RESUME:String = "resume";
		public static const EVENT_MIDPOINT:String = "midpoint";
		public static const EVENT_1STQUARTILE:String = "firstQuartile";
		public static const EVENT_3RDQUARTILE:String = "thirdQuartile";
		public static const EVENT_COMPLETE:String = "complete";
		public static const EVENT_MUTE:String = "mute";
		public static const EVENT_UNMUTE:String = "unmute";
		public static const EVENT_PAUSE:String = "pause";
		public static const EVENT_REPLAY:String = "replay";
		public static const EVENT_FULLSCREEN:String = "fullscreen";
		public static const TRIGGER_FIRE_DELAY_MILLISECONDS:Number = 5000; // 5 second delay between refiring of events
 
		public function TrackingEvent(eventType:String = null, url:NetworkResource = null) {
			_eventType = eventType;
			if(url != null) addURL(url);
		}
		
		public function set urls(urls:Array):void {
			_urls = urls;
		}
		
		public function get urls():Array {
			return _urls;
		}
		
		public function addURL(url:NetworkResource):void {
			_urls.push(url);
		}
		
		public function set eventType(eventType:String):void {
			_eventType = eventType;
		}
		
		public function get eventType():String {
			return _eventType;
		}
		
		public function execute():void {
			var now:Date = new Date();
			var canFire:Boolean = false;
			if(_lastFired == -1) {
				canFire = true;
			}
			else canFire = false;
			
			if(canFire) {
				doLog("Firing tracking event - " + eventType, Debuggable.DEBUG_TRACKING_EVENTS);
				for(var i:int = 0; i < _urls.length; i++) {
					urls[i].call();
				}	
			}
			else doLog("Not firing tracking event - " + eventType + " - already fired", Debuggable.DEBUG_TRACKING_EVENTS);
			_lastFired = now.getTime();
		}
	}
}