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
package org.openvideoads.vast.model {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;
	import org.openvideoads.vast.events.CompanionAdDisplayEvent;
	
	/**
	 * @author Paul Schulz
	 */
	public class CompanionAd extends NonLinearVideoAd {
		public function CompanionAd() {
			super();
		}
		
		public function getMarkup():String {
			var newHtml:String = "";
			if(isHtml()) {
				doLog("Inserting a HTML codeblock into the DIV for a companion banner... " + clickThroughs.length + " click through URL described", Debuggable.DEBUG_CUEPOINT_EVENTS);
				doTrace(codeBlock, Debuggable.DEBUG_CUEPOINT_EVENTS);
				if(hasClickThroughURL()) {
					newHtml = "<a href=\"" + clickThroughs[0].url + "\" target=_blank>";
					newHtml += codeBlock;
					newHtml += "</a>";
				}
				else newHtml = codeBlock;
			}
			else {
				if(isImage()) {
					doLog("Inserting a <IMG> into the DIV for a companion banner..." + clickThroughs.length + " click through URL described", Debuggable.DEBUG_CUEPOINT_EVENTS);
					if(hasClickThroughURL()) {
						newHtml = "<a href=\"" + clickThroughs[0].url + "\" target=_blank>";
						newHtml += "<img src=\"" + url.url + "\" border=\"0\"/>";
						newHtml += "</a>";
					}
					else {
						newHtml += "<img src=\"" + url.url + "\" border=\"0\"/>";								
					}
				}		
				else doLog("Unknown resource type " + resourceType);
			}	
			return newHtml;		
		}
		
		override public function start(displayEvent:VideoAdDisplayEvent):void {
			displayEvent.controller.onDisplayCompanionAd(new CompanionAdDisplayEvent(CompanionAdDisplayEvent.DISPLAY, this));
		}
		
		override public function stop(displayEvent:VideoAdDisplayEvent):void {
			displayEvent.controller.onHideCompanionAd(new CompanionAdDisplayEvent(CompanionAdDisplayEvent.HIDE, this));
		}
	}
}