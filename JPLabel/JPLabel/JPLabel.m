//
//  JPLabel.m
//  JPLabel
//
//  Created by lava on 16/9/2.
//  Copyright © 2016年 lavaMusic. All rights reserved.
//

#import "JPLabel.h"

@interface JPLabel()

/** NSMutableAttributeString的子类 */
@property(nonatomic, strong)NSTextStorage *textStorage;

/** 布局管理者 */
@property(nonatomic, strong)NSLayoutManager *layoutManager;

/** 容器,需要设置容器的大小 */
@property(nonatomic, strong)NSTextContainer *textContainer;

/** 点击类型 */
@property(nonatomic, assign)HandleStyle tapStyle;

/** 用于记录用户选中的range */
@property(nonatomic, assign)NSRange selectedRange;

/** 用户记录点击还是松开 */
@property(nonatomic, assign)BOOL isSelected;

/** 用户文字颜色 */
@property(nonatomic, strong)UIColor *userHightColor;

/** 话题文字颜色 */
@property(nonatomic, strong)UIColor *topicHightColor;

/** 链接文字颜色 */
@property(nonatomic, strong)UIColor *linkHightColor;

/** 协议/政策文字颜色 */
@property(nonatomic, strong)UIColor *agreementHightColor;

/** 链接范围 */
@property(nonatomic, strong)NSArray *linkRangesArr;

/** 用户名范围 */
@property(nonatomic, strong)NSArray *userRangesArr;

/** 话题范围 */
@property(nonatomic, strong)NSArray *topicRangesArr;

/** 协议/政策范围 */
@property(nonatomic, strong)NSArray *agreementRangesArr;

/** 自定义要查找的范围 */
@property(nonatomic, strong)NSArray *userDefineRangesArr;

@end


static NSString *JPRange = @"jprange";
static NSString *JPColor = @"jpcolor";
@implementation JPLabel

#pragma mark --------------------------------------------------
#pragma mark Publish

-(void)setHightLightTextColor:(UIColor *)hightLightColor forHandleStyle:(HandleStyle)handleStyle{
    switch (handleStyle) {
        case HandleStyleLink:
        {
            self.linkHightColor = hightLightColor;
            [self prepareText];
        }
            break;
        case HandleStyleTopic:
        {
            self.topicHightColor = hightLightColor;
            [self prepareText];
        }
            break;
        case HandleStyleAgreement:
        {
            self.agreementHightColor = hightLightColor;
            [self prepareText];
        }
            break;
        case HandleStyleUser:
        {
            self.userHightColor = hightLightColor;
            [self prepareText];
        }
            break;
            
        default:
            break;
    }
}

-(void)setJp_commonTextColor:(UIColor *)jp_commonTextColor{
    _jp_commonTextColor = jp_commonTextColor;
    [self prepareText];
}

-(void)setJp_matchArr:(NSArray<NSDictionary *> *)jp_matchArr{
    _jp_matchArr = jp_matchArr;
    [self prepareText];
}


#pragma mark --------------------------------------------------
#pragma mark 重写系统的属性

-(void)setText:(NSString *)text{
    [super setText:text];
    [self prepareText];
}

-(void)setFont:(UIFont *)font{
    [super setFont:font];
    [self prepareText];
}

-(void)setTextColor:(UIColor *)textColor{
    [super setTextColor:textColor];
    [self prepareText];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    
    _textStorage = [NSTextStorage new];
    _layoutManager = [NSLayoutManager new];
    _textContainer = [NSTextContainer new];
    _jp_commonTextColor = [UIColor colorWithRed:162.0/255 green:162.0/255  blue:162.0/255  alpha:162.0/255];
    _jp_textHightLightBackgroundColor = [UIColor colorWithWhite:0.7 alpha:0.2];
    _linkHightColor = _topicHightColor = _agreementHightColor = _userHightColor = [UIColor colorWithRed:64.0/255 green:64.0/255 blue:64.0/255 alpha:1];
    
    [self prepareTextSystem];
}


#pragma mark --------------------------------------------------
#pragma mark 系统回调

// 布局子控件
-(void)layoutSubviews{
    [super layoutSubviews];
    
    // 设置容器的大小为Label的尺寸
    self.textContainer.size = self.frame.size;
}


// 重写drawTextInRect方法
-(void)drawRect:(CGRect)rect{
    
    // 不调用super就不会绘制原有文字
//    [super drawRect:rect];
    
    // 1.绘制背景
    if (self.selectedRange.length != 0) {
        
        // 2.0.确定颜色
        UIColor *selectedColor = self.isSelected ? self.jp_textHightLightBackgroundColor : [UIColor clearColor];
        
        // 2.1.设置颜色
        [self.textStorage addAttribute:NSBackgroundColorAttributeName value:selectedColor range:self.selectedRange];
        
        // 2.2.绘制背景
        [self.layoutManager drawBackgroundForGlyphRange:self.selectedRange atPoint:CGPointMake(0, 0)];
    }
    
    // 2.绘制字形
    // 需要绘制的范围
    NSRange range = NSMakeRange(0, self.textStorage.length);
    [self.layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
}



#pragma mark --------------------------------------------------
#pragma mark Private

// 准备文本系统
-(void)prepareTextSystem{
    // 0.准备文本
    [self prepareText];
    
    // 1.将布局添加到storeage中
    [self.textStorage addLayoutManager:self.layoutManager];
    
    // 2.将容器添加到布局中
    [self.layoutManager addTextContainer:self.textContainer];
    
    // 3.让label可以和用户交互
    self.userInteractionEnabled = YES;
    
    // 4.设置间距为0
    self.textContainer.lineFragmentPadding = 0;
}

// 准备文本
-(void)prepareText{
    
    // 1.准备字符串
    NSAttributedString *attrString = nil;
    if (self.attributedText != nil) {
        attrString = self.attributedText;
    }
    else if (self.text != nil){
        attrString = [[NSAttributedString alloc]initWithString:self.text];
    }
    else{
        attrString = [[NSAttributedString alloc]initWithString:@""];
    }
    
    if (attrString.length == 0) return;
    
    self.selectedRange = NSMakeRange(0, 0);
    
    // 2.设置换行模型
    NSMutableAttributedString *attrStringM = [self addLineBreak:attrString];

    // 3.给文本添加显示字号和颜色
    NSDictionary *attr;
    attr = @{
             NSFontAttributeName : self.font,
             NSForegroundColorAttributeName : self.jp_commonTextColor
             };

    [attrStringM setAttributes:attr range:NSMakeRange(0, attrStringM.length)];
    
    // 4.设置textStorage的内容
    [self.textStorage setAttributedString:attrStringM];
    
    // 5.匹配URL
    NSArray *linkRanges = [self getLinkRanges];
    self.linkRangesArr = linkRanges;
    for (NSValue *value in linkRanges) {
        NSRange range;
        [value getValue:&range];
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:self.linkHightColor range:range];
    }
    
    // 6.匹配@用户
    NSArray *userRanges = [self getRanges:@"@[\\u4e00-\\u9fa5a-zA-Z0-9_-]*"];
    self.userRangesArr = userRanges;
    for (NSValue *value in userRanges) {
        NSRange range;
        [value getValue:&range];
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:self.userHightColor range:range];
    }
    
    // 7.匹配话题##
    NSArray *topicRanges = [self getRanges:@"#.*?#"];
    self.topicRangesArr = topicRanges;
    for (NSValue *value in topicRanges) {
        NSRange range;
        [value getValue:&range];
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:self.topicHightColor range:range];
    }
    
    // 8.匹配协议/政策 << >>
    NSArray *agreementRanges = [self getRanges:@"《([^》]*)》"];
    self.agreementRangesArr = agreementRanges;
    for (NSValue *value in agreementRanges) {
        NSRange range;
        [value getValue:&range];
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:self.agreementHightColor range:range];
    }
    
    // 9.匹配用户自定义的字符串
    if (self.jp_matchArr.count > 0) {
        NSArray<NSDictionary *> *userDefineRangeDicts = [self getUserDefineStringsRange];
        if (userDefineRangeDicts.count > 0) {
            NSMutableArray *arrM = [NSMutableArray array];
            for (NSDictionary *dict in userDefineRangeDicts) {
                NSValue *value = dict[JPRange];
                [arrM addObject:value];
                UIColor *color = dict[JPColor];
                NSRange range;
                [value getValue:&range];
                [self.textStorage addAttribute:NSForegroundColorAttributeName value:color range:range];
            }
            self.userDefineRangesArr = [arrM copy];
        }
        
    }
    
    // 10.更新显示，重新绘制
    [self setNeedsDisplay];
}



