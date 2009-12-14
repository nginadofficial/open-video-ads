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
 */    
package org.openvideoads.vast.server {
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.model.TemplateLoadListener;
	import org.openvideoads.vast.model.VideoAdServingTemplate;
	
	public class AdServerRequestProcessor extends Debuggable implements TemplateLoadListener {
		protected var _templateLoadListener:TemplateLoadListener = null;
		protected var _groups:Dictionary = new Dictionary();
		protected var _groupKeys:Array = new Array();
		protected var _vastResponses:Array = null;
		protected var _activeAdServerRequests:Array = null;
		protected var _activeAdServerRequestGroupsIndex:int = 0;
		protected var _activeAdServerRequestIndex:int = 0;
		protected var _templates:Array = new Array();
		protected var _activeTemplate:VideoAdServingTemplate = null;
		protected var _finalTemplate:VideoAdServingTemplate = new VideoAdServingTemplate();
		
		public function AdServerRequestProcessor(templateLoadListener:TemplateLoadListener, adSlots:Array) {
			_templateLoadListener = templateLoadListener;
			for(var i:int = 0; i < adSlots.length; i++) {
				if(adSlots[i].hasAdServerConfigured()) {
					if(_groups[adSlots[i].adServerConfig.serverType] == null) {
						_groups[adSlots[i].adServerConfig.serverType] = new AdServerRequestGroup(adSlots[i].adServerConfig.serverType, adSlots[i].adServerConfig.oneAdPerRequest);
						_groupKeys.push(adSlots[i].adServerConfig.serverType);
					}
					_groups[adSlots[i].adServerConfig.serverType].addAdSlot(adSlots[i]);					
				}
				else doLog("Not configuring ad request for slot " + i + " - no ad server configuration provided", Debuggable.DEBUG_CONFIG);
			}
			doLog("Have configured " + _groupKeys.length + " ad server request groups", Debuggable.DEBUG_CONFIG);
		}

        public function start():void {
        	_templates = new Array();
 			if(_groupKeys.length > 0) {
				startProcessingAdServerRequestGroup(0);
			}
			else {
				doLog("No ad requests to process - 0 ad server groupings found", Debuggable.DEBUG_VAST_TEMPLATE);
				postProcessRequestsAndNotifyListener();
			}       	
        }
        
        protected function startProcessingAdServerRequestGroup(groupIndex:int=0):void {
        	doLog("Triggering ad server requests for group " + _groupKeys[groupIndex] + " (" + groupIndex + ")", Debuggable.DEBUG_VAST_TEMPLATE);
			_activeAdServerRequestGroupsIndex = groupIndex;
			var adServerRequest:AdServerRequest = null;
			if(_groups[_groupKeys[groupIndex]].oneAdPerRequest) {
				doLog("One ad per request required by ad server in group " + _groupKeys[groupIndex] + " (" + groupIndex + ")", Debuggable.DEBUG_VAST_TEMPLATE);
				_activeAdServerRequests = _groups[_groupKeys[groupIndex]].getAdServerRequests();
				_activeAdServerRequestIndex=0;
				adServerRequest = _activeAdServerRequests[_activeAdServerRequestIndex];
				_activeTemplate = new VideoAdServingTemplate(this, adServerRequest, adServerRequest.replaceIds, adServerRequest.replacementIds);	
			}
			else {
				doLog("Multiple ads per request permitted by ad server in group " + _groupKeys[groupIndex] + " (" + groupIndex + ")", Debuggable.DEBUG_VAST_TEMPLATE);
				_activeAdServerRequests = null;
				adServerRequest = _groups[_groupKeys[groupIndex]].getSingleAdServerRequest();
				if(adServerRequest != null) {
					_activeTemplate = new VideoAdServingTemplate(this, adServerRequest, adServerRequest.replaceIds, adServerRequest.replacementIds);					
				}
				else moveOntoNextAdServerRequestGroup();
			}        	
        }
        
        protected function moveOntoNextAdServerRequestGroup():void {
			// we were processing that group as a single request which is now done, so move onto the next group
			if(_activeAdServerRequestGroupsIndex+1 < _groupKeys.length) {
				startProcessingAdServerRequestGroup(_activeAdServerRequestGroupsIndex+1);
			}
			else postProcessRequestsAndNotifyListener();        	
        }
        
        protected function processNextAdServerRequestInActiveAdServerRequestGroup():void {
        	if(_activeAdServerRequestIndex+1 < _activeAdServerRequests.length) {
        		_activeAdServerRequestIndex++;
        		var adServerRequest:AdServerRequest = _activeAdServerRequests[_activeAdServerRequestIndex];
				_activeTemplate = new VideoAdServingTemplate(this, adServerRequest, adServerRequest.replaceIds, adServerRequest.replacementIds);
        	}
        	else moveOntoNextAdServerRequestGroup();
        }
        
        protected function postProcessRequestsAndNotifyListener():void {
        	// merge any retrieved templates together before notifying the listener with the result
        	doLog("Merging the returned templates back into 1 master template...", Debuggable.DEBUG_VAST_TEMPLATE);
        	for(var i:int=0; i < _templates.length; i++) {
        		_finalTemplate.merge(_templates[i]);
        	}
        	doLog("Merge complete - " + _finalTemplate.ads.length + " ads recorded in the master template", Debuggable.DEBUG_VAST_TEMPLATE);
        	_finalTemplate.dataLoaded = true;
        	if(_templateLoadListener != null) _templateLoadListener.onTemplateLoaded(_finalTemplate);        	
        }
       
		public function onTemplateLoaded(template:VideoAdServingTemplate):void {
			_templates.push(template);
			if(_activeAdServerRequests != null) {
				// we are processing this ad server request group one ad request at a time
				processNextAdServerRequestInActiveAdServerRequestGroup();
			}
			else moveOntoNextAdServerRequestGroup();
		}
		
		public function onTemplateLoadError(event:Event):void {
			moveOntoNextAdServerRequestGroup();
		}
	}
}
			

