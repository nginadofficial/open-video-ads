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
package org.openvideoads.vast.model {
	import flash.events.*;
	import flash.net.*;
	import flash.xml.*;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.vast.server.openx.OpenXVASTAdRequest;
	
	/**
	 * @author Paul Schulz
	 */
	public class VideoAdServingTemplate extends Debuggable {
		protected var _xmlLoader:URLLoader = null;
		protected var _listener:TemplateLoadListener = null;
		protected var _ads:Array = new Array();
		protected var _templateData:String = null;
		protected var _dataLoaded:Boolean = false;

		/**
		 * The constructor for a VideoAdServingTemplate
		 * 
		 * @param listener an optional VASTLoadListener that will receive a callback when 
		 * the template successfully loads or fails
		 * @param request an optional OpenXVASTAdRequest that is the request URL to call to 
		 * obtain the VAST template from an OpenX Ad Server
		 */		
		public function VideoAdServingTemplate(listener:TemplateLoadListener=null, request:OpenXVASTAdRequest=null) {
			if(listener != null) _listener = listener;
			if(request != null) load(request);
		}
		
		/**
		 * Makes a request to the Open X Ad Server to retrieve a VAST dataset given the request
		 * parameters before loading up the returned data and making a callback to the VASTLoadListener
		 * registered on construction of the template.
		 * 
		 * @param request the OpenXVASTAdRequest object that specifies the parameters to be passed
		 * to the OpenX Ad Server, including the address of the server itself 
		 */
		public function load(request:OpenXVASTAdRequest):void {
			doLog("Loading VAST data from Open X server via " + request.formRequest(), Debuggable.DEBUG_VAST_TEMPLATE);
			_xmlLoader = new URLLoader();
			_xmlLoader.addEventListener(Event.COMPLETE, templateLoaded);
			_xmlLoader.addEventListener(ErrorEvent.ERROR, errorHandler);
			_xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_xmlLoader.load(new URLRequest(request.formRequest()));
		}

		protected function templateLoaded(e:Event):void {
			doLog("Loaded " + _xmlLoader.bytesLoaded + " bytes for the VAST template", Debuggable.DEBUG_VAST_TEMPLATE);
			doTrace(_xmlLoader, Debuggable.DEBUG_VAST_TEMPLATE);
			_templateData = _xmlLoader.data;
			parseFromRawData(_templateData);
			doLogAndTrace("VAST Template parsed and ready to use", this, Debuggable.DEBUG_VAST_TEMPLATE);
			_dataLoaded = true;
			if(_listener != null) _listener.onTemplateLoaded(this);
		}
		
		protected function errorHandler(e:Event):void {
			doLog("HTTP ERROR: " + e.toString(), Debuggable.DEBUG_VAST_TEMPLATE);
			if(_listener != null) _listener.onTemplateLoadError(e);
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
				if(ads[i].children().length() == 1) { // this is the InLine tag
					var theInLineRecord:XMLList = ads[i].children();
					var vad:VideoAd = parseAdSpecification(i, adIds[0], theInLineRecord[0]);
					if(vad != null) addVideoAd(vad);
				}
				else doLog("No InLine tag found for Ad - " + adIds[0] + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE);	
			}
			doLog("Parsing DONE", Debuggable.DEBUG_VAST_TEMPLATE);
		}
		
		private function parseAdSpecification(adRecordPosition:int, adId:String, ad:XML):VideoAd {
			doLog("Parsing Ad record at position " + adRecordPosition + " with ID " + adId, Debuggable.DEBUG_VAST_TEMPLATE);
			doLog("Ad has " + ad.children().length() + " attributes defined - see trace", Debuggable.DEBUG_VAST_TEMPLATE);
			doTrace(ad, Debuggable.DEBUG_VAST_TEMPLATE);
			if(ad.children().length() > 0) {
				var vad:VideoAd = new VideoAd();
				vad.id = adId;
				vad.adSystem = ad.AdSystem;
				vad.adTitle = ad.AdTitle;
				vad.description = ad.Description;
				vad.survey = ad.Survey;
				vad.error = ad.Error;
				var i:int;
				doLog("Parsing impression data...", Debuggable.DEBUG_VAST_TEMPLATE);
				if(ad.Impression != null && ad.Impression.children() != null) {
					var impressions:XMLList = ad.Impression.children();
					for(i = 0; i < impressions.length(); i++) {
						vad.addImpression(new NetworkResource(impressions[i].id, impressions[i].text()));
					}
				}
				doLog("Parsing TrackingEvent data...", Debuggable.DEBUG_VAST_TEMPLATE);
				if(ad.TrackingEvents != null && ad.TrackingEvents.children() != null) {
					var trackingEvents:XMLList = ad.TrackingEvents.children();
					for(i = 0; i < trackingEvents.length(); i++) {
						var trackingEventXML:XML = trackingEvents[i];
						var trackingEvent:TrackingEvent = new TrackingEvent(trackingEventXML.@event);
						var trackingEventURLs:XMLList = trackingEventXML.children();
						for(var j:int = 0; j < trackingEventURLs.length(); j++) {
							var trackingEventURL:XML = trackingEventURLs[j];
							trackingEvent.addURL(new NetworkResource(trackingEventURL.@id, trackingEventURL.text()));
						}
						vad.addTrackingEvent(trackingEvent);				
					}
				}
				if(ad.Video != undefined) {
					doLog("Parsing Video data...", Debuggable.DEBUG_VAST_TEMPLATE);
					var linearVideoAd:LinearVideoAd = new LinearVideoAd();
					linearVideoAd.adID = ad.Video.AdID;
					linearVideoAd.duration = ad.Video.Duration;
					if(ad.Video.VideoClicks != undefined) {
						var clickList:XMLList;
						var clickURL:XML;
						if(ad.Video.VideoClicks.ClickThrough.children().length() > 0) {
							doLog("Parsing VideoClicks ClickThrough data...", Debuggable.DEBUG_VAST_TEMPLATE);
							clickList = ad.Video.VideoClicks.ClickThrough.children();
							for(i = 0; i < clickList.length(); i++) {
								clickURL = clickList[i];
								linearVideoAd.addClickThrough(new NetworkResource(clickURL.@id, clickURL.text()));
							}
						}
						if(ad.Video.VideoClicks.ClickTracking.children().length() > 0) {
							doLog("Parsing VideoClicks ClickTracking data...", Debuggable.DEBUG_VAST_TEMPLATE);
							clickList = ad.Video.VideoClicks.ClickTracking.children();
							for(i = 0; i < clickList.length(); i++) {
								clickURL = clickList[i];
								linearVideoAd.addClickTrack(new NetworkResource(clickURL.@id, clickURL.text()));
							}
						}
						if(ad.Video.VideoClicks.CustomClick.children().length() > 0) {
							doLog("Parsing VideoClicks CustomClick...", Debuggable.DEBUG_VAST_TEMPLATE);
							clickList = ad.Video.CustomClick.ClickTracking.children();
							for(i = 0; i < clickList.length(); i++) {
								clickURL = clickList[i];
								linearVideoAd.addCustomClick(new NetworkResource(clickURL.@id, clickURL.text()));
							}
						}
					}
					if(ad.Video.MediaFiles != undefined) {
						doLog("Parsing MediaFiles data...", Debuggable.DEBUG_VAST_TEMPLATE);
						var mediaFiles:XMLList = ad.Video.MediaFiles.children();
						for(i = 0; i < mediaFiles.length(); i++) {
							var mediaFileXML:XML = mediaFiles[i];
							var mediaFile:MediaFile = new MediaFile();
							mediaFile.id = mediaFileXML.@id; 
							mediaFile.bandwidth = mediaFileXML.@bandwidth; 
							mediaFile.delivery = mediaFileXML.@delivery; 
							mediaFile.mimeType = mediaFileXML.@type; 
							mediaFile.bitRate = mediaFileXML.@bitrate; 
							mediaFile.width = mediaFileXML.@width; 
							mediaFile.height = mediaFileXML.@height; 
							if(mediaFileXML.children().length() > 0) {
								var mediaFileURLXML:XML = mediaFileXML.children()[0];
								mediaFile.url = new NetworkResource(mediaFileURLXML.@id, mediaFileURLXML.text());
							}
							linearVideoAd.addMediaFile(mediaFile);
						}					
					}
					vad.linearVideoAd = linearVideoAd;
				}
				if(ad.NonLinearAds != undefined) {
					doLog("Parsing NonLinearAd data...", Debuggable.DEBUG_VAST_TEMPLATE);
					var nonLinearAds:XMLList = ad.NonLinearAds.children();
					for(i = 0; i < nonLinearAds.length(); i++) {
						var nonLinearAdXML:XML = nonLinearAds[i];
						var nonLinearAd:NonLinearVideoAd = null;
						switch(nonLinearAdXML.@resourceType.toUpperCase()) {
							case "HTML":
								nonLinearAd = new NonLinearHtmlAd();
								break;
							case "TEXT":
								nonLinearAd = new NonLinearTextAd();
								break;
							case "STATIC":
								if(nonLinearAdXML.@creativeType != undefined && nonLinearAdXML.@creativeType != null) {
									switch(nonLinearAdXML.@creativeType.toUpperCase()) {
										case "JPEG":
										case "GIF":
										case "PNG":
											nonLinearAd = new NonLinearImageAd();
											break;
										case "SWF":
											nonLinearAd = new NonLinearFlashAd();
											break;
										default:
											nonLinearAd = new NonLinearVideoAd();
									}									
								}
								else nonLinearAd = new NonLinearVideoAd();
								break;
							default:
								nonLinearAd = new NonLinearVideoAd();
						}
						nonLinearAd.id = nonLinearAdXML.@id;
						nonLinearAd.width = nonLinearAdXML.@width;
						nonLinearAd.height = nonLinearAdXML.@height; 
						nonLinearAd.resourceType = nonLinearAdXML.@resourceType; 
						nonLinearAd.creativeType = nonLinearAdXML.@creativeType; 
						nonLinearAd.apiFramework = nonLinearAdXML.@apiFramework; 
						if(nonLinearAdXML.URL != undefined) nonLinearAd.url = new NetworkResource(null, nonLinearAdXML.URL.text());
						if(nonLinearAdXML.Code != undefined) {
							nonLinearAd.codeBlock = nonLinearAdXML.Code.text();
						}
						if(nonLinearAdXML.NonLinearClickThrough != undefined) {
							var nlClickList:XMLList = nonLinearAdXML.NonLinearClickThrough.children();
							var nlClickURL:XML;
							for(i = 0; i < nlClickList.length(); i++) {
								nlClickURL = nlClickList[i];
								nonLinearAd.addClickThrough(new NetworkResource(nlClickURL.@id, nlClickURL.text()));
							}							
						}
						vad.addNonLinearVideoAd(nonLinearAd);
					}
				}
				if(ad.CompanionAds != undefined) {
					doLog("Parsing CompanionAd data...", Debuggable.DEBUG_VAST_TEMPLATE);
					var companionAds:XMLList = ad.CompanionAds.children();
					for(i = 0; i < companionAds.length(); i++) {
						var companionAdXML:XML = companionAds[i];
						var companionAd:CompanionAd = new CompanionAd();
						companionAd.id = companionAdXML.@id;
						companionAd.width = companionAdXML.@width;
						companionAd.height = companionAdXML.@height; 
						companionAd.resourceType = companionAdXML.@resourceType; 
						companionAd.creativeType = companionAdXML.@creativeType;
						if(companionAdXML.URL != undefined) companionAd.url = new NetworkResource(null, companionAdXML.URL.text());
						if(companionAdXML.Code != undefined) {
							companionAd.codeBlock = companionAdXML.Code.text();							
						}
						if(companionAdXML.CompanionClickThrough != undefined) {
							var caClickList:XMLList = companionAdXML.CompanionClickThrough.children();
							var caClickURL:XML;
							for(i = 0; i < caClickList.length(); i++) {
								caClickURL = caClickList[i];
								companionAd.addClickThrough(new NetworkResource(caClickURL.@id, caClickURL.text()));
							}							
						}
						vad.addCompanionAd(companionAd);						 						
					}					
				}
				doLog("Parsing ad record " + adId + " done", Debuggable.DEBUG_VAST_TEMPLATE);
				doTrace(vad, Debuggable.DEBUG_VAST_TEMPLATE);
				return vad;
			}
			else doLog("No tags found for Ad " + adId + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE);
			return null;
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