//
//  TimerViewController.h
//  PomodoroTech
//
//  Created by Kronan on 5/11/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coordinator.h"
#import "TasksViewController.h"


@interface TimerViewController : UIViewController

@property (nonatomic, strong) Coordinator *coordinator;

@property (nonatomic, strong) TasksViewController *tasksViewController;

@end
