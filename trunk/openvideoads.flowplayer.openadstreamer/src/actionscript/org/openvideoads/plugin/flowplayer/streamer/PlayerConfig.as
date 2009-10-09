/*    
 *    Copyright (c) 2009 Open Video Ads - Option 3 Ventures Limited
 *
 *    This file is part of the Open Video Ads Flowplayer Open Ad Streamer.
 *
 *    The Open Ad Streamer is free software: you can redistribute it 
 *    and/or modify it under the terms of the GNU General Public License 
 *    as published by the Free Software Foundation, either version 3 of 
 *    the License, or (at your option) any later version.
 *
 *    The Open Ad Streamer is distributed in the hope that it will be 
 *    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.plugin.flowplayer.streamer
{
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.MediaSize;
	import org.openvideoads.base.Debuggable;
	
	public class PlayerConfig extends Debuggable {
		public function PlayerConfig() {
		}
		
		public static function setClipConfig(clip:Clip, config:Object):void {
			if(config.accelerated != undefined) {
				clip.accelerated = config.accelerated;
				Debuggable.getInstance().doLog("Custom Clip Config: Setting accelerated to " + config.accelerated, Debuggable.DEBUG_CONFIG);
			}
			if(config.autoBuffering != undefined) {
				clip.autoBuffering = config.autoBuffering;
				Debuggable.getInstance().doLog("Custom Clip Config: Setting autoBuffering to " + config.autoBuffering, Debuggable.DEBUG_CONFIG); 
			}
			if(config.bufferLength != undefined) {
				clip.bufferLength = config.bufferLength;
				Debuggable.getInstance().doLog("Custom Clip Config: Setting bufferLength to " + config.bufferLength, Debuggable.DEBUG_CONFIG);				
			}
			if(config.fadeInSpeed != undefined) {
				clip.fadeInSpeed = config.fadeInSpeed;
				Debuggable.getInstance().doLog("Custom Clip Config: Setting fadeInSpeed to " + config.fadeInSpeed, Debuggable.DEBUG_CONFIG); 
			}
			if(config.fadeOutSpeed != undefined) {
				clip.fadeOutSpeed = config.fadeOutSpeed;
				Debuggable.getInstance().doLog("Custom Clip Config: Setting fadeOutSpeed to " + config.fadeOutSpeed, Debuggable.DEBUG_CONFIG);
			}
			if(config.metaData != undefined) {
				clip.metaData = config.metaData;
				Debuggable.getInstance().doLog("Custom Clip Config: Setting metaData to " + config.metaData, Debuggable.DEBUG_CONFIG);
			}
			if(config.scaling != undefined) {
				clip.scaling = MediaSize.forName(config.scaling);
				Debuggable.getInstance().doLog("Custom Clip Config: Setting scaling to " + config.scaling, Debuggable.DEBUG_CONFIG);
			}
			if(config.seekableOnBegin != undefined) {
				clip.seekableOnBegin = config.seekableOnBegin;
				Debuggable.getInstance().doLog("Custom Clip Config: Setting seekableOnBegin to " + config.seekableOnBegin, Debuggable.DEBUG_CONFIG);
			}
		}
	}
}