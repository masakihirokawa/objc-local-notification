//
//  LocalNotificationManager.m
//  LocalNotificationSample
//
//  Created by Dolice on 2020/07/10.
//

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

@end
