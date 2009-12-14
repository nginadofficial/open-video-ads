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
 *    Lesser GNU General Public License for more details.
 *
 *    You should have received a copy of the Lesser GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.base {
	import com.adobe.utils.StringUtil;
	
	import flash.external.ExternalInterface;
	
	import nl.demonsters.debugger.MonsterDebugger;	
	
	/**
	 * @author Paul Schulz
	 */
	public class Debuggable {		
		public static var DEBUG_ALL:int = 1;
		public static var DEBUG_VAST_TEMPLATE:int = 2;
		public static var DEBUG_CUEPOINT_EVENTS:int = 4;	
		public static var DEBUG_SEGMENT_FORMATION:int = 8;
		public static var DEBUG_REGION_FORMATION:int = 16;
		public static var DEBUG_CUEPOINT_FORMATION:int = 32;
		public static var DEBUG_CONFIG:int = 64;
		public static var DEBUG_CLICKTHROUGH_EVENTS:int = 128;
		public static var DEBUG_DATA_ERROR:int = 256;
		public static var DEBUG_HTTP_CALLS:int = 512;
		public static var DEBUG_FATAL:int = 1024;
		public static var DEBUG_CONTENT_ERRORS:int = 2048;
		public static var DEBUG_MOUSE_EVENTS:int = 4096;
		public static var DEBUG_PLAYLIST:int = 8192;
		public static var DEBUG_JAVASCRIPT:int = 16384;         // obsolete?
		public static var DEBUG_STYLES:int = 32768;             // obsolete?
		public static var DEBUG_TRACKING_TABLE:int = 65536;
		public static var DEBUG_DISPLAY_EVENTS:int = 131072;
		public static var DEBUG_STREAM_CONNECTION:int = 262144; // obsolete?
		public static var DEBUG_TRACKING_EVENTS:int = 524288;
		
		public static var BUILD_NUMBER:String = "0.2.2";
		
		protected static var _level:int = 1;
		protected static var _activeDebuggers:String = "firebug";
					
		public static var _debugger:MonsterDebugger;
		public static var _instance:Debuggable;
		
 
		public function Debuggable() {
			if(_debugger == null && usingDeMonster()) {
				_debugger = new MonsterDebugger(this);
			}
		}

		public static function getInstance():Debuggable {
			if(_instance == null) _instance = new Debuggable();
			return _instance;
		}
		
		public function set level(level:int):void {
			_level = level;
			doLog("Debug level has been set to " + _level);
		}
		
		public function set activeDebuggers(activeDebuggers:String):void {
			_activeDebuggers = activeDebuggers;
			doLog("Active debuggers have been set to " + _activeDebuggers);
		}
		
		protected function usingDeMonster():Boolean {
			return (_activeDebuggers.toUpperCase().indexOf("DEMONSTER") > -1);			
		}
		
		protected function usingFirebug():Boolean {
			// http://code.google.com/p/fbug/issues/detail?id=1494
			return (_activeDebuggers.toUpperCase().indexOf("FIREBUG") > -1);
		}
		
		public function setLevelFromString(levelAsString:String):void {
  			var results:Array = levelAsString.split(/,/);
  			var newLevel:int = 0;
  			for(var i:int=0; i < results.length; i++) {
  				switch((StringUtil.trim(results[i])).toUpperCase()) {
  					case "ALL":
  						newLevel = newLevel | DEBUG_ALL;
  						break;
  						
  					case "VAST_TEMPLATE":
  						newLevel = newLevel | DEBUG_VAST_TEMPLATE;
  						break;
  				
  					case "CUEPOINT_EVENTS":
  						newLevel = newLevel | DEBUG_CUEPOINT_EVENTS;
  						break;
  						
  					case "SEGMENT_FORMATION":
  						newLevel = newLevel | DEBUG_SEGMENT_FORMATION;
  						break;
  						
  					case "REGION_FORMATION":
  						newLevel = newLevel | DEBUG_REGION_FORMATION;
  						break;
  						
  					case "CUEPOINT_FORMATION":
  						newLevel = newLevel | DEBUG_CUEPOINT_FORMATION;
  						break;
  						
  					case "CONFIG":
  						newLevel = newLevel | DEBUG_CONFIG;
  						break;
  						
  					case "CLICKTHROUGH_EVENTS":
  						newLevel = newLevel | DEBUG_CLICKTHROUGH_EVENTS;
  						break;
  						
  					case "DATA_ERROR":
  						newLevel = newLevel | DEBUG_DATA_ERROR;
  						break;
  						
  					case "HTTP_CALLS":
  						newLevel = newLevel | DEBUG_HTTP_CALLS;
  						break;
  						
  					case "FATAL":
  					    newLevel = newLevel | DEBUG_FATAL;
  					    break;
  					    
  					case "CONTENT_ERRORS":
  						newLevel = newLevel | DEBUG_CONTENT_ERRORS;
  						break;
  						
  					case "MOUSE_EVENTS":
  						newLevel = newLevel | DEBUG_MOUSE_EVENTS;
  						break;

  					case "PLAYLIST":
  						newLevel = newLevel | DEBUG_PLAYLIST;
  						break;

  					case "JAVASCRIPT":
  						newLevel = newLevel | DEBUG_JAVASCRIPT;
  						break;

  					case "STYLES":
  						newLevel = newLevel | DEBUG_STYLES;
  						break;

  					case "TRACKING_TABLE":
  						newLevel = newLevel | DEBUG_TRACKING_TABLE;
  						break;
  						
  					case "DISPLAY_EVENTS":
  						newLevel = newLevel | DEBUG_DISPLAY_EVENTS;
  						break;

  					case "STREAM_CONNECTION":
  						newLevel = newLevel | DEBUG_STREAM_CONNECTION;
  						break;
  						
  					case "TRACKING_EVENTS":
  						newLevel = newLevel | DEBUG_TRACKING_EVENTS;
  						break;
  				}
  			}
			level = newLevel;
		}
		
		public function doLog(data:String, level:int=1):void {
			if(_level == Debuggable.DEBUG_ALL || level == DEBUG_ALL || (_level & level)) {
				if(usingDeMonster()) {
					MonsterDebugger.trace(this, data);							
				}
				if(usingFirebug()) {
					ExternalInterface.call("console.log", data);
				}
			}
		}
		
		public function doTrace(o:Object, level:int=1):void {
			if(_level == DEBUG_ALL || level == DEBUG_ALL || (_level & level)) {
				if(usingDeMonster()) {
					MonsterDebugger.trace(this, o);
				}
				if(usingFirebug()) {
					for(var name:* in o) {
						ExternalInterface.call("console.log", name + ": " + o[name]);
						ExternalInterface.call("console.log", typeof(o[name]));
					}
				}
			}
		}
		
		public function doLogAndTrace(data:String, o:Object, level:int=1):void {
				doLog(data, level);
				doTrace(o, level);
		}
		
		public function dump(o:Object):void {
			for(var name:* in o) {
				doLog(name + ": " + o[name]);
				doLog(typeof(o[name]));
			}
		}
	}
}