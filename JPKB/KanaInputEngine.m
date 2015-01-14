//
//  KanaInputEngine.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "KanaInputEngine.h"

@interface KanaInputEngine ()

@property (nonatomic) NSMutableString *proccessedText;
@property (nonatomic) NSMutableString *displayText;

@property (nonatomic) NSMutableString *buffer;

@end

@implementation KanaInputEngine

- (instancetype)initWithInputSignal:(RACSignal *)inputSignal
{
    self = [super init];
    if (self) {
        self.proccessedText = [[NSMutableString alloc] init];
        self.displayText = [[NSMutableString alloc] init];
        
        self.buffer = [[NSMutableString alloc] init];
        
        RACSignal *bufferedInputSignal = [inputSignal doNext:^(NSString *inputCharacter) {
            [self.buffer appendString:inputCharacter];
            NSLog(@"buffer: %@", self.buffer);
        }];
        
        RACMulticastConnection *bufferedInputConnection = [bufferedInputSignal multicast:[RACReplaySubject subject]];
        [bufferedInputConnection connect];
        
        RACSignal *vowelSignal = [[bufferedInputConnection.signal filter:^BOOL(NSString *inputCharacter) {
            return [@[@"A", @"I", @"U", @"E", @"O"] containsObject:inputCharacter];
        }] map:^(NSString *inputCharacter) {
            NSMutableString *mutableBuffer = [[NSMutableString alloc] initWithString:self.buffer];
            CFStringTransform((CFMutableStringRef)mutableBuffer, NULL, kCFStringTransformLatinHiragana, FALSE);
            return [NSString stringWithString:mutableBuffer];
        }];
        
        RACSignal *secondConsecutiveSignal = [[[bufferedInputConnection.signal combinePreviousWithStart:@"" reduce:^(NSString *previous, NSString *current) {
            return [NSSet setWithArray:@[previous, current]];
        }] filter:^BOOL(NSSet *characters) {
            return [characters count] == 1;
        }] map:^(NSSet *characters) {
            NSString *consecutiveCharacter = [characters anyObject];
            return ([consecutiveCharacter isEqualToString:@"N"]) ? @"ん" : @"っ";
        }];
        
        RACSubject *transformedCharacter = [RACSubject subject];

        [[[RACSignal merge:@[vowelSignal, secondConsecutiveSignal]] doNext:^(id _) {
            self.buffer = [[NSMutableString alloc] init];
        }] subscribe:transformedCharacter];
        
        [transformedCharacter subscribeNext:^(NSString *character) {
            _displayText.string = character;
            [self.delegate keyboardInputEngine:self processedText:_proccessedText.copy displayText:_displayText.copy];
        }];
    }
    return self;
}

- (void)backspace
{
    if (_displayText.length > 0) {
        [_displayText deleteCharactersInRange:NSMakeRange(_displayText.length - 1, 1)];
    }
    _proccessedText.string = _displayText.copy;
}

- (void)setText:(NSString *)text
{
    _proccessedText.string = text;
    _displayText.string = text;
}

@end
