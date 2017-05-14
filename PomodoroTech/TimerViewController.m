//
//  TimerViewController.m
//  PomodoroTech
//
//  Created by Kronan on 5/11/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TimerViewController.h"
#import "Timer.h"

#import "TimerController.h"


@interface TimerViewController () <TimerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;
@property (weak, nonatomic) IBOutlet UIButton *stopTimerButton;

@property (nonatomic, strong) Timer *timer;


@property (assign, nonatomic) NSInteger durationTimePomodor;

@end


@implementation TimerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.startTimerButton setEnabled:YES];
    [self.stopTimerButton setEnabled:NO];
    
    [[TimerController sharedInstance] setDelegate:self];
    
    //init
    [self.timePicker setHidden:YES];
}



- (IBAction)tapUILabel:(UITapGestureRecognizer *)sender
{
    if (self.timePicker.hidden){
        [self.timePicker setHidden:NO];
        //NSInteger timeLable = (int)self.timerLabel.text;  translate to intager???
        [self.timePicker setCountDownDuration: 25.f * 60.f];
    } else {
        [self.timePicker setHidden:YES];
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
    [[TimerController sharedInstance] startTimer];
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

@end
