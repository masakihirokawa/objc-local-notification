# iOSアプリでローカルプッシュ通知を使用する

iOSアプリで指定した時刻にローカルプッシュ通知を送信する手順を以下に記載します。

## ローカルプッシュ通知の導入手順

### 1. Frameworkの追加

今回のサンプルは iOS 10以降を対象としていますので、*UserNotifications.framework*をプロジェクトに追加します。

### 2. プッシュ通知の許可をユーザーに求める

ローカルプッシュ通知の送信には、アプリ起動時にユーザーに対しプッシュ通知の受信許可を求める必要があります。

#### AppDelegate.h

```objective-c
@import UserNotifications;
```

#### AppDelegate.m

```objective-c
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
```

### 3. ローカルプッシュ通知管理クラスの作成

今回のサンプルでは、指定した時刻にローカルプッシュ通知を送信するよう実装しています。

#### LocalNotificationManager.h

```objective-c
#import <UIKit/UIKit.h>

@import UserNotifications;

NS_ASSUME_NONNULL_BEGIN

@interface LocalNotificationManager : NSObject

#pragma mark - property
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDate     *nowDate;

#pragma mark - public method
- (void)scheduleLocalNotifications:(NSArray *)notificationHours;

@end

NS_ASSUME_NONNULL_END
```

#### LocalNotificationManager.m

```objective-c
#import "LocalNotificationManager.h"

@implementation LocalNotificationManager

#pragma mark - Scheduler

// ローカルプッシュ通知のスケジューリング
- (void)scheduleLocalNotifications:(NSArray *)notificationHours
{
    // 通知を全てキャンセルする
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    
    // 通知時間を設定する
    for (int i = 0; i < [notificationHours count]; i++) {
        // 通知時間保持
        NSUInteger notificationHour = [notificationHours[i] intValue];
        
        // カレンダー初期化
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        // 現在の日付取得
        _nowDate  = [NSDate date];
        
        // コンポーネント初期化
        NSDateComponents *fireDateComponents = [_calendar components:(NSCalendarUnitHour |
                                                                      NSCalendarUnitMinute |
                                                                      NSCalendarUnitSecond)
                                                            fromDate:_nowDate];
        
        // コンポーネントに通知時間を指定
        [fireDateComponents setHour:notificationHour];
        [fireDateComponents setMinute:0];
        [fireDateComponents setSecond:0];
        [fireDateComponents setTimeZone:[NSTimeZone systemTimeZone]];
        
        // ローカル通知のスケジュール呼び出し
        [self makeNotification:fireDateComponents notificationHour:notificationHour userInfo:nil];
    }
}

// ローカルプッシュ通知生成
- (void)makeNotification:(NSDateComponents *)fireDateComponents notificationHour:(NSUInteger)notificationHour userInfo:(NSDictionary *)userInfo
{
    // デバッグ出力
    //NSLog(@"fireDateComponents: %@", fireDateComponents);
    
    // ローカルプッシュ通知のスケジューリング
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title    = @"It's time to go.";
    content.body     = [NSString stringWithFormat:@"t's now %lu:00.", notificationHour];
    content.sound    = [UNNotificationSound defaultSound];
    content.badge    = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
    content.userInfo = userInfo;
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger
                                              triggerWithDateMatchingComponents:fireDateComponents repeats:YES];
    
    NSString *const notificationIdentifier = [NSString stringWithFormat:@"NotificationHour: %lu", notificationHour];
    
    UNNotificationRequest *request = [UNNotificationRequest
                                      requestWithIdentifier:notificationIdentifier content:content trigger:trigger];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", error);
        }
    }];
}
```

### 4. プッシュ通知の予約

ユーザーがアプリを閉じたタイミングでプッシュ通知を予約します。今回は9時、12時、15時、18時にローカルプッシュ通知が送信されるよう指定しました。

#### AppDelegate.h

```objective-c
#import "LocalNotificationManager.h"
```

#### AppDelegate.m

```objective-c
// アプリがバックグラウンドになった時に呼ばれる
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // ローカルプッシュ通知を送信する時間を指定
    NSArray *notificationHours = @[@9, @12, @15, @18];
    
    // バックグラウンド移行時にプッシュ通知を設定
    LocalNotificationManager *notificationManager = [[LocalNotificationManager alloc] init];
    [notificationManager scheduleLocalNotifications:notificationHours];
}
```

### e.x. アイコンバッジの削除

このサンプルではプッシュ通知送信時にアイコンバッジを付与するよう指定していますので、アプリが起動されたらアイコンバッジを削除するようにします。

#### AppDelegate.m

```objective-c
// アプリがバックグラウンドからフォアグラウンドになる直前に呼ばれる
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // アイコンバッジ削除
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
```

以上でローカルプッシュ通知の実装は完了になります。