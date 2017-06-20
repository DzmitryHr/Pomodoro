//
//  AddTaskViewController.m
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#define NUMBER_OF_COMPONENTS_IN_PICKERVIEW  1;
#define MAX_NUMBER_OF_POMODOR   100;

#import "AddTaskViewController.h"

@interface AddTaskViewController () 

@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *numberOfPomodorPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *numberPicker;

@property (nonatomic, strong, readwrite) NSString *taskName;
@property (nonatomic, assign, readwrite) NSInteger amountOfPomodors;


@end


@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numberPicker.delegate = self;
    self.numberPicker.dataSource = self;
    
//    [self.taskNameTextField becomeFirstResponder];
}


- (void)createNewTask
{
    if (self.taskNameTextField.text){
        self.taskName = self.taskNameTextField.text;
        
        CDUser *currentUser = [self.coordinator giveCurrentUser];
        
        [self.coreData createTaskInMainContextWithName:self.taskName forUser:currentUser];
    }
}


#pragma mark - IBAction

- (IBAction)addTaskButton:(UIButton *)sender
{
    [self createNewTask];
    
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark - PickerView DataSource


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return NUMBER_OF_COMPONENTS_IN_PICKERVIEW;
}


// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return MAX_NUMBER_OF_POMODOR;
}


#pragma mark - PickerView Delegate


- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
//    NSLog(@"number of component = %ld", (long)row + 1);
    return [NSString stringWithFormat:@"%ld", (long)row + 1];
}


- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    self.amountOfPomodors = row +1;
    NSLog(@"selected = %ld", row + 1);
}


#pragma mark - Life Cicle VC

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

@end
