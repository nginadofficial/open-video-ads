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
 package org.openvideoads.vast.playlist {
	import org.openvideoads.vast.schedule.Stream;
	
	/**
	 * @author Paul Schulz
	 */
	public interface PlaylistItem {
		function set stream(stream:Stream):void;
		function get stream():Stream;
//		function set httpStreamerType(httpStreamerType:String):void;
//		function get httpStreamerType():String;
        function set provider(provider:String):void;
        function get provider():String;
		function get title():String;
		function get link():String;
		function get description():String;
		function set filename(filename:String):void;
		function get filename():String;
		function set url(url:String):void;
		function get url():String;
		function set mimeType(mimeType:String):void;
		function get mimeType():String;
		function getFilename(retainPrefix:Boolean=true):String;
		function get duration():String;
//		function getDuration():String;
		function getDurationAsSeconds():int;
		function getStartTime():String;
		function getStartTimeAsSeconds():int;
		function getAuthor():String;
		function getType():String;
		function getStreamer():String;
		function toString():String;
		function toShowStreamConfigObject():Object;
		function isRTMP():Boolean;
		function reset():void;
		function rewind():void;		
	}
}