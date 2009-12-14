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
package org.openvideoads.regions.view {
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.RegionController;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.GraphicsUtils;
	import org.openvideoads.util.NumberUtils;
	import org.openvideoads.util.StyleUtils;
 	
	/**
	 * @author Paul Schulz
	 */
	public class RegionView extends Sprite {
		protected var _controller:RegionController;
		protected var _config:RegionViewConfig;
		protected var _displayProperties:DisplayProperties;
		protected var _stylesheet:LoadableStyleSheet = null;
		protected var _text:TextField;
		protected var _textMask:Sprite;
		protected var _closeButton:CrossCloseButton = null;
		protected var _contentLoader:Loader = null;
		protected var _border:Sprite;
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		
		public function RegionView(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties, showCloseButton:Boolean=true) {
            super();
			visible = false;
			buttonMode = true;
			mouseChildren = true; 
			_controller = controller;
			_config = regionConfig;
			_displayProperties = displayProperties;
            if(regionConfig.stylesheet != null) {
            	_stylesheet = new LoadableStyleSheet(regionConfig.stylesheet, onStyleSheetLoaded);
            }
            if(regionConfig.style != null) {
            	if(_stylesheet == null) _stylesheet = new LoadableStyleSheet();
            	_stylesheet.parseCSS(regionConfig.style);
            }
			if(_config.showCloseButton) {
				_closeButton = new CrossCloseButton(null, this);
				addChild(_closeButton);
			}
			if(_config.clickable) addListeners();
			if(_config.html) html = _config.html;
			resize();
			redraw();
		}

		public override function get width():Number {
            if (scaleX > 1) {
	            return _width * scaleX;
            }
			return _width || super.width;
		}
		
		public override function set width(value:Number):void {
			setSize(value, _height);
		}

		public override function get height():Number {
            if (scaleY > 1) {
            	return _height * scaleY;
            }
			return _height || super.height;
		}
		
		public override function set height(value:Number):void {
			setSize(_width, value);
		}

		public function setSize(newWidth:Number, newHeight:Number):void {
			_width = newWidth;
			_height = newHeight;
			onResize();
			redraw();			
		}		

		public function set borderRadius(borderRadius:int):void {
			if(_config != null) _config.borderRadius = borderRadius;
		}
		
		public function get borderRadius():int {
			return ((_config != null) ? _config.borderRadius : -1);
		}
		
		public function hasBorderRadius():Boolean {
			return ((_config != null) ? _config.hasBorderRadius() : false);
		}

		public function getBorderRadiusAsInt():int {
			if(hasBorderRadius() == false) {
				return 5;
			}
			return NumberUtils.toPixels(borderRadius);
		}

		public function set borderWidth(borderWidth:int):void {
			if(_config != null) _config.borderWidth = borderWidth;
		}
		
		public function get borderWidth():int {
			return ((_config != null) ? _config.borderWidth : -1);
		}
		
		public function hasBorderWidth():Boolean {
			return ((_config != null) ? _config.hasBorderWidth() : false);
		}

		public function set borderColor(borderColor:String):void {
			if(_config != null) _config.borderColor = borderColor;
		}
		
		public function get borderColor():String {
			return ((_config != null) ? _config.borderColor : null);
		}
		
		public function hasBorderColor():Boolean {
			return ((_config != null) ? _config.hasBorderColor() : false);
		}
		
		public function set border(border:String):void {
			if(_config != null) _config.border = border;
		}
		
		public function get border():String {
			return (_config != null) ? _config.border : null;
		}
		
		public function hasBorder():Boolean {
			return ((_config != null) ? _config.hasBorder() : false);			
		}

		public function getBorderWidthAsNumber():Number {
			if(hasBorderWidth()) {
				return NumberUtils.toPixels(borderWidth);
			}
			if(hasBorder() == false) {
				return 0;
			}
			return NumberUtils.toPixels(StyleUtils.toElements(border)[0]);
		}

		public function getBorderColorAsUInt():uint {
			if(hasBorderColor()) {
				return StyleUtils.toColorValue(borderColor);
			}
			if(hasBorder()) {
				return StyleUtils.toColorValue(StyleUtils.toElements(border)[2]);
			}
			return 0xffffff;
		}

        public function parseCSS(cssText:String):void {
           	if(_stylesheet == null) _stylesheet = new LoadableStyleSheet();
            _stylesheet.parseCSS(cssText);
        	doLog("Stylesheet settings have been updated to include: " + cssText, Debuggable.DEBUG_STYLES);            
        }
        
		public function set background(background:String):void {
			if(_config != null) _config.background = background;
		}
		
		public function get background():String {
			return (_config != null) ? _config.background : null;
		}
		
		public function hasBackground():Boolean {
			return ((_config != null) ? _config.hasBackground() : false);			
		}
		
		public function set backgroundGradient(backgroundGradient:*):void {
			if(_config != null) _config.backgroundGradient = backgroundGradient;
		}
		
		public function get backgroundGradient():* {
			return (_config != null) ? _config.backgroundGradient : null;
		}
		
		public function hasBackgroundGradient():Boolean {
			return ((_config != null) ? _config.hasBackgroundGradient() : false);						
		}

		public function getBackgroundGradientAsArray():Array {
			if(hasBackgroundGradient()) {
				if(backgroundGradient is String) {
					switch(backgroundGradient) {
						case "none":
							return null;
						case "high":
							return [1.0, 0.5, 0.1, 0.3];
						case "medium":
							return [0.6, 0.21, 0.21];
						case "low":
							return [0.4, 0.15, 0.15];
					}
					return [0.4, 0.15, 0.15];
				}	
				return backgroundGradient;
			}
			return null;
		}

		public function set backgroundTransparent(backgroundTransparent:Boolean):void {
			if(_config != null) _config.backgroundColor = (backgroundTransparent) ? "transparent" : null;
		}
		
		public function isBackgroundTransparent():Boolean {
			if(hasBackgroundColor() == false) {
				return false;
			}
			return (backgroundColor.toUpperCase() == "TRANSPARENT");
		}

		public function set backgroundColor(backgroundColor:String):void {
			if(_config != null) _config.backgroundColor = backgroundColor;
		}
		
		public function get backgroundColor():String {
			return (_config != null) ? _config.backgroundColor : null;
		}
		
		public function hasBackgroundColor():Boolean {
			return (_config != null) ? _config.hasBackgroundColor() : false;
		}
		
		public function getBackgroundColorAsUInt():uint {
			if(hasBackgroundColor()) { 
				return StyleUtils.toColorValue(backgroundColor);
			}
			if(hasBackground()) { 
				var props:Array = StyleUtils.toElements(backgroundColor);
				if (String(props[0]).indexOf("#") == 0) {
					return StyleUtils.toColorValue(props[0]);
				}
			}
			return 0x333333;
		}
		
		public function set opacity(opacity:Number):void {
			if(_config != null) _config.opacity = opacity;
		}
		
		public function get opacity():Number {
			return (_config != null) ? _config.opacity : 1.0;
		}
		
		public function hasOpacity():Boolean {
			return (_config != null) ? _config.hasOpacity() : false;			
		}

		public function set showCloseButton(showCloseButton:Boolean):void {
			if(_config != null) _config.showCloseButton = showCloseButton;
		}
		
		public function get showCloseButton():Boolean {
			return (_config != null) ? _config.showCloseButton : false;
		}		

        public function set padding(padding:String):void {
        	if(_config != null) _config.padding = padding;
        }
        
        public function get padding():String {
			return (_config != null) ? _config.padding : null;
        }
        
		public function get template():String {
			return (_config != null) ? _config.template : null;
		}

		public function hasTemplate():Boolean {
			return (_config != null) ? _config.hasTemplate() : false;
		}
		
		public function get contentTypes():String {
			return (_config != null) ? _config.contentTypes : null;
		}
		
		public function hasContentTypes():Boolean {
			return (_config != null) ? _config.hasContentTypes() : false;
		}

        protected function onStyleSheetLoaded():void {
        	doLog("Stylesheet has been loaded", Debuggable.DEBUG_STYLES);
        }

		public function get id():String {
			return (_config != null) ? _config.id : "none";
		}

		private function addListeners():void {
			addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function removeListeners():void {
			removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			removeEventListener(MouseEvent.CLICK, onClick);
		}
				
		public function setWidth():void {
			var requiredWidth:* = _config.width;
			var parentWidth:int = _displayProperties.displayWidth;
			if(typeof requiredWidth == "string") { // it's a percentage
				if(requiredWidth.indexOf("pct") != -1) {
					var widthPercentage:int = parseInt(requiredWidth.substring(0,requiredWidth.indexOf("pct")));
					width = ((parentWidth / 100) * widthPercentage);
					doLog("Width is to be set to a percentage of the parent - " + requiredWidth + " setting to " + width, Debuggable.DEBUG_REGION_FORMATION);
				}
				else {
					doLog("Region width is a string value " + requiredWidth + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);
					width = parseInt(requiredWidth);			
				}
			}
			else if(requiredWidth is Number) {
				doLog("Region width is defined as a number " + requiredWidth + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);
				width = requiredWidth;
			}
			else doLog("Bad type " + (typeof width) + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);
		}
		
		public function setHeight():void {
			var requiredHeight:* = _config.height;	
			var parentHeight:int = _displayProperties.displayHeight;
			if(typeof requiredHeight == "string") { // it's a percentage
				if(requiredHeight.indexOf("pct") != -1) {
					var heightPercentage:int = parseInt(requiredHeight.substring(0,requiredHeight.indexOf("pct")));
					height = ((parentHeight / 100) * heightPercentage);
					doLog("Height is to be set to a percentage of the parent - " + requiredHeight + " setting to " + height, Debuggable.DEBUG_REGION_FORMATION);
				}
				else {
					doLog("Region height is a string value " + requiredHeight + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);
					height = parseInt(requiredHeight);
				}
			}
			else if(typeof requiredHeight == "number") {
				doLog("Region height is defined as a number " + requiredHeight + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);
				height = requiredHeight;
			}
			else doLog("Bad type " + (typeof width) + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);
		}
		
		public function setVerticalAlignment():void {
			var align:* = _config.verticalAlign;
			var parentHeight:int = (_displayProperties.displayHeight * scaleY);
			if(typeof align == "string") {
				if(align == "top") {
					y = 0;
				}
				else if(align == "bottom") {
					y = parentHeight - height - _displayProperties.bottomMargin; 
				}
				else if(align == "center") {
					y = ((parentHeight - height) / 2);
				}
				else { // must be a number
					y = new Number(align);
				}	
				doLog("Vertical alignment set to " + y + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);		
			}
			else if(typeof align == "number") {
				y = align;
				doLog("Vertical alignment set to " + y + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);		
			}
			else doLog("bad vertical alignment value " + align + " on region " + id, Debuggable.DEBUG_REGION_FORMATION);
		}

		public function setHorizontalAlignment():void {
			var align:* = _config.horizontalAlign;
			var parentWidth:int = (_displayProperties.displayWidth * scaleX);
			if(typeof align == "string") {
				if(align == "left") {
					x = 0;
				}
				else if(align == "right") {
					x = parentWidth-width;
				}		
				else if(align == "center") {
					x = ((parentWidth-width) / 2);
				}
				else { // must be a number
					x = new Number(align);
				}	
				doLog("Horizontal alignment set to " + x + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);		
			}
			else if(typeof align == "number") {
				x = align;
				doLog("Horizontal alignment set to " + x + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);		
			}
			else doLog("bad horizontal alignment value " + align + " on region " + id, Debuggable.DEBUG_REGION_FORMATION);
		}
		
		public function resize(resizeProperties:DisplayProperties=null):void {
			if(resizeProperties != null) {
				scaleX  = resizeProperties.scaleX;
				scaleY  = resizeProperties.scaleY;
				doLog("Scaling set to X: " + scaleX + " Y: " + scaleY, Debuggable.DEBUG_REGION_FORMATION);
			}
			setWidth();
			setHeight();		
			setVerticalAlignment();
			setHorizontalAlignment();
		}

		public function set html(htmlText:String):void {
			if(_config != null) {
				_config.html = ((htmlText == null) ? "" : htmlText);
				createTextField();
				arrangeCloseButton();
				doLog("set html to " + html, Debuggable.DEBUG_REGION_FORMATION);				
			}
		}

		public function get html():String {
			return ((_config != null) ? _config.html : null);
		}
					
		public function loadDisplayContent(url:String, allowDomains:String):void {
		  	 clearDisplayContent();
			 doLog("Loading display object resource from " + url, Debuggable.DEBUG_REGION_FORMATION);
			 doLog("Security.allowDomain() has been set to " + allowDomains, Debuggable.DEBUG_CONFIG);
		  	 Security.allowDomain(allowDomains);
			 _contentLoader = new Loader();
			 var urlReq:URLRequest = new URLRequest(url);
		 	 _contentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
			 	function(event:Event):void {
					doLog("External SWF successfully loaded from " + url, Debuggable.DEBUG_REGION_FORMATION);
				}
			 );
			 _contentLoader.mouseChildren = false;
			 _contentLoader.mouseEnabled = false;
			 _contentLoader.load(urlReq);
			 addChild(_contentLoader);
			 arrangeCloseButton();
		}
		
		public function clearDisplayContent():void {
			if(_contentLoader != null) {
				try {					
					this.removeChild(_contentLoader);
				}
				catch(ae:ArgumentError) {
				}
				_contentLoader = null;
			}
		}
		
		private function createTextField():void {
			if(_text) removeChild(_text);
			_text = GraphicsUtils.createFlashTextField(false, null, 12, false);
			_text.blendMode = BlendMode.NORMAL;
			_text.autoSize = TextFieldAutoSize.CENTER;
			_text.wordWrap = true;
			_text.multiline = true;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.condenseWhite = true;
			_text.mouseEnabled = false;
			if(_stylesheet != null) {
				_text.styleSheet = _stylesheet.stylesheet;
			}
			if(html != null) _text.htmlText = html;
			addChild(_text);
			_textMask = createMask();
			addChild(_textMask);
			_text.mask = _textMask;
			arrangeText();
		}

		private function arrangeText():void {
			if(_text) {
				var result:Array = new Array();
				if (padding.indexOf(" ") > 0) {
					var pads:Array = padding.split(" ");
					_text.y = NumberUtils.toPixels(pads[0]);
					_text.x = NumberUtils.toPixels(pads[3]);
					_text.height = Math.round(_height - NumberUtils.toPixels(pads[0]) - NumberUtils.toPixels(pads[2]));
					_text.width = Math.round(_width - NumberUtils.toPixels(pads[1]) - NumberUtils.toPixels(pads[3]));
				}
				else {
					var paddingInPixles:int = NumberUtils.toPixels(padding);
					_text.y = Math.round(paddingInPixles[0]);
					_text.x = Math.round(paddingInPixles[3]);
					_text.height = Math.round(_height - paddingInPixles[0] - paddingInPixles[2]);
					_text.width = Math.round(_width - paddingInPixles[1] - paddingInPixles[3]);
				}
				doLog("Arranging text to sit at X:" + _text["y"] + " Y:" + _text["x"] + " height:" + _text["height"] + " width:" + _text["width"], Debuggable.DEBUG_REGION_FORMATION);
			}
		}
		
		protected function onResize():void {
			arrangeCloseButton();
			if (_textMask) {
				_textMask.width = _width;
				_textMask.height = _height;
			}
			this.x = 0;
			this.y = 0;
		}

		protected function onRedraw():void {
			arrangeText();
			arrangeCloseButton();
		}
		
		private function arrangeCloseButton():void {
			if (_closeButton) { 
				_closeButton.x = _width - 5 - (borderRadius/5);
				_closeButton.y = 5 + borderRadius/5;
				if(numChildren > 0) setChildIndex(_closeButton, numChildren-1);
			}
		}

		public function onCloseClicked():void {
			removeListeners();
			hide();
			_controller.onRegionCloseClicked(this);			
		}
		
		public function hide():void {
			this.visible = false;
		}
		
		protected function onMouseOver(event:MouseEvent):void {
			doLog("RegionView: mouse over", Debuggable.DEBUG_MOUSE_EVENTS);
		}

		protected function onMouseOut(event:MouseEvent):void {
			doLog("RegionView: mouse out", Debuggable.DEBUG_MOUSE_EVENTS);
		}

		protected function onClick(event:MouseEvent):void {
			doLog("RegionView: on click", Debuggable.DEBUG_MOUSE_EVENTS);
			if(!_config.keepVisibleAfterClick) hide();
			_controller.onRegionClicked(this);
		}
				
		private function redraw():void {
			drawBackground();
			drawBorder();
			onRedraw();
		}

		private function drawBackground():void {
			graphics.clear();
			if(hasOpacity()) alpha = opacity;
			if (isBackgroundTransparent() == false) {
				graphics.beginFill(getBackgroundColorAsUInt());
			} 
			else graphics.beginFill(0,0);
			GraphicsUtils.drawRoundRectangle(graphics, 0, 0, _width, _height, borderRadius);
			graphics.endFill();
			if (backgroundGradient) {
				GraphicsUtils.addGradient(this, 0,  backgroundGradient, borderRadius);
			} 
			else GraphicsUtils.removeGradient(this);
		}
		
		protected function createMask():Sprite {
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0);
			GraphicsUtils.drawRoundRectangle(mask.graphics, 0, 0, width, height, borderRadius);
			return mask;
		}

		private function drawBorder():void {
			if (_border && _border.parent == this) {
				removeChild(_border);
			}
			if (borderWidth <= 0) return;
			_border = new Sprite();
			addChild(_border);
			_border.graphics.lineStyle(borderWidth, getBorderColorAsUInt());
			GraphicsUtils.drawRoundRectangle(_border.graphics, 0, 0, width, height, borderRadius);
		}		
					
		// DEBUG METHODS
		
		protected function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		protected function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
		
		protected function doLogAndTrace(data:String, o:Object, level:int=1):void {
			Debuggable.getInstance().doLogAndTrace(data, o, level);
		}
	}
}