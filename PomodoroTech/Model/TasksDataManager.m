//
//  TasksDataManager.m
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TasksDataManager.h"

@interface TasksDataManager() 

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
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]];
    
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


#pragma mark - <fetchedResultsControllerDelegate> 

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // tableView begin update
    [self.delegate dataWillChangeForTasksDataManager:self];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // tableView end update
    [self.delegate dataDidChangeForTasksDataManager:self];
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
            
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.delegate tasksDataManager:self
                                atIndexPath:indexPath
                                 changeType:deleteData
                               newIndexPath:newIndexPath];
            
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self.delegate tasksDataManager:self
                                atIndexPath:indexPath
                                 changeType:updateData
                               newIndexPath:newIndexPath];
           
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.delegate tasksDataManager:self
                                atIndexPath:indexPath
                                 changeType:moveData
                               newIndexPath:newIndexPath];
           
            break;
        }
    }
}


#pragma mark - DataSource: TasksViewControllerDataSource

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
