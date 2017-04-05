//
//  CDCalendarManager.m
//  CodoonSport
//
//  Created by jiaxin on 16/4/21.
//  Copyright © 2016年 Codoon. All rights reserved.
//

#import "CDCalendarManager.h"

@interface CDCalendarManager ()

@property (nonatomic, strong) NSCache *calendaerCache;

@end

@implementation CDCalendarManager

+ (instancetype)defaultManager
{
    static CDCalendarManager *calendarManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendarManager = [[CDCalendarManager alloc] init];
        calendarManager.calendaerCache = [[NSCache alloc] init];
        calendarManager.defaultCalendar = [calendarManager calendarWithFirstWeekday:1];
    });
    return calendarManager;
}

- (NSCalendar *)calendarWithFirstWeekday:(NSUInteger)firstWeekday
{
    NSCalendar *calendar = [self.calendaerCache objectForKey:[@(firstWeekday) stringValue]];
    if (!calendar) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        calendar.firstWeekday = firstWeekday;
        [self.calendaerCache setObject:calendar forKey:[@(firstWeekday) stringValue]];
    }
    return calendar;
}

- (NSCalendar *)calendar
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return calendar;
}

@end
