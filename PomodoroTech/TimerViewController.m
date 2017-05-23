//
//  TimerViewController.m
//  PomodoroTech
//
//  Created by Kronan on 5/11/17.
//  Copyright © 2017 Kronan. All rights reserved.
//
@import UserNotifications;
#import "TimerViewController.h"

#import "CoordinatorController.h"


@interface TimerViewController () <CoordinatorControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;
@property (weak, nonatomic) IBOutlet UIButton *stopTimerButton;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;

@property (assign, nonatomic) NSInteger currentTimerValue;
@property (nonatomic, strong) CoordinatorController *coordinator;

@property (nonatomic, strong) UNMutableNotificationContent *localNotification;

@end



@implementation TimerViewController


#pragma mark - init

- (CoordinatorController *)coordinator
{
    if (!_coordinator){
        _coordinator = [[CoordinatorController alloc] init];
    }
    
    return _coordinator;
}


@synthesize currentTimerValue = _currentTimerValue;


- (NSInteger)currentTimerValue
{
    if (!_currentTimerValue){
        _currentTimerValue = [self.coordinator uiTimer];
    };
    
    [self repaintTimerLableWithTime:_currentTimerValue];
    
    return _currentTimerValue;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //inst delegate CoordinatorController
    [[self coordinator] setDelegate:self];
    
    [self.startTimerButton setEnabled:YES];
    [self.stopTimerButton setEnabled:NO];
    
    [self.timePicker setHidden:YES];
    
    [self updateUI];
}

#pragma mark - other


- (IBAction)tapUILabel:(UITapGestureRecognizer *)sender
{
    if (!self.timePicker.enabled){
        return;
    }
    
    self.timePicker.hidden ? [self.timePicker setHidden:NO] : [self.timePicker setHidden:YES] ;
    
    if (!self.timePicker.hidden){
        [self.timePicker setDatePickerMode:UIDatePickerModeCountDownTimer];
        self.timePicker.countDownDuration = self.currentTimerValue;
    }
    
};


- (IBAction)changeDurationPomodor:(UIDatePicker *)sender
{
    CGFloat durationSec = [self.timePicker countDownDuration];
    
    self.currentTimerValue = (NSInteger)durationSec;
    
    [self.coordinator changeCurrentDurationPomodor:_currentTimerValue];

    [self repaintTimerLableWithTime:self.currentTimerValue];
}


- (IBAction)startTimerButton:(UIButton *)sender
{
    // where???
    // [self showNotification];
        
    [self.startTimerButton setEnabled:NO];
    [self.stopTimerButton setEnabled:YES];
    [self.timePicker setEnabled:NO];
    
    [self.timePicker setHidden:YES];
    
    [self updateUI];
    
    // chops and changes
    [self.coordinator runWorkCycle];
}


- (IBAction)stopTimerButton:(UIButton *)sender
{
    [self.startTimerButton setEnabled:YES];
    [self.stopTimerButton setEnabled:NO];
    [self.timePicker setEnabled:YES];
    
    [self.coordinator stopWorkCycle];
    
    [self updateUI];
}


- (void)repaintTimerLableWithTime:(NSTimeInterval)durationSec
{
    NSInteger hours = (NSInteger)durationSec/(60 * 60);
    NSInteger mins = (NSInteger)durationSec/60 - (hours * 60);
    NSInteger secs = (NSInteger)durationSec - (hours * 60 * 60) - (mins * 60);
    
    self.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", mins, secs];
}


- (void)updateUI
{
    CDUser *user = [self.coordinator giveCurrentUser];
    CDTask *task = [self.coordinator giveCurrentTask];
    NSString *inf = [NSString stringWithFormat:@" User: %@ \n Task: %@ \n Pomodors: %lu", user.login, task.name, task.pomodors.count]; // all pomodors - choose complit pomodors
   self.informationLabel.text = inf;
    
    [self repaintTimerLableWithTime:self.currentTimerValue];
}

#pragma mark - CoordinatorControllerDelegate

- (void)coordinatorController:(CoordinatorController *)coordinator timerDidChanged:(NSTimeInterval)time;
{
    self.currentTimerValue = time;
    [self updateUI];
}


#pragma mark - Notification

- (void)showNotification
{
    self.localNotification = [[UNMutableNotificationContent alloc] init];
    
    self.localNotification.title = [NSString localizedUserNotificationStringForKey:@"Time Down!"
                                                          arguments:nil];
    
    self.localNotification.body = [NSString localizedUserNotificationStringForKey:@"Pomodor is eaten"
                                                         arguments:nil];
    
    self.localNotification.sound = [UNNotificationSound defaultSound];
    self.localNotification.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
    
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:self.currentTimerValue
                                                                                                    repeats:NO];
    
    UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"Time Down"
                                                                                      content:self.localNotification
                                                                                      trigger:trigger];
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:notificationRequest
             withCompletionHandler:^(NSError * _Nullable error) {
                 if (!error){
                     NSLog(@"Add NotificationRequest succeeded!");
                 }
             }];
    
}
@end
