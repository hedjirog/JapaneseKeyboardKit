//
//  InputManager.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "InputManager.h"
#import "InputCandidate.h"

@interface InputManager ()

@property (nonatomic, readwrite) NSArray *candidates;
@property (nonatomic) NSOperationQueue *networkQueue;

@end

@implementation InputManager

- (id)init
{
    self = [super init];
    if (self) {
        self.networkQueue = [[NSOperationQueue alloc] init];
        self.networkQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

- (void)requestCandidatesForInput:(NSString *)input
{
    [self.networkQueue cancelAllOperations];
    
    NSString *encodedText =[input stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/transliterate?langpair=ja-Hira%%7Cja&text=%@", encodedText]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    request.HTTPShouldUsePipelining = YES;
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSMutableArray *candidates = [[NSMutableArray alloc] init];
            
            NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            for (NSArray *result in results) {
                NSString *text = result.firstObject;
                NSArray *list = result.lastObject;
                for (NSString *candidate in list) {
                    [candidates addObject:[[InputCandidate alloc] initWithInput:text candidate:candidate]];
                }
                
                self.candidates = candidates;
                
                break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate inputManager:self didCompleteWithCandidates:self.candidates];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate inputManager:self didFailWithError:connectionError];
            });
        }
    }];
}

@end
