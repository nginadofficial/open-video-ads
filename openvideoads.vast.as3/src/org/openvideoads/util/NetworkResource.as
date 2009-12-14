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
package org.openvideoads.util {
    import flash.events.*;
    import flash.net.*;

    import com.adobe.utils.StringUtil;
    
    import org.openvideoads.base.Debuggable;
    import org.openvideoads.util.StringUtils;
		
	/**
	 * @author Paul Schulz
	 */
	public class NetworkResource extends Debuggable {
		private var _id:String = null;
		private var _url:String = null;
		private	var _loader:URLLoader = new URLLoader();
		
		public function NetworkResource(id:String = null, url:String = null) {
			_id = id;
			_url = url;
		}
		
		public function set id(id:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function set url(url:String):void {
			_url = url;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function get qualifiedHTTPUrl():String {
			if(!isQualified()) {
				return "http://" + StringUtils.trim(_url);
			}
			else {
				return _url;
			}
		}
		
		public function get data():String {
			return _loader.data;
		}
		
		public function isQualified():Boolean {
			if(_url != null) {
				return (_url.indexOf("http://") > -1 || _url.indexOf("rtmp://") > -1);
			}
			return false;
		}
		
		public function getQualifiedStreamAddress(defaultNetConnectionURL:String = null):String {
			if(isQualified()) {
				return _url;
			}
			else {
				if(defaultNetConnectionURL != null) {
					return defaultNetConnectionURL	+ _url;
				}
				else return _url;
			}
		}
		
		public function getFilename(fileMarker:String=null):String {
			if(_url != null) {
				if(fileMarker != null) {
					var firstMarkerIndex:int = _url.indexOf(fileMarker);
					if(firstMarkerIndex == -1) {
						return _url;
					}
					else return _url.substr(firstMarkerIndex);
				}
				else {
					var lastSlashIndex:int = _url.lastIndexOf("/");
					if(lastSlashIndex == -1) {
						return _url;
					}
					else { // strip out the URI
						return _url.substr(lastSlashIndex+1);
					}
				}
			}
			else return null;
		}
		
		public function get netConnectionAddress():String {
			if(_url != null) {
				if(_url.indexOf("mp4:") > 0) {
					return _url.substr(0, _url.indexOf("mp4:"));
				}			
				else if(_url.indexOf("flv:") > 0) {					
					return _url.substr(0, _url.indexOf("flv:"));
				}
			}
			return null;
		}
		
		public function isRTMP():Boolean {
			if(_url != null) {
				return (_url.indexOf("rtmp") > -1);			
			}
			else return false;
		}
		
		public function getURI():String {
			if(_url != null) {
				var lastSlashIndex:int = _url.lastIndexOf("/");
				if(lastSlashIndex == -1) {
					return null;
				}
				else { // strip out the filename
					return _url.substr(0, lastSlashIndex+1);
				}			
			}
			else return null;
		}
		
		public function isLiveURL():Boolean {
			var filename:String = getFilename();
			if(filename != null) {
				return (filename.indexOf("(live)") > -1);
			}
			return false;
		}
		
		public function getLiveStreamName():String {
			if(isLiveURL()) {
				var filename:String = getFilename();
				return filename.substr(filename.lastIndexOf("(live)") + 6);
			}
			else return null;					
		}
		
		public static function addBaseURL(baseURL:String, fileName:String):String {
			if (fileName == null) return null;
			
			if (isCompleteURLWithProtocol(fileName)) return fileName;
			if (fileName.indexOf("/") == 0) return fileName;
			
			if (baseURL == '' || baseURL == null || baseURL == 'null') {
				return fileName;
			}
			if (baseURL != null) {
				if (baseURL.lastIndexOf("/") == baseURL.length - 1)
					return baseURL + fileName;
				return baseURL + "/" + fileName;
			}
			return fileName;
		}

        public static function appendToPath(base:String, postFix:String):String {
            if (StringUtil.endsWith(base, "/")) return base + postFix;
            return base + "/" + postFix;
        }

		public static function isCompleteURLWithProtocol(fileName:String):Boolean {
			if (! fileName) return false;
			return fileName.indexOf("://") > 0;
		}		
		
		public function call():void {
			if(_url != null) {
				if(StringUtils.trim(_url).length > 0) {
					doLog("Making HTTP call to " + _url, Debuggable.DEBUG_HTTP_CALLS);
					_loader = new URLLoader();
					_loader.addEventListener(Event.COMPLETE, callComplete);
					_loader.addEventListener(ErrorEvent.ERROR, errorHandler)
					_loader.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
					_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
					_loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					_loader.load(new URLRequest(_url));					
				}
				else doLog("HTTP call not made - the URL is empty", Debuggable.DEBUG_HTTP_CALLS);
			}
			else doLog("HTTP call cannot be made - no URL set", Debuggable.DEBUG_HTTP_CALLS);
		}

		protected function callComplete(e:Event):void {
			doLog("HTTP call complete (to " + id + ") - " + _loader.bytesLoaded + " bytes loaded", Debuggable.DEBUG_HTTP_CALLS);
			loadComplete(_loader.data);
		}
		
		protected function errorHandler(e:Event):void {
			doLog("HTTP ERROR: " + e.toString(), Debuggable.DEBUG_HTTP_CALLS);
		}		
		
		protected function loadComplete(data:String):void {
		}
	}
}