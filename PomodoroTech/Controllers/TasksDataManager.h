//
//  TasksDataManager.h
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TasksViewController.h"

typedef NS_ENUM(NSInteger, ChangeDataType)
{
    insertData = 0,
    deleteData,
    updateData,
    moveData
};

@class TasksDataManager;

@protocol TasksDataManagerDelegate <NSObject>

- (void)dataWillChangeForTasksDataManager:(TasksDataManager *)tasksDataManager;
- (void)dataDidChangeForTasksDataManager:(TasksDataManager *)tasksDataManager;
- (void)tasksDataManager:(TasksDataManager *)tasksDataManager
             atIndexPath:(NSIndexPath *)indexPath
              changeType:(ChangeDataType)type
            newIndexPath:(NSIndexPath *)newIndexPath;


@end


@interface TasksDataManager : NSObject

@property (nonatomic, weak) id<TasksDataManagerDelegate> delegate;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
