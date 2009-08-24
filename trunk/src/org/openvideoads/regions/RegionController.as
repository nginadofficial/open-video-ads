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
package org.openvideoads.regions {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.regions.config.RegionsConfig;
	import org.openvideoads.regions.view.RegionView;
	import org.openvideoads.regions.events.RegionMouseEvent;
	import org.openvideoads.util.DisplayProperties;

	import flash.display.Sprite;	
	import flash.events.EventDispatcher;

	/**
	 * @author Paul Schulz
	 */
	public class RegionController extends Sprite {
		protected var _config:RegionsConfig = null;
		protected var _regionViews:Array = new Array();
		protected var _displayProperties:DisplayProperties;
		
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
			return null;
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
			return null;
		}
		
		protected function createRegionViews():void {
			if(_config != null) {
				if(_config.hasRegionDefinitions()) {
					// setup the regions
					for(var i:int=0; i < _config.regions.length; i++) {
						doLogAndTrace("The following config has been used to create RegionView (" + i + ")", _config.regions[i], Debuggable.DEBUG_CONFIG);
						createRegionView(_config.regions[i]);
					}
				}
				else { 
				    // setup a default region for the bottom, one for the top and a fullscreen region
					createRegionView(new RegionViewConfig({ id: 'reserved-top', verticalAlign: 'top', width: '100pct', height: '50' }));
					createRegionView(new RegionViewConfig({ id: 'reserved-bottom', verticalAlign: 'bottom', backgroundColor: '#000000', width: '100pct', height: '50' }));
					createRegionView(new RegionViewConfig({ id: 'reserved-fullscreen', verticalAlign: 0, horizontalAlign: 0, width: '100pct', height: '100pct' }));
				}

				// always add the standard defaults
				createRegionView(new RegionViewConfig(
				         { 
				            id: 'reserved-system-message', 
				            verticalAlign: 'bottom', 
				            horizontalAlign: 'right', 
				            backgroundColor: 'transparent',
//				            backgroundColor: '#000000',
				            opacity: 0.6,
				            width: '100pct', 
				            height: '20' 
				         })
				);
				
				doLogAndTrace("Regions created - " + _regionViews.length + " in total. Trace follows:", _config.regions, Debuggable.DEBUG_CONFIG);				
			}
		}
		
		protected function newRegion(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties, showCloseButton:Boolean=false):RegionView {
			return new RegionView(this, regionConfig, _displayProperties);
		}
		
		protected function createRegionView(regionConfig:RegionViewConfig):void {
			doLogAndTrace("Creating region with ID " + regionConfig.id, regionConfig, Debuggable.DEBUG_REGION_FORMATION);
			var newView:RegionView = newRegion(this, regionConfig, _displayProperties);
			doLogAndTrace("Pushing new view onto the stack. Trace follows:", newView, Debuggable.DEBUG_REGION_FORMATION);
			_regionViews.push(newView);
			addChild(newView);
			setChildIndex(newView, 0);
		}

		public function hideAllRegions():void {
			for(var i:int=0; i < _regionViews.length; i++) {
				_regionViews[i].hide();
			}
		}	
		
		public function onRegionClicked(regionView:RegionView):void {			
			dispatchEvent(new RegionMouseEvent(RegionMouseEvent.REGION_CLICKED, regionView));		
		}	
		
		public function resize(resizedProperties:DisplayProperties):void {
			for(var i:int=0; i < _regionViews.length; i++) {
				_regionViews[i].resize(resizedProperties);
			}
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