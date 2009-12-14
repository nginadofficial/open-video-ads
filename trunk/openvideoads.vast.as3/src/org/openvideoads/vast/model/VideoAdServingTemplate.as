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
package org.openvideoads.vast.model {
	import flash.events.*;
	import flash.net.*;
	import flash.xml.*;
	
	import mx.utils.UIDUtil;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.server.AdServerRequest;
	
	/**
	 * @author Paul Schulz
	 */
	public class VideoAdServingTemplate extends Debuggable {
		protected var _xmlLoader:URLLoader = null;
		protected var _listener:TemplateLoadListener = null;
		protected var _registeredLoaders:Array = new Array();
		protected var _ads:Array = new Array();
		protected var _templateData:String = null;
		protected var _dataLoaded:Boolean = false;
		protected var _replaceAdIds:Boolean = false;
		protected var _replacementAdIds:Array = null;
		protected var _uid:String = null;
		protected var _forceImpressionServing:Boolean = false;

		/**
		 * The constructor for a VideoAdServingTemplate
		 * 
		 * @param listener an optional VASTLoadListener that will receive a callback when 
		 * the template successfully loads or fails
		 * @param request an optional OpenXVASTAdRequest that is the request URL to call to 
		 * obtain the VAST template from an OpenX Ad Server
		 */		
		public function VideoAdServingTemplate(listener:TemplateLoadListener=null, request:AdServerRequest=null, replaceAdIds:Boolean=false, adIds:Array=null) {
			_uid = UIDUtil.getUID(this);
			if(listener != null) _listener = listener;
			if(request != null) load(request);
			_replaceAdIds = replaceAdIds; 
			_replacementAdIds = adIds;
		}
		
		/**
		 * Makes a request to the VAST Ad Server to retrieve a VAST dataset given the request
		 * parameters before loading up the returned data and making a callback to the VASTLoadListener
		 * registered on construction of the template.
		 * 
		 * @param request the OpenXVASTAdRequest object that specifies the parameters to be passed
		 * to the OpenX Ad Server, including the address of the server itself 
		 */
		public function load(request:AdServerRequest):void {
			var requestString:String = request.formRequest();
			doLog("Loading VAST data from " + request.serverType() + " - request is " + requestString, Debuggable.DEBUG_VAST_TEMPLATE);
			_forceImpressionServing = request.config.forceImpressionServing;
			registerLoader(_uid);
			_xmlLoader = new URLLoader();
			_xmlLoader.addEventListener(Event.COMPLETE, templateLoaded);
			_xmlLoader.addEventListener(ErrorEvent.ERROR, errorHandler);
			_xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_xmlLoader.load(new URLRequest(requestString));
		}
		
		protected function replacingAdIds():Boolean {
			return _replaceAdIds;
		}
		
		protected function getReplacementAdId(index:int):String {
			if(_replacementAdIds != null) {
				if(index < _replacementAdIds.length) {
					return _replacementAdIds[index];
				}
			}	
			return "no-replacement-found";
		}
		
		public function merge(template:VideoAdServingTemplate):void {
			if(template.hasAds()) {
				_ads = _ads.concat(template.ads);
			}
		}
		
		protected function templateLoaded(e:Event):void {
			doLog("Loaded " + _xmlLoader.bytesLoaded + " bytes for the VAST template", Debuggable.DEBUG_VAST_TEMPLATE);
			doTrace(_xmlLoader, Debuggable.DEBUG_VAST_TEMPLATE);
			_templateData = _xmlLoader.data;
			parseFromRawData(_templateData);
			doLogAndTrace("VAST Template parsed and ready to use", this, Debuggable.DEBUG_VAST_TEMPLATE);
			_dataLoaded = true;
			signalTemplateLoaded(_uid);
		}
		
		protected function errorHandler(e:Event):void {
			doLog("VideoAdServingTemplate: HTTP ERROR: " + e.toString(), Debuggable.DEBUG_VAST_TEMPLATE);
			signalTemplateLoadError(_uid, e);
		}
		
		/**
		 * Returns the raw template data that was returned by the Open X VAST server
		 * 
		 * return string the raw data
		 */
		public function get rawTemplateData():String {
			return _templateData;
		}
		
		/**
		 * Returns a version of the raw template data without newlines etc. that break a html textarea
		 * 
		 * return string the raw data minus newlines
		 */
		public function getHtmlFriendlyTemplateData():String {
		    var xmlData:XML = new XML(rawTemplateData);
			var thePattern:RegExp = /\n/g;
			var encodedString:String = xmlData.toXMLString().replace(thePattern, "\\n");			
			return encodedString;
		}
		
		/**
		 * Identifies whether or not the data has been successfully loaded into the template. Remains false
		 * until the data has been retrieved from the OpenX Ad Server.
		 * 
		 * @return <code>true</code> if the data has been successfully retrieved 
		 */
		public function get dataLoaded():Boolean {
			return _dataLoaded;
		}
	
		public function registerLoader(uid:String):void {
			_registeredLoaders.push(uid);
		}
		
		protected function registeredLoadersIsEmpty():Boolean {
			if(_registeredLoaders.length > 0) {
				for(var i:int=0; i < _registeredLoaders.length; i++) {
					if(_registeredLoaders[i] != null) return false;
				}
			}
			return true;
		}
		
		public function signalTemplateLoaded(uid:String):void {
			var locationIndex:int = _registeredLoaders.indexOf(uid);
			_registeredLoaders[locationIndex] = null;
			if(registeredLoadersIsEmpty()) {
				if(_listener != null) _listener.onTemplateLoaded(this);			
			}
		}

		public function signalTemplateLoadError(uid:String, e:Event):void {
			if(_listener != null) {
				_listener.onTemplateLoadError(e);
			}
		}
		
		/**
		 * Identifies whether or not the data has been successfully loaded into the template. Remains false
		 * until the data has been retrieved from the OpenX Ad Server. Can be forceably set if there
		 * aren't any ads to get data for - hence why there is this public interface
		 * 
		 * @param loadedStatus a boolean value that identifies whether or not the data has been loaded 
		 */
		public function set dataLoaded(loadedStatus:Boolean):void {
			_dataLoaded = loadedStatus;
		}
				
		public function parseFromRawData(rawData:*):void {
	      	XML.ignoreWhitespace = true;
	      	var xmlData:XML = new XML(rawData);
 			doLog("Number of video ad serving templates returned = " + xmlData.length(), Debuggable.DEBUG_VAST_TEMPLATE);
 			if(xmlData.length() > 0) {
 				parseAdSpecs(xmlData.children());
 			}
		}
		
		private function parseAdSpecs(ads:XMLList):void {
			doLog("Parsing " + ads.length() + " ads in the template...", Debuggable.DEBUG_VAST_TEMPLATE);
			for(var i:int=0; i < ads.length(); i++) {
				var adIds:XMLList = ads[i].attribute("id");
				if(ads[i].children().length() == 1) {
					var vad:VideoAd = parseAdResponse(i, adIds[0], ads[i]);
					vad.forceImpressionServing = _forceImpressionServing;
					if(vad != null) addVideoAd(vad);
				}
				else doLog("No InLine tag found for Ad - " + adIds[0] + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE);	
			}
			doLog("Parsing DONE", Debuggable.DEBUG_VAST_TEMPLATE);
		}
		
		private function parseAdResponse(adRecordPosition:int, adId:String, adResponse:XML):VideoAd {
			doLog("Parsing ad record at position " + +adRecordPosition + " with ID " + adId, Debuggable.DEBUG_VAST_TEMPLATE);
			if(adResponse.InLine != undefined) {
				return parseInlineAd(adRecordPosition, adId, adResponse.children()[0]);
			}
			else return parseWrappedAd(adRecordPosition, adId, adResponse.children()[0]);
		}

        private function parseWrappedAd(adRecordPosition:int, adId:String, wrapperXML:XML):WrappedVideoAd {
			doLog("Parsing XML Wrapper Ad record at position " + adRecordPosition + " with ID " + adId, Debuggable.DEBUG_VAST_TEMPLATE);
			if(wrapperXML.children().length() > 0) {
				return new WrappedVideoAd(getReplacementAdId(adRecordPosition), wrapperXML, this);	
			}
			else doLog("No tags found for Wrapper " + adId + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE);
        	return null;
        }	

		private function parseInlineAd(adRecordPosition:int, adId:String, ad:XML):VideoAd {
			doLog("Parsing INLINE Ad record at position " + adRecordPosition + " with ID " + adId, Debuggable.DEBUG_VAST_TEMPLATE);
			doLog("Ad has " + ad.children().length() + " attributes defined - see trace", Debuggable.DEBUG_VAST_TEMPLATE);
			doTrace(ad, Debuggable.DEBUG_VAST_TEMPLATE);
			if(ad.children().length() > 0) {
				var vad:VideoAd = new VideoAd();
				if(replacingAdIds()) {
					vad.id = getReplacementAdId(adRecordPosition);
					doLog("Have replaced the received Ad ID " + adId + " with " + vad.id + " (" + adRecordPosition + ")");
				}
				else vad.id = adId;
				vad.adSystem = ad.AdSystem;
				vad.adTitle = ad.AdTitle;
				vad.description = ad.Description;
				vad.survey = ad.Survey;
				vad.error = ad.Error;
				vad.parseImpressions(ad);
				vad.parseTrackingEvents(ad);
				if(ad.Video != undefined) vad.parseLinear(ad);
				if(ad.NonLinearAds != undefined) vad.parseNonLinear(ad);
				if(ad.CompanionAds != undefined) vad.parseCompanions(ad);
				doLog("Parsing ad record " + adId + " done", Debuggable.DEBUG_VAST_TEMPLATE);
				doTrace(vad, Debuggable.DEBUG_VAST_TEMPLATE);
				return vad;
			}
			else doLog("No tags found for Ad " + adId + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE);
			return null;
		}
		
		public function getFirstAd():VideoAd {
			if(_ads != null) {
				if(_ads.length > 0) {
					return _ads[0];
				}
			}	
			return null;
		}
		
		public function hasAds():Boolean {
			if(_ads == null) {
				return false;
			}
			return (_ads.length > 0);
		}
		
		/**
		 * Allows the list of "ads" to be manually set.
		 * 
		 * @param ads an array of VideoAd(s)
		 */
		public function set ads(ads:Array):void {
			_ads = ads;
		}

		/**
		 * Returns the list of video ads that are currently held by the template. If there are no
		 * ads currently being held, a zero length array is returned.
		 * 
		 * @return array an array of VideoAd(s)
		 */
		public function get ads():Array {
			return _ads;
		}		

		/**
		 * Add a VideoAd to the end of the current list of video ads recorded for this template
		 * 
		 * @param ad a VideoAd
		 */
		public function addVideoAd(ad:VideoAd):void {
			_ads.push(ad);
		}
		
		public function getVideoAdWithID(id:String):VideoAd {
			doLog("Looking for a Video Ad " + id, Debuggable.DEBUG_VAST_TEMPLATE);
			if(_ads != null) {
				for(var i:int = 0; i < _ads.length; i++) {
					if(_ads[i].id == id) {
						doLog("Found Video Ad " + id + " - returning", Debuggable.DEBUG_VAST_TEMPLATE);
						return _ads[i];
					}
				}	
				doLogAndTrace("Could not find Video Ad " + id + " in the VAST template", this, Debuggable.DEBUG_VAST_TEMPLATE);
			}
			else doLog("No ads in the list!", Debuggable.DEBUG_VAST_TEMPLATE);
			return null;
		}		
	}
}