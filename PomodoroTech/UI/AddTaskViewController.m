//
//  AddTaskViewController.m
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "AddTaskViewController.h"

@interface AddTaskViewController () 

@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *numberOfPomodorPicker;

@end


@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numberOfPomodorPicker.delegate = self;
    self.numberOfPomodorPicker.dataSource = self;
    
}



@end
