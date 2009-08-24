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
	import org.openvideoads.vast.playlist.mrss.MediaRSSPlaylist;
	import org.openvideoads.vast.playlist.rss.RSSPlaylist;
	import org.openvideoads.vast.playlist.smil.SMILPlaylist;
	import org.openvideoads.vast.playlist.xml.XMLPlaylist;
	import org.openvideoads.vast.playlist.xspf.XSPFPlaylist;
	import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class PlaylistController {
		public static const PLAYLIST_FORMAT_DEFAULT:int = 1;
		public static const PLAYLIST_FORMAT_RSS:int = 2;
		public static const PLAYLIST_FORMAT_XML:int = 3;
		public static const PLAYLIST_FORMAT_SMIL:int = 4;
		public static const PLAYLIST_FORMAT_MEDIA:int = 5;
		public static const PLAYLIST_FORMAT_XSPF:int = 6;

		public static function createPlaylist(streamSequence:StreamSequence, type:int=PLAYLIST_FORMAT_DEFAULT):Playlist {
			switch(type) {
				case PLAYLIST_FORMAT_RSS:
					return new RSSPlaylist(streamSequence);
					break;
				case PLAYLIST_FORMAT_XML:
					return new XMLPlaylist(streamSequence);
					break;
				case PLAYLIST_FORMAT_SMIL:
					return new SMILPlaylist(streamSequence);
					break;
				case PLAYLIST_FORMAT_MEDIA:
					return new MediaRSSPlaylist(streamSequence);
					break;
				case PLAYLIST_FORMAT_XSPF:
					return new XSPFPlaylist(streamSequence);
					break;
			}
			return new DefaultPlaylist(streamSequence);
		}
	}
}