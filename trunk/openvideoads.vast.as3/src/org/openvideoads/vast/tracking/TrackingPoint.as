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
package org.openvideoads.vast.tracking {
	/**
	 * @author Paul Schulz
	 */
	public class TrackingPoint {
		protected var _milliseconds:Number;
		protected var _label:String;
		protected var _id:String;
		
		public function TrackingPoint(milliseconds:Number, label:String, id:String=null) {
			_milliseconds = milliseconds;
			_label = label;
			_id = id;
		}
		
		public function get milliseconds():Number {
			return _milliseconds;
		}
		
		public function get seconds():Number {
			return _milliseconds / 1000;
		}
		
		public function get label():String {
			return _label;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get type():String {
			if(label != null) {
				return label.substr(0,2);			
			}
			return null;
		}
		
		public function isLinear():Boolean {
			var linearLabels:String = "BS ES BA EA 1Q HW 3Q CS CE SN HN";
			return (linearLabels.indexOf(type) > -1);
		}
		
		public function isNonLinear():Boolean {
			var nonLinearLabels:String = "NS NE CS CE";
			return (nonLinearLabels.indexOf(type) > -1);
        }		
	}
}