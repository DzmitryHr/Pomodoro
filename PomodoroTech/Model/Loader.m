//
//  Loader.m
//  PomodoroTech
//
//  Created by Kronan on 5/24/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "Loader.h"


@interface Loader()

@property (nonatomic, strong) NSUserDefaults *defaultSetting;

@end


@implementation Loader

static const NSTimeInterval MIN = 60;
static const NSTimeInterval DEFAULT_DURATION_POMODOR = 25 * MIN;
static const NSTimeInterval DEFAULT_DURATION_SHORT_BREAK = 5 * MIN;
static const NSTimeInterval DEFAULT_DURATION_LONG_BREAK = 15 * MIN;
static const NSTimeInterval AMOUNT_POMODOR_FOR_LONG_BREAK = 4;

NSString * const DEFAULT_USER = @"defaultUser";
NSString * const DEFAULT_TASK = @"detaultTask";

NSString * const keyDurationPomodor = @"durationPomodor";
NSString * const keyDurationShortBreak = @"durationShortBreak";
NSString * const keyDurationLongBreak = @"durationLongBreak";
NSString * const keyAmountPomodorsForLongBreak = @"amountPomodorsForLongBreak";

NSString * const keyDefaultUser = @"defaultUser";
NSString * const keyDefaultTask = @"detaultTask";


- (instancetype)init
{
    self = [super init];
    
    if (self) {
    
        NSUserDefaults *defaultSetting = [NSUserDefaults standardUserDefaults];
        
        [defaultSetting registerDefaults:@{
                                             keyDurationPomodor : @(DEFAULT_DURATION_POMODOR),
                                             keyDurationShortBreak : @(DEFAULT_DURATION_SHORT_BREAK),
                                             keyDurationLongBreak : @(DEFAULT_DURATION_LONG_BREAK),
                                             keyAmountPomodorsForLongBreak : @(AMOUNT_POMODOR_FOR_LONG_BREAK),
                                             keyDefaultUser : DEFAULT_USER,
                                             keyDefaultTask : DEFAULT_TASK
                                             }];
        
        self.lastDurationPomodor = [defaultSetting doubleForKey:keyDurationPomodor];
        self.lastDurationShortBreak = [defaultSetting doubleForKey:keyDurationShortBreak];
        self.lastDurationLongBreak = [defaultSetting doubleForKey:keyDurationLongBreak];
        self.lastAmountPomodorsForLongBreak = [defaultSetting doubleForKey:keyAmountPomodorsForLongBreak];
        
        self.lastUserLogin = [defaultSetting objectForKey:keyDefaultUser];
        self.lastTaskName = [defaultSetting objectForKey:keyDefaultTask];
        
        self.defaultSetting = defaultSetting;
    }
    
    return self;
}

- (void)setLastDurationPomodor:(NSTimeInterval)lastDurationPomodor
{
    _lastDurationPomodor = lastDurationPomodor;
    
    [self saveSettings];
}

- (void)saveSettings
{
    [self.defaultSetting setDouble:self.lastDurationPomodor forKey:keyDurationPomodor];
    [self.defaultSetting setDouble:self.lastDurationShortBreak forKey:keyDurationShortBreak];
    [self.defaultSetting setDouble:self.lastDurationLongBreak forKey:keyDurationLongBreak];
    [self.defaultSetting setDouble:self.lastAmountPomodorsForLongBreak forKey:keyAmountPomodorsForLongBreak];
    
    [self.defaultSetting setObject:self.lastUserLogin forKey:keyDefaultUser];
    [self.defaultSetting setObject:self.lastTaskName forKey:keyDefaultTask];
}
@end
