//
//  KeyboardLayout.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "KeyboardLayout.h"
#import "KeyboardView.h"
#import "KeyboardButton.h"

@interface KeyboardLayout ()

@property (nonatomic) NSArray *inputButtons;
@property (nonatomic) NSArray *functionButtons;

@property (nonatomic) KeyboardButton *shiftButton;
@property (nonatomic) KeyboardButton *spaceButton;
@property (nonatomic) KeyboardButton *deleteButton;
@property (nonatomic) KeyboardButton *returnButton;

@property (nonatomic) NSArray *keycaps;
@property (nonatomic) UIFont *buttonTitleFont;

@property (nonatomic) UIImage *shiftImage;
@property (nonatomic) UIImage *highlightedShiftImage;
@property (nonatomic) UIImage *shiftLockImage;
@property (nonatomic) UIImage *deleteImage;
@property (nonatomic) UIImage *returnImage;

@property (nonatomic) CGRect shiftButtonFrame;
@property (nonatomic) CGRect spaceButtonFrame;
@property (nonatomic) CGRect deleteButtonFrame;
@property (nonatomic) CGRect returnButtonFrame;

@end

@implementation KeyboardLayout

+ (KeyboardLayout *)keyboardLayout
{
    KeyboardLayout *layout = [[self alloc] init];
    return layout;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupInputButtons];
        [self setupFunctionButtons];
    }
    
    return self;
}

#pragma mark -

- (void)setupInputButtons
{
    NSArray *keycaps = self.keycaps;
    
    NSMutableArray *inputButtons = [[NSMutableArray alloc] init];
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < keycaps.count; i++) {
        NSArray *row = keycaps[i];
        for (NSUInteger j = 0; j < row.count; j++) {
            NSArray *col = row[j];
            NSString *title = [col componentsJoinedByString:@"\n"];
            
            KeyboardButton *button = [self whiteButtonWithTitle:title image:nil];
            
            button.keyIndex = index;
            [inputButtons addObject:button];
            
            index++;
        }
    }
    
    self.inputButtons = inputButtons;
}

- (void)setupFunctionButtons
{
    NSMutableArray *functionButtons = [[NSMutableArray alloc] init];
    KeyboardButton *button;
    
    button = [self darkgrayButtonWithTitle:nil image:nil];
    [button setBackgroundImage:[UIImage imageNamed:@"key_white"] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:@"key_white"] forState:UIControlStateHighlighted | UIControlStateSelected];
    button.keyIndex = KeyboardButtonIndexShift;
    [functionButtons addObject:button];
    self.shiftButton = button;
    
    button = [self whiteButtonWithTitle:NSLocalizedString(@"space", nil) image:nil];
    button.keyIndex = KeyboardButtonIndexSpace;
    [functionButtons addObject:button];
    self.spaceButton = button;
    
    button = [self darkgrayButtonWithTitle:nil image:nil];
    button.keyIndex = KeyboardButtonIndexDelete;
    [functionButtons addObject:button];
    self.deleteButton = button;
    
    button = [self blueButtonWithTitle:nil image:nil];
    button.keyIndex = KeyboardButtonIndexReturn;
    [functionButtons addObject:button];
    self.returnButton = button;
    
    self.functionButtons = functionButtons;
}

- (void)setupKeyboardButtonsWithView:(UIView *)view
{
    NSArray *buttons = [self.inputButtons arrayByAddingObjectsFromArray:self.functionButtons];
    for (KeyboardButton *button in buttons) {
        [button addTarget:view action:@selector(buttonDidTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
}

#pragma mark -

- (void)updateKeycaps
{
    NSArray *keycaps = self.keycaps;
    
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < keycaps.count; i++) {
        NSArray *row = keycaps[i];
        for (NSUInteger j = 0; j < row.count; j++) {
            NSArray *col = row[j];
            NSString *title = [col componentsJoinedByString:@"\n"];
            KeyboardButton *button = self.inputButtons[index];
            [button setTitle:title forState:UIControlStateNormal];
            
            index++;
        }
    }
}

- (CGRect)inputButtonFrameForRow:(NSInteger)row column:(NSInteger)column
{
    return CGRectZero;
}

- (void)updateFunctionButtonFrames
{
    
}

- (void)updateButtonLayout
{
    NSArray *keycaps = self.keycaps;
    
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < keycaps.count; i++) {
        NSArray *row = keycaps[i];
        for (NSUInteger j = 0; j < row.count; j++) {
            KeyboardButton *button = self.inputButtons[index];
            
            button.frame = [self inputButtonFrameForRow:i column:j];
            button.hidden = CGRectIsEmpty(button.frame);
            
            button.titleLabel.font = self.buttonTitleFont;
            
            index++;
        }
    }
    
    self.shiftButton.frame = self.shiftButtonFrame;
    [self.shiftButton setImage:self.shiftImage forState:UIControlStateNormal];
    
    self.spaceButton.frame = self.spaceButtonFrame;
    
    self.deleteButton.frame = self.deleteButtonFrame;
    [self.deleteButton setImage:self.deleteImage forState:UIControlStateNormal];
    
    self.returnButton.frame = self.returnButtonFrame;
    [self.returnButton setImage:self.returnImage forState:UIControlStateNormal];
    
    for (KeyboardButton *button in self.functionButtons) {
        button.hidden = CGRectIsEmpty(button.frame);
        button.titleLabel.font = self.buttonTitleFont;
    }
}

- (void)updateShiftButton
{
    if (self.shifted) {
        self.shiftButton.selected = YES;
        [self.shiftButton setImage:self.shiftImage forState:UIControlStateNormal];
        [self.shiftButton setImage:self.highlightedShiftImage forState:UIControlStateSelected];
        [self.shiftButton setImage:self.highlightedShiftImage forState:UIControlStateHighlighted | UIControlStateSelected];
    } else {
        self.shiftButton.selected = NO;
        [self.shiftButton setImage:self.shiftImage forState:UIControlStateNormal];
        [self.shiftButton setImage:nil forState:UIControlStateSelected];
        [self.shiftButton setImage:nil forState:UIControlStateHighlighted | UIControlStateSelected];
    }
}

#pragma mark -

- (void)setMetrics:(KeyboardMetrics)metrics
{
    _metrics = metrics;
    [self updateFunctionButtonFrames];
    [self updateButtonLayout];
}

- (void)setShifted:(BOOL)shifted
{
    _shifted = shifted;
    [self updateShiftButton];
}

#pragma mark -

- (UIFont *)buttonTitleFont
{
    return [UIFont fontWithName:@"HiraKakuProN-W3" size:16.0];;
}

- (UIImage *)shiftImage
{
    if (self.metrics == KeyboardMetricsDefault) {
        return [UIImage imageNamed:@"shift_portrait_phone"];
    } else {
        return [UIImage imageNamed:@"shift_landscape_phone"];
    }
}

- (UIImage *)highlightedShiftImage
{
    if (self.metrics == KeyboardMetricsDefault) {
        return [UIImage imageNamed:@"shift_portrait_phone_highlighted"];
    } else {
        return [UIImage imageNamed:@"shift_landscape_phone_highlighted"];
    }
}

- (UIImage *)shiftLockImage
{
    if (self.metrics == KeyboardMetricsDefault) {
        return [UIImage imageNamed:@"shift_lock_portrait_phone"];
    } else {
        return [UIImage imageNamed:@"shift_lock_landscape_phone"];
    }
}

- (UIImage *)deleteImage
{
    if (self.metrics == KeyboardMetricsDefault) {
        return [UIImage imageNamed:@"delete_portrait_skinny"];
    } else {
        return [UIImage imageNamed:@"delete_landscape_phone"];
    }
}

- (UIImage *)returnImage
{
    return [UIImage imageNamed:@"return_phone"];
}

#pragma mark -

- (NSArray *)keycaps
{
    static NSArray *alphabet;
    if (!alphabet) {
        alphabet = @[
                     @[@[@"Q"], @[@"W"], @[@"E"], @[@"R"], @[@"T"], @[@"Y"], @[@"U"], @[@"I"], @[@"O"], @[@"P"]],
                     @[@[@"A"], @[@"S"], @[@"D"], @[@"F"], @[@"G"], @[@"H"], @[@"J"], @[@"K"], @[@"L"]],
                     @[@[@"Z"], @[@"X"], @[@"C"], @[@"V"], @[@"B"], @[@"N"], @[@"M"]],
                     ];
    }
    
    return alphabet;
}

#pragma mark -

- (KeyboardButton *)whiteButtonWithTitle:(NSString *)title image:(UIImage *)image
{
    UIImage *backgroundImage = [UIImage imageNamed:@"key_white"];
    UIImage *highlightedBackgroundImage = [UIImage imageNamed:@"key_darkgray"];
    KeyboardButton *button = [self buttonWithTitle:title image:image backgroundImage:backgroundImage highlightedBackgroundImage:highlightedBackgroundImage];
    return button;
}

- (KeyboardButton *)grayButtonWithTitle:(NSString *)title image:(UIImage *)image
{
    UIImage *backgroundImage = [UIImage imageNamed:@"key_gray"];
    UIImage *highlightedBackgroundImage = [UIImage imageNamed:@"key_darkgray"];
    KeyboardButton *button = [self buttonWithTitle:title image:image backgroundImage:backgroundImage highlightedBackgroundImage:highlightedBackgroundImage];
    return button;
}

- (KeyboardButton *)darkgrayButtonWithTitle:(NSString *)title image:(UIImage *)image
{
    UIImage *backgroundImage = [UIImage imageNamed:@"key_darkgray"];
    UIImage *highlightedBackgroundImage = [UIImage imageNamed:@"key_white"];
    KeyboardButton *button = [self buttonWithTitle:title image:image backgroundImage:backgroundImage highlightedBackgroundImage:highlightedBackgroundImage];
    return button;
}

- (KeyboardButton *)blueButtonWithTitle:(NSString *)title image:(UIImage *)image
{
    UIImage *backgroundImage = [UIImage imageNamed:@"key_blue"];
    UIImage *highlightedBackgroundImage = [UIImage imageNamed:@"key_white"];
    KeyboardButton *button = [self buttonWithTitle:title image:image backgroundImage:backgroundImage highlightedBackgroundImage:highlightedBackgroundImage];
    return button;
}

- (KeyboardButton *)buttonWithTitle:(NSString *)title image:(UIImage *)image backgroundImage:(UIImage *)backgroundImage highlightedBackgroundImage:(UIImage *)highlightedBackgroundImage
{
    KeyboardButton *button = [KeyboardButton buttonWithType:UIButtonTypeCustom];
    
    button.titleLabel.font = self.buttonTitleFont;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.numberOfLines = 2;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    
    return button;
}

@end

@implementation KeyboardLayoutPhone5

- (CGRect)inputButtonFrameForRow:(NSInteger)row column:(NSInteger)column
{
    if (self.metrics == KeyboardMetricsDefault) {
        CGFloat top = 40.0;
        CGFloat left = 0.0;
        CGFloat width = 32.0;
        CGFloat height = 55.0;
        if (row == 1) {
            left = 16.0;
        } else if (row == 2) {
            left = 48.5;
        }
        return CGRectMake(left + column * width, top + height * row, width, height);
    } else if (self.metrics == KeyboardMetricsLandscape568) {
        CGFloat top = 30.0;
        CGFloat left = 0.0;
        CGFloat width = 56.5;
        CGFloat height = 41.0;
        if (row == 1) {
            left = 28.0;
        } else if (row == 2) {
            left = 83.5;
        }
        return CGRectMake(left + column * width, top + height * row, width, height);
    } else {
        CGFloat top = 30.0;
        CGFloat left = 0.0;
        CGFloat width = 48.0;
        CGFloat height = 41.0;
        if (row == 1) {
            left = 24.0;
        } else if (row == 2) {
            left = 72.0;
        }
        return CGRectMake(left + column * width, top + height * row, width, height);
    }
}

- (void)updateFunctionButtonFrames
{
    if (self.metrics == KeyboardMetricsDefault) {
        CGFloat top = 40.0;
        CGFloat width = 45.5;
        CGFloat height = 55.0;
        
        self.shiftButtonFrame = CGRectMake(0.0, top + height * 2, width, height);
        self.spaceButtonFrame = CGRectMake(width * 2, top + height * 3, width * 2, height);
        self.deleteButtonFrame = CGRectMake(width * 6, top + height * 2, width, height);
        self.returnButtonFrame = CGRectMake(width * 6, top + height * 3, width, height);
    } else if (self.metrics == KeyboardMetricsLandscape568) {
        CGFloat top = 30.0;
        CGFloat height = 41.0;
        
        self.shiftButtonFrame = CGRectMake(0.0, top + height * 2, 84.0, height);
        self.spaceButtonFrame = CGRectMake(139.5, top + height * 3, 56.0 * 4 + 1.5, height);
        self.deleteButtonFrame = CGRectMake(87.0 + 56.0 * 7, top + height * 2, 86.0, height);
        self.returnButtonFrame = CGRectMake(87.0 + 56.0 * 7, top + height * 3, 86.0, height);
    } else {
        CGFloat top = 30.0;
        CGFloat width = 48.0;
        CGFloat height = 41.0;
        
        self.shiftButtonFrame = CGRectMake(0.0, top + height * 2, width, height);
        self.spaceButtonFrame = CGRectMake(width * 2, top + height * 3, width * 5, height);
        self.deleteButtonFrame = CGRectMake(width * 9, top + height * 2, width, height);
        self.returnButtonFrame = CGRectMake(width * 9, top + height * 3, width, height);
    }
}

@end

@implementation KeyboardLayoutPhone6

- (CGRect)inputButtonFrameForRow:(NSInteger)row column:(NSInteger)column
{
    if (self.metrics == KeyboardMetricsDefault) {
        CGFloat top = 40.0;
        CGFloat left = 0.0;
        CGFloat width = 37.5;
        CGFloat height = 55.0;
        if (row == 1) {
            left = 19.0;
        } else if (row == 2) {
            left = 56.5;
        }
        return CGRectMake(left + column * width, top + height * row, width, height);
    } else {
        CGFloat top = 30.0;
        CGFloat left = 56.0;
        CGFloat width = 55.5;
        CGFloat height = 41.0;
        if (row == 1) {
            left = 84.0;
        } else if (row == 2) {
            left = 139.5;
        }
        return CGRectMake(left + column * width, top + height * row, width, height);
    }
}

- (void)updateFunctionButtonFrames
{
    if (self.metrics == KeyboardMetricsDefault) {
        CGFloat top = 40.0;
        CGFloat width = 47.0;
        CGFloat height = 55.0;
        
        self.shiftButtonFrame = CGRectMake(0.0, top + height * 2, width, height);
        self.spaceButtonFrame = CGRectMake(width * 2, top + height * 3, width * 3, height);
        self.deleteButtonFrame = CGRectMake(width * 7, top + height * 2, width, height);
        self.returnButtonFrame = CGRectMake(width * 7, top + height * 3, width, height);
    } else {
        CGFloat top = 30.0;
        CGFloat left = 139.5;
        CGFloat height = 41.0;
        
        self.shiftButtonFrame = CGRectMake(56.0, top + height * 2, 84.0, height);
        self.spaceButtonFrame = CGRectMake(left, top + height * 3, 55.5 * 6, height);
        self.deleteButtonFrame = CGRectMake(139.0 + 55.5 * 7, top + height * 2, 82.0, height);
        self.returnButtonFrame = CGRectMake(left + 55.5 * 6, top + height * 3, 111.0, height);
    }
}

@end

@implementation KeyboardLayoutPhone6Plus

- (CGRect)inputButtonFrameForRow:(NSInteger)row column:(NSInteger)column
{
    if (self.metrics == KeyboardMetricsDefault) {
        CGFloat top = 40.0;
        CGFloat left = 0.0;
        CGFloat width = 41.4;
        CGFloat height = 57.0;
        if (row == 1) {
            left = 20.5;
        } else if (row == 2) {
            left = 62.0;
        }
        return CGRectMake(left + column * width, top + height * row, width, height);
    } else {
        CGFloat top = 30.0;
        CGFloat left = 61.0;
        CGFloat width = 61.0;
        CGFloat height = 41.0;
        if (row == 1) {
            left = 91.5;
        } else if (row == 2) {
            left = 152.5;
        }
        return CGRectMake(left + column * width, top + height * row, width, height);
    }
}

- (void)updateFunctionButtonFrames
{
    if (self.metrics == KeyboardMetricsDefault) {
        CGFloat top = 40.0;
        CGFloat width = 51.7;
        CGFloat height = 57.0;
        
        self.shiftButtonFrame = CGRectMake(0.0, top + height * 2, width, height);
        self.spaceButtonFrame = CGRectMake(width * 2, top + height * 3, width * 3, height);
        self.deleteButtonFrame = CGRectMake(width * 7, top + height * 2, width, height);
        self.returnButtonFrame = CGRectMake(width * 7, top + height * 3, width, height);
    } else {
        CGFloat top = 30.0;
        CGFloat left = 152.5;
        CGFloat width = 61.0;
        CGFloat height = 41.0;
        
        self.shiftButtonFrame = CGRectMake(width, top + height * 2, 92.0, height);
        self.spaceButtonFrame = CGRectMake(left, top + height * 3, width * 7, height);
        self.deleteButtonFrame = CGRectMake(left + width * 7, top + height * 2, 92.0, height);
        self.returnButtonFrame = CGRectMake(left + width * 7, top + height * 3, 92.0, height);
    }
}

@end
