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
#import "TasksViewController.h"
#import "TimerViewController.h"
#import "TasksDataManager.h"

#import "CoordinatorDelegate.h"


@interface Coordinator : NSObject <AddTaskVCDelegate,
                                   TasksVCDelegate,
                                   TasksVCNavigation,
                                   TimerVCNavigation,
                                   TimerVCDataSource>

@property (nonatomic, weak) id<CoordinatorDelegate> delegate;

@property (nonatomic, readonly, assign) NSTimeInterval uiTimer;

@property (nonatomic, strong, readonly) CoreData *coreData;

// designated initializer
- (instancetype)initWithLoader:(Loader *)loader coreData:(CoreData *)coreData delegate:(id)delegate;


// current Objects
- (NSInteger)giveCurentDurationPomodor;

- (void)changeCurrentTask:(CDTask *)task;

@end
