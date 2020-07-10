//
//  AppDelegate.m
//  LocalNotificationSample
//
//  Created by Dolice on 2020/07/10.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

// アプリ起動時の処理
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ユーザーにプッシュ通知の許可を求める
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Succeeded!");
        }
    }];
    
    return YES;
}

#pragma mark - delegate method

// アプリがバックグラウンドになった時に呼ばれる
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // ローカルプッシュ通知を送信する時間を指定
    NSArray *notificationHours = @[@9, @12, @15, @18];
    
    // バックグラウンド移行時にプッシュ通知を設定
    LocalNotificationManager *notificationManager = [[LocalNotificationManager alloc] init];
    [notificationManager scheduleLocalNotifications:notificationHours];
}

// アプリがバックグラウンドからフォアグラウンドになる直前に呼ばれる
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // アイコンバッジ削除
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
