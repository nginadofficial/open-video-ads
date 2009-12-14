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
	import flash.events.Event;
	
	import mx.utils.UIDUtil;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;
	import org.openvideoads.vast.server.wrapped.WrappedAdServerRequest;
	
	public class WrappedVideoAd extends VideoAd implements TemplateLoadListener {
		protected var _vastAdTag:String = null;
		protected var _template:VideoAdServingTemplate = null;
		protected var _originalAdId:String = null
		protected var _vastContainer:VideoAdServingTemplate = null;
		protected var _videoAdReturnedFromWrapper:VideoAd = null;
		protected var _uid:String = null;
		
		public function WrappedVideoAd(originalAdId:String, wrapperXML:XML=null, vastContainer:VideoAdServingTemplate=null) {
			super();
			_uid = UIDUtil.getUID(this);
			_originalAdId = originalAdId;
			_vastContainer = vastContainer;
			if(wrapperXML != null) initialise(wrapperXML);
		}
		
		protected function initialise(wrapperXML:XML):void {
			doLog("XML Wrapper: XML response has " + wrapperXML.children().length() + " attributes defined - see trace", Debuggable.DEBUG_VAST_TEMPLATE);
			doTrace(wrapperXML, Debuggable.DEBUG_VAST_TEMPLATE);
			id = wrapperXML.adId;
			adSystem = wrapperXML.AdSystem;
			if(wrapperXML.VASTAdTagURL.URL != undefined) {
				vastAdTag = wrapperXML.VASTAdTagURL.URL.text();
			}
			parseImpressions(wrapperXML);
			parseTrackingEvents(wrapperXML);
			if(hasVASTAdTag()) {
				loadVASTFromWrappedAdServer();
			}
		}

		public override function get id():String {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.id;
			}			
			return _id;
		}
		
		public function set vastAdTag(vastAdTag:String):void {
			_vastAdTag = vastAdTag;
		}
		
		public function get vastAdTag():String {
			return _vastAdTag;
		}
		
		public function hasVASTAdTag():Boolean {
			return (_vastAdTag != null)
		}
		
		public function loadVASTFromWrappedAdServer():void {
			if(_vastAdTag != null) {
				if(_vastContainer != null) {
					_vastContainer.registerLoader(_uid);
				}
				var adServerRequest:WrappedAdServerRequest = new WrappedAdServerRequest(_vastAdTag);
				var adIds:Array = new Array;
				adIds.push(_originalAdId);
				_template = new VideoAdServingTemplate(this, adServerRequest, true, adIds);					
			}
			else doLog("XML Wrapper: Request to load ad from wrapped ad server has been ignored - no vastAdTag provided in wrapper XML", Debuggable.DEBUG_VAST_TEMPLATE);
		}
		
		public function onTemplateLoaded(template:VideoAdServingTemplate):void {
			doLog("XML Wrapper: VAST data loaded for original ad " + _originalAdId + " loaded - signalling load completion", Debuggable.DEBUG_VAST_TEMPLATE);
			_videoAdReturnedFromWrapper = _template.getFirstAd();
			_vastContainer.signalTemplateLoaded(_uid);
		}
		
		public function onTemplateLoadError(event:Event):void {
			doLog("XML Wrapper: Failure obtaining VAST data for original ad " + _originalAdId), Debuggable.DEBUG_VAST_TEMPLATE;
			_vastContainer.signalTemplateLoadError(_uid, event);
		}	

		public function hasReplacementVideoAd():Boolean {
			return (_videoAdReturnedFromWrapper != null);
		}		
		
		public override function get duration():int {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.duration;
			}
			else return super.duration;
		}
				
		public override function get error():String {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.error;
			}
			return super.error
		}
		
		public override function get impressions():Array {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.impressions;
//				return impressions;
			}
			return super.impressions;
		}
		
		public override function get trackingEvents():Array {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.trackingEvents;
			}
			return super.trackingEvents;
		}
		
		public override function get linearVideoAd():LinearVideoAd {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.linearVideoAd;
			}
			else return super.linearVideoAd;
		}

		public override function get nonLinearVideoAds():Array {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.nonLinearVideoAds;
			}
			return super.nonLinearVideoAds;
		}
		
		public override function get firstNonLinearVideoAd():NonLinearVideoAd {
			if(hasReplacementVideoAd()) {
				if(hasNonLinearAds()) {
					return _videoAdReturnedFromWrapper.firstNonLinearVideoAd;
				}
				return null;
			}
			else return super.firstNonLinearVideoAd;
		}
		
		public override function hasNonLinearAds():Boolean {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.hasNonLinearAds();				
			}
			return super.hasNonLinearAds();
		}
		
		public override function hasLinearAd():Boolean {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.hasLinearAd();			
			}
			return super.hasLinearAd();
		}
		
		public override function get companionAds():Array {
			if(hasReplacementVideoAd()) {					
				return _videoAdReturnedFromWrapper.companionAds;
			}
			return super.companionAds;
		}

		public override function hasCompanionAds():Boolean {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.hasCompanionAds();				
			}
			return super.hasCompanionAds();
		}

		public override function isLinear():Boolean {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.isLinear();					
			}
			return super.isLinear();	
		}
		
		public override function isNonLinear():Boolean {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.isNonLinear();				
			}
			return super.isNonLinear();	
		}
		
		public override function getStreamToPlay(deliveryType:String, mimeType:String, bitrate:String="any"):NetworkResource {
			if(hasReplacementVideoAd()) {
				return _videoAdReturnedFromWrapper.getStreamToPlay(deliveryType, mimeType, bitrate);
			}
			else return super.getStreamToPlay(deliveryType, mimeType, bitrate);
		}
		
		public override function triggerTrackingEvent(eventType:String):void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.triggerTrackingEvent(eventType);
			}
			super.triggerTrackingEvent(eventType);
		}

		public override function triggerForcedImpressionConfirmations():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.triggerForcedImpressionConfirmations();
			}
			super.triggerForcedImpressionConfirmations();
		}

		public override function processStartAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processStartAdEvent();
			}
			super.processStartAdEvent();
		}

		public override function processStopAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processStopAdEvent();
			}
			super.processStopAdEvent();
		}
		
		public override function processPauseAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processPauseAdEvent();
			}
			super.processPauseAdEvent();
		}

		public override function processResumeAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processResumeAdEvent();
			}
			super.processResumeAdEvent();
		}

		public override function processFullScreenAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processFullScreenAdEvent();
			}
			super.processFullScreenAdEvent();
		}

		public override function processMuteAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processMuteAdEvent();
			}
			super.processMuteAdEvent();
		}

		public override function processUnmuteAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processUnmuteAdEvent();
			}
			super.processUnmuteAdEvent();
		}

		public override function processReplayAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processReplayAdEvent();
			}
			super.processReplayAdEvent();
		}

		public override function processHitMidpointAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processHitMidpointAdEvent();
			}
			super.processHitMidpointAdEvent();
		}

		public override function processFirstQuartileCompleteAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processFirstQuartileCompleteAdEvent();
			}
			super.processFirstQuartileCompleteAdEvent();
		}

		public override function processThirdQuartileCompleteAdEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processThirdQuartileCompleteAdEvent();
			}
			super.processThirdQuartileCompleteAdEvent();
		}

		public override function processAdCompleteEvent():void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processAdCompleteEvent();
			}
			super.processAdCompleteEvent();
		}
		
		public override function processStartNonLinearOverlayAdEvent(event:VideoAdDisplayEvent):void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processStartNonLinearOverlayAdEvent(event);
			}
			//super.processStartNonLinearOverlayAdEvent(event);
			super.triggerImpressionConfirmations();
		}
		
		public override function processStopNonLinearOverlayAdEvent(event:VideoAdDisplayEvent):void { 
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processStopNonLinearOverlayAdEvent(event);
			}
			super.processStopNonLinearOverlayAdEvent(event);
		}
		
		public override function processStartCompanionAdEvent(displayEvent:VideoAdDisplayEvent):void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processStartCompanionAdEvent(displayEvent);
			}
			super.processStartCompanionAdEvent(displayEvent);
		}
		
		public override function processStopCompanionAdEvent(displayEvent:VideoAdDisplayEvent):void {
			if(hasReplacementVideoAd()) {
				_videoAdReturnedFromWrapper.processStopCompanionAdEvent(displayEvent);
			}
			super.processStopCompanionAdEvent(displayEvent);
		}		
	}
}