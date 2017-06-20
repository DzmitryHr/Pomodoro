//
//  TasksViewController.h
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreData.h"
#import "TasksViewCell.h"
#import "AddTaskViewController.h"
#import "Coordinator.h"
//#import "TasksDataManager.h"
#import "TasksDataManagerProtocol.h"

@class TasksViewController;

@protocol TasksViewControllerDataSource <NSObject>
@required
- (NSInteger)numberOfDataForTasksViewController:(TasksViewController *)taskViewController;

- (CDTask *)tasksViewController:(TasksViewController *)taskViewController
                                forIndexPath:(NSIndexPath *)indexPath;
@end


@interface TasksViewController : UIViewController <UITableViewDataSource,
                                                   UITableViewDelegate>

//@interface TasksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,TasksDataManagerDelegate>


@property (strong, nonatomic) id <TasksViewControllerDataSource> dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableViewTasks;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) AddTaskViewController *addTaskViewController;

@property (strong, nonatomic) Coordinator *coordinator;

@end
