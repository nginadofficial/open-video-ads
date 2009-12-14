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
 *    Lesser GNU General Public License for more details.
 *
 *    You should have received a copy of the Lesser GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.regions.config {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class RegionViewConfig extends BaseRegionConfig {
		protected var _verticalAlign:String = "top";
		protected var _horizontalAlign:String = "left";
		protected var _width:*;
		protected var _height:*;
		protected var _autoShow:Boolean = false;
		protected var _clickable:Boolean = true;
		protected var _clickToPlay:Boolean = false;
		protected var _template:String = null;
		protected var _contentTypes:String = null;
		protected var _keepVisibleAfterClick:Boolean = false;
		
		protected static var TEMPLATES:Array = [
		      { id:'standard-text', html: '' }
		];
		
		public function RegionViewConfig(config:Object=null) {
			super(config);
		}
		
		public override function setup(config:Object):void {
			if(config != null) {
				super.setup(config);
				if(config.verticalAlign) verticalAlign = config.verticalAlign;
				if(config.horizontalAlign) horizontalAlign = config.horizontalAlign;
				if(config.width) width = config.width;
				if(config.height) height = config.height;
				if(config.autoShow) autoShow = config.autoShow;
				if(config.clickable) clickable = config.clickable;
				if(config.clickToPlay) clickToPlay = config.clickToPlay;
				if(config.keepAfterClick) keepVisibleAfterClick = config.keepAfterClick;
			}
		}
		
		public function set width(width:*):void {
			_width = width;
		}
		
		public function get width():* {
			return _width;
		}
		
		public function set height(height:*):void {
			_height = height;
		}
		
		public function get height():* {
			return _height;
		}
		
		public function set autoShow(autoShow:Boolean):void {
			_autoShow = autoShow;
		}
		
		public function get autoShow():Boolean {
			return _autoShow;
		}

		public function set keepVisibleAfterClick(keepVisibleAfterClick:Boolean):void {
			_keepVisibleAfterClick = keepVisibleAfterClick;
		}
		
		public function get keepVisibleAfterClick():Boolean {
			return _keepVisibleAfterClick;
		}
		
		public function set verticalAlign(verticalAlign:String):void {
			_verticalAlign = verticalAlign;
		}
		
		public function get verticalAlign():String {
			return _verticalAlign;
		}
		
		public function set horizontalAlign(horizontalAlign:String):void {
			_horizontalAlign = horizontalAlign;
		}
		
		public function get horizontalAlign():String {
			return _horizontalAlign;
		}
		
		public function set clickable(clickable:Boolean):void {
			_clickable = clickable;
		}
		
		public function get clickable():Boolean {
			return _clickable;
		}
		
		public function set clickToPlay(clickToPlay:Boolean):void {
			_clickToPlay = clickToPlay;
		}
		
		public function get clickToPlay():Boolean {
			return _clickToPlay;
		}
		
		public function set template(template:String):void {
			_template = template;
		}
		
		public function get template():String {
			return _template;
		}

		public function hasTemplate():Boolean {
			return (_template != null);
		}
		
		public function set contentTypes(contentTypes:String):void {
			_contentTypes = contentTypes;
		}
		
		public function get contentTypes():String {
			return _contentTypes;
		}
		
		public function hasContentTypes():Boolean {
			return (_contentTypes != null);
		}
	}
}