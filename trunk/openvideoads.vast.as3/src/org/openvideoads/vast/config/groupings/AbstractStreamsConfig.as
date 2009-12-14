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
package org.openvideoads.vast.config.groupings {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class AbstractStreamsConfig extends Debuggable {
		protected static var DEFAULT_BASE_URL:String = null;
		protected static var DEFAULT_STREAM_TYPE:String = "any";
		protected static var DEFAULT_DELIVERY_TYPE:String = "any";
		protected static var DEFAULT_BIT_RATE:String = "any";
		protected static var DEFAULT_SUBSCRIBE:Boolean = false;
		protected static var DEFAULT_PLAY_ALLOW_PLAYLIST_CONTROL:Boolean = false;
		protected static var DEFAULT_PLAY_ONCE:Boolean = false;
		
		protected var _baseURL:String = DEFAULT_BASE_URL;
		protected var _streamType:String = DEFAULT_STREAM_TYPE;
		protected var _deliveryType:String = DEFAULT_DELIVERY_TYPE;
		protected var _bitrate:String = DEFAULT_BIT_RATE;
		protected var _subscribe:Boolean = DEFAULT_SUBSCRIBE;
		protected var _allowPlaylistControl:Boolean = DEFAULT_PLAY_ALLOW_PLAYLIST_CONTROL;
		protected var _playOnce:Boolean = DEFAULT_PLAY_ONCE;
		protected var _metaData:Boolean = true;
		protected var _autoPlay:Boolean = false;
		protected var _stripFileExtensions:Boolean = false;
		protected var _playerConfig:Object = new Object();
		protected var _providersConfig:ProvidersConfigGroup = null;

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
				if(config.providers != undefined) this.providers = config.providers;				
				if(config.allowPlaylistControl != undefined) {
					if(config.allowPlaylistControl is String) {
						this.allowPlaylistControl = ((config.allowPlaylistControl.toUpperCase() == "TRUE") ? true : false);					
					}
					else this.allowPlaylistControl = config.allowPlaylistControl;					
				}
				if(config.autoPlay != undefined) {
					if(config.autoPlay is String) {
						this.autoPlay = ((config.autoPlay.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.autoPlay = config.autoPlay;
				}
				if(config.playOnce != undefined) {
					if(config.playOnce is String) {
						this.playOnce = ((config.playOnce.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.playOnce = config.playOnce;
				}
				if(config.player != undefined) this.player = config.player;
			}			
		}

        public function hasProviders():Boolean {
        	return (_providersConfig != null);
        }
 
        public function setDefaultProviders():void {
        	_providersConfig = new ProvidersConfigGroup();
        }        
        
		public function set providers(config:Object):void {	
			if(config.http != undefined) {
				providersConfig.httpProvider = config.http;
			}
			if(config.rtmp != undefined) {
				providersConfig.rtmpProvider = config.rtmp;
			}
		}
		
		public function set providersConfig(providersConfig:ProvidersConfigGroup):void {
			_providersConfig = providersConfig;
		}
		
		public function get providersConfig():ProvidersConfigGroup {
			if(_providersConfig == null) _providersConfig = new ProvidersConfigGroup();
			return _providersConfig;
		}

		public function getProvider(providerType:String):String {
			return providersConfig.getProvider(providerType);
		}

		public function set rtmpProvider(rtmpProvider:String):void {
			providersConfig.rtmpProvider = rtmpProvider;	
		}
		
		public function get rtmpProvider():String {
			return providersConfig.rtmpProvider;			
		}

		public function set httpProvider(httpProvider:String):void {
			providersConfig.httpProvider = httpProvider;	
		}

		public function get httpProvider():String {
			return providersConfig.httpProvider;			
		}

		public function set player(config:Object):void {
			_playerConfig = config;
		}
		
		public function get player():Object {
			return _playerConfig;
		}

		public function set stripFileExtensions(stripFileExtensions:Boolean):void {
			_stripFileExtensions = stripFileExtensions;
		}
		
		public function get stripFileExtensions():Boolean {
			return _stripFileExtensions;
		}

		public function set metaData(metaData:Boolean):void {
			_metaData = metaData;
		}
		
		public function get metaData():Boolean {
			return _metaData;
		}
		
		public function set allowPlaylistControl(allowPlaylistControl:Boolean):void {
			_allowPlaylistControl = allowPlaylistControl;
		}
		
		public function get allowPlaylistControl():Boolean {
			return _allowPlaylistControl;
		}

		public function allowPlaylistControlHasChanged():Boolean {
			return (_allowPlaylistControl != DEFAULT_PLAY_ALLOW_PLAYLIST_CONTROL);
		}
				
		public function set playOnce(playOnce:Boolean):void {
			_playOnce = playOnce;
		}
		
		public function get playOnce():Boolean {
			return _playOnce;
		}
		
		public function set autoPlay(autoPlay:Boolean):void {
			_autoPlay = autoPlay;
		}
		
		public function get autoPlay():Boolean {
			return _autoPlay;
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