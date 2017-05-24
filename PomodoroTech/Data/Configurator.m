//
//  Configurator.m
//  PomodoroTech
//
//  Created by Kronan on 5/24/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "Configurator.h"

@interface Configurator()

@property (nonatomic, strong) NSUserDefaults *defaultTimeSetting;

@end


@implementation Configurator

static const NSTimeInterval MIN = 60;
static const NSTimeInterval DEFAUL_DURATION_POMODOR = 25 * MIN;
static const NSTimeInterval DEFAUL_DURATION_SHORT_BREAK = 5 * MIN;
static const NSTimeInterval DEFAUL_DURATION_LONG_BREAK = 15 * MIN;
static const NSTimeInterval AMOUNT_POMODOR_FOR_LONG_BREAK = 4;

NSString * const titleDurationPomodor = @"durationPomodor";
NSString * const titleDurationShortBreak = @"durationShortBreak";
NSString * const titleDurationLongBreak = @"durationLongBreak";
NSString * const titleAmountPomodorsForLongBreak = @"amountPomodorsForLongBreak";

- (instancetype)init
{
    self = [super init];
    
    if (self) {
    
        NSUserDefaults *defaultTimeSetting = [NSUserDefaults standardUserDefaults];
        
        [defaultTimeSetting doubleForKey:titleDurationPomodor] ? nil : [defaultTimeSetting setDouble:DEFAUL_DURATION_POMODOR forKey:titleDurationPomodor];
        
        [defaultTimeSetting doubleForKey:titleDurationShortBreak] ? nil : [defaultTimeSetting setDouble:DEFAUL_DURATION_SHORT_BREAK forKey:titleDurationShortBreak];
        
        [defaultTimeSetting doubleForKey:titleDurationLongBreak] ? nil : [defaultTimeSetting setDouble:DEFAUL_DURATION_LONG_BREAK forKey:titleDurationShortBreak];
        
        [defaultTimeSetting doubleForKey:titleAmountPomodorsForLongBreak] ? nil : [defaultTimeSetting setDouble:AMOUNT_POMODOR_FOR_LONG_BREAK forKey:titleAmountPomodorsForLongBreak];
        
        self.durationPomodor = [defaultTimeSetting doubleForKey:titleDurationPomodor];
        self.durationShortBreak = [defaultTimeSetting doubleForKey:titleDurationShortBreak];
        self.durationLongBreak = [defaultTimeSetting doubleForKey:titleDurationLongBreak];
        self.amountPomodorsForLongBreak = [defaultTimeSetting doubleForKey:titleAmountPomodorsForLongBreak];
        
        self.defaultTimeSetting = defaultTimeSetting;
        
        [self.defaultTimeSetting synchronize];
        
    }
    
    return self;
}

- (void)setDurationPomodor:(NSTimeInterval)pomodorDuration
{
    _durationPomodor = pomodorDuration;
    
    [self.defaultTimeSetting setDouble:pomodorDuration forKey:titleDurationPomodor];
}

- (void)setDurationShortBreak:(NSTimeInterval)durationShortBreak
{
    _durationShortBreak = durationShortBreak;
    
    [self.defaultTimeSetting setDouble:durationShortBreak forKey:titleDurationShortBreak];
}

- (void)setDurationLongBreak:(NSTimeInterval)durationLongBreak
{
    _durationLongBreak = durationLongBreak;
    
    [self.defaultTimeSetting setDouble:durationLongBreak forKey:titleDurationLongBreak];
}

- (void)setAmountPomodorsForLongBreak:(NSInteger)amountPomodorsForLongBreak
{
    _amountPomodorsForLongBreak = amountPomodorsForLongBreak;
    
    [self.defaultTimeSetting setDouble:amountPomodorsForLongBreak forKey:titleAmountPomodorsForLongBreak];
}

@end
