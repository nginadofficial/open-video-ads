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
 *
 *    Example RSS format:
 *
 *	  <?xml version="1.0" encoding="UTF-8"?>
 *	  <rss version="2.0" xmlns:jwplayer="http://developer.longtailvideo.com/trac/wiki/FlashFormats">
 *	  <channel>
 *	  	  <title>YOUR TITLE</title>
 *		  <description>YOUE DESCRIPTION.</description>
 *		  <item>
 *				<title>PLAY LIST TITLE</title>
 *				<description>PLA LIST DESCRIPTION</description>
 *				<meta rel="type">rtmp</meta> 
 *				<enclosure url="YOUR FILENAME.mp4"></enclosure> 
 *		  </item>
 *	  </channel>
 *    </rss>
 */
package org.openvideoads.vast.playlist.rss {
    import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
    import org.openvideoads.vast.playlist.DefaultPlaylist;
    import org.openvideoads.vast.playlist.PlaylistItem;
    import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class RSSPlaylist extends DefaultPlaylist {		
		
		public function RSSPlaylist(streamSequence:StreamSequence=null, showProviders:ProvidersConfigGroup=null, adProviders:ProvidersConfigGroup=null) {
			super(streamSequence, showProviders, adProviders);
		}

		public override function newPlaylistItem():PlaylistItem {
			return new RSSPlaylistItem();
		}		
		
		public override function getModel():Array {
			return new Array();
		}

		public override function toString():String {
			var content:String = new String();
//			content += '<?xml version="1.0" encoding="UTF-8"?>';
//			content += '<rss version="2.0" xmlns:jwplayer="http://developer.longtailvideo.com/trac/wiki/FlashFormats">';
			content += '<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">';
			content += '<channel>';
			content += '<title>Open Video Ads generated RSS ad sequenced playlist</title>';
			content += '<description>none</description>';
			for(var i:int=0; i < _playlist.length; i++) {
				content += _playlist[i].toString();
			}
			content += '</channel>';
			content += '</rss>';
			return content;
		}
	}
}
