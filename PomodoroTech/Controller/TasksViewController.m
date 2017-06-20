//
//  TasksViewController.m
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TasksViewController.h"


@interface TasksViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@end


@implementation TasksViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}


# pragma mark - action

- (IBAction)newTaskBarButton:(UIBarButtonItem *)sender
{
    [self.navigationController pushViewController:self.addTaskViewController animated:NO];
}

# pragma mark - tableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource numberOfDataForTasksViewController:self];
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
    NSManagedObject *dataObject = [self.dataSource tasksViewController:self forIndexPath:indexPath];
    
    cell.taskLabel.text = [dataObject valueForKey:@"name"];
    cell.amtPomodorLabel.text = [NSString stringWithFormat:@"%@",[dataObject valueForKey:@"createTime"]];
}

// change current task
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *task = [self.dataSource tasksViewController:self forIndexPath:indexPath];
    
    [self.coordinator changeCurrentTask:(CDTask*)task];
    
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - TaskDataManager Delegate

- (void)dataWillChangeForTasksDataManager:(TasksDataManager *)tasksDataManager
{
    [self.tableViewTasks beginUpdates];
}


- (void)dataDidChangeForTasksDataManager:(TasksDataManager *)tasksDataManager
{
    [self.tableViewTasks endUpdates];
}


- (void)tasksDataManager:(TasksDataManager *)tasksDataManager
             atIndexPath:(NSIndexPath *)indexPath
              changeType:(ChangeDataType)type
            newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case insertData: {
            
            [self.tableViewTasks insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case deleteData: {
            
            [self.tableViewTasks deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case updateData: {
            
            [self configureCell:(TasksViewCell *)[self.tableViewTasks cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            
            break;
        }
        case moveData: {

            [self.tableViewTasks deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewTasks insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
    }
}
*/

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableViewTasks reloadData];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

@end
