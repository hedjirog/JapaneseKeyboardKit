//
//  KanaInputEngine.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "KeyboardView.h"

@interface KanaInputEngine : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic) NSString *text;

- (instancetype)initWithInputSignal:(RACSignal *)inputSignal;
- (void)backspace;

@end

@protocol KeyboardInputEngineDelegate <NSObject>

- (void)keyboardInputEngine:(KanaInputEngine *)engine processedText:(NSString *)text displayText:(NSString *)displayText;

@end
