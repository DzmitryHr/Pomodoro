//
//  TaskViewManager.m
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TaskViewManager.h"

@implementation TaskViewManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self.tasksViewController setDataSource:self];
        
    }
    return self;
}

#pragma mark - <TaskViewControllerDataSource>

- (NSInteger)numberOfRowsForTasksViewController:(TasksViewController *)taskViewController
{
    NSLog(@"TaskViewManager - numerOfRows");
    return nil;
}

- (UITableViewCell *)tasksViewController:(TasksViewController *)taskViewController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"TaskViewManager - configureCell atIndexPath");
    return nil;
}

@end
