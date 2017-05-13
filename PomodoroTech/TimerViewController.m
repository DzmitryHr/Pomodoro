//
//  TimerViewController.m
//  PomodoroTech
//
//  Created by Kronan on 5/11/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "TimerViewController.h"
#import "Timer.h"


@interface TimerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@property (assign, nonatomic) NSInteger durationTimePomodor;

@end


@implementation TimerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    NSInteger hours = (NSInteger)durationSec/(60 * 60);
    NSInteger mins = (NSInteger)durationSec/60 - (hours * 60);
    NSInteger secs = (NSInteger)durationSec - (hours * 60 * 60) - (mins * 60);
    
    self.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", mins, secs];
}


- (IBAction)startTimerButton:(UIButton *)sender
{
    [Timer startTimerWithDuration:self.durationTimePomodor];
}


- (IBAction)stopTimerButton:(UIButton *)sender
{
    
}

//to do delegate from Timer where ui repaint 1sec;

@end
