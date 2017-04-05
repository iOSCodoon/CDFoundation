//
//  CDDateFormatterManager.h
//  CodoonSport
//
//  Created by jiaxin on 16/5/4.
//  Copyright © 2016年 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDDateFormatterManager : NSObject

+ (instancetype)defaultManager;
/**
 *  注意：获取到的NSDateFormatter实例是全局共享的，不允许做属性修改。如果需要多次设置dateFormat，请多次调用该方法，维护多个实例。如果需要设置dateFormat以外的属性，请使用dateFormatter实例方法获取新的对象，并进行单独配置。
 */
- (NSDateFormatter *)dateFormatterWithDateFormatString:(NSString *)dateFormatString;
- (NSDateFormatter *)dateFormatter;

@end
