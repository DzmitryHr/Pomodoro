//
//  Configurator.h
//  PomodoroTech
//
//  Created by Kronan on 5/24/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configurator : NSObject

@property (nonatomic, assign) NSTimeInterval durationPomodor;
@property (nonatomic, assign) NSTimeInterval durationShortBreak;
@property (nonatomic, assign) NSTimeInterval durationLongBreak;
@property (nonatomic, assign) NSInteger amountPomodorsForLongBreak;

@end
