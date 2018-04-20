#import <UIKit/UIKit.h>

#import <UserNotifications/UserNotifications.h>

#import <Flutter/Flutter.h>
#import <FH/FH.h>

@interface AppDelegate : FlutterAppDelegate <UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

@end