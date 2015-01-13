//
//  KeyboardLayout.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KeyboardMetrics) {
    KeyboardMetricsDefault,
    KeyboardMetricsLandscape,
    KeyboardMetricsLandscape568,
};

typedef NS_ENUM(NSUInteger, KeyboardButtonIndex) {
    KeyboardButtonIndexShift = 41,
    KeyboardButtonIndexSpace,
    KeyboardButtonIndexDelete,
    KeyboardButtonIndexReturn,
};

@class KeyboardButton;

@interface KeyboardLayout : NSObject

@property (nonatomic) KeyboardMetrics metrics;

@property (nonatomic) BOOL shifted;

+ (KeyboardLayout *)keyboardLayout;
- (void)setupKeyboardButtonsWithView:(UIView *)view;

@end

@interface KeyboardLayoutPhone5 : KeyboardLayout

@end

@interface KeyboardLayoutPhone6 : KeyboardLayout

@end

@interface KeyboardLayoutPhone6Plus : KeyboardLayout

@end
