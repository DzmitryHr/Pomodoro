//
//  Timer.m
//  PomodoroTech
//
//  Created by Kronan on 5/11/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "Timer.h"


@interface Timer()

@property (nonatomic, assign, getter=isWorkTimer, readwrite) BOOL workTimer;

@end


@implementation Timer

-(void)updateTimerDown
{
    
}

+(void)startTimerWithDuration:(NSInteger)durarion
{
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"mm:ss"];
        NSLog(@"%@", [dateFormatter stringFromDate:[NSDate date]]);
    
    }];
    
}

@end
