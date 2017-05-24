//
//  CoordinatorController.m
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "CoordinatorController.h"
#import "CoreDataController.h"
#import "Configurator.h"


typedef NS_ENUM(NSInteger, CoordinatorControllerState)
{
    // stateInit = 0,
    
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


@property (nonatomic, readwrite, assign) CoordinatorControllerState currentState;

@property (nonatomic, strong) CDUser *user;
@property (nonatomic, strong) CDTask *task;
@property (nonatomic, strong) CDPomodor *pomodor;
@property (nonatomic, strong) CDBreak *breaK;

@property (nonatomic, assign) NSTimeInterval durationPomodor;
@property (nonatomic, assign) NSTimeInterval durationShortBreak;
@property (nonatomic, assign) NSTimeInterval durationLongBreak;
@property (nonatomic, assign) NSInteger amountPomodorsForLongBreak;

@property (nonatomic, strong) Configurator *configurator;

@property (nonatomic, strong) CoreDataController *coreData;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, readwrite, assign) NSTimeInterval uiTimer;


@end


@implementation CoordinatorController

#pragma mark - init

// initialization
- (instancetype)init
{
    self = [super init];
    
    if (self){
        
        self.configurator = [[Configurator alloc] init];
        
        self.durationPomodor = self.configurator.durationPomodor;
        self.durationShortBreak = self.configurator.durationShortBreak;
        self.durationLongBreak = self.configurator.durationLongBreak;
        self.amountPomodorsForLongBreak = self.configurator.amountPomodorsForLongBreak;
        
        self.coreData = [[CoreDataController alloc] init];
        
        if (!self.user){
            CDUser *user = [self.coreData getCurrentUser];
            self.user = user;
            
            if (!user){
                self.user = [self.coreData createUserWithLogin:@"defaultUser"];
            }
        }
        
        if (!self.task){
            CDTask *task = [self.coreData getCurrentTask];
            self.task = task;
            
            if (!task){
                self.task = [self.coreData createTaskWithName:@"defaultTask"];
            }
        }
        
        // init current state
        self.currentState = stateReadyForWork;
        
        self.uiTimer = self.durationPomodor;
        
    }
    
    return self;
}

- (void)setDurationPomodor:(NSTimeInterval)durationPomodor
{
    _durationPomodor = durationPomodor;
    self.configurator.durationPomodor = durationPomodor;
}

- (void)setDurationShortBreak:(NSTimeInterval)durationShortBreak
{
    _durationShortBreak = durationShortBreak;
    self.configurator.durationShortBreak = durationShortBreak;
}

- (void)setDurationLongBreak:(NSTimeInterval)durationLongBreak
{
    _durationLongBreak = durationLongBreak;
    self.configurator.durationLongBreak = durationLongBreak;
}

- (void)setAmountPomodorsForLongBreak:(NSInteger)amountPomodorsForLongBreak
{
    _amountPomodorsForLongBreak = amountPomodorsForLongBreak;
    self.configurator.amountPomodorsForLongBreak = amountPomodorsForLongBreak;
}

- (void)setUiTimer:(NSTimeInterval)uiTimer
{
    _uiTimer = uiTimer;
    [self.delegate coordinatorController:self timerDidChanged:uiTimer];
}


#pragma mark - ohter metods

- (NSInteger)giveCurentDurationPomodor
{
   return(self.pomodor ? (NSTimeInterval)[self.pomodor.duration integerValue] : self.durationPomodor);
}


- (void)changeCurrentDurationPomodor:(NSInteger)newCurrentDurationPomodor
{
    self.durationPomodor = newCurrentDurationPomodor;
}


- (CDUser *)giveCurrentUser
{
    return self.user;
}


- (CDTask *)giveCurrentTask
{
    return  self.task;
}


- (void)saveCoreDataForEntity:(NSManagedObject *)entity
{
    [entity.managedObjectContext save:nil];
}


- (CoordinatorControllerState)giveCureentState
{
    return self.currentState;
}


#pragma mark - State

- (void)runWorkCycle
{
    self.currentState = statePrepareToCountPomodor;
    
    [self processState];
}


- (void)stopWorkCycle
{
    self.currentState = stateStopCount;
    
    [self processState];
}


- (void)processState
{
    switch (self.currentState) {
        
        case statePrepareToCountPomodor:{
            
            self.pomodor = [self createNewPomodor];
            //self.pomodor.duration = @(self.durationPomodor);
            
            self.uiTimer = [self.pomodor.duration integerValue];
            
            [self startTimer];
            
            self.currentState = stateCountingPomodor;
            
            break;
        }
            
        case stateCountingPomodor:{
            
            NSTimeInterval durationCurrentPomodor = (NSTimeInterval)[self.pomodor.duration integerValue];
            
            NSTimeInterval timeIntervalLost = (NSTimeInterval)lround([[NSDate date] timeIntervalSinceDate:self.pomodor.createTime]);
            
            if (timeIntervalLost >= durationCurrentPomodor){
            
                self.currentState = statePrepareToCountBreak;
                
                
            } else {
                
                self.uiTimer = durationCurrentPomodor - timeIntervalLost;
            }
            
            break;
        }
            
        case statePrepareToCountBreak:{

            [self stopTimer];
            
            if ((self.task.pomodors.count % self.amountPomodorsForLongBreak) == 0){
                self.breaK = [self createNewBreakWithDuration:self.durationLongBreak];
            } else {
                self.breaK = [self createNewBreakWithDuration:self.durationShortBreak];
            }
            
            self.uiTimer = [self.breaK.duration integerValue];
            
            [self startTimer];
            
            self.currentState = stateCountingBreak;
            
            break;
        }
            
        case stateCountingBreak:{
            
            NSTimeInterval durationBreak = (NSTimeInterval)([self.breaK.duration integerValue]);
            
            NSTimeInterval timeIntervalLost = (NSTimeInterval)lround([[NSDate date] timeIntervalSinceDate:self.breaK.createTime]);
            
            if (timeIntervalLost >= durationBreak){
                
                self.pomodor.complit = @(YES);
                
                self.currentState = stateStopCount;
                
            } else {
                
                self.uiTimer = durationBreak - timeIntervalLost;
            }
            
            break;
        }
            
        case stateStopCount:{
            
            [self stopTimer];
            
            self.uiTimer = self.durationPomodor;
            
            self.currentState = stateReadyForWork;
            
            
            break;
        }
            
        case stateReadyForWork:{
            
            self.uiTimer = self.durationPomodor;
            
            break;
        }
            
        case exitFromBackground:{
            
            
            break;
        }
            
        default:
            break;
    }
    
    
}


- (void)startTimer
{
    [self stopTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
                                          [self processState];
                                      }];
}


-(void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;

}


#pragma mark - methods for State

- (CDPomodor *)createNewPomodor
{
    CDPomodor *pomodor = [self.coreData createPomodorWithDuration:self.durationPomodor];
    
    if (!pomodor.whoseTask && !self.task){
       pomodor.whoseTask = self.task;
    }
   
    [self saveCoreDataForEntity:pomodor];
    
    return pomodor;
}


- (CDBreak *)createNewBreakWithDuration:(NSInteger)duration
{
    CDBreak *breaK = [self.coreData createBreakWithDuration:duration];
    
    if (!breaK.whoseTask && !self.task){
        breaK.whoseTask = self.task;
    }
    
    [self saveCoreDataForEntity:breaK];
    
    return breaK;
}


@end
