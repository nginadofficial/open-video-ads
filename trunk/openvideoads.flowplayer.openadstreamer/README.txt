Change Log

0.2.1 - August 24, 2009

* Initial release with defects/restrictions

0.2.2 - August 26, 2009

* OpenAdStreamer.as: Fixed issue with mid-roll RTMP ad insertion - clip.start=0; added to ensure
  mid-roll ad starts at 0
* OpenAdStreamer.as: Example04 - "autoPlay:false" on "pre-roll" ad not working - clip now sets autoPlay
  based on stream.autoPlay value
* RegionView.as - fix to the framework - and now appears over "click here" textsign and over
  text on overlays
* RegionController.as - fix to ensure RegionViews childIndex puts them on top as they are added
* CrossCloseButton.as - fix to ensure that close button can be clicked and region closed
* OpenAdStreamer.as - Fixed sizing is set on the DisplayProperties - derived automatically from DisplayObject()

0.2.3 - September 1, 2009

* ISSUE 26: Support added for tracking of "unmute, pause and resume" events
* ISSUE 18: Deprecation of "selectionCriteria" config param - replaced with "adTags"

0.2.4 - September 6, 2009

* All HTTP examples moved to official release of Flowplayer 3.1.3 (the official release doesn't
  seem to work with RTMP right now as there isn't an official 3.1.3 RTMP plugin)
* ISSUE 36:	Flowplayer - Ad Notice positioning on fullscreen was incorrect - placed very
  wide so the ad notice disappeared - fixed now

0.2.5 - October 6, 2009

* ISSUE 78: "deliveryType" config option set to "any" by default - meaning in most cases,
  this option is no longer required - removed from examples
* ISSUE 40 & ISSUE 80: Change "streamType" configuration to be generalised - default is now "any"
  all-example41 created to test/illustrate new streamType configuration
* ISSUE 88:	Flowplayer custom clip properties not imported - "player" config grouping added
  at general, stream, ads and ad slot levels. See example44.html
* ISSUE 92:	Fix up the "autoPlay" usage in the examples - example04 now illustrates turning autoPlay:true
* ISSUE 87:	Issues with "applyToParts" config - many fixes - see test cases test01-12.html
* ISSUE 101: Flowplayer playlists can now be used to derive the "shows" configuration - this should
  fix the issue with bandwidth checker compatibility
* ISSUE 99:	Removed references to global.js in examples
* ISSUE 17:	Support pseudo-streaming provider
* ISSUE 59:	Restore the 'providers' configuration option for Flowplayer

0.3.0 - November 4, 2009

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

0.4.0 - December 10, 2009

* If OpenX is used, requires OpenX server side Video plugin v1.2
* Moved examples to Flowplayer 3.1.5
* ISSUE 129 - Restore JS Event API - see Javascript API doc on google code site for details - support
  for events and region styling added - see all-example56.html
* ISSUE 140: Ampersand in OpenX "targeting" parameters breaks JSON parser - customProperties can
  now be specified either as a single param (e.g. "gender=male") or as an array
  (e.g. ["gender=male", "age=20-30"]) - Arrays will be converted to ampersand delimited parameter
  strings (e.g. gender=male&age=20-30
* ISSUE 146: Add support for creativeType="image/jpg" etc. - changed NonLinearVideoAd.as to
  strip out any prefixes like "image/" etc.
* ISSUE 147: Impression tracking should be fired on empty VAST ads - see all-example58.html - as
  per the AOL/AdTech request - new configuration option "forceImpressionServing" added to the
  AdServer config - set to "true" by default for AdTech, false for others.
* ISSUE 137: Issue of "Play Again" button appearing in mid-roll config for Flowplayer playlist
  based configs - now fixed.
* ISSUE 148: url tags not being processed in non linear ad VAST responses when creativeType
  is set as mimeType (e.g. "image/jpg" etc.). The OpenX Video Ads plugin 1.2 now produces
  mimeType creativeType values.
* ISSUE 149: overlay <code></code> tags not being correctly processed by overlay display
  code. Fixed now - code just inserted - templates just used for <url></url> values
* ISSUE 138: Unable to resume after pausing example 43 (Flowplayer) - fixed with rewrite
  of the way Flowplayer playlists are handled
* ISSUE 111: playOnce issue with example43 (playlists) - stops after first playlist item -
  fixed with the change to the way Flowplayer playlists are read in/configured as show streams
* ISSUE 133: Issues with autoPlay not working on Flowplayer playlist based streams fixed
* ISSUE 129: Example 39 - overlay does not show after mid-roll - resolved



