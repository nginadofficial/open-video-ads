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
	import org.openvideoads.vast.playlist.Playlist;
	import org.openvideoads.vast.playlist.PlaylistController;
	
	
	public class ShowsPlaylistConfigGroup extends Debuggable {
		protected var _url:String = null;
		protected var _type:int = PlaylistController.PLAYLIST_FORMAT_MEDIA;
		protected var _playlist:Playlist = null;
		
		public function ShowsPlaylistConfigGroup(config:Object) {
			if(config.type != undefined) {
				_type = PlaylistController.getType(config.type);
			}
			if(config.url != undefined) {
				_url = config.url;
				loadPlaylistFromExternalURL();
			}
		}

		protected function loadPlaylistFromExternalURL():void {
			_playlist = PlaylistController.getPlaylistObject(_type);
			_playlist.loadFromURL(_url);
		}	
			
		public function set url(url:String):void {
			_url = url;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function set type(type:int):void {
			_type = type;
		}
		
		public function get type():int {
			return _type;
		}
		
		public function toShowStreamsConfigArray():Array {
			if(_playlist != null) {
				return _playlist.toShowStreamsConfigArray();
			}
			else return new Array();
		}
	}
}