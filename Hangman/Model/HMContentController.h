//
//  HMContentController.h
//  Hangman
//
//  Created by Ray Wenderlich on 7/12/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const HMContentControllerCurrentThemeDidChangeNotification;
extern NSString *const HMContentControllerCurrentWordsDidChangeNotification;
extern NSString *const HMContentControllerHintsDidChangeNotification;
extern NSString *const HMContentControllerUnlockedThemesDidChangeNotification;
extern NSString *const HMContentControllerUnlockedWordsDidChangeNotification;

@class HMTheme;
@class HMWords;

@interface HMContentController : NSObject

+ (HMContentController *)sharedInstance;

- (NSArray *) unlockedThemes;
- (NSArray *) unlockedWords;

@property (nonatomic, strong) HMTheme * currentTheme;
@property (nonatomic, strong) HMWords * currentWords;
@property (nonatomic, assign) NSInteger hints;

- (void)unlockThemeWithDirURL:(NSURL *)dirURL;
- (void)unlockWordsWithDirURL:(NSURL *)dirURL;
- (void)unlockContentWithDirURL:(NSURL *)dirURL;

@end