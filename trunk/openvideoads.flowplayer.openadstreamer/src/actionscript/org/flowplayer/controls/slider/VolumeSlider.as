/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.slider {
    import flash.display.DisplayObject;
import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.controls.Config;
	import org.flowplayer.controls.slider.AbstractSlider;	

	/**
	 * @author api
	 */
	public class VolumeSlider extends AbstractSlider {
		public static const DRAG_EVENT:String = AbstractSlider.DRAG_EVENT;

        override public function get name():String {
            return "volume";
        }

		public function VolumeSlider(config:Config, animationEngine:AnimationEngine, controlbar:DisplayObject) {
			super(config, animationEngine, controlbar);
			tooltipTextFunc = function(percentage:Number):String {
				return Math.round(percentage) + "%";
			};
		}
		
		override protected function isToolTipEnabled():Boolean {
			return _config.tooltips.volume;
		}

        override protected function get barHeight():Number {
            log.debug("bar height ratio is " + _config.style.volumeSliderHeightRatio);
            return height * _config.style.volumeBarHeightRatio;

        }

        override protected function get sliderGradient():Array {
            return _config.style.volumeSliderGradient;
        }

        override protected function get sliderColor():Number {
            return _config.style.volumeSliderColor;
        }

        override protected function get barCornerRadius():Number {
            if (isNaN(_config.style.volumeBorderRadius)) return super.barCornerRadius;
            return _config.style.volumeBorderRadius;
        }
	}
}
