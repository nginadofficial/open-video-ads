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
package org.openvideoads.vast.playlist.test {
	public class MediaRSSPlaylistTestHarness {
		public function MediaRSSPlaylistTestHarness(){
		}
		
		public static function getTestData():String {
			var result:String = '';
			result += '<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/" >';
			result += '	<channel>';
			result += '		<description>Test mRss</description>';
			result += '		<title>Test mRss Playlist</title>';
			result += '		<link>www.openvideoads.org</link>';
			result += '		<item>';
			result += '			<description>Item 1</description>';
			result += '			<guid isPermaLink="false">34962|arhzhssxws</guid>';
			result += '			<link></link>';
			result += '			<pubDate>2009-08-03 13:05:02</pubDate>';
			result += '			<media:content url="http://streaming.openvideoads.org/shows/" fileSize="1136041" type="video/x-mp4" medium="video" duration="10" lang="en"/>';
			result += '			<media:title type="plain">the-black-hole.mp4</media:title>';
			result += '			<media:description></media:description>';
			result += '			<media:keywords></media:keywords>';
			result += '			<media:thumbnail url=""/>';
			result += '			<media:credit role="">34962</media:credit>';
			result += '		</item>';
			result += '		<item>';
			result += '			<description>Item 1</description>';
			result += '			<guid isPermaLink="false">34962|arhzhssxws</guid>';
			result += '			<link></link>';
			result += '			<pubDate>2009-08-03 13:05:02</pubDate>';
			result += '			<media:content url="rtmp://ne7c0nwbit.rtmphost.com/videoplayer" fileSize="1136041" type="video/x-mp4" medium="video" duration="10" lang="en"/>';
			result += '			<media:title type="plain">mp4:the-black-hole.mp4</media:title>';
			result += '			<media:description></media:description>';
			result += '			<media:keywords></media:keywords>';
			result += '			<media:thumbnail url=""/>';
			result += '			<media:credit role="">34962</media:credit>';
			result += '		</item>';
			result += '	</channel>';
			result += '</rss>';	
			return result;
		}
	}
}