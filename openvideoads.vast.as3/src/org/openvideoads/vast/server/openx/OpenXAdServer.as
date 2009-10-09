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
package org.openvideoads.vast.server.openx {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.model.TemplateLoadListener;
	import org.openvideoads.vast.model.VideoAdServingTemplate;
	import org.openvideoads.vast.schedule.ads.AdSchedule;
	import org.openvideoads.vast.server.AdServer;
	import org.openvideoads.vast.server.openx.OpenXServerConfig;
	
	/**
	 * @author Paul Schulz
	 */
	public class OpenXAdServer extends Debuggable implements AdServer {
		protected var _openXConfig:OpenXServerConfig = null;
		protected var _template:VideoAdServingTemplate = null;
		protected var _adSchedule:AdSchedule = null;
		protected var _controller:TemplateLoadListener = null;
		
		public function OpenXAdServer() {
		}
		
		public function initialise(config:Config):void {
			if(config != null) {
	            _openXConfig = config.adServerConfig as OpenXServerConfig;
	   		}
		}

		public function get template():VideoAdServingTemplate {
			return _template;
		}
		
		public function loadVideoAdData(listener:TemplateLoadListener, adSchedule:AdSchedule):void {
			_controller = listener;
			_adSchedule = adSchedule;
			if(adSchedule.haveAdSlotsToSchedule()) {
				doLog("Requesting a template with " + adSchedule.adSlots.length + " ads...", Debuggable.DEBUG_VAST_TEMPLATE);
				var openXRequest:OpenXVASTAdRequest = new OpenXVASTAdRequest(_openXConfig);
				openXRequest.zones = adSchedule.zones;
				_template = new VideoAdServingTemplate(listener, openXRequest);
			}
			else {
				doLog("No ad spots to schedule for this stream so no request made to OpenX", Debuggable.DEBUG_VAST_TEMPLATE);
				_template = new VideoAdServingTemplate();
				_template.dataLoaded = true;
				if(listener) listener.onTemplateLoaded(_template);
			}
		}
	}
}