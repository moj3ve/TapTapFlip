THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 armv7s arm64
THEOS_DEVICE_IP = 192.168.0.5

include theos/makefiles/common.mk

TWEAK_NAME = TapTapFlip
TapTapFlip_FILES = TapTapFlip.xm
TapTapFlip_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete

after-stage::
	$(ECHO_NOTHING)find $(FW_STAGING_DIR) -iname '*.png' -exec pincrush-osx -i {} \;$(ECHO_END)
	$(ECHO_NOTHING)ssh root@192.168.0.5 killall -9 MobileCydia || exit 0$(ECHO_END)

after-install::
	install.exec "killall -9 backboardd"

SUBPROJECTS += taptapflip
include $(THEOS_MAKE_PATH)/aggregate.mk

