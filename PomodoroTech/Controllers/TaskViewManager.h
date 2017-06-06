//
//  TaskViewManager.h
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TasksViewController.h"

@interface TaskViewManager : NSObject <TaskViewControllerDataSource>

@property (nonatomic, strong) TasksViewController *tasksViewController;

@end
