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
#import "CoreDataController.h"


@interface TimerViewController () <TimerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;
@property (weak, nonatomic) IBOutlet UIButton *stopTimerButton;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;

@property (assign, nonatomic) NSInteger durationTimePomodor;

@property (nonatomic, strong) UNMutableNotificationContent *localNotification;
@end


@implementation TimerViewController

static const int MIN = 60;

-(NSInteger)durationTimePomodor
{
    if (!_durationTimePomodor){
        _durationTimePomodor = 1 * MIN;
    };
    [self repaintTimerLableWithTime:_durationTimePomodor];
    return _durationTimePomodor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.startTimerButton setEnabled:YES];
    [self.stopTimerButton setEnabled:NO];
    
    //inst delegate TimerController
    [[TimerController sharedInstance] setDelegate:self];
    
    //init
    [self.timePicker setHidden:YES];
    
    [self updateUI];
}


- (void)showPicker:(BOOL)show
{
    [self.timePicker setHidden:!show];
}


- (IBAction)tapUILabel:(UITapGestureRecognizer *)sender
{
    if (self.timePicker.hidden){
        [self showPicker:YES];
        //NSInteger timeLable = (int)self.timerLabel.text;  translate to intager???
        [self.timePicker setCountDownDuration: self.durationTimePomodor];
    } else {
        [self showPicker:NO];
        self.durationTimePomodor = [self.timePicker countDownDuration];
    };
};


- (IBAction)changedTimeDuration:(UIDatePicker *)sender
{
    CGFloat durationSec = [self.timePicker countDownDuration];
    
    [self repaintTimerLableWithTime:(NSInteger)durationSec];
    
}


- (IBAction)startTimerButton:(UIButton *)sender
{
    
    [self showNotification];
        
    [[TimerController sharedInstance] startTimerWithDurationPomodor:self.durationTimePomodor];
    [self showPicker:NO];
    
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
    self.durationTimePomodor = durationSec;
}


- (void)updateUI
{
    CDUser *user = [[CoreDataController sharedInstance] user];
    CDTask *task = [[CoreDataController sharedInstance] task];
    NSString *inf = [NSString stringWithFormat:@" User: %@ \n Task: %@ \n Pomodors: %lu", user.login, task.name, task.pomodors.count]; // all pomodors - choose complit pomodors
   self.informationLabel.text = inf;
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
    
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:self.durationTimePomodor
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
