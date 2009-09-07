/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls {
	import org.flowplayer.util.Log;	
	import org.flowplayer.util.PropertyBinder;	
	
	/**
	 * @author api
	 */
	public class Config {
		private var log:Log = new Log(this);
		private var _skin:String;
		private var _style:Style;
		private var _autoHide:String = "fullscreen"; // never | fullscreen | always
		private var _hideDelay:Number = 4000;
		private var _visible:WidgetBooleanStates = new WidgetBooleanStates();
		private var _enabled:WidgetBooleanStates = new WidgetEnabledStates();
		private var _tooltips:ToolTips = new ToolTips();

        public function get autoHide():String {
			return _autoHide;
		}
		
		public function set autoHide(autoHide:String):void {
			_autoHide = autoHide;
		}
		
		public function get style():Style {
			return _style || new Style();
		}
		
		public function addStyleProps(styleProps:Object):void {
			_style = new PropertyBinder(style, "bgStyle").copyProperties(styleProps) as Style;
		}
		
		public function get hideDelay():Number {
			return _hideDelay;
		}
		
		public function set hideDelay(hideDelay:Number):void {
			_hideDelay = hideDelay;
		}
		
		public function get visible():WidgetBooleanStates {
			return _visible;
		}
		
		public function set visible(visible:WidgetBooleanStates):void {
			_visible = visible;
		}
		
		public function get enabled():WidgetBooleanStates {
			return _enabled;
		}
		
		public function set enabled(enabled:WidgetBooleanStates):void {
			_enabled = enabled;
		}
		
		public function get skin():String {
			return _skin;
		}
		
		public function set skin(skin:String):void {
			_skin = skin;
		}
		
		public function get tooltips():ToolTips {
			return _tooltips;
		}
		
		public function set tooltips(tooltips:ToolTips):void {
			_tooltips = tooltips;
		}
	}
}
