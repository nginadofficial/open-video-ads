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
	import org.openvideoads.util.ArrayUtils;
	import org.openvideoads.vast.server.AdServerConfig;
	import org.openvideoads.vast.server.AdServerConfigFactory;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdsConfigGroup extends AbstractStreamsConfig {
		private var _adServerConfig:AdServerConfig = null;
		private var _schedule:Array = new Array();
		private var _disableControls:Boolean = true;
		private var _companionDivIDs:Array = new Array(); 
		private var _displayCompanions:Boolean = true;
		private var _visuallyCueLinearAdClickThrough:Boolean = true;
		private var _pauseOnClickThrough:Boolean = true;
        private var _noticeConfig:AdNoticeConfig = new AdNoticeConfig();
		private var _clickSignConfig:ClickSignConfig = new ClickSignConfig();
		private var _allowDomains:String = "*";
		private var _keepOverlayVisibleAfterClick:Boolean = false;

		public function AdsConfigGroup(config:Object=null) {
			if(config != null) {
				if(config is String) {
					// should already a JSON object so not converting - just ignoring for safety	
				}
				else initialise(config);				
			}
		}
		
		public override function initialise(config:Object):void {
			super.initialise(config);
			if(config != null) {
				if(config.companions != undefined) {
					if(config.companions is String) {
						this.companionDivIDs = ArrayUtils.makeArray(config.companions);
					}
					else this.companionDivIDs = config.companions;
				}
				if(config.displayCompanions != undefined) {
					if(config.displayCompanions is String) {
						this.displayCompanions = (config.displayCompanions.toUpperCase() == "TRUE");
					}
					else this.displayCompanions = config.displayCompanions;
				}
				if(config.disableControls != undefined) {
					if(config.disableControls is String) {
						this.disableControls = ((config.disableControls.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.disableControls = config.disableControls;
				}
				if(config.playOnce != undefined) {
					if(config.playOnce is String) {
						this.playOnce = ((config.playOnce.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.playOnce = config.playOnce;
				}
				if(config.keepOverlayVisibleAfterClick != undefined) {
					if(config.keepOverlayVisibleAfterClick is String) {
						this.keepOverlayVisibleAfterClick = ((config.keepOverlayVisibleAfterClick.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.keepOverlayVisibleAfterClick = config.keepOverlayVisibleAfterClick;
				}
				if(config.notice != undefined) {
					this.notice = config.notice;
				}
				if(config.visuallyCueLinearAdClickThrough != undefined) {
					if(config.visuallyCueLinearAdClickThrough is String) {
						this.visuallyCueLinearAdClickThrough = ((config.visuallyCueLinearAdClickThrough.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.visuallyCueLinearAdClickThrough = config.visuallyCueLinearAdClickThrough;
				}
				if(config.pauseOnClickThrough != undefined) {
					if(config.pauseOnClickThrough is String) {
						this.pauseOnClickThrough = ((config.pauseOnClickThrough.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.pauseOnClickThrough = config.pauseOnClickThrough;
				}
				if(config.clickSign != undefined) {
					this.clickSignConfig = new ClickSignConfig(config.clickSign);
				}
				if(config.allowDomains != undefined) {
					this.allowDomains = config.allowDomains;
				}
				if(config.schedule != undefined) {
					if(config.schedule is Array) {
						this.schedule = config.schedule;						
					}
					else this.schedule = ArrayUtils.makeArray(config.schedule);														
				}
				
				// Finally, do the ad server config - but load the right ad server config class
				if(config.server != undefined) {
					if(config.server.type != undefined) {
						this.adServerConfig = AdServerConfigFactory.getAdServerConfig(config.server.type);
						this.adServerConfig.initialise(config.server);
					}
				}
			}
		}
		
		public function get clickSignEnabled():Boolean {
			if(_clickSignConfig != null) {
				return _clickSignConfig.enabled;
			}	
			else return true;
		}
		
		public function set adServerConfig(adServerConfig:AdServerConfig):void {
			_adServerConfig = adServerConfig;	
		}
		
		public function get adServerConfig():AdServerConfig {
			return _adServerConfig;
		}
		
		public function set pauseOnClickThrough(pauseOnClickThrough:Boolean):void {
			_pauseOnClickThrough = pauseOnClickThrough;
		}
		
		public function get pauseOnClickThrough():Boolean {
			return _pauseOnClickThrough;
		}

		public function set keepOverlayVisibleAfterClick(keepOverlayVisibleAfterClick:Boolean):void {
			_keepOverlayVisibleAfterClick = keepOverlayVisibleAfterClick;
		}
		
		public function get keepOverlayVisibleAfterClick():Boolean {
			return _keepOverlayVisibleAfterClick;
		}
		
		public function set allowDomains(allowDomains:String):void {
			_allowDomains = allowDomains;
		}
		
		public function get allowDomains():String {
			return _allowDomains;
		}
		
		public function hasCompanionDivs():Boolean {
			return _companionDivIDs.length > 0;
		}
		
		public function set companionDivIDs(companionDivIDs:Array):void {
			_companionDivIDs = companionDivIDs;
		}
		
		public function get companionDivIDs():Array {
			return _companionDivIDs;
		}
		
		public function set displayCompanions(displayCompanions:Boolean):void {
			_displayCompanions = displayCompanions;
		}
		
		public function get displayCompanions():Boolean {
			return _displayCompanions;
		}

        public function showNotice():Boolean {
        	if(_noticeConfig != null) {
        		return _noticeConfig.show;
        	}	
        	return false;
        }
        
		public function set notice(newNotice:Object):void {
			if(_noticeConfig == null) _noticeConfig = new AdNoticeConfig();
			if(newNotice.show != undefined) _noticeConfig.show = newNotice.show;
			if(newNotice.message != undefined) _noticeConfig.message = newNotice.message;
			if(newNotice.region != undefined) _noticeConfig.region = newNotice.region;
			if(newNotice.textStyle != undefined) _noticeConfig.textStyle = newNotice.textStyle;
		}
		
		public function get notice():Object {
			return _noticeConfig;
		}

		public function set disableControls(disableControls:Boolean):void {
			_disableControls = disableControls;
		}
		
		public function get disableControls():Boolean {
			return _disableControls;
		}

		public function set schedule(schedule:Array):void {
			_schedule = schedule;
		}

		public function get schedule():Array {
			return _schedule;
		}
		
		public function set visuallyCueLinearAdClickThrough(visuallyCueLinearAdClickThrough:Boolean):void {
			_visuallyCueLinearAdClickThrough = visuallyCueLinearAdClickThrough;
		}
		
		public function get visuallyCueLinearAdClickThrough():Boolean {
			return _visuallyCueLinearAdClickThrough;
		}
		
		public function set clickSignConfig(clickSignConfig:ClickSignConfig):void {
			_clickSignConfig = clickSignConfig;
		}
		
		public function get clickSignConfig():ClickSignConfig {
			return _clickSignConfig;
		}
	}
}