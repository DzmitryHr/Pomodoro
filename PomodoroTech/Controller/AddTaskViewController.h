//
//  AddTaskViewController.h
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AddTaskVCDelegate <NSObject>

@required
- (void)createNewTaskWithTaskName:(NSString *)nameOfTask andAmountOfPomodors:(NSInteger)amountOfPomodors;

@end


@interface AddTaskViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) id<AddTaskVCDelegate> delegate;

@end
