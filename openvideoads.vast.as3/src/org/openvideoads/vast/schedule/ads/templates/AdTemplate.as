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
package org.openvideoads.vast.schedule.ads.templates {
	import flash.display.DisplayObject;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.model.NonLinearVideoAd;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdTemplate extends Debuggable {
		public static var DISPLAY_TYPE_HTML:String = "html";
		public static var DISPLAY_TYPE_DIRECT:String = "direct";
		
		protected var _template:String = "_code_";
		protected var _displayObject:DisplayObject = null;
		protected var _displayType:String = DISPLAY_TYPE_HTML;
		
		public function AdTemplate(template:String=null) {
			if(template != null) _template = template;
		}
		
		protected function replace(template:String, variable:String, value:String):String {
			var pattern:RegExp = new RegExp("_" + variable + "_", "g");
			return template.replace(pattern, value);			
		}
		
		public function getContent(nonLinearVideoAd:NonLinearVideoAd):String {
			if(nonLinearVideoAd != null) {
				if(nonLinearVideoAd.hasCode()) {
					return nonLinearVideoAd.codeBlock;
				}
				else {
					if(nonLinearVideoAd.url != null) {
						return replace(_template, "code", nonLinearVideoAd.url.url);				
					}
					else return "";
				}
			}
			else return "Non-linear video ad not available";
		}
		
		public function getDisplayType():String {
			return _displayType;
		}
		
		public function isDirectDisplay():Boolean {
			return (_displayType == DISPLAY_TYPE_DIRECT);
		}
		
		public function isHtmlDisplay():Boolean {
			return (_displayType == DISPLAY_TYPE_HTML);
		}
	}
}