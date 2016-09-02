//
//  JPLabel.h
//  JPLabel
//
//  Created by lava on 16/9/2.
//  Copyright © 2016年 lavaMusic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HandleStyle) {
    HandleStyleNone = 0,
    HandleStyleUser = 1,
    HandleStyleTopic = 2,
    HandleStyleLink = 3,
    HandleStyleAgreement = 4
};


typedef void(^TapHandle)(UILabel *, HandleStyle, NSString *, NSRange);

@interface JPLabel : UILabel

/** 普通文字颜色 */
@property(nonatomic, strong)UIColor *jp_commonTextColor;

/** 选中时高亮背景色 */
@property(nonatomic, strong)UIColor *jp_textHightLightBackgroundColor;

/** 给不同种类的高亮文字设置颜色*/
-(void)setHightLightTextColor:(UIColor *)hightLightColor forHandleStyle:(HandleStyle)handleStyle;

/** 点击事件block */
@property(nonatomic, strong)TapHandle jp_tapOperation;

@end
