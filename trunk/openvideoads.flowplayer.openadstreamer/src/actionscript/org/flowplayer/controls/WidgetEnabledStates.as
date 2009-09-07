/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 * Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls {

    public class WidgetEnabledStates extends WidgetBooleanStates{

        override public function get stop():Boolean {
            return value("stop", true);
        }

        override public function get playlist():Boolean {
            return value("playlist", true);
        }
    }
}