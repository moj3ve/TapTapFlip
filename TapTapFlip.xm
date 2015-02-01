
static BOOL kEnabled;

@interface CAMFlipButton : UIButton
@end

@interface CAMCameraView : UIView

- (CAMFlipButton *)_flipButton;

@end

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

static void loadPrefs() {
    CFPreferencesAppSynchronize(CFSTR("com.cpdigitaldarkroom.taptapflip"));
    kEnabled = !CFPreferencesCopyAppValue(CFSTR("isEnabled"), CFSTR("com.cpdigitaldarkroom.taptapflip")) ? YES : [(id)CFPreferencesCopyAppValue(CFSTR("isEnabled"), CFSTR("com.cpdigitaldarkroom.taptapflip")) boolValue];
}

%ctor{

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.cpdigitaldarkroom.taptapflip/settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
}
