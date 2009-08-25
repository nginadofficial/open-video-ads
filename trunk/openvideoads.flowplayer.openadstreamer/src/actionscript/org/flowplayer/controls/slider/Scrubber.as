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
import org.flowplayer.controls.Config;
    import org.flowplayer.controls.button.SkinClasses;
import org.flowplayer.controls.flash.ScrubberBottomEdge;
import org.flowplayer.controls.flash.ScrubberLeftEdge;
import org.flowplayer.model.Playlist;
    import org.flowplayer.util.Arrange;
import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.AnimationEngine;

    public class Scrubber extends AbstractSprite{
        public static const DRAG_EVENT:String = AbstractSlider.DRAG_EVENT;
        private var _scrubber:ScrubberSlider;
        private var _controlbar:DisplayObject;
        private var _config:Config;
        private var _leftEdge:DisplayObject;
        private var _bottomEdge:DisplayObject;
        private var _rightEdge:DisplayObject;
        private var _topEdge:DisplayObject;

        /**
         * Scrubber widget holds the actual ScrubberSlider instance plus some graphics around it.
         * It's sole purpose is to decorate the ScrubberSlider with some graphical elements.
         * @param config
         * @param animationEngine
         * @param controlbar
         */
        public function Scrubber(config:Config, animationEngine:AnimationEngine, controlbar:DisplayObject) {
            _config = config;
            _controlbar = controlbar;

            _leftEdge = addChild(SkinClasses.getScrubberLeftEdge());
            _bottomEdge = addChild(SkinClasses.getScrubberBottomEdge());
            _topEdge = addChild(SkinClasses.getScrubberTopEdge());
            _rightEdge = addChild(SkinClasses.getScrubberRightEdge());

            addChild(_bottomEdge);
            _scrubber = new ScrubberSlider(config, animationEngine, controlbar);
            addChild(_scrubber);
        }





        override public function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int = 0,useWeakReference:Boolean = false):void {
            if (type == DRAG_EVENT) {
                _scrubber.addEventListener(type, listener, useCapture, priority, useWeakReference);
            } else {
                super.addEventListener(type, listener, useCapture, priority, useWeakReference);
            }
        }

        protected override function onResize():void {
            _leftEdge.height = height - _topEdge.height - _bottomEdge.height;
            _leftEdge.x = 0;
            _leftEdge.y = _topEdge.height;

            _rightEdge.height = height - _topEdge.height - _bottomEdge.height;
            _rightEdge.x = width - _rightEdge.width;
            _rightEdge.y = _topEdge.height;

            _scrubber.x = _leftEdge.width;
            _scrubber.setSize(width - _leftEdge.width, (height-_bottomEdge.height) * _config.style.scrubberHeightRatio);
            Arrange.center(_scrubber, 0, height);

            _bottomEdge.y = height - _bottomEdge.height;
            _bottomEdge.width = width;

            _topEdge.y = 0;
            _topEdge.width = width;
        }

        override public function get name():String {
            return "scrubber";
        }

        public function set playlist(playlist:Playlist):void {
            _scrubber.playlist = playlist;
        }

        public function set allowRandomSeek(value:Boolean):void {
            _scrubber.allowRandomSeek = value;
        }

        public function setBufferRange(start:Number, end:Number):void {
            _scrubber.setBufferRange(start, end);
        }

        public function redraw(config:Config):void {
            _scrubber.redraw(config);
        }

        public function set enabled(value:Boolean) :void {
            _scrubber.enabled = value;
        }

        public function get value():Number {
            return _scrubber.value;
        }

        public final function set value(value:Number):void {
            _scrubber.value = value;
        }

        public function set tooltipTextFunc(tooltipTextFunc:Function):void {
            _scrubber.tooltipTextFunc = tooltipTextFunc;
        }

    }
}