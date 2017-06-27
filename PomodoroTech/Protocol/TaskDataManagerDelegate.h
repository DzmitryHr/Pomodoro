//
//  TaskDataManagerDelegate.h
//  PomodoroTech
//
//  Created by Kronan on 6/21/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

typedef NS_ENUM(NSInteger, ChangeDataType)
{
    insertData = 0,
    deleteData,
    updateData,
    moveData
};


#import <Foundation/Foundation.h>


@class TasksDataManager;

@protocol TasksDataManagerDelegate <NSObject>

- (void)dataWillChangeForTasksDataManager:(TasksDataManager *)tasksDataManager;
- (void)dataDidChangeForTasksDataManager:(TasksDataManager *)tasksDataManager;
- (void)tasksDataManager:(TasksDataManager *)tasksDataManager
             atIndexPath:(NSIndexPath *)indexPath
              changeType:(ChangeDataType)type
            newIndexPath:(NSIndexPath *)newIndexPath;

@end
