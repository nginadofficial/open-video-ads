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
package org.openvideoads.vast.server {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdServerConfig extends Debuggable {
		public static var DEFAULT_FORMAT:String = "vast";
		public static var DEFAULT_CHARSET_UTF8:String = "UTF_8";
		public static var DEFAULT_VAST_SERVER_URL:String = "http://localhost/vast";

		protected var _charset:String = DEFAULT_CHARSET_UTF8;
		protected var _zones:Array = new Array();
		protected var _format:String = DEFAULT_FORMAT;
		protected var _vastURL:String = DEFAULT_VAST_SERVER_URL;
		protected var _referrer:String = null;
		protected var _selectionCriteria:Array = null;
		protected var _allowAdRepetition:Boolean = false;
		protected var _randomizer:String = null;

		public function AdServerConfig(vastServerURL:String=null,
									   randomizer:String=null, 
									   format:String=null, 
									   charset:String=null, 
									   zones:Array=null,
									   referrer:String=null,
									   selectionCriteria:Array=null,
								       allowAdRepetition:Boolean = false) {
			if(vastURL != null) _vastURL = vastURL;
			if(randomizer != null) {
				_randomizer = randomizer;
			}
			else randomize();
			if(format != null) _format = format;
			if(charset != null) _charset = charset;
			if(zones != null) _zones = zones;
			if(referrer != null) _referrer = referrer;
			if(selectionCriteria != null) _selectionCriteria = selectionCriteria;
			_allowAdRepetition = allowAdRepetition;
		}

		public function initialise(config:Object):void {
			if(config != null) {
				if(config.vastURL != undefined) vastURL = config.vastURL;
				if(config.randomizer != undefined) randomizer = config.randomizer;
				if(config.format != undefined) format = config.format;
				if(config.charset != undefined) charset = config.charset;
				if(config.referrer != undefined) referrer = config.referrer;
				if(config.selectionCriteria != null) _selectionCriteria = config.selectionCriteria;
				if(config.allowAdRepetition != undefined) allowAdRepetition = config.allowAdRepetition;
			}
		}

		public function hasSelectionCriteria():Boolean {
			return (_selectionCriteria != null);	
		}
		
		public function set selectionCriteria(selectionCriteria:Array):void {
			_selectionCriteria = selectionCriteria;	
		}

		public function get selectionCriteria():Array {
			return _selectionCriteria;	
		}
		
		public function getSelectionCriteriaAsParams():String {
			var paramString:String = "";
			
			if(_selectionCriteria != null) {
				for(var i:int = 0; i < _selectionCriteria.length; i++) {
					if(_selectionCriteria[i].name != undefined) {
						paramString += "&" + _selectionCriteria[i].name + "=" + _selectionCriteria[i].value;	
					}
				}
			}
			return paramString;
		}
		
		public function set allowAdRepetition(allowAdRepetition:Boolean):void {
			_allowAdRepetition = allowAdRepetition;
		}
		
		public function get allowAdRepetition():Boolean {
			return _allowAdRepetition;
		}
				
		public function set randomizer(randomizer:String):void {
			_randomizer = randomizer;
		}
		
		public function get randomizer():String {
			return _randomizer;
		}
		
		public function randomize():void {
			_randomizer = new String(Math.random() * 10000000);			
		}

		public function set format(format:String):void {
			_format = format;
		}
		
		public function get format():String {
			return _format;
		}
		
		public function set charset(charset:String):void {
			_charset = charset;
		}
		
		public function get charset():String {
			return _charset;
		}
		
		public function set zones(zones:Array):void {
			_zones = zones;
		}
		
		public function get zones():Array {
			return _zones;
		}
		
		public function set referrer(referrer:String):void {
			_referrer = referrer;
		}
		
		public function get referrer():String {
			return _referrer;
		}
		
		public function set vastURL(vastURL:String):void {
			_vastURL = vastURL;
		}
		
		public function get vastURL():String {
			return _vastURL;
		}
		
		public function get type():String {
			return "generic";
		}
	}
}