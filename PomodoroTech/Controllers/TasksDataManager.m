//
//  TasksDataManager.m
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TasksDataManager.h"

@interface TasksDataManager() <TaskViewControllerDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TasksDataManager

#pragma mark - init


// designated initializer
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [super init];
    if (self) {
        self.managedObjectContext = managedObjectContext;
    }
    return self;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController){
        return _fetchedResultsController;
    }
    
    NSString *entityName = @"CDTask";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:YES]]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    [_fetchedResultsController performFetch:&error];
    
    if (error){
        NSLog(@"- Unable to performFetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    return _fetchedResultsController;
}


#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.delegate dataWillChangeForTasksDataManager:self];
//    [self.tableViewTasks beginUpdates];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.delegate dataDidChangeForTasksDataManager:self];
//    [self.tableViewTasks endUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.delegate tasksDataManager:self
                                atIndexPath:indexPath
                                 changeType:insertData
                               newIndexPath:newIndexPath];
            /*
            [self.tableViewTasks insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
             */
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.delegate tasksDataManager:self
                                atIndexPath:indexPath
                                 changeType:deleteData
                               newIndexPath:newIndexPath];
            /*
            [self.tableViewTasks deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
             */
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self.delegate tasksDataManager:self
                                atIndexPath:indexPath
                                 changeType:updateData
                               newIndexPath:newIndexPath];
            /*
            [self configureCell:(TasksViewCell *)[self.tableViewTasks cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
             */
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.delegate tasksDataManager:self
                                atIndexPath:indexPath
                                 changeType:moveData
                               newIndexPath:newIndexPath];
            /*
            [self.tableViewTasks deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewTasks insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
             */
            break;
        }
    }
}


#pragma mark - <TasksViewControllerDataSource>

- (NSInteger)numberOfDataForTasksViewController:(TasksViewController *)taskViewController
{
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:0];

    return [sectionInfo numberOfObjects];
}


- (NSManagedObject *)tasksViewController:(TasksViewController *)taskViewController
                                forIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return record;
}
@end
