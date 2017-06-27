//
//  TasksViewController.m
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TasksViewController.h"


@interface TasksViewController ()

@end


@implementation TasksViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;

// ??? maybe not need ???
//    [self.tableViewTasks reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}


# pragma mark - IBAction

- (IBAction)newTaskBarButton:(UIBarButtonItem *)sender
{
    [self.navigationCoordinator goToAddTasksVCformTasksVC:self];
}


#pragma mark - Private

- (void)configureCell:(TasksViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *dataObject = [self.dataSource tasksViewController:self forIndexPath:indexPath];
    
    cell.taskLabel.text = [dataObject valueForKey:@"name"];
    cell.amtPomodorLabel.text = [NSString stringWithFormat:@"%@",[dataObject valueForKey:@"createTime"]];
}


#pragma mark - DataSource: tableView

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


# pragma mark - Delegate: tableView

// change current task
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *task = [self.dataSource tasksViewController:self forIndexPath:indexPath];
    
    [self.delegate tasksVC:self changeCurrentTask:task];
}



#pragma mark - Delegate: TaskDataManager

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



@end
