//
//  CoordinatorController.h
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataController.h"
#import "Loader.h"

@class CoordinatorController;


@protocol CoordinatorControllerDelegate<NSObject>
@required
- (void)coordinatorController:(CoordinatorController *)coordinator timerDidChanged:(NSTimeInterval)time;
@end


@interface CoordinatorController : NSObject

@property (nonatomic, weak) id <CoordinatorControllerDelegate> delegate;

@property (nonatomic, readonly, assign) NSTimeInterval uiTimer;

// designated initializer
- (instancetype)initWithLoader:(Loader *)configurator coreData:(CoreDataController *)coreData;

- (NSInteger)giveCurentDurationPomodor;
- (void)changeCurrentDurationPomodor:(NSInteger)newCurrentDurationPomodor;

- (CDUser *)giveCurrentUser;
- (CDTask *)giveCurrentTask;

- (NSString *)giveCurrentStage;


// run count duration pomodor (WORK) and run count Long or Short BREAK (Break)
- (void)runWorkCycle;

- (void)stopWorkCycle;


@end
