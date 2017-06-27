//
//  AddTaskViewController.h
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AddTaskViewController;

@protocol AddTaskVCDelegate <NSObject>

@required
- (void)vc:(AddTaskViewController *)taskVC createNewTaskWithTaskName:(NSString *)nameOfTask andAmountOfPomodors:(NSInteger)amountOfPomodors;
- (void)popVCfromVC:(AddTaskViewController *)taskVC;

@end


@interface AddTaskViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) id<AddTaskVCDelegate> delegate;

@end
