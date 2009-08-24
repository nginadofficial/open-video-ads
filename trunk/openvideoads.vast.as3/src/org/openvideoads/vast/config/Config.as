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
package org.openvideoads.vast.config {
	import org.openvideoads.vast.config.groupings.AbstractStreamsConfig;
	import org.openvideoads.vast.config.groupings.AdsConfigGroup;
	import org.openvideoads.vast.config.groupings.DebugConfigGroup;
	import org.openvideoads.vast.config.groupings.OverlaysConfigGroup;
	import org.openvideoads.vast.config.groupings.ShowsConfigGroup;
	import org.openvideoads.vast.server.AdServerConfig;
	
	/**
	 * @author Paul Schulz
	 */
	public class Config extends AbstractStreamsConfig {
		protected var _adsConfig:AdsConfigGroup = new AdsConfigGroup();
		protected var _overlaysConfig:OverlaysConfigGroup = new OverlaysConfigGroup();
		protected var _showsConfig:ShowsConfigGroup = new ShowsConfigGroup();
		protected var _debugConfig:DebugConfigGroup = new DebugConfigGroup();
				
		public function Config(rawConfig:Object=null) {
			if(rawConfig != null) {
				initialise(rawConfig);
			}
		}
		
		public override function initialise(config:Object):void {
			super.initialise(config);
			if(config.shows != undefined) this.shows = config.shows;
			if(config.overlays != undefined) this.overlays = config.overlays;
			if(config.ads != undefined) this.ads = config.ads;
			if(config.debug != undefined) this.debug = config.debug;
		}

		public function set shows(config:Object):void {
			_showsConfig = new ShowsConfigGroup(config);
		}

		public function set overlays(config:Object):void {
			_overlaysConfig = new OverlaysConfigGroup(config);
		}
		
		public function get overlaysConfig():OverlaysConfigGroup {
			return _overlaysConfig;
		}
		
		public function set ads(config:Object):void {
			_adsConfig = new AdsConfigGroup(config);
		}
		
		public function get adsConfig():AdsConfigGroup {
			return _adsConfig;
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
		
		public function get streams():Array {
			return _showsConfig.streams;
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
		
		public function get notice():Object {
			return _adsConfig.notice;
		}

		public function get showNotice():Boolean {
			return _adsConfig.showNotice();
		}

		public function get disableControls():Boolean {
			return _adsConfig.disableControls;
		}
		
		public function get adSchedule():Array {
			return _adsConfig.schedule;
		}
		
		public override function get providers():Object {
			return ((_showsConfig.providersHasChanged()) ? _showsConfig.providers : _providers);
		}
		
		public override function get rtmpProvider():String {
			return ((_showsConfig.rtmpProviderHasChanged()) ? _showsConfig.providers.rtmp : _providers.rtmp);
		}

		public override function get httpProvider():String {
			return ((_showsConfig.httpProviderHasChanged()) ? _showsConfig.providers.http : _providers.http);
		}
		
		public function hasProviderUrl(providerID:String):Boolean {
			switch(providerID) {
				case "rtmp":
					return _providers.rtmp != "rtmp";
					
				case "http":
					return _providers.http != "http";
			}				
			return false;
		}
		
		public function providerUrl(providerID:String):String {
			if (hasProviderUrl(providerID)) {
				switch(providerID) {
					case "rtmp":
						return rtmpProvider;
					case "http":
						return httpProvider;
				}	
			}
			return null;
		}
		
		public override function get playContiguously():Boolean {
			return ((_showsConfig.playContiguouslyHasChanged()) ? _showsConfig.playContiguously : _playContiguously);
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