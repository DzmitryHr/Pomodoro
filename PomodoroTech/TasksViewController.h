//
//  TasksViewController.h
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataController.h"

@interface TasksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableViewTasks;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
