//
//  CoordinatorDelegate.h
//  PomodoroTech
//
//  Created by Kronan on 6/23/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Coordinator;

@protocol CoordinatorDelegate <NSObject>
@required
- (void)coordinatorController:(Coordinator *)coordinator timerDidChanged:(NSTimeInterval)time;

@end
