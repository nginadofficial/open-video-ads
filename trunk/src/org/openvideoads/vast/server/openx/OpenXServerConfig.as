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
	public class OpenXServerConfig extends AdServerConfig {
		public static var DEFAULT_NZ:String = "1";
		public static var DEFAULT_SOURCE:String = "";
		public static var DEFAULT_BLOCK:String = "1";
		public static var DEFAULT_SCRIPT:String = "bannerTypeHtml:vastInlineBannerTypeHtml:vastInlineHtml";
		
		protected var _nz:String = DEFAULT_NZ;
		protected var _source:String = DEFAULT_SOURCE;
		protected var _block:String = DEFAULT_BLOCK;
		protected var _script:String = DEFAULT_SCRIPT;
		
		public function OpenXServerConfig(vastServerURL:String=null,
		                                  script:String=null,
										  source:String=null, 
										  randomizer:String=null, 
										  format:String=null, 
										  charset:String=null, 
										  zones:Array=null,
										  referrer:String=null,
										  selectionCriteria:Array=null,
										  allowAdRepetition:Boolean = false) {
			super(vastServerURL, randomizer, format, charset, zones, referrer, selectionCriteria, allowAdRepetition);
			if(script != null) _script = script;
			if(source != null) _source = source;
		}
		
		public override function initialise(config:Object):void {
			super.initialise(config);
			if(config != null) {
				if(config.script != undefined) script = config.script;
				if(config.source != undefined) source = config.source;
			}
		}
				
		public function set script(script:String):void {
			_script = script;
		}
		
		public function get script():String {
			return _script;
		}
		
		public function set nz(nz:String):void {
			_nz = nz;
		}
		
		public function get nz():String {
			return _nz;
		}
		
		public function set source(source:String):void {
			_source = source;
		}
		
		public function get source():String {
			return _source;
		}		

		public override function get type():String {
			return "openx";
		}
	}
}