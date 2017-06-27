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
@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet UIButton *addTaskButton;

@property (nonatomic, strong, readwrite) NSString *taskName;
@property (nonatomic, assign, readwrite) NSInteger amountOfPomodors;

@end


@implementation AddTaskViewController

#pragma mark - Life Cicle VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numberOfPomodorPicker.delegate = self;
    self.numberOfPomodorPicker.dataSource = self;
    
    [self.taskNameTextField becomeFirstResponder];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.contentScroll.contentSize = self.contentScroll.frame.size;
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


#pragma mark - IBAction

- (IBAction)addTaskButton:(UIButton *)sender
{
    [self createNewTask];
    
    //[self.delegate popVCfromVC:self];
    [self.navigationCoordinator popVCfromVC:self];
}


- (IBAction)hideKeyboardField:(UITextField *)sender
{
    [self hideKeyboard];
}


#pragma mark - Private

- (void)createNewTask
{
    if (self.taskNameTextField.text && self.taskNameTextField.text.length > 0){
        self.taskName = self.taskNameTextField.text;
        
        [self.delegate vc:self createNewTaskWithTaskName:self.taskName andAmountOfPomodors:self.amountOfPomodors];
    }
}


- (void)hideKeyboard
{
    //[self.view endEditing:YES];
    [self.taskNameTextField resignFirstResponder];
}


#pragma mark - Notification: Keyboard Methods

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSLog(@"= keyboardDidShow");
    
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    UIEdgeInsets contentInserts = UIEdgeInsetsMake(0, 0, kbRect.size.height, 0);
    
    self.contentScroll.contentInset = contentInserts;
    self.contentScroll.scrollIndicatorInsets = contentInserts;
   
    // go to "add" button
    [self.contentScroll scrollRectToVisible:self.addTaskButton.frame animated:YES];
    // ??? change frame
    
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInserts = UIEdgeInsetsZero;
    
    self.contentScroll.contentInset = contentInserts;
    self.contentScroll.scrollIndicatorInsets = contentInserts;
    
    NSLog(@"= keyboardWillHide");
}


#pragma mark - DataSource: PickerView

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


#pragma mark - Delegate: PickerView

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld", (long)row + 1];
}


- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    self.amountOfPomodors = row +1;
}


@end
