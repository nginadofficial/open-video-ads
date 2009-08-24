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
package org.openvideoads.vast.config.groupings {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class AbstractStreamsConfig extends Debuggable {
		protected static var DEFAULT_BASE_URL:String = null;
		protected static var DEFAULT_STREAM_TYPE:String = "mp4";
		protected static var DEFAULT_DELIVERY_TYPE:String = "streaming";
		protected static var DEFAULT_PROVIDERS:Object = { rtmp: 'rtmp', http: 'http' };
		protected static var DEFAULT_PROVIDERS_RTMP:String = "rtmp";
		protected static var DEFAULT_PROVIDERS_HTTP:String = "http";
		protected static var DEFAULT_BIT_RATE:String = "any";
		protected static var DEFAULT_SUBSCRIBE:Boolean = false;
		protected static var DEFAULT_PLAY_CONTIGUOUSLY:Boolean = true;
		protected static var DEFAULT_PLAY_ONCE:Boolean = false;
		
		protected var _baseURL:String = DEFAULT_BASE_URL;
		protected var _streamType:String = DEFAULT_STREAM_TYPE;
		protected var _deliveryType:String = DEFAULT_DELIVERY_TYPE;
		protected var _providers:Object = DEFAULT_PROVIDERS;
		protected var _bitrate:String = DEFAULT_BIT_RATE;
		protected var _subscribe:Boolean = DEFAULT_SUBSCRIBE;
		protected var _playContiguously:Boolean = DEFAULT_PLAY_CONTIGUOUSLY;
		protected var _playOnce:Boolean = DEFAULT_PLAY_ONCE;
		protected var _metaData:Boolean = true;
		protected var _autoStart:Boolean = true;
		protected var _stripFileExtensions:Boolean = false;

		public function AbstractStreamsConfig(config:Object=null) {
			if(config != null) {
				if(config is String) {
					// should already a JSON object so not converting - just ignoring for safety	
				}
				else initialise(config);				
			}
		}
		
		public function initialise(config:Object):void {
			if(config != null) {
				if(config.baseURL != undefined) {
					this.baseURL = config.baseURL;					
				}
				if(config.streamType != undefined) {					
					this.streamType = config.streamType;
				}
				if(config.metaData != undefined) {
					if(config.metaData is String) {
						this.metaData = ((config.metaData.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.metaData = config.metaData;					
				}
				if(config.stripFileExtensions != undefined) {
					if(config.stripFileExtensions is String) {
						this.stripFileExtensions = ((config.stripFileExtensions.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.stripFileExtensions = config.stripFileExtensions;					
				}
				if(config.bitrate != undefined) {
					this.bitrate = config.bitrate;					
				}
				if(config.subscribe != undefined) {
					if(config.subscribe is String) {
						this.subscribe = ((config.subscribe.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.subscribe = config.subscribe;
				}
				if(config.deliveryType != undefined) {
					this.deliveryType = config.deliveryType;					
				}
				if(config.providers != undefined) {
					if(config.providers.rtmp != undefined) this.providers.rtmp = config.providers.rtmp;
					if(config.providers.http != undefined) this.providers.http = config.providers.http;
				}
				if(config.playContiguously != undefined) {
					if(config.playContiguously is String) {
						this.playContiguously = ((config.playContiguously.toUpperCase() == "TRUE") ? true : false);					
					}
					else this.playContiguously = config.playContiguously;					
				}
				if(config.autoStart != undefined) {
					if(config.autoStart is String) {
						this.autoStart = ((config.autoStart.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.autoStart = config.autoStart;
				}
			}			
		}

		public function set providers(providers:Object):void {
			_providers = providers;	
		}
		
		public function get providers():Object {
			return _providers;
		}
		
		public function set stripFileExtensions(stripFileExtensions:Boolean):void {
			_stripFileExtensions = stripFileExtensions;
		}
		
		public function get stripFileExtensions():Boolean {
			return _stripFileExtensions;
		}
		
		public function providersHasChanged():Boolean {
			return (rtmpProviderHasChanged() || httpProviderHasChanged());
		}
		
		public function get rtmpProvider():String {
			return ((_providers.rtmp != undefined) ? _providers.rtmp : "rtmp");
		}

		public function rtmpProviderHasChanged():Boolean {
			return (_providers.rtmp != DEFAULT_PROVIDERS_RTMP);
		}

		public function get httpProvider():String {
			return ((_providers.http != undefined) ? _providers.http : "http");
		}

		public function httpProviderHasChanged():Boolean {
			return (_providers.http != DEFAULT_PROVIDERS_HTTP);
		}
		
		public function set metaData(metaData:Boolean):void {
			_metaData = metaData;
		}
		
		public function get metaData():Boolean {
			return _metaData;
		}
		
		public function set playContiguously(playContiguously:Boolean):void {
			_playContiguously = playContiguously;
		}
		
		public function get playContiguously():Boolean {
			return _playContiguously;
		}

		public function playContiguouslyHasChanged():Boolean {
			return (_playContiguously != DEFAULT_PLAY_CONTIGUOUSLY);
		}
				
		public function set playOnce(playOnce:Boolean):void {
			_playOnce = playOnce;
		}
		
		public function get playOnce():Boolean {
			return _playOnce;
		}
		
		public function set autoStart(autoStart:Boolean):void {
			_autoStart = autoStart;
		}
		
		public function get autoStart():Boolean {
			return _autoStart;
		}

		public function playOnceHasChanged():Boolean {
			return (_playOnce != DEFAULT_PLAY_ONCE);
		}
		
		public function set deliveryType(deliveryType:String):void {
			_deliveryType = deliveryType;
		}
		
		public function get deliveryType():String {
			return _deliveryType;
		}

		public function deliveryTypeHasChanged():Boolean {
			return (_deliveryType != DEFAULT_DELIVERY_TYPE);
		}
		
		public function get baseURL():String {
			return _baseURL;
		}
		
		public function set baseURL(baseURL:String):void {
			_baseURL = baseURL;
		}

		public function baseURLHasChanged():Boolean {
			return (_baseURL != DEFAULT_BASE_URL);
		}
		
		public function set streamType(streamType:String):void {
			_streamType = streamType;
		}
		
		public function get streamType():String {
			return _streamType;
		}

		public function streamTypeHasChanged():Boolean {
			return (_streamType != DEFAULT_STREAM_TYPE);
		}

		public function set subscribe(subscribe:Boolean):void {
			_subscribe = subscribe;
		}		
		
		public function get subscribe():Boolean {
			return _subscribe;
		}

		public function subscribeHasChanged():Boolean {
			return (_subscribe != DEFAULT_SUBSCRIBE);
		}
		
		public function set bitrate(bitrate:String):void {
			_bitrate = bitrate;
		}
		
		public function get bitrate():String {
			return _bitrate;	
		}

		public function bitrateHasChanged():Boolean {
			return (_bitrate != DEFAULT_BIT_RATE);
		}
		
		public function hasBitRate():Boolean {
			return _bitrate != null;
		}
	}
}