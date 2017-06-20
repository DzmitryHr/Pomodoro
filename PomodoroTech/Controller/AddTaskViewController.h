//
//  AddTaskViewController.h
//  PomodoroTech
//
//  Created by Kronan on 6/6/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coordinator.h"
#import "CoreData.h"

@interface AddTaskViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong, readonly) NSString *taskName;
@property (nonatomic, assign, readonly) NSInteger amountOfPomodors;

@property (nonatomic, strong) Coordinator *coordinator;
@property (nonatomic, strong) CoreData *coreData;

@end
