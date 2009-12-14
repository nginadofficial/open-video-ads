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
package org.openvideoads.regions {
	import flash.display.Sprite;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.regions.config.RegionsConfig;
	import org.openvideoads.regions.events.RegionMouseEvent;
	import org.openvideoads.regions.view.RegionView;
	import org.openvideoads.util.DisplayProperties;

	/**
	 * @author Paul Schulz
	 */
	public class RegionController extends Sprite {
		protected var _config:RegionsConfig = null;
		protected var _regionViews:Array = new Array();
		protected var _displayProperties:DisplayProperties;
		public var DEFAULT_REGION:RegionView = null;
		
		public function RegionController(displayProperties:DisplayProperties, config:RegionsConfig) {
			_displayProperties = displayProperties;
			_config = config;
			createRegionViews();
		}

		
		protected function get regionViews():Array {
			return _regionViews;
		}
		
		protected function getRegion(regionID:String):RegionView {
			for(var i:int=0; i < _regionViews.length; i++) {
				if(_regionViews[i].id == regionID) {
					return _regionViews[i];
				}
			}
			return DEFAULT_REGION;
		}

		protected function getRegionMatchingContentType(regionID:String, contentType:String):RegionView {
			for(var i:int=0; i < _regionViews.length; i++) {
				if(_regionViews[i].id == regionID) {
					if(_regionViews[i].hasContentTypes()) {
						if(_regionViews[i].contentTypes.toUpperCase().indexOf(contentType.toUpperCase()) > -1) {
							return _regionViews[i];
						}
					}
					else return _regionViews[i];
				}
			}
			return DEFAULT_REGION;
		}
		
		protected function createRegionViews():void {
		}
		
		protected function newRegion(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties, showCloseButton:Boolean=false):RegionView {
			return new RegionView(this, regionConfig, _displayProperties);
		}
		
		protected function createRegionView(regionConfig:RegionViewConfig):RegionView {
			doLogAndTrace("Creating region with ID " + regionConfig.id, regionConfig, Debuggable.DEBUG_REGION_FORMATION);
			var newView:RegionView = newRegion(this, regionConfig, _displayProperties);
			doLogAndTrace("Pushing new view onto the stack. Trace follows:", newView, Debuggable.DEBUG_REGION_FORMATION);
			_regionViews.push(newView);
			addChild(newView);
			this.setChildIndex(newView, this.numChildren-1);
			return newView;
		}

		public function hideAllRegions():void {
			for(var i:int=0; i < _regionViews.length; i++) {
				_regionViews[i].hide();
			}
		}	
		

		public function onRegionCloseClicked(regionView:RegionView):void {			
			// we are not doing anything with closed regions
  		}

		public function onRegionClicked(regionView:RegionView):void {			
			dispatchEvent(new RegionMouseEvent(RegionMouseEvent.REGION_CLICKED, regionView));		
		}	
		
		public function resize(resizedProperties:DisplayProperties):void {
			for(var i:int=0; i < _regionViews.length; i++) {
				_regionViews[i].resize(resizedProperties);
			}
		}		
		
		public function setRegionStyle(regionID:String, cssText:String):String {
			var region:RegionView = getRegion(regionID);
			if(region != null) {
				region.parseCSS(cssText);
				return "1, successfully passed to region to process";
			}
			else return "-2, No region found for id: " + regionID;
		}
		
		// DEBUG
		
		protected static function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		protected static function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
		
		protected static function doLogAndTrace(data:String, o:Object, level:int=1):void {
			Debuggable.getInstance().doLogAndTrace(data, o, level);
		}				
	}
}