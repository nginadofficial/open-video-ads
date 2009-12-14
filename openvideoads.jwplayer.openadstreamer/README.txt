Change Log

0.2.1 - June 30, 2009

* The initial version - ad types supported are pre, mid, post roll linear video and companions
* HTTP and RTMP protocols supported

0.3.0 - August 27, 2009

* Config.as: "autoPlay" correctly implemented - only available at top level
* Config.as: "contiguous" option name changed to "allowPlaylistControl"
* Overlays supported

0.3.1 - September 1, 2009

* ISSUE 18: Deprecation of "selectionCriteria" config param - replaced with "adTags"

0.3.2 - September 6, 2009

* "adTags" should have been "adParameters" - fixed
* ISSUE 25:	Full screen positioning of "this is an ad" message is wrong - was a general problem
  around resizing not being done in the JW Player Open Ad Streamer
* Companion ad timing fixed
* Moved to final 3.1.3 Flowplayer release - "providers" config depreciated because we can't get
  the autoload of RTMP providers to work for instream clips - needs investigation. Manually
  define the provider plugins for now (see any rtmp example with an overlay to see how to do this)
* Examples cleaned up - example19 made a single example all-example19.html
* Some old overlay OpenX zones removed - in general zone definitions cleaned up
* Templates added to allow overlay formats to be changed as needed
* Example 19 fixed so that regions are right width,height and display properly
* ISSUE 21: overlay examples included
* ISSUE 23: problem with skipping between clips fixed on example 04 (autoPlay configuration issue)
* ISSUE 51: Support added to change ad notice text size from normal to small - size:smalltext|normaltext

0.3.3 - October 6, 2009

* ISSUE 67: all-example29 created
* ISSUE 78: "deliveryType" config option set to "any" by default - meaning in most cases,
  this option is no longer required - removed from examples
* ISSUE 81: HTTP progressive FLV example12 fixed - plays now - was an openx banner config issue
* ISSUE 31: JW Player examples don't work on IE8 - fixed - <embed> tags used instead of <object>
* ISSUE 79: Click through on overlay click to video ads not activated for JW Player - also ensure
  that overlay linear video ad tracking events are fired
* ISSUE 40 & ISSUE 80: Change "streamType" configuration to be generalised - default is now "any"
  all-example41 created to test/illustrate new streamType configuration
* ISSUE 92:	Fix up the "autoPlay" usage in the examples - example04 now illustrates turning
  autoPlay:true
* ISSUE 17:	Support pseudo-streaming provider
* ISSUE 59:	Restore the 'providers' configuration option for Flowplayer

0.4.0 - November 4, 2009

* ISSUE 123: Moved to LGPL
* ISSUE 114: "Out of the Box" support for AdTech requests
* ISSUE 120: Ad servers can now be configured per ad slot
* ISSUE 110: Load issues with the Ant build of the OAS due to control bar strongly typed references
  in the codebase which meant that the controls plugin had to be loaded before the OAS - strong
  references removed
* ISSUE 104: Option to allow companions to display permanently until replaced
* ISSUE 102: Refactor out the Ad Server to support multiple calls - single and multiple ad
  calls now supported - see Ad Tech XML Wrapper examples
* ISSUE 100: Factor out the OpenX references when creating Ad Server config/instances
* ISSUE 10: XML Wrapper Support added
* ISSUE 71: Better support for the display of companion ad types (HTML, image and straight code) added
* New Ad Server request configuration - any ad server can now be configured
* Check added to ensure that only one companion will be added per DIV
* "resourceType" and "creativeType" config options added to "companions" config so that the selection
  of a companion from the VAST response can also be based on the type (script, html, swf, image etc.)
* "zone" identifier is no longer required for "direct" ad server requests - see example 52

0.4.1 - December 4, 2009

* If OpenX is used, requires OpenX server side Video plugin v1.2
* ISSUE 141 and ISSUE 93 - Support added for preview images - see all-example57.html
* Javascript event callback API added - see all-example56.html
* ISSUE 147: Impression tracking should be fired on empty VAST ads - see all-example58.html - as
  per the AOL/AdTech request - new configuration option "forceImpressionServing" added to the
  AdServer config - set to "true" by default for AdTech, false for others.
