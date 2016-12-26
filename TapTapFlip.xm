#import <version.h>

static BOOL kEnabled;

#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define CURRENT_INTERFACE_ORIENTATION iPad ? [[UIApplication sharedApplication] statusBarOrientation] : [[UIApplication sharedApplication] activeInterfaceOrientation]

@interface CAMFlipButton : UIButton
@end

@interface CMKFlipButton : UIButton
@end


@interface CAMModeDial : UIControl
@property (nonatomic) int selectedMode;
@end

@interface CAMTopBar : UIView
@property (nonatomic, retain) CAMFlipButton *flipButton;
@end

@interface CAMBottomBar : UIView
@property (nonatomic, retain) CAMModeDial *modeDial;
@property (nonatomic, retain) CAMFlipButton *flipButton;
@end

@interface CAMPreviewContainerView : UIView
@end

@interface CAMViewfinderView : UIView
-(CMKFlipButton *)_flipButton;
@end

@interface CAMCameraView : UIView
- (CAMFlipButton *)_flipButton;
@end

@interface PLCameraView : UIView
- (CAMFlipButton *)_flipButton;
@end

@interface CAMPreviewViewController : UIViewController
@end

@interface CAMViewfinderViewController : UIViewController
@property (nonatomic, readonly) CAMPreviewViewController *_previewViewController;
@property (nonatomic, readonly) CAMBottomBar *_bottomBar;
@property (nonatomic, readonly) CAMTopBar *_topBar;
@end

UITapGestureRecognizer *tapGesture;
UIView *previewContainerView;
int cameraMode;

%group MostModernOS
%hook CAMViewfinderViewController
- (void)loadView {
    %orig;
    if(!kEnabled)
        return;

    CAMPreviewViewController *previewController = self._previewViewController;
    tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)] autorelease];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [previewController.view addGestureRecognizer:tapGesture];
}

%new
- (void)flipCamera:(UITapGestureRecognizer *)sender {

    CAMBottomBar *bBar = self._bottomBar;
    CAMModeDial *dial = bBar.modeDial;
    int currentMode = dial.selectedMode;

    /* Camera Mode Dial Modes - Disable flipping on non-supported modes - iOS 10
    * 0 = Photo
    * 1 = Video
    * 2 = Slo-Mo / Flip not supported stock
    * 3 = Pano / Flip not supported stock
    * 4 = Square
    * 5 = Time-Lapse
    * 6 = Portrait / Flip not supported stock
    */

    HBLogInfo(@"Am in right mode?");
    if(currentMode == 0 || currentMode == 1 || currentMode == 4 || currentMode == 5) {
        HBLogInfo(@"Yea boy");
        if(iPad) {
            // I actually don't have an iPad on iOS 10 to test this so left the old implementation
            // It's probably not going to work
            CAMFlipButton *flipButton = [[self valueForKey:@"_topBar"] valueForKey:@"_bottomBar"];
            [flipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        else {
            CAMFlipButton *flipButton = self._bottomBar.flipButton;
            HBLogInfo(@"Attemp button flip with Button: %@", flipButton);
            [flipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}
%end
%end

%group ModernOS
%hook CAMViewfinderView

- (void)layoutSubviews {
    %orig;
    if(!kEnabled)
        return;

    self.userInteractionEnabled = YES;

    CAMPreviewContainerView *previewContainerView = [self valueForKey:@"_previewContainerView"];
    tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)] autorelease];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [previewContainerView addGestureRecognizer:tapGesture];

}

%new
- (void)flipCamera:(UITapGestureRecognizer *)sender {

    CAMBottomBar *bBar = MSHookIvar<CAMBottomBar *>(self, "_bottomBar");
    CAMModeDial *dial = MSHookIvar<CAMModeDial *>(bBar, "_modeDial");
    NSInteger *currentMode = MSHookIvar<NSInteger *>(dial, "_selectedMode");
    if(kEnabled && ((int)(size_t)currentMode == 0 || (int)(size_t)currentMode == 1 || (int)(size_t)currentMode == 4 || (int)(size_t)currentMode == 6))
    {
        if(iPad)
        {
            CAMFlipButton *flipButton = [[self valueForKey:@"_topBar"] valueForKey:@"_bottomBar"];
            [flipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            CAMFlipButton *flipButton = [[self valueForKey:@"_topBar"] valueForKey:@"_flipButton"];
            [flipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}
%end

%hook CMKCameraView

- (void)layoutSubviews{
    %orig;
    if(!kEnabled)
        return;

    CAMPreviewContainerView *previewContainerView = [self valueForKey:@"_previewContainerView"];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [previewContainerView addGestureRecognizer:tapGesture];
    [tapGesture release];

}

%new
- (void)flipCamera:(UITapGestureRecognizer *)sender {
    if(kEnabled) {
        if(iPad) {
            CAMFlipButton *flipButton = [[self valueForKey:@"_topBar"] valueForKey:@"_bottomBar"];
            [flipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else {
            CAMFlipButton *flipButton = [[self valueForKey:@"_topBar"] valueForKey:@"_flipButton"];
            [flipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}
%end
%end

%group LegacyOS
%hook CAM_HOOK_CLASS

- (void)layoutSubviews{
    %orig;
    if(!kEnabled)
        return;

    previewContainerView = MSHookIvar<UIView *>(self, "_previewContainerView");
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [previewContainerView addGestureRecognizer:tapGesture];
        [tapGesture release];

}

%new
- (void)flipCamera:(UITapGestureRecognizer *)sender {
    if(kEnabled)
    {
        [[self _flipButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
%end
%end

static void loadPrefs() {
    CFPreferencesAppSynchronize(CFSTR("com.cpdigitaldarkroom.taptapflip"));
    kEnabled = !CFPreferencesCopyAppValue(CFSTR("isEnabled"), CFSTR("com.cpdigitaldarkroom.taptapflip")) ? YES : [(id)CFPreferencesCopyAppValue(CFSTR("isEnabled"), CFSTR("com.cpdigitaldarkroom.taptapflip")) boolValue];
}

%ctor{

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.cpdigitaldarkroom.taptapflip/settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    loadPrefs();

    if(IS_IOS_BETWEEN(iOS_7_0, iOS_8_4)) {
        Class camClass = nil;
        if(IS_IOS_BETWEEN(iOS_7_0, iOS_7_1)) {
            camClass = objc_getClass("PLCameraView");
        } else if(IS_IOS_BETWEEN(iOS_8_0, iOS_8_4)) {
            camClass = objc_getClass("CAMCameraView");
        }
        %init(LegacyOS, CAM_HOOK_CLASS=camClass);
    } else if(IS_IOS_BETWEEN(iOS_9_0, iOS_9_3)) {
         %init(ModernOS);
    } else if(IS_IOS_OR_NEWER(iOS_10_0)) {
         %init(MostModernOS);
    }
}
