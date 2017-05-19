//
//  CoordinatorController.m
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "CoordinatorController.h"
#import "CoreDataController.h"


typedef NS_ENUM(NSInteger, CoordinatorControllerState)
{
    statePrepareToCountPomodor = 0,
    stateCountingPomodor,
    
    statePrepareToCountBreak,
    stateCountingBreak,
    
    stateStopCount,
    
    // defaultState
    stateReadyForWork,
    
    exitFromBackground
    
};


@interface CoordinatorController()


@property (nonatomic, assign) CoordinatorControllerState currentState;

@property (nonatomic, strong) CDUser *user;
@property (nonatomic, strong) CDTask *task;
@property (nonatomic, strong) CDPomodor *pomodor;
@property (nonatomic, strong) CDBreak *breaK;
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
        
        self.user = user;
        self.task = task;
        
        [condition.managedObjectContext save:nil];
    }
    
    return self;
}


- (CDPomodor *)pomodor
{
    if (!_pomodor){
        [self createNewPomodor];
    }
    
    return _pomodor;
    
}

- (CDTask *)task
{
    if (!_task){
        NSLog(@"=============================================");
    }
    
    return _task;
}

-(CDCondition *)condition
{
    if (!_condition){
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


- (void)saveCoreDataForEntity:(NSManagedObject *)entity
{
    [entity.managedObjectContext save:nil];
}


#pragma mark - State

- (void)runWorkCycle
{
    self.currentState = statePrepareToCountPomodor;
    
    [self processState];
}


- (void)processState
{
    switch (self.currentState) {
        
        case statePrepareToCountPomodor:{
            
            [self createNewPomodor];
            // [timerStartCount: durationPomodor];
            self.currentState = stateCountingPomodor;
            
            break;
        }
            
        case stateCountingPomodor:{
            // if (timer == stop)
            
            break;
        }
            
        case statePrepareToCountBreak:{
            
            
            break;
        }
            
        case stateCountingBreak:{
            
            
            break;
        }
            
        case stateStopCount:{
            
            
            break;
        }
            
        case stateReadyForWork:{
            
            
            break;
        }
            
        case exitFromBackground:{
            
            
            break;
        }
            
        default:
            break;
    }
    
    
}

#pragma mark - methods for State

- (void)createNewPomodor
{
    CDPomodor *pomodor = [[CoreDataController sharedInstance] createPomodor];
    
    pomodor.complit = NO;
    pomodor.createTime = [NSDate date];
    pomodor.duration = self.condition.durationPomodor;
    
    pomodor.whoseTask = self.condition.currentTask;
    pomodor.currentCondition = self.condition;
    
    [self saveCoreDataForEntity:pomodor];
    
    self.pomodor = pomodor;
}

static const int AMOUNT_POMODOR_FOR_LONG_BREAK = 4;

- (void)createNewBreak
{
    CDBreak *breaK = [[CoreDataController sharedInstance] createBreak];
    
    breaK.complit = NO;
    breaK.createTime = [NSDate date];
    if (!self.task.pomodors.count % AMOUNT_POMODOR_FOR_LONG_BREAK){
        breaK.duration = self.condition.durationLongBreak;
    } else {
        breaK.duration = self.condition.durationShortBreak;
    };
    
    [self saveCoreDataForEntity:breaK];
    
    self.breaK = breaK;
}


@end
