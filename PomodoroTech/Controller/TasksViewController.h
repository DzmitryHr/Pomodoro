//
//  TasksViewController.h
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TasksViewCell.h"
#import "TaskDataManagerDelegate.h"
#import "CoreData.h"


@class TasksViewController;

@protocol TasksViewControllerDataSource <NSObject>
@required
- (NSInteger)numberOfDataForTasksViewController:(TasksViewController *)taskViewController;

- (CDTask *)tasksViewController:(TasksViewController *)taskViewController
                                forIndexPath:(NSIndexPath *)indexPath;
@end


@protocol TasksVCDelegate <NSObject>
@required
- (void)tasksVC:(TasksViewController *)tasksVC changeCurrentTask:(NSManagedObject *)task;

- (void)tasksVC:(TasksViewController *)tasksVC didPushDelButtonInCellWithTask:(NSManagedObject *)task;

- (void)tasksVC:(TasksViewController *)tasksVC didPushEditButtonInCellWithTask:(NSManagedObject *)task;

@end


@protocol TasksVCNavigation <NSObject>
@required
- (void)goToAddTasksVCformTasksVC:(TasksViewController *)tasksVC;
- (void)goToBackFromTasksVC:(TasksViewController *)tasksVC;

@end

@interface TasksViewController : UIViewController <UITableViewDataSource,
                                                   UITableViewDelegate,
                                                   TasksDataManagerDelegate>

@property (nonatomic, strong) id <TasksViewControllerDataSource> dataSource;
@property (nonatomic, weak) id <TasksVCDelegate> delegate;
@property (nonatomic, weak) id<TasksVCNavigation> navigationCoordinator;

@property (weak, nonatomic) IBOutlet UITableView *tableViewTasks;

@end