#pragma mark --------------------------------------------------
#pragma mark 点击交互的封装

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 0.记录点击
    self.isSelected = YES;
    
    // 1.获取用户点击的点
    CGPoint selectedPoint = [[touches anyObject]locationInView:self];
    
    // 2.获取该点所在的字符串的range
    self.selectedRange = [self getSelectRange:selectedPoint];

    // 3.是否处理了事件
    if (self.selectedRange.length == 0) {
        [super touchesBegan:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.selectedRange.length == 0) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    // 0.记录松开
    self.isSelected = NO;
    
    // 2.重新绘制
    [self setNeedsDisplay];
    
    // 3.取出内容
    NSString *selectedString = [[self.textStorage string] substringWithRange:self.selectedRange];
    
    // 3.回调
    switch (self.tapStyle) {
        case HandleStyleAgreement:{
            __weak typeof(self) weakSelf = self;
            if (self.jp_tapOperation) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (strongSelf.jp_tapOperation) {
                    strongSelf.jp_tapOperation(strongSelf, HandleStyleAgreement, selectedString, strongSelf.selectedRange);
                }
            }
        }
            break;
        case HandleStyleLink:{
            __weak typeof(self) weakSelf = self;
            if (self.jp_tapOperation) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (strongSelf.jp_tapOperation) {
                    strongSelf.jp_tapOperation(strongSelf, HandleStyleLink, selectedString, strongSelf.selectedRange);
                }
            }
        }
            break;
        case HandleStyleTopic:{
            __weak typeof(self) weakSelf = self;
            if (self.jp_tapOperation) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (strongSelf.jp_tapOperation) {
                    strongSelf.jp_tapOperation(strongSelf, HandleStyleTopic, selectedString, strongSelf.selectedRange);
                }
            }
        }
            break;
        case HandleStyleUser:{
            __weak typeof(self) weakSelf = self;
            if (self.jp_tapOperation) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (strongSelf.jp_tapOperation) {
                    strongSelf.jp_tapOperation(strongSelf, HandleStyleUser, selectedString, strongSelf.selectedRange);
                }
            }
        }
            break;
        case HandleStyleUserDefine:{
            __weak typeof(self) weakSelf = self;
            if (self.jp_tapOperation) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (strongSelf.jp_tapOperation) {
                    strongSelf.jp_tapOperation(strongSelf, HandleStyleUserDefine, selectedString, strongSelf.selectedRange);
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    // 4.代理
    if ([self.delegate respondsToSelector:@selector(jp_label:didSelectedString:forStyle:inRange:)]) {
        [self.delegate jp_label:self didSelectedString:selectedString forStyle:self.tapStyle inRange:self.selectedRange];
    }
    
}

-(NSRange)getSelectRange:(CGPoint)selectPoint{
    // 0.如果属性字符串为nil,则不需要判断
    if (self.textStorage.length == 0) return NSMakeRange(0, 0);
    
    // 1.获取选中点所在的下标值(index)
    NSUInteger index = [self.layoutManager glyphIndexForPoint:selectPoint inTextContainer:self.textContainer];

    // 2.判断下标在什么内
    // 2.1.判断是否是一个链接
    for (NSValue *value in self.linkRangesArr) {
        NSRange range;
        [value getValue:&range];
        if (index > range.location && index < range.location + range.length) {
            [self setNeedsDisplay];
            self.tapStyle = HandleStyleLink;
            return range;
        }
    }
    
    // 2.2.判断是否是一个@用户
    for (NSValue *value in self.userRangesArr) {
        NSRange range;
        [value getValue:&range];
        if (index > range.location && index < range.location + range.length) {
            [self setNeedsDisplay];
            self.tapStyle = HandleStyleUser;
            return range;
        }
    }
    
    // 2.3.判断是否是一个#话题#
    for (NSValue *value in self.topicRangesArr) {
        NSRange range;
        [value getValue:&range];
        if (index > range.location && index < range.location + range.length) {
            [self setNeedsDisplay];
            self.tapStyle = HandleStyleTopic;
            return range;
        }
    }
    
    // 2.4.判断是否是一个协议/政策 <<>>
    for (NSValue *value in self.agreementRangesArr) {
        NSRange range;
        [value getValue:&range];
        if (index > range.location && index < range.location + range.length) {
            [self setNeedsDisplay];
            self.tapStyle = HandleStyleAgreement;
            return range;
        }
    }
    
    // 2.5.判断是否是一个用户自定义要匹配的字符串
    for (NSValue *value in self.userDefineRangesArr) {
        NSRange range;
        [value getValue:&range];
        if (index > range.location && index < range.location + range.length) {
            [self setNeedsDisplay];
            self.tapStyle = HandleStyleUserDefine;
            return range;
        }
    }
    
    return NSMakeRange(0, 0);
}


#pragma mark --------------------------------------------------
#pragma mark 字符串匹配封装

// 查找用户给定的字符串的range
-(NSArray<NSDictionary*> *)getUserDefineStringsRange{
    
    if (self.jp_matchArr.count == 0) return nil;
    
    NSMutableArray<NSDictionary*> *arrM = [NSMutableArray array];
    
    NSString *str = [self.textStorage string];
    for (NSDictionary *dict in self.jp_matchArr) {
        NSString *subStr = dict[@"string"];
        UIColor *color = dict[@"color"];
        // 没传入字符串
        if (!subStr) return nil;
        
        NSRange range = [str rangeOfString:subStr];
        
        // 没找到
        if (range.length == 0) continue;
        
        NSValue *value = [NSValue valueWithBytes:&range objCType:@encode(NSRange)];
        NSMutableDictionary *aDictM = [NSMutableDictionary dictionary];
        aDictM[JPRange] = value;
        aDictM[JPColor] = color;
        [arrM addObject:[aDictM copy]];
    }
    
    return [arrM copy];
}

-(NSArray *)getRanges:(NSString *)pattern{
    
    // 创建正则表达式对象
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:pattern options:0 error:&error];
    
    return [self getRangesFromResult:regex];
}

-(NSArray *)getLinkRanges{
     // 创建正则表达式
    NSError *error;
    NSDataDetector *detector = [NSDataDetector  dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    return [self getRangesFromResult:detector];
}

-(NSArray *)getRangesFromResult:(NSRegularExpression *)regex{
    
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:[self.textStorage string] options:0 range:NSMakeRange(0, self.textStorage.length)];
    
    // 2.遍历结果
    NSMutableArray *ranges = [NSMutableArray array];
    for (NSTextCheckingResult *result in results) {
       
        // 将结构体保存到数组
        // 先用一个变量接受结构体
        NSRange range = result.range;
        NSValue *value = [NSValue valueWithBytes:&range objCType:@encode(NSRange)];
        [ranges addObject:value];
    }
    
    return ranges;
}


#pragma mark --------------------------------------------------
#pragma mark Extesion

// 如果用户没有设置lineBreak,则所有内容会绘制到同一行中,因此需要主动设置
-(NSMutableAttributedString *)addLineBreak:(NSAttributedString *)attrString{
    
    NSMutableAttributedString *attrStringM = [attrString mutableCopy];
    
    if (attrStringM.length == 0) return attrStringM;
    
    NSRange range = NSMakeRange(0, 0);
    NSMutableDictionary *attributes = [[attrStringM attributesAtIndex:0 effectiveRange:&range] mutableCopy];
    NSMutableParagraphStyle *paragraphStyle = [attributes[NSParagraphStyleAttributeName] mutableCopy];
    
    if (paragraphStyle != nil) {
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    }
    else{
        paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        attributes[NSParagraphStyleAttributeName] = paragraphStyle;
        
        [attrStringM setAttributes:attributes range:range];
    }
    
    return attrStringM;
}


@end
