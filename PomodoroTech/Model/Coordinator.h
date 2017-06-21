//
//  Coordinator.h
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreData.h"
#import "Loader.h"

#import "AddTaskViewController.h"


@class Coordinator;

@protocol CoordinatorControllerDelegate<NSObject>

@required
- (void)coordinatorController:(Coordinator *)coordinator timerDidChanged:(NSTimeInterval)time;

@end


@interface Coordinator : NSObject <AddTaskVCDelegate>

@property (nonatomic, weak) id<CoordinatorControllerDelegate> delegate;

@property (nonatomic, readonly, assign) NSTimeInterval uiTimer;


// designated initializer
- (instancetype)initWithLoader:(Loader *)loader coreData:(CoreData *)coreData;


// current Objects
- (NSInteger)giveCurentDurationPomodor;
- (void)changeCurrentDurationPomodor:(NSInteger)newCurrentDurationPomodor;

- (CDUser *)giveCurrentUser;
- (CDTask *)giveCurrentTask;

- (NSString *)giveCurrentStage;

- (void)changeCurrentTask:(CDTask *)task;

// run count Work Cycle:
// duration pomodor (WORK) and run count Long or Short BREAK (Break)
- (void)runWorkCycle;

- (void)stopWorkCycle;


@end
