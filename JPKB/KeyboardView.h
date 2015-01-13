//
//  KeyboardView.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardLayout.h"

@class KeyboardButton;

@interface KeyboardView : UIView

@property (nonatomic, weak) id delegate;

- (void)buttonDidTouchDown:(KeyboardButton *)button;
- (void)buttonDidTouchUp:(KeyboardButton *)button;

@end

@protocol KeyboardViewDelegate <NSObject>

- (void)keyboardViewDidInputDelete:(KeyboardView *)keyboardView;
- (void)keyboardViewDidInputReturn:(KeyboardView *)keyboardView;
- (void)keyboardView:(KeyboardView *)keyboardView didAcceptCandidate:(NSString *)candidate;

@end
