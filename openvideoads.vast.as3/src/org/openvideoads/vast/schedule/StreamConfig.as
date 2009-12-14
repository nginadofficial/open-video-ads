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
package org.openvideoads.vast.schedule {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.Timestamp;
	
	/**
	 * @author Paul Schulz
	 */
	public class StreamConfig extends Debuggable {
		private var _id:String = null;
		private var _filename:String;
		private var _duration:String = "00:00:00";
		private var _reduceLength:Boolean = false;
		private var _isLive:Boolean = false;
		private var _deliveryType:String = "any"; //streaming
		private var _playOnce:Boolean = false;
		private var _metaData:Boolean = true;
		private var _autoPlay:Boolean = true;
		private var _provider:String = null;
		private var _playerConfig:Object = new Object();
		
		public function StreamConfig(id:String, filename:String, duration:String, reduceLength:Boolean=false, deliveryType:String="any", playOnce:Boolean=false, metaData:Boolean=true, autoPlay:Boolean=true, provider:String=null, playerConfig:Object=null) {
			_id = id;
			if(filename.indexOf("(live)") > -1) {
				_filename = filename.substr(filename.lastIndexOf("(live)") + 6);
				_isLive = true;
			}
			else _filename = filename;
			_duration = duration;
			_reduceLength = reduceLength;
			_deliveryType = deliveryType;
			_playOnce = playOnce;
			_metaData = metaData;
			_autoPlay = autoPlay;
			_provider = provider;
			if(playerConfig != null) _playerConfig = playerConfig;
		}

		public function get id():String {
			return _id;
		}
		
		public function get player():Object {
			return _playerConfig;
		}
		
		public function set provider(provider:String):void {
			_provider = provider;
		}
		
		public function get provider():String {
			return _provider;
		}
		
		public function set autoPlay(autoPlay:Boolean):void {
			_autoPlay = autoPlay;
		}
		
		public function get autoPlay():Boolean {
			return _autoPlay;
		}
		
		public function set deliveryType(deliveryType:String):void {
			_deliveryType = deliveryType;
		}
		
		public function get deliveryType():String {
			return _deliveryType;
		}
		
		public function set metaData(metaData:Boolean):void {
			_metaData = metaData;
		}
		
		public function get metaData():Boolean {
			return _metaData;
		}

		public function set filename(filename:String):void {
			_filename = filename;
		}
		
		public function get filename():String {
			return _filename;
		}
		
		public function get file():String {
			return this.filename;
		}
		
		public function isStream():Boolean {
			if(_filename != null) {
        		var pattern:RegExp = new RegExp('.jpg|.png|.gif|.swf|.JPG|.PNG|.GIF|.SWF');
        		return (_filename.match(pattern) == null);
/*
				return (_filename.indexOf(".jpg") == -1 &&
				        _filename.indexOf(".png") == -1 &&
				        _filename.indexOf(".gif") == -1 &&
				        _filename.indexOf(".swf") == -1);
*/
			}
			return false; 
		}
		
		public function set duration(duration:String):void {
			_duration = duration;
		}
		
		public function get duration():String {
			return _duration;
		}
		
		public function getDurationAsInt():int {
			return Timestamp.timestampToSeconds(duration);
		}

		public function set reduceLength(reduceLength:Boolean):void {
			_reduceLength = reduceLength;
		}
		
		public function get reduceLength():Boolean {
			return _reduceLength;
		}
		
		public function isLive():Boolean {
			return _isLive;
		}
		
		public function set playOnce(playOnce:Boolean):void {
			_playOnce = playOnce;
		}
		
		public function get playOnce():Boolean {
			return _playOnce;
		}
	}
}