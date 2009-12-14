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
package org.openvideoads.util {

	/**
	 * @author Paul Schulz
	 */
	public class StringUtils {
		public function StringUtils() {
		}

		public static function trim(par_String:String):String { 
			var sReturn:String = ""; 
			for (var i:int=0; i < par_String.length; i++) { 
				if (par_String.charAt(i) != " ") { 
					sReturn = sReturn+par_String.charAt(i); 
				} 
			}	 
			return sReturn; 
		}
		
        public static function removeControlChars(string:String):String {
        	if(string != null) {
	            var result:String = string;
	            var resultArray:Array;
	            // convert tabs to spaces
	            result = result.split("\t").join(" ");
	            // convert returns to spaces
	            result = result.split("\r").join(" ");
	            // convert newlines to spaces
	            result = result.split("\n").join(" ");
	            return result;        		
        	}
        	return string;
        }

        public static function compressWhitespace(string:String):String {
            var result:String = string;
            var resultArray:Array;
            resultArray = result.split(" ");
            for(var idx:uint = 0; idx < resultArray.length; idx++) {
                if(resultArray[idx] == "") {
                   resultArray.splice(idx,1);
                   idx--;
                }
            }
            result = resultArray.join(" ");
            return result;
        }
        
		public static function beginsWith(p_string:String, p_begin:String):Boolean {
			if (p_string == null) { return false; }
			return p_string.indexOf(p_begin) == 0;
		}        
        
        public static function endsWith(p_string:String, p_end:String):Boolean {
			return p_string.lastIndexOf(p_end) == p_string.length - p_end.length;
		}
		
        public static function revertSingleQuotes(string:String, replacement:String):String {
			var quotePattern:RegExp = /{quote}/g;  
 			return string.replace(quotePattern, replacement);         	
        }
        
        public static function replaceSingleWithDoubleQuotes(data:String):String {
			var pattern:RegExp = /'/g;
			return data.replace(pattern, '"');
        }
    }
}
