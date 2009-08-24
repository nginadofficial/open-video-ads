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
 package org.openvideoads.vast.playlist {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class DefaultPlaylist extends Debuggable implements Playlist {		
		protected var _playlist:Array = new Array();
		protected var _currentTrackIndex:int = 0;
		protected var _playingTrackIndex:int = 0;
		
		public function DefaultPlaylist(streamSequence:StreamSequence) {
			for(var i:int=0; i < streamSequence.length; i++) {
				var newItem:PlaylistItem = newPlaylistItem();
				newItem.stream = streamSequence.streamAt(i);
				_playlist.push(newItem);
			}
		}
		
		public function playlist():Array {
			return _playlist;
		}
		
		public function newPlaylistItem():PlaylistItem {
			return new DefaultPlaylistItem();
		}
		
		public function rewind():void {
			_currentTrackIndex = 0;
			if(_playlist != null) {
				for(var i:int=0; i < _playlist.length; i++) {
					_playlist[i].rewind();
				}
			}
		}

		public function reset():void {
			_currentTrackIndex = 0;
			if(_playlist != null) {
				for(var i:int=0; i < _playlist.length; i++) {
					_playlist[i].reset();
				}
			}
		}
		
		public function get playingTrackIndex():int {
			return _playingTrackIndex;
		}
		
		public function get currentTrackIndex():int {
			return _currentTrackIndex;
		}
		
		public function nextTrackAsPlaylistString():String {
			if(_playlist != null) {
				if(_currentTrackIndex < _playlist.length) {
					_playingTrackIndex = _currentTrackIndex;
 			        if(_playlist[_currentTrackIndex].canPlay()) {
	 			        var trackData:String = header();
						trackData += _playlist[_currentTrackIndex].toString();
						_playlist[_currentTrackIndex].markAsPlayed(); 			        	
						trackData += footer();
						_currentTrackIndex++;
						return trackData;
 			        }
 			        else {	
						_currentTrackIndex++;
 			        	return nextTrackAsPlaylistString();
 			        }
				}				
			}
			return null;
		}
		
		public function nextTrackAsPlaylistXML():XML {
			var data:String = nextTrackAsPlaylistString();
			if(data != null) {
				return new XML(data);			
			}
			else return null;
		}
		
		public function previousTrackAsPlaylistString():String {
			if(_playlist != null) {
				if(_currentTrackIndex >= 0) {
 			        if(_playlist[_currentTrackIndex].canPlay()) {
	 			        var trackData:String = header();
						trackData += _playlist[_currentTrackIndex].toString();
						_playlist[_currentTrackIndex].markAsPlayed();
						trackData += footer();
						_currentTrackIndex--;
						return trackData;					
 			        }
 			        else {
						_currentTrackIndex--;
 			        	return previousTrackAsPlaylistString();
 			        }
				}				
			}
			return null;
		}

		public function previousTrackAsPlaylistXML():XML {
			var data:String = previousTrackAsPlaylistString();
			if(data != null) {
				return new XML(data);			
			}
			else return null;
		}

		public function getModel():Array {
			return new Array();
		}

        public function toXML():XML {
        	return new XML(toString());
        }
        
	    protected function header():String {
			return new String();
	    }

	    protected function footer():String {
			return new String();
	    }
	    
		public function toString():String {
			var result:String = new String();
			for(var i:int=0; i < _playlist.length; i++) {
				result += _playlist[i].toString();
			}
			return result;
		}
	}
}