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
package org.openvideoads.vast.server.wrapped {
	import org.openvideoads.vast.server.AdServerRequest;
	
	public class WrappedAdServerRequest extends AdServerRequest {
		protected var _url:String = null;
		
		public function WrappedAdServerRequest(url:String) {
			super(new WrappedAdServerConfig());
			_url = url;
		}
		
	 	public override function formRequest(zones:Array=null):String {
	 		return _url;
	 	}	
	}
}