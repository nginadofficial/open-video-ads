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
package org.openvideoads.vast.config.groupings {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class DebugConfigGroup extends Debuggable {
		private var _debugger:String = "demonster";
		private var _levels:String = "fatal";

		public function DebugConfigGroup(config:Object=null) {
			if(config != null) {
				if(config is String) {
					// should already a JSON object so not converting - just ignoring for safety	
				}
				else initialise(config);				
			}
		}

        public function initialise(config:Object):void {
			if(config != null) {
				if(config.levels != undefined) this.levels = config.levels;
				if(config.debugger != undefined) this.debugger = config.debugger;
			}        	
        }
        
		public function debuggersSpecified():Boolean {
			return (_debugger != null);
		}
		
		public function set debugger(debugger:String):void {
			_debugger = debugger;
		}
		
		public function get debugger():String {
			return _debugger;
		}
		
		public function set levels(levels:String):void {
			_levels = levels;
		}
		
		public function get levels():String {
			return _levels;
		}
		
		public function debugLevelSpecified():Boolean {
			return (_levels != null);
		}
	}
}