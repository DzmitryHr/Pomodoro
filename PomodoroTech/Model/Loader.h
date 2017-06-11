//
//  Configurator.h
//  PomodoroTech
//
//  Created by Kronan on 5/24/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Loader : NSObject

@property (nonatomic, assign) NSTimeInterval lastDurationPomodor;
@property (nonatomic, assign) NSTimeInterval lastDurationShortBreak;
@property (nonatomic, assign) NSTimeInterval lastDurationLongBreak;
@property (nonatomic, assign) NSInteger lastAmountPomodorsForLongBreak;

@property (nonatomic, strong) NSString *lastUserName;
@property (nonatomic, strong) NSString *lastTaskName;

- (void)saveSettings;

@end
