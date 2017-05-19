//
//  TimerViewController.m
//  PomodoroTech
//
//  Created by Kronan on 5/11/17.
//  Copyright © 2017 Kronan. All rights reserved.
//
@import UserNotifications;
#import "TimerViewController.h"
#import "TimerController.h"

#import "CoordinatorController.h"


@interface TimerViewController () <TimerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;
@property (weak, nonatomic) IBOutlet UIButton *stopTimerButton;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;

@property (assign, nonatomic) NSInteger durationPomodor;

@property (nonatomic, strong) UNMutableNotificationContent *localNotification;
@end



@implementation TimerViewController


@synthesize durationPomodor = _durationPomodor;

#pragma mark - init

- (NSInteger)durationPomodor
{
    if (!_durationPomodor){
        _durationPomodor = [[CoordinatorController sharedInstance] giveCurentDurationPomodor];
    };
    
    [self repaintTimerLableWithTime:_durationPomodor];
    
    return _durationPomodor;
}


- (void)setDurationPomodor:(NSInteger)durationPomodor
{
    _durationPomodor = durationPomodor;
    
    [[CoordinatorController sharedInstance] changeCurrentDurationPomodor:_durationPomodor];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //inst delegate TimerController
    [[TimerController sharedInstance] setDelegate:self];
    
    [self.startTimerButton setEnabled:YES];
    [self.stopTimerButton setEnabled:NO];
    [self.timePicker setHidden:YES];
    
    [self updateUI];
}

#pragma mark - other

- (void)showPicker:(BOOL)show
{
    [self.timePicker setHidden:!show];
}


- (IBAction)tapUILabel:(UITapGestureRecognizer *)sender
{
    if (![self.timePicker isEnabled]){
        return;
    }
    
    if (self.timePicker.hidden){
        [self showPicker:YES];
        //NSInteger timeLable = (int)self.timerLabel.text;  translate to intager???
        [self.timePicker setCountDownDuration: self.durationPomodor];
    } else {
        [self showPicker:NO];
        self.durationPomodor = [self.timePicker countDownDuration];
    };
};


- (IBAction)changeDurationPomodor:(UIDatePicker *)sender
{
    CGFloat durationSec = [self.timePicker countDownDuration];
    
    self.durationPomodor = (NSInteger)durationSec;

    [self repaintTimerLableWithTime:self.durationPomodor];
}


- (IBAction)startTimerButton:(UIButton *)sender
{
    //where???
    [self showNotification];
        
    [[TimerController sharedInstance] startTimerWithDurationPomodor:self.durationPomodor];
 
    [self showPicker:NO];
    [self.timePicker setEnabled:NO];
    
    // chops and changes
    [[CoordinatorController sharedInstance] runWorkCycle];
}


- (IBAction)stopTimerButton:(UIButton *)sender
{
    [[TimerController sharedInstance] stopTimer];
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
    CDUser *user = [[CoordinatorController sharedInstance] giveCurrentUser];
    CDTask *task = [[CoordinatorController sharedInstance] giveCurrentTask];
    NSString *inf = [NSString stringWithFormat:@" User: %@ \n Task: %@ \n Pomodors: %lu", user.login, task.name, task.pomodors.count]; // all pomodors - choose complit pomodors
   self.informationLabel.text = inf;
    
    [self repaintTimerLableWithTime:self.durationPomodor];
}


#pragma mark - TimerControllerDelegate

-(void)timerControllerDidStarted:(TimerController *)timerController
{
    [self.startTimerButton setEnabled:NO];
    [self.stopTimerButton setEnabled:YES];
}


-(void)timerControllerDidStop:(TimerController *)timerController
{
    [self.startTimerButton setEnabled:YES];
    [self.stopTimerButton setEnabled:NO];
    [self.timePicker setEnabled:YES];

}


-(void)timerController:(TimerController *)timerController timeDidChanged:(NSTimeInterval)time
{
    [self repaintTimerLableWithTime:time];
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
    
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:self.durationPomodor
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
