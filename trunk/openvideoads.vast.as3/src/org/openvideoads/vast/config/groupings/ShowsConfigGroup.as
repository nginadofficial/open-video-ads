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
	import org.openvideoads.util.ArrayUtils;
	import org.openvideoads.vast.schedule.StreamConfig;
	
	/**
	 * @author Paul Schulz
	 */
	public class ShowsConfigGroup extends AbstractStreamsConfig {
		protected var _previewImage:String = null;
		protected var _streams:Array = new Array();
		protected var _playlist:ShowsPlaylistConfigGroup = null;
		
		public function ShowsConfigGroup(config:Object=null) {
			if(config != null) {
				if(config is String) {
					// should already a JSON object so not converting - just ignoring for safety	
				}
				else initialise(config);				
			}
		}

		public override function initialise(config:Object):void {
			super.initialise(config);
			
			if(config != null) {
				if(config.preview != undefined) {
					_previewImage = config.preview;
				}
				if(config.playlist != undefined) {
					_playlist = new ShowsPlaylistConfigGroup(config.playlist);
					this.streams = _playlist.toShowStreamsConfigArray();
				}
				else {
					if(config.streams != undefined) {
						if(config.streams is String) {
							this.streams = ArrayUtils.makeArray(config.streams);
						}
						this.streams = config.streams;
					}				
				}
			}
		}

		public function getPreviewImage():String {
			return _previewImage;
		}
		
		public function hasPreviewImage():Boolean {
			return (getPreviewImage() != null);
		}
		
		public function getLiveStreamName():String {
			if(_streams.length > 0) {
				if(_streams[0].isLive()) {
					return _streams[0].filename;
				}
			}
			return null;
		}
		
		public function hasShowStreamsDefined():Boolean {
			return (_streams.length > 0);
		}
		
		public function prependStreams(preStreams:Array):void {
			_streams = preStreams.concat(_streams);
		}
		
		public function set streams(streams:Array):void {
			_streams = new Array();
			if(streams != null) {
				for(var i:int = 0; i < streams.length; i++) {
					_streams.push(new StreamConfig(
					                    streams[i].file, // this is the ID
										streams[i].file, 
				                        ((streams[i].duration != undefined) ? streams[i].duration : '00:00:00'), 
				                        ((streams[i].reduceLength != undefined) ? streams[i].reduceLength : false),
				                        ((streams[i].deliveryType != undefined) ? streams[i].deliveryType : "any"),
				                        ((streams[i].playOnce != undefined) ? streams[i].playOnce : false),
				                        ((streams[i].metaData != undefined) ? streams[i].metaData : true),
				                        ((streams[i].autoPlay != undefined) ? streams[i].autoPlay : true),
				                        ((streams[i].provider != undefined) ? streams[i].provider : null),
				                        ((streams[i].player != undefined) ? streams[i].player : this.player)));
				}
			}
		}
		
		public function get streams():Array {
			return _streams;
		}
	}
}