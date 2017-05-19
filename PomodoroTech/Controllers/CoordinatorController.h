//
//  CoordinatorController.h
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataController.h"

@interface CoordinatorController : NSObject

//@property (nonatomic, assign) NSInteger durationPomodoro;
//@property (nonatomic, assign) NSInteger durationLongBreak;
//@property (nonatomic, assign) NSInteger durationShortBreak;

//@property (nonatomic, strong) CDUser *user;
//@property (nonatomic, strong) CDTask *task;
//@property (nonatomic, strong) CDPomodor *pomodor;
//@property (nonatomic, strong) CDCondition *condition;

+ (instancetype)sharedInstance;

- (NSInteger)giveCurentDurationPomodor;
- (void)changeCurrentDurationPomodor:(NSInteger)newCurrentDurationPomodor;

- (CDUser *)giveCurrentUser;
- (CDTask *)giveCurrentTask;

// run count duration pomodor (WORK) and run count Long or Short BREAK (Break)
- (void)runWorkCycle;

@end
