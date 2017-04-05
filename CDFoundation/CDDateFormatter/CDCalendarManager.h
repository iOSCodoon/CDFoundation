//
//  CDCalendarManager.h
//  CodoonSport
//
//  Created by jiaxin on 16/4/21.
//  Copyright © 2016年 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDCalendarManager : NSObject

//firstWeekday为默认值1
@property (nonatomic, strong) NSCalendar *defaultCalendar;
+ (instancetype)defaultManager;
/**
 *  注意：获取到的NSCalendar实例是全局共享的，不允许做属性修改。如果需要自定义，请使用calendar实例方法获取新的对象，并进行单独配置。
 */
- (NSCalendar *)calendarWithFirstWeekday:(NSUInteger)firstWeekday;
- (NSCalendar *)calendar;

@end
