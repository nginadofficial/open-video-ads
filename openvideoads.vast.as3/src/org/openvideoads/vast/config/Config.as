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
package org.openvideoads.vast.config {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.config.groupings.AbstractStreamsConfig;
	import org.openvideoads.vast.config.groupings.AdsConfigGroup;
	import org.openvideoads.vast.config.groupings.DebugConfigGroup;
	import org.openvideoads.vast.config.groupings.OverlaysConfigGroup;
	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
	import org.openvideoads.vast.config.groupings.RemoteConfigGroup;
	import org.openvideoads.vast.config.groupings.ShowsConfigGroup;
	import org.openvideoads.vast.playlist.Playlist;
	import org.openvideoads.vast.server.AdServerConfig;
	
	/**
	 * @author Paul Schulz
	 */
	public class Config extends AbstractStreamsConfig {
		protected var _adsConfig:AdsConfigGroup = new AdsConfigGroup();
		protected var _overlaysConfig:OverlaysConfigGroup = new OverlaysConfigGroup();
		protected var _showsConfig:ShowsConfigGroup = new ShowsConfigGroup();
		protected var _debugConfig:DebugConfigGroup = new DebugConfigGroup();
		protected var _openVideoAdsConfig:RemoteConfigGroup = new RemoteConfigGroup();
				
		public function Config(rawConfig:Object=null) {
			setDefaultProviders();
			if(rawConfig != null) {
				initialise(rawConfig);
			}
		}
		
		public override function initialise(config:Object):void {
			super.initialise(config);
			if(config.shows != undefined) {
				this.shows = config.shows;
			}
			if(config.overlays != undefined) this.overlays = config.overlays;
			if(config.ads != undefined) {
				this.ads = config.ads;
			}
			if(config.debug != undefined) this.debug = config.debug;
		}
		
		public function loadShowStreamsConfigFromPlaylist(playlist:Playlist):void {
			_showsConfig.streams = playlist.toShowStreamsConfigArray();
		}

		public function set shows(config:Object):void {
			if(config.player != undefined) {
				config.player = this.player;
			}
			_showsConfig = new ShowsConfigGroup(config);
		}

		public function hasShowsDefined():Boolean {
			return _showsConfig.hasShowStreamsDefined();
		}

		public function set overlays(config:Object):void {
			_overlaysConfig = new OverlaysConfigGroup(config);
		}
		
		public function get overlaysConfig():OverlaysConfigGroup {
			return _overlaysConfig;
		}
				
		public function set ads(config:Object):void {
			if(config.player != undefined) {
				config.player = this.player;
			}
			_adsConfig = new AdsConfigGroup(config);
		}
		
		public function get adsConfig():AdsConfigGroup {
			return _adsConfig;
		}
		
		public function get openVideoAdsConfig():RemoteConfigGroup {
			return _openVideoAdsConfig;
		}
		
		public function get pauseOnClickThrough():Boolean {
			return _adsConfig.pauseOnClickThrough;
		}
		
		public function get adServerConfig():AdServerConfig {
			return _adsConfig.adServerConfig;
		}

		public function set debug(config:Object):void {
			_debugConfig = new DebugConfigGroup(config);
		}
		
		// INTERFACES
		
		public function hasStreams():Boolean {
			return _showsConfig.hasShowStreamsDefined();
		}
		
		public function set streams(streams:Array):void {
			_showsConfig.streams = streams;
		}
		
		public function get streams():Array {
			return _showsConfig.streams;
		}
		
		public function prependStreams(streams:Array):void {
			_showsConfig.prependStreams(streams);
		}
		
		public function get previewImage():String {
			if(_showsConfig != null) {
				return _showsConfig.getPreviewImage();
			}
			else return null;
		}
		
		public function hasCompanionDivs():Boolean {
			return _adsConfig.hasCompanionDivs();
		}
		
		public function get companionDivIDs():Array {
			return _adsConfig.companionDivIDs;
		}
		
		public function get displayCompanions():Boolean {
			return _adsConfig.displayCompanions;
		}
		
		public function get restoreCompanions():Boolean {
			return _adsConfig.restoreCompanions;
		}
		
		public function get notice():Object {
			return _adsConfig.notice;
		}

		public function get showNotice():Boolean {
			return _adsConfig.showNotice();
		}
		
		public function get clickSignEnabled():Boolean {
			return _adsConfig.clickSignEnabled;
		}

		public function get disableControls():Boolean {
			return _adsConfig.disableControls;
		}
		
		public function get adSchedule():Array {
			return _adsConfig.schedule;
		}

        public override function hasProviders():Boolean {
        	return (_showsConfig.hasProviders() && _adsConfig.hasProviders());	
        }
        
        public override function setDefaultProviders():void {
        	_providersConfig = new ProvidersConfigGroup();
        	_showsConfig.setDefaultProviders();
        	_adsConfig.setDefaultProviders();
        }

        public function ensureProvidersAreSet():void {
        	if(_providersConfig == null) _providersConfig = new ProvidersConfigGroup();
        	if(!_showsConfig.hasProviders()) _showsConfig.setDefaultProviders();
        	if(!_adsConfig.hasProviders()) _adsConfig.setDefaultProviders();
        }
        
        public function setMissingProviders(httpProvider:String, rtmpProvider:String):void {
        	if(_providersConfig == null) {
        		doLog("Setting missing general providers...", Debuggable.DEBUG_CONFIG);
				_providersConfig = new ProvidersConfigGroup();
				_providersConfig.httpProvider = httpProvider;
				_providersConfig.rtmpProvider = rtmpProvider;        	
        	}
        	if(!_showsConfig.hasProviders()) {
        		doLog("Setting missing show providers...", Debuggable.DEBUG_CONFIG);
        		_showsConfig.setDefaultProviders();
        		_showsConfig.httpProvider = httpProvider;
        		_showsConfig.rtmpProvider = rtmpProvider;
        	}
        	if(!_adsConfig.hasProviders()) {
        		doLog("Setting missing ad providers...", Debuggable.DEBUG_CONFIG);
        		_adsConfig.setDefaultProviders();
        		_adsConfig.httpProvider = httpProvider;
        		_adsConfig.rtmpProvider = rtmpProvider;
        	}       	
        }
        
		public override function set rtmpProvider(rtmpProvider:String):void {
			providersConfig.rtmpProvider = rtmpProvider;
			_showsConfig.rtmpProvider = rtmpProvider;	
			_adsConfig.rtmpProvider = rtmpProvider;
		}
		
		public override function set httpProvider(httpProvider:String):void {
			providersConfig.httpProvider = httpProvider;
			_showsConfig.httpProvider = httpProvider;	
			_adsConfig.httpProvider = httpProvider;
		}
		
		public function providersForShows():ProvidersConfigGroup {
			return _showsConfig.providersConfig;
		}

		public function providersForAds():ProvidersConfigGroup {
			return _adsConfig.providersConfig;
		}

		public function getProviderForShow(providerType:String):String {
			return _showsConfig.getProvider(providerType);
		}

		public function set rtmpProviderForShow(rtmpProvider:String):void {
			_showsConfig.rtmpProvider = rtmpProvider;	
		}
		
		public function get rtmpProviderForShow():String {
			return _showsConfig.rtmpProvider;
		}

		public function set httpProviderForShow(httpProvider:String):void {
			_showsConfig.httpProvider = httpProvider;	
		}

		public function get httpProviderForShow():String {
			return _showsConfig.httpProvider;
		}

		public function getProviderForAds(providerType:String):String {
			return _adsConfig.getProvider(providerType);
		}

		public function set rtmpProviderForAds(rtmpProvider:String):void {
			_adsConfig.rtmpProvider = rtmpProvider;	
		}
		
		public function get rtmpProviderForAds():String {
			return _adsConfig.rtmpProvider;
		}

		public function set httpProviderForAds(httpProvider:String):void {
			_adsConfig.httpProvider = httpProvider;	
		}

		public function get httpProviderForAds():String {
			return _adsConfig.httpProvider;
		}

		public override function get allowPlaylistControl():Boolean {
			return ((_showsConfig.allowPlaylistControlHasChanged()) ? _showsConfig.allowPlaylistControl : _allowPlaylistControl);
		}
		
		public override function get playOnce():Boolean {
			return ((_adsConfig.playOnceHasChanged()) ? _adsConfig.playOnce : _playOnce);
		}

		public override function get deliveryType():String {
			return ((_showsConfig.deliveryTypeHasChanged()) ? _showsConfig.deliveryType : 
			        ((_adsConfig.deliveryTypeHasChanged()) ? _adsConfig.deliveryType : _deliveryType));
		}
		
		public override function get baseURL():String {
			return ((_showsConfig.baseURLHasChanged()) ? _showsConfig.baseURL : 
			        ((_adsConfig.baseURLHasChanged()) ? _adsConfig.baseURL : _baseURL));
		}
				
		public override function get streamType():String {
			return ((_showsConfig.streamTypeHasChanged()) ? _showsConfig.streamType : 
			        ((_adsConfig.streamTypeHasChanged()) ? _adsConfig.streamType : _streamType));
		}

		public override function get subscribe():Boolean {
			return ((_showsConfig.subscribeHasChanged()) ? _showsConfig.subscribe : 
			        ((_adsConfig.subscribeHasChanged()) ? _adsConfig.subscribe : _subscribe));
		}

		public override function get bitrate():String {
			return ((_showsConfig.bitrateHasChanged()) ? _showsConfig.bitrate : 
			        ((_adsConfig.bitrateHasChanged()) ? _adsConfig.bitrate : _bitrate));
		}
		
		public function get visuallyCueLinearAdClickThrough():Boolean {
			return _adsConfig.visuallyCueLinearAdClickThrough;	
		}
		
		public function debuggersSpecified():Boolean {
			return _debugConfig.debuggersSpecified();
		}
		
		public function get debugger():String {
			return _debugConfig.debugger;
		}
		
		public function get debugLevel():String {
			return _debugConfig.levels;
		}
		
		public function debugLevelSpecified():Boolean {
			return _debugConfig.debugLevelSpecified();
		}
	}
}