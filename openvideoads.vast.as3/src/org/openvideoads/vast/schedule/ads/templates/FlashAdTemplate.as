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
	import org.openvideoads.vast.model.NonLinearVideoAd;

	/**
	 * @author Paul Schulz
	 */
	public class FlashAdTemplate extends AdTemplate {
		public static var DEFAULT_SWF_TEMPLATE:String = "<img src='_code_'/>";
		
		public function FlashAdTemplate(template:String=null) {
			super((template != null) ? template : DEFAULT_SWF_TEMPLATE);
		}
		
		public override function getContent(nonLinearVideoAd:NonLinearVideoAd):String {
			if(nonLinearVideoAd != null) {
				if(nonLinearVideoAd.hasCode()) {
					return replace(_template, "code", nonLinearVideoAd.codeBlock);				
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
	}
}