//
//  CoordinatorController.m
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "CoordinatorController.h"
#import "CoreDataController.h"

@interface CoordinatorController()

@property (nonatomic, strong) CDCondition *condition;

@end


@implementation CoordinatorController

static const int MIN = 60;
static const int DEFAUL_DURATION_POMODOR = 25 * MIN;
static const int DEFAUL_DURATION_SHORT_BREAK = 5 * MIN;
static const int DEFAUL_DURATION_LONG_BREAK = 15 * MIN;


#pragma mark - init

// initialization
- (instancetype)init
{
    self = [super init];
    
    if (self){
        CDCondition *condition = [[CoreDataController sharedInstance] condition];
        
        if (!condition.durationPomodor){
            condition.durationPomodor = DEFAUL_DURATION_POMODOR;
        };
        
        if (!condition.durationShortBreak){
            condition.durationShortBreak = DEFAUL_DURATION_SHORT_BREAK;
        };
        
        if (!condition.durationLongBreak){
            condition.durationLongBreak = DEFAUL_DURATION_LONG_BREAK;
        };
        
        CDUser *user = [[CoreDataController sharedInstance] user];
        
        CDTask *task = [[CoreDataController sharedInstance] task];
        
        task.whoseUser = user;
        
        condition.currentUser = user;
        condition.currentTask = task;
        
        [condition.managedObjectContext save:nil];
    }
    
    return self;
}


-(CDCondition *)condition
{
    if(!_condition){
        _condition = [[CoreDataController sharedInstance] condition];
    }
    
    return _condition;
}


+ (instancetype)sharedInstance
{
    static CoordinatorController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CoordinatorController alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - ohter metods

- (NSInteger)giveCurentDurationPomodor
{
    return self.condition.durationPomodor;
}


- (void)changeCurrentDurationPomodor:(NSInteger)newCurrentDurationPomodor
{
    //self.condition.durationPomodor = [NSNumber numberWithInteger:newCurrentDurationPomodor];
    
    self.condition.durationPomodor = newCurrentDurationPomodor;
    
    [self.condition.managedObjectContext save:nil];
}


- (CDUser *)giveCurrentUser
{
    return self.condition.currentUser;
}


- (CDTask *)giveCurrentTask
{
    return self.condition.currentTask;    
}


@end
