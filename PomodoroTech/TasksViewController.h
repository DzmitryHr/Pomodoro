//
//  TasksViewController.h
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataController.h"
#import "TasksViewCell.h"
/*
@protocol TaskViewControllerDelegate <NSObject>
@optional
<#methods#>

@end

*/
@class TasksViewController;

@protocol TaskViewControllerDataSource <NSObject>
@required
- (NSInteger)numberOfDataForTasksViewController:(TasksViewController *)taskViewController;

// ??? what to return? ???
- (NSManagedObject *)tasksViewController:(TasksViewController *)taskViewController
                                forIndexPath:(NSIndexPath *)indexPath;
@end


@interface TasksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>


@property (weak, nonatomic) id <TaskViewControllerDataSource> dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableViewTasks;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
