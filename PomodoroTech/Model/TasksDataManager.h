//
//  TasksDataManager.h
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TasksViewController.h"

#import "TaskDataManagerDelegate.h"


@interface TasksDataManager : NSObject <TasksViewControllerDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id<TasksDataManagerDelegate> delegate;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
