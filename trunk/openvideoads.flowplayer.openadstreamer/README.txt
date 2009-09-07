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


