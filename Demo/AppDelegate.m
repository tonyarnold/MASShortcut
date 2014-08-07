#import "AppDelegate.h"

NSString *const MASPreferenceKeyShortcut = @"MASDemoShortcut";
NSString *const MASPreferenceKeyShortcutEnabled = @"MASDemoShortcutEnabled";
NSString *const MASPreferenceKeyConstantShortcutEnabled = @"MASDemoConstantShortcutEnabled";

@implementation AppDelegate

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Checkbox will enable and disable the shortcut view
    [self.shortcutView bind:@"enabled" toObject:self withKeyPath:@"shortcutEnabled" options:nil];
}

#pragma mark NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Shortcut view will follow and modify user preferences automatically
    [_shortcutView bind:MASShortcutBinding
        toObject:[NSUserDefaultsController sharedUserDefaultsController]
        withKeyPath:[@"values." stringByAppendingString:MASPreferenceKeyShortcut]
        options:@{NSValueTransformerNameBindingOption:NSKeyedUnarchiveFromDataTransformerName}];

    // Activate the global keyboard shortcut if it was enabled last time
    [self resetShortcutRegistration];

    // Activate the shortcut Command-F1 if it was enabled
    [self resetConstantShortcutRegistration];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark - Custom shortcut

- (BOOL)isShortcutEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:MASPreferenceKeyShortcutEnabled];
}

- (void)setShortcutEnabled:(BOOL)enabled
{
    if (self.shortcutEnabled != enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:MASPreferenceKeyShortcutEnabled];
        [self resetShortcutRegistration];
    }
}

- (void)resetShortcutRegistration
{
    if (self.shortcutEnabled) {
        [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:MASPreferenceKeyShortcut toAction:^{
            [[NSAlert alertWithMessageText:NSLocalizedString(@"Global hotkey has been pressed.", @"Alert message for custom shortcut")
                             defaultButton:NSLocalizedString(@"OK", @"Default button for the alert on custom shortcut")
                           alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
        }];
    }
    else {
        [[MASShortcutBinder sharedBinder] breakBindingWithDefaultsKey:MASPreferenceKeyShortcut];
    }
}

#pragma mark - Constant shortcut

- (BOOL)isConstantShortcutEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:MASPreferenceKeyConstantShortcutEnabled];
}

- (void)setConstantShortcutEnabled:(BOOL)enabled
{
    if (self.constantShortcutEnabled != enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:MASPreferenceKeyConstantShortcutEnabled];
        [self resetConstantShortcutRegistration];
    }
}

- (void)resetConstantShortcutRegistration
{
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_F2 modifierFlags:NSCommandKeyMask];
    if (self.constantShortcutEnabled) {
        [[MASShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
            [[NSAlert alertWithMessageText:NSLocalizedString(@"⌘F2 has been pressed.", @"Alert message for constant shortcut")
                             defaultButton:NSLocalizedString(@"OK", @"Default button for the alert on constant shortcut")
                           alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
        }];
    }
    else {
        [[MASShortcutMonitor sharedMonitor] unregisterShortcut:shortcut];
    }
}

@end
