//
//  CDDateFormatterManager.m
//  CodoonSport
//
//  Created by jiaxin on 16/5/4.
//  Copyright © 2016年 Codoon. All rights reserved.
//

#import "CDDateFormatterManager.h"

@interface CDDateFormatter : NSDateFormatter
@property (readwrite, nonatomic, assign) BOOL initialized;
@end

@implementation CDDateFormatter

- (instancetype)initWithFormat:(NSString *)format calendar:(NSCalendar *)calendar locale:(NSLocale *)locale
{
    self = [super init];

    self.dateFormat = format;
    self.calendar = calendar;
    self.locale = locale;

    self.initialized = YES;

    return self;
}


- (void)setDateFormat:(NSString *)dateFormat
{
    NSAssert(!_initialized, @"禁止修改dateFormat属性");

    if(!_initialized)
    {
        [super setDateFormat:dateFormat];
    }
}

- (void)setCalendar:(NSCalendar *)calendar
{
    NSAssert(!_initialized, @"禁止修改calendar属性");

    if(!_initialized)
    {
        [super setCalendar:calendar];
    }
}

- (void)setLocale:(NSLocale *)locale
{
    NSAssert(!_initialized, @"禁止修改locale属性");

    if(!_initialized)
    {
        [super setLocale:locale];
    }
}

@end


@interface CDDateFormatterManager ()

@property (nonatomic, strong) NSCache *dateFormatterCache;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSLocale *locale;

@end

@implementation CDDateFormatterManager

+ (instancetype)defaultManager
{
    static CDDateFormatterManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CDDateFormatterManager alloc] init];
        manager.dateFormatterCache = [[NSCache alloc] init];
        manager.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        manager.locale = [NSLocale systemLocale];
    });
    return manager;
}

- (NSDateFormatter *)dateFormatterWithDateFormatString:(NSString *)dateFormatString
{
    CDDateFormatter *dateFormatter = [self.dateFormatterCache objectForKey:dateFormatString];
    if (!dateFormatter) {
        dateFormatter = [[CDDateFormatter alloc] initWithFormat:dateFormatString calendar:self.calendar locale:self.locale];
        [self.dateFormatterCache setObject:dateFormatter forKey:dateFormatString];
    }
    return dateFormatter;
}

- (NSDateFormatter *)dateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.locale = [NSLocale systemLocale];
    return formatter;
}

@end
