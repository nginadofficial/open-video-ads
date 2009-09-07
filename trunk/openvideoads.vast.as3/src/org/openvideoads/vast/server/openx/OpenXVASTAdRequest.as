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
	import org.openvideoads.vast.server.AdServerConfig;
	
	
	/**
	 * @author Paul Schulz
	 */
	public class OpenXVASTAdRequest extends OpenXServerConfig {
		public function OpenXVASTAdRequest(config:OpenXServerConfig=null) {
			if(config != null) initialise(config);
		}
		
		private function formZoneParameters():String {
			var zoneIDs:String = "";
			for(var i:int = 0; i < _zones.length; i++) {
				if(zoneIDs.length > 0) {
					zoneIDs += "%7C";
				}
				zoneIDs += _zones[i].id + "%3D" + _zones[i].zone;		
			}
			return zoneIDs;			
		}
		
		public function formRequest(zones:Array=null):String {
			if(zones != null) _zones = zones;
			return vastURL + "?" +
			       "script=" + script +
			       "&zones=" + formZoneParameters() +
			       ((hasSelectionCriteria()) ? getSelectionCriteriaAsParams() : "") + 
			       "&nz=" + nz +
			       "&source=" + source +
			       "&r=" + randomizer + 
			       "&block=" + ((allowAdRepetition) ? "0" : "1") +
			       "&format=" + format +
			       "&charset=" + charset;
		}
	}
}