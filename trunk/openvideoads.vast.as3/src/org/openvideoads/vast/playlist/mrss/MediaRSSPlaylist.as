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
 *
 *    Example Media RSS format:
 * 
 * 		<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
 *			<channel>
 *				<title>Example media RSS playlist for the JW Player</title>
 *				<link>http://www.longtailvideo.com</link>
 *				<item>
 *					<title>Big Buck Bunny - FLV Video</title>
 *					<link>http://www.bigbuckbunny.org/</link>
 *					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
 *					<media:credit role="author">the Peach Open Movie Project</media:credit>
 *					<media:content url="http://www.longtailvideo.com/jw/upload/bunny.flv" type="video/x-flv" duration="33" />
 *					<media:thumbnail url="http://www.longtailvideo.com/jw/upload/bunny.jpg" />
 *				</item>
 *			</channel>
 *		</rss>
 */
 package org.openvideoads.vast.playlist.mrss {
    import org.openvideoads.vast.playlist.DefaultPlaylist;
    import org.openvideoads.vast.playlist.PlaylistItem;
    import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class MediaRSSPlaylist extends DefaultPlaylist {		
		
		public function MediaRSSPlaylist(streamSequence:StreamSequence) {
			super(streamSequence);
		}

		public override function newPlaylistItem():PlaylistItem {
			return new MediaRSSPlaylistItem();
		}		
		
		public override function getModel():Array {
			return new Array();
		}

		public override function toString():String {
			var content:String = new String();
			content += '<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">';
			content += '<channel>';
			content += '<title>OpenX generated Media RSS ad sequenced playlist</title>';
			content += '<link></link>';
			for(var i:int=0; i < _playlist.length; i++) {
				content += _playlist[i].toString();
			}
			content += '</channel>';
			content += '</rss>';
			return content;
		}
	}
}
