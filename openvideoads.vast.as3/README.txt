Change Log

0.2.1 - July 15, 2009

* Initial release to support JW Player development

0.3.0 - August 20, 2009

* Major upgrade - callbacks to the plugin on framework status are now "event" based
* Integrated support for overlays within the framework
* Extensions to support new ad server integrations
* Major modifications to the config framework to support a unified JSON approach
  across the JW and Flowplayer Open Ad Streamer plugins
* Support for firebug debug output
* Many bug fixes

0.3.1 - August 31, 2009

* "autoStart" parameter changed to "autoPlay" in configuration objects and API
* RegionView.as: set "mouseChildren=false" so that the hand shows over the text on the overlays
* CrossCloseButton.as: Regions can now be clicked to close (including the Ad Notice)
* Config.as: "autoPlay" correctly implemented - only available at top level
* Config.as: "contiguous" option name changed to "allowPlaylistControl"
* OpenVideoAdsConfig.as: tracking configuration added and tracking URLs
* Built in support for the various non-linear types (text, html, image and swf) in the
  "model" and "ads.template" components
* Templating now supported for overlays/regions (default and config based)

0.3.2 - September 1, 2009

* Added NetworkResource.qualifiedHTTPUrl() so that click through URLs will always be
  checked that they start with "http://" before they are fired off
* Modification of VAST parsing code for non-linear ad types - only image and swf
  require a "creativeType" to be defined now - text and html just need "resourceType"
* Fixed OverlayController.hideNonLinearOverlayAd() so that overlays are hidden based
  on either "position" or the "regions" Ad Slot param
* ISSUE 24: + (close) button turned off on the "system-message" region by default.
  This means that the "this is an ad message" doesn't show close by default
* ISSUE 26: Support added to track "unmute" events
* ISSUE 27: Support added to VASTController track "pause and resume" events
* ISSUE 18: Deprecation of "selectionCriteria" config param - replaced with "adTags"
* ISSUE 28: Changed "_activeStreamIndex" to "_playlist.playingTrackIndex" for use
  in onPlayer type events (e.g. on fullscreen etc.)

0.3.3 - September 6, 2009

* ISSUE 18: "adTags" should have been "adParameters" - fixed
* Flash overlays loading - required Security.allowDomain() to be used. An additional
  config parameter "allowDomains" has been added to the AdConfigGroup - this parameter
  is used by the Security.allowDomain() call - "*" is the default.
* ISSUE 5: All default overlay sizes now supported with standard region definitions
* ISSUE 36:	Flowplayer - Ad Notice positioning on fullscreen was incorrect - placed very
  wide so the ad notice disappeared - fixed now
* ISSUE 44: Have changed the logic in the region matching functions RegionController.getRegion()
  and RegionController.getRegionMatchingContentType() to return a DEFAULT_REGION if no match is
  found - this is a safety valve for the case where no sizing info is provided in the VAST template.
  The default template is "reserved-bottom-w100pct-h50px-transparent"
* ISSUE 35:	'Click me call to action' region doesn't show when ad replayed - same for ad
  notices - the show/hide ad notice event is not firing because it's marked as hit
  and the show/hide 'click me' region is tied to start/end ad events that aren't firing.
  Changed so that ad notice events are always refired, and click me show/hide tied to that event
* If not "creativeType" provided for a static "resourceType" image is assumed.
* All overlay types (text, html, image, flash) successfully tested
* Templates added to allow overlay formats to be changed as needed
* "playOnce" configuration wasn't being set at the top level. Missing code from
  AbstractStreamConfig added to set it.
* Support added to change ad notice text size from normal to small - size:smalltext|normaltext

0.3.4 - October 6, 2009

* ISSUE 49: "adParameters" values moved to end of OpenX URL to allow "source" to be overridden
* ISSUE 76: Event callback added for Overlay CLOSE_CLICKED
* ISSUE 77: Config option added to allow overlays to stay visible after being clicked (only for 'click to web')
* ISSUE 33: Text overlay text looks washed out - now _text.blendMode = BlendMode.NORMAL;
* ISSUE 78: "deliveryType" config option set to "any" by default - meaning in most cases,
  this option is no longer required - removed from examples
* ISSUE 68:	Click through mouse over sign does not show if Ad Notice turned off - fixed
* ISSUE 78:	"deliveryType" is this really needed? No longer - need removed. Default setting
  is "any", but "progressive" or "streaming" can be used to limit the choice - example 10
* ISSUE 49:	OpenX targeting by "source" value in the URL - adParameters are now appended
  to the end of the OpenX VAST request rather than mid URL - this allows a "source"
  parameter to be specified in the "adParameters" - in addition a check is made
  to the "adParameters" value - if "source" is there, the default value is removed
* ISSUE 40 & ISSUE 80: Change "streamType" configuration to be generalised - default is now "any"
  all-example41 created to test/illustrate new streamType configuration
* ISSUE 88:	Flowplayer custom clip properties not imported - "player" config grouping added
  at general, stream, ads and ad slot levels. See FP all-example44.html
* ISSUE 89:	Option to turn off click me message on linear ads - "enabled" option now
  permitted in the "clickSign" config to turn the click through notice on/off - it is on by default
* ISSUE 87:	Issues with "applyToParts" config - many fixes - see FP test cases 01-12.html
* ISSUE 96:	Support load of MRSS format in place of "shows"
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

0.5.0 - December 4, 2009

* If OpenX is used, requires OpenX server side Video plugin v1.2
* ISSUE 129 - Restore JS Event API - see Javascript API doc on google code site for details - support
  for events and region styling added - see all-example56.html
* ISSUE 140: Ampersand in OpenX "targeting" parameters breaks JSON parser - customProperties can
  now be specified either as a single param (e.g. "gender=male") or as an array
  (e.g. ["gender=male", "age=20-30"]) - Arrays will be converted to ampersand delimited parameter
  strings (e.g. gender=male&age=20-30
* ISSUE 141 - Support added for JW Player preview images - see all-example57.html
* ISSUE 146: Add support for creativeType="image/jpg" etc. - changed NonLinearVideoAd.as to
  strip out any prefixes like "image/" etc.
* ISSUE 147: Impression tracking should be fired on empty VAST ads - see all-example58.html - as
  per the AOL/AdTech request - new configuration option "forceImpressionServing" added to the
  AdServer config - set to "true" by default for AdTech, false for others.
* ISSUE 148: url tags not being processed in non linear ad VAST responses when creativeType
  is set as mimeType (e.g. "image/jpg" etc.). The OpenX Video Ads plugin 1.2 now produces
  mimeType creativeType values.
* ISSUE 149: overlay <code></code> tags not being correctly processed by overlay display
  code. Fixed now - code just inserted - templates just used for <url></url> values
