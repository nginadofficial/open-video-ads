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
package org.openvideoads.vast.tracking {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class TrackingTable extends Debuggable {
		protected var _tid:int = -1;
		protected var _points:Array = new Array();

		public function TrackingTable(tid:int) {
			_tid = tid;
		}

	    public function setPoint(trackingPoint:TrackingPoint, isForLinearChild:Boolean=false):void {
	    	trackingPoint.isForLinearChild = isForLinearChild;
	    	_points[_points.length] = { point:trackingPoint, hit:false, childLinear:isForLinearChild };
			doLog("Tracking point recorded in table (" + _tid + ") at " + trackingPoint.milliseconds + " milliseconds with event label " + trackingPoint.label + " (child:" + isForLinearChild + ")", Debuggable.DEBUG_TRACKING_TABLE);	    	
	    }
		
		public function resetRepeatableTrackingPoints():void {
			doLog("Reseting repeatable tracking points on table " + _tid + " so they fire again", Debuggable.DEBUG_TRACKING_TABLE);
        	for(var i:int=0; i < _points.length; i++) {
        		var event:Object = _points[i];
        		if(event.point.repeatable()) event.hit = false;
        	}
		}
		
        public function hasActiveTrackingPoint(timeEvent:TimeEvent, includeChildLinear:Boolean=true):TrackingPoint {
        	for(var i:int=0; i < _points.length; i++) {
        		var event:Object = _points[i];
        		if(!includeChildLinear && event.childLinear) {
        			// we are not inspecting child linear events at this time
        		}
        		else {
	        		if(event.hit) { // && !event.point.repeatable()) {
	    				//doLog("hasActiveTrackingPoint: Ignoring tracking point " + event.point.label + " because it's been hit and is not repeatable", Debuggable.DEBUG_TRACKING_TABLE);
	        		}
	        		else {
	        			if(timeEvent.label != null) {
		       				if((event.point.milliseconds <= timeEvent.milliseconds) && (event.point.label == timeEvent.label)) {
		       					event.hit = true;
		       					return event.point;
			       			}
	        			}
	       				else if((event.point.milliseconds <= timeEvent.milliseconds)) {
	       					event.hit = true;
	       					return event.point;
		       			}
		        		else if(event.milliseconds > timeEvent.milliseconds) {
		        			return null;
		        		}
	        		}        			
        		}
        	}
        	return null;
		}
		
		public function activeTrackingPoints(timeEvent:TimeEvent, includeChildLinear:Boolean=true):Array {
			var result:Array = new Array();
        	for(var i:int=0; i < _points.length; i++) {
        		var event:Object = _points[i];
        		if(!includeChildLinear && event.childLinear) {
        			// we are not inspecting child linear events at this time
        		}
        		else {
	        		if(event.hit) { // && !event.point.repeatable()) {
	    				//doLog("get activeTrackingPoints: Ignoring tracking point " + event.point.label + " because it's been hit and is not repeatable", Debuggable.DEBUG_TRACKING_TABLE);
	        		}
	        		else {
	        			if(timeEvent.label != null) {
		       				if((event.point.milliseconds <= timeEvent.milliseconds) && (event.point.label == timeEvent.label)) {
		       					event.hit = true;
		       					result.push(event.point);
			       			}        				
	        			}
	       				else if((event.point.milliseconds <= timeEvent.milliseconds)) {
	       					event.hit = true;
		     				result.push(event.point);
		       			}
		        		else if(event.milliseconds > timeEvent.milliseconds) {
		        			return result;
		        		}
	        		}        			
        		}
        	}
			return result;
		}
		
		public function pointAt(index:int):TrackingPoint {
			if(index < length) {
				return _points[index].point;				
			}
			return null;
		}
		
		public function get length():int {
			return _points.length;
		}
		
		public function getPointAtIndex(i:int):TrackingPoint {
			if(i < length-1) {
				return _points[i].point;
			}
			return null;
		}
	}
}