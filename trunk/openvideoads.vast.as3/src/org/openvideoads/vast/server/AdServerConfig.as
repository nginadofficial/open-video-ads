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
package org.openvideoads.vast.server {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdServerConfig extends Debuggable {
		protected var _allowAdRepetition:Boolean = false;
		protected var _id:String = "";
		protected var _serverType:String = null;
		protected var _oneAdPerRequest:Boolean = false;
		protected var _customProperties:CustomProperties;
		protected var _requestTemplate:String = null;
		protected var _apiServerAddress:String = "http://localhost";
		protected var _defaultAdServer:Boolean = false;
		protected var _forceImpressionServing:Boolean = false;

		public function AdServerConfig(serverType:String=null, config:Object=null) {
			_serverType = serverType;
			_customProperties = this.defaultCustomProperties;
			initialise(config);
		}

		public function initialise(config:Object):void {
			if(config != null) {
				if(config.id != undefined) _id = config.id;
				if(config.type != undefined) _serverType = config.type;
				if(config.apiAddress != undefined) _apiServerAddress = config.apiAddress;
				if(config.requestTemplate != undefined) _requestTemplate = config.requestTemplate;
				if(config.allowAdRepetition != undefined) _allowAdRepetition = config.allowAdRepetition;
				if(config.oneAdPerRequest != undefined) _oneAdPerRequest = config.oneAdPerRequest;
				if(config.customProperties != undefined) _customProperties.addProperties(config.customProperties);
				if(config.defaultAdServer != undefined) _defaultAdServer = config.defaultAdServer;
				if(config.forceImpressionServing != undefined) {
					this.forceImpressionServing = config.forceImpressionServing;
				}
			}
		}
		
		protected function get defaultTemplate():String {
			return "";
		}
		
		protected function get defaultCustomProperties():CustomProperties {
			return new CustomProperties();
		}
		
		public function get template():String {
			if(_requestTemplate != null) {
				return _requestTemplate;
			}
			return this.defaultTemplate;
		}
		
		public function set template(requestTemplate:String):void {
			_requestTemplate = requestTemplate;
		}
		
		public function set apiServerAddress(apiServerAddress:String):void {
			_apiServerAddress = apiServerAddress;
		}
		
		public function get apiServerAddress():String {
			return _apiServerAddress;
		}
		
		public function set forceImpressionServing(forceImpressionServing:Boolean):void {
			_forceImpressionServing = forceImpressionServing;
			doLog("Impression serving being forced: " + _forceImpressionServing, Debuggable.DEBUG_CONFIG);
		}
		
		public function get forceImpressionServing():Boolean {
			return _forceImpressionServing;
		}
		
		public function set customProperties(customProperties:CustomProperties):void {
			_customProperties = customProperties;
		}
		
		public function get customProperties():CustomProperties {
			return _customProperties;
		}

        public function set oneAdPerRequest(oneAdPerRequest:Boolean):void {
        	_oneAdPerRequest = oneAdPerRequest;
        }
        
        public function get oneAdPerRequest():Boolean {
        	return _oneAdPerRequest;
        }
        
        public function set defaultAdServer(defaultAdServer:Boolean):void {
        	_defaultAdServer = defaultAdServer;
        }
        
        public function get defaultAdServer():Boolean {
        	return _defaultAdServer;
        }
        		
		public function set allowAdRepetition(allowAdRepetition:Boolean):void {
			_allowAdRepetition = allowAdRepetition;
		}
		
		public function get allowAdRepetition():Boolean {
			return _allowAdRepetition;
		}

		public function set serverType(serverType:String):void {
			_serverType = serverType;
		}
		
		public function get serverType():String {
			return _serverType;
		}
		
		public function matchesId(id:String):Boolean {
			if(_id == null) {
				return (id == null);
			} 
			if(id == null) {
				return false;
			}
			return (_id.toUpperCase() == id.toUpperCase());
		}
		
		public function set id(id:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}
				
		public function clone():AdServerConfig {
			var newVersion:AdServerConfig = AdServerConfigFactory.getAdServerConfig(_serverType);
			newVersion.allowAdRepetition = _allowAdRepetition;
			newVersion.oneAdPerRequest = _oneAdPerRequest;
			newVersion.customProperties = _customProperties;
			newVersion.template = _requestTemplate;
			newVersion.apiServerAddress = _apiServerAddress;
			newVersion.defaultAdServer = _defaultAdServer;
			newVersion.forceImpressionServing = _forceImpressionServing;
			return newVersion;
		}
	}
}