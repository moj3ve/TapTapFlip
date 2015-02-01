#import <version.h>

static BOOL kEnabled;

@interface CAMFlipButton : UIButton
@end

@interface CAMCameraView : UIView

- (CAMFlipButton *)_flipButton;

@end

@interface PLCameraView : UIView

- (CAMFlipButton *)_flipButton;

@end

%group iOS_8
%hook CAMCameraView

- (void)layoutSubviews{
	%orig;
	if(!kEnabled)
		return;

	UIView *previewContainerView = MSHookIvar<UIView *>(self, "_previewContainerView");
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)];
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

%group iOS_7
%hook PLCameraView

- (void)layoutSubviews{

    %orig;
    if(!kEnabled)
        return;

    UIView *previewContainerView = MSHookIvar<UIView *>(self, "_previewContainerView");
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)];
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

    if(IS_IOS_BETWEEN(iOS_7_0, iOS_7_1_2)){
        %init(iOS_7);
    } else if (IS_IOS_OR_NEWER(iOS_8_0_2)){
         %init(iOS_8);
    }
}