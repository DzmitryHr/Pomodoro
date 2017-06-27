//
//  TimerViewController.h
//  PomodoroTech
//
//  Created by Kronan on 5/11/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TasksViewController.h"
#import "TasksDataManager.h"
#import "CoreData.h"
#import "CoordinatorDelegate.h"


@class TimerViewController;

@protocol TimerVCNavigation <NSObject>
@required
- (void)goToTasksVCFromTimerVC:(TimerViewController *)timerVC;

@end


@protocol TimerVCDataSource <NSObject>
@required
- (CDUser *)currentUserForTimerVC:(TimerViewController *)timerVC;
- (CDTask *)currentTaskForTimerVC:(TimerViewController *)timerVC;
- (NSString *)currentStageForTimerVC:(TimerViewController *)timerVC;

- (void)changeDurationPomodor:(NSTimeInterval)pomodorDuration;
- (void)runWorkCycleFromTimerVC;
- (void)stopWorkCycleFromTimerVC;

@end


@interface TimerViewController : UIViewController <CoordinatorDelegate>

@property (nonatomic, weak) id<TimerVCNavigation> navigationCoordinator;
@property (nonatomic, strong) id<TimerVCDataSource> dataSource;


@end
