//
//  TasksViewController.m
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TasksViewController.h"


@interface TasksViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UINavigationItem *tasksNavigationItem;

@end


@implementation TasksViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}


# pragma mark - action

- (IBAction)tapBackButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


# pragma mark - tableView

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
    
    //return [self.dataSource tasksViewController:self configureCell:cell atIndexPath:indexPath]
    return cell;
}


- (void)configureCell:(TasksViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *dataObject = [self.dataSource tasksViewController:self forIndexPath:indexPath];
    
    cell.taskLabel.text = [dataObject valueForKey:@"name"];
    cell.amtPomodorLabel.text = [NSString stringWithFormat:@"%@",[dataObject valueForKey:@"createTime"]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self.tasksNavigationItem setHidesBackButton:NO];
}

@end
