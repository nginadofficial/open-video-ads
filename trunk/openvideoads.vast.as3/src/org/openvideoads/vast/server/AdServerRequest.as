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
	public class AdServerRequest extends Debuggable {
		protected var _config:AdServerConfig = null;
		protected var _zones:Array = new Array();
		
		public function AdServerRequest(config:AdServerConfig=null) {
			if(config != null) _config = config;	
		}		
		
		public function set config(config:AdServerConfig):void {
			_config = config;
		}
		
		public function get config():AdServerConfig {
			if(_config == null) _config = new AdServerConfig();
			return _config
		}

		public function addZone(id:String, zone:String):void {
			if(_zones == null) _zones = new Array();
			var newZone:Object = new Object();
			newZone.id = id;
			newZone.zone = zone;
			_zones.push(newZone);
		}
				
		public function serverType():String {
			return config.serverType;
		}
		
		public function get replaceIds():Boolean {
			return true;
		}
		
		public function get replacementIds():Array {
			var result:Array = new Array();
			for(var i:int = 0; i < _zones.length; i++) {
				result.push(_zones[i].id);
			}
			return result;
		}

		protected function replaceApiServerAddress(template:String):String {
			var thePattern:RegExp = new RegExp("__api-address__", "g");
			template = template.replace(thePattern, config.apiServerAddress);
			return template;	
		}
		
		protected function replaceCustomProperties(template:String, properties:Object):String {
			return _config.customProperties.completeTemplate(template);
		}

		protected function replaceZone(template:String):String {
			if(_zones != null) {
				if(_zones.length > 0) {
					var thePattern:RegExp = new RegExp("__zone__", "g");
					template = template.replace(thePattern, _zones[0].zone);	
				}
			}
			return template;	
		}
		
		protected function replaceZones(template:String):String {
			return template;	
		}

		protected function replaceRandomNumber(template:String):String {
			var thePattern:RegExp = new RegExp("__random-number__", "g");
			template = template.replace(thePattern, "R" + Math.random());
			return template;	
		}

		protected function replaceDuplicatesAsBinary(template:String):String {
			var thePattern:RegExp = new RegExp("__allow-duplicates-as-binary__", "g");
			template = template.replace(thePattern, (_config.allowAdRepetition) ? "1" : "0");
			return template;
		}
		
		protected function replaceDuplicatesAsBoolean(template:String):String {
			var thePattern:RegExp = new RegExp("__allow-duplicates-as-boolean__", "g");
			template = template.replace(thePattern, (_config.allowAdRepetition) ? "true" : "false");
			return template;
		}

	 	public function formRequest(zones:Array=null):String {
	 		if(zones != null) _zones = zones;
			var template:String = config.template;
			template = replaceApiServerAddress(template);
			template = replaceCustomProperties(template, config.customProperties);
			template = replaceRandomNumber(template);
			template = replaceDuplicatesAsBinary(template);
			template = replaceDuplicatesAsBoolean(template);
			template = replaceZone(template);
			template = replaceZones(template);
	 		return template;
	 	}	 	
	}
}