//
//  TasksViewController.m
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TasksViewController.h"
#import "TasksViewCell.h"

@interface TasksViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end


@implementation TasksViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}


# warning missing DI

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext){
        CoreDataController *coreDataController = [[CoreDataController alloc] init];
        _managedObjectContext = coreDataController.contextPomodoro;
    }
    return _managedObjectContext;
}


# pragma mark - action

- (IBAction)tapBackButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


# pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return  [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableCellIdentifier = @"TASKS_CELL";
    TasksViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier
                                                          forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)configureCell:(TasksViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.taskLabel.text = [record valueForKey:@"name"];
    cell.amtPomodorLabel.text = [NSString stringWithFormat:@"%@",[record valueForKey:@"createTime"]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *) fetchedResultsController
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
        NSLog(@"Unable to performFetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }

    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableViewTasks beginUpdates];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableViewTasks endUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableViewTasks insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableViewTasks deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(TasksViewCell *)[self.tableViewTasks cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableViewTasks deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewTasks insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

@end
