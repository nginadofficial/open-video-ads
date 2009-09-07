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
 *    Example MRSS item format:
 * 
 *		<item>
 *			<title>Big Buck Bunny - FLV Video</title>
 *			<link>http://www.bigbuckbunny.org/</link>
 *			<description>Big Buck Bunny is a short animated film by the Blender Institute</description>
 *			<media:credit role="author">the Peach Open Movie Project</media:credit>
 *			<media:content url="http://www.longtailvideo.com/jw/upload/bunny.flv" type="video/x-flv" duration="33" />
 *		</item>
 */
 package org.openvideoads.vast.playlist.mrss {
	import org.openvideoads.vast.playlist.DefaultPlaylistItem;
	
	/**
	 * @author Paul Schulz
	 */
	public class MediaRSSPlaylistItem extends DefaultPlaylistItem {
		
		public override function toString():String {
			var result:String = new String();
			result += '<item>';
			result += '<title>' + getTitle() + '</title>';
			result += '<link>' + getLink() + '</link>';
			result += '<description>' + getDescription() + '</description>';
			result += '<media:credit role="author">' + getAuthor() + '</media:credit>';
			if(isRTMP()) {
				result += '<media:content url="' + getStreamer() + getFilename() + '" type="video/x-mp4"/>';			
			}
			else result += '<media:content url="' + getFilename() + '" />';			
			result += '<guid>' + getFilename() + '</guid>'; 
			result += '</item>';
			return result;
		}
	}
}
