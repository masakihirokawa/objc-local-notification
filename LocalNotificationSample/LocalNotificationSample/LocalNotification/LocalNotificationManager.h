//
//  LocalNotificationManager.h
//  LocalNotificationSample
//
//  Created by Dolice on 2020/07/10.
//

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
