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
package org.openvideoads.vast.config.groupings {
	import org.openvideoads.base.Debuggable;
	
	public class ProvidersConfigGroup extends Debuggable{
		protected var _httpProvider:String = "http";
		protected var _rtmpProvider:String = "rtmp";
		
		public function ProvidersConfigGroup(providers:Object=null) {
			if(providers != null) {
				if(providers.http != undefined) _httpProvider = providers.http;
				if(providers.rtmp != undefined) _rtmpProvider = providers.rtmp;
			}
		}
		
		public function getProvider(providerType:String):String {
			switch(providerType.toUpperCase()) {
				case "RTMP":
					return rtmpProvider;
				case "HTTP":
					return httpProvider;
			}
			return null;
		}
		
		public function set httpProvider(httpProvider:String):void {
			_httpProvider = httpProvider;
			doLog("HTTP provider set to " + _httpProvider, Debuggable.DEBUG_CONFIG);
		}
		
		public function get httpProvider():String {
			return _httpProvider;
		}

		public function set rtmpProvider(rtmpProvider:String):void {
			_rtmpProvider = rtmpProvider;
			doLog("RTMP provider set to " + _rtmpProvider, Debuggable.DEBUG_CONFIG);
		}
		
		public function get rtmpProvider():String {
			return _rtmpProvider;
		}		
	}
}