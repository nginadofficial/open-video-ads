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
	import org.openvideoads.vast.config.groupings.ShowsConfigGroup;
	

	/**
	 * @author Paul Schulz
	 */
	public interface Playlist {		
		function loadFromURL(url:String):void;
		function loadFromString(xmlData:String):void;
		function newPlaylistItem():PlaylistItem;
		function getModel():Array;
        function reset():void;
        function rewind():void;
		function get playingTrackIndex():int;
		function get currentTrackIndex():int;
		function currentTrackAsPlaylistXML(startTime:int=0):XML;
		function nextTrackAsPlaylistString():String;
		function nextTrackAsPlaylistXML():XML;
		function previousTrackAsPlaylistString():String;
		function previousTrackAsPlaylistXML():XML;
		function get length():int;
		function toShowStreamsConfigArray():Array;
		function toXML():XML;
		function toString():String;
	}
}