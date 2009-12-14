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
	import org.openvideoads.vast.model.NonLinearTextAd;
	import org.openvideoads.vast.model.NonLinearVideoAd;

	/**
	 * @author Paul Schulz
	 */
	public class TextAdTemplate extends AdTemplate  {
		public static var DEFAULT_TEXT_TEMPLATE:String = 
		         "<body>" + 
		         "<p align='left' class='title'>_title_</p>" + 
		         "<p align='left' class='description'>_description_</p>" + 
		         "<p align='left' class='callToActionTitle'>_callToActionTitle_</p>" + 
		         "</body>";

		public function TextAdTemplate(template:String=null) {
			super((template != null) ? template : DEFAULT_TEXT_TEMPLATE);
		}

		public override function getContent(nonLinearVideoAd:NonLinearVideoAd):String {
			if(nonLinearVideoAd != null) {
				var result:String = replace(_template, "title", (nonLinearVideoAd as NonLinearTextAd).title);
				result = replace(result, "description", (nonLinearVideoAd as NonLinearTextAd).description);
				return replace(result, "callToActionTitle", (nonLinearVideoAd as NonLinearTextAd).callToActionTitle);
			}
			else return "Non-linear video ad not available";
		}
	}
}