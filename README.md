# TapTapFlip

TapTapFlip was created upon request by a user on Reddit. The request can be found here: http://www.reddit.com/r/jailbreak/comments/2uc1e0/request_doubletap_in_ios_camera_to_switch_cameras/

It's main purpose is simple.

  - Flip between front and back cameras by double tapping the preview window in the stock camera app.
  - Produce awesome swag
  - Magic

### Version
0.0.1-11
 - Add iOS 7 Support
 - 
0.0.1-8
 - Initial release


### Known Issues
 - Double tapping in unsupported camera modes (Pano and SloMo) will freeze the app.

### Installation

You'll need Theos installed on your machine of course. Some things which you may need to do is:
- Update the IP I used in the Makefile
- If so chosen add pincrush-osx to your machine. Otherwise remove that line from the Makefile

```sh
$ make package install
```

License
----

GNU GPL v3.0
