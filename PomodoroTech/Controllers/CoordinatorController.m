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

@property (nonatomic, assign) NSInteger durationPomodor;
@property (nonatomic, assign) NSInteger durationShortBreak;
@property (nonatomic, assign) NSInteger durationLongBreak;

@property (nonatomic, strong) NSUserDefaults *defaulTimeSetting;

@property (nonatomic, strong) CoreDataController *coreData;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, readwrite, assign) NSTimeInterval uiTimer;


@end


@implementation CoordinatorController

static const NSInteger MIN = 60;
static const NSInteger DEFAUL_DURATION_POMODOR = 25 * MIN;
static const NSInteger DEFAUL_DURATION_SHORT_BREAK = 5 * MIN;
static const NSInteger DEFAUL_DURATION_LONG_BREAK = 15 * MIN;
static const NSInteger AMOUNT_POMODOR_FOR_LONG_BREAK = 4;

NSString * const titleDurationPomodor = @"durationPomodor";
NSString * const titleDurationShortBreak = @"durationShortBreak";
NSString * const titleDurationLongBreak = @"durationLongBreak";



#pragma mark - init

// initialization
- (instancetype)init
{
    self = [super init];
    
    if (!self.defaulTimeSetting){
        
        self.defaulTimeSetting = [NSUserDefaults standardUserDefaults];
        [self.defaulTimeSetting setInteger:DEFAUL_DURATION_POMODOR forKey:titleDurationPomodor];
        [self.defaulTimeSetting setInteger:DEFAUL_DURATION_SHORT_BREAK forKey:titleDurationShortBreak];
        [self.defaulTimeSetting setInteger:DEFAUL_DURATION_LONG_BREAK forKey:titleDurationLongBreak];
        
        self.durationPomodor = DEFAUL_DURATION_POMODOR;
        self.durationShortBreak = DEFAUL_DURATION_SHORT_BREAK;
        self.durationLongBreak = DEFAUL_DURATION_LONG_BREAK;
        
        [self.defaulTimeSetting synchronize];

        self.coreData = [[CoreDataController alloc] init];
        
        if (!self.user){
            CDUser *user = [self.coreData getActiveUser];
            self.user = user;
            
            if (!user){
                self.user = [self.coreData createUserWithLogin:@"defaultUser"];
            }
        }
        
        if (!self.task){
            CDTask *task = [self.coreData getActiveTask];
            self.task = task;
            
            if (!task){
                self.task = [self.coreData createTaskWithName:@"defaultTask"];
            }
        }
    }
    
    self.currentState = stateReadyForWork;
    
    self.uiTimer = self.durationPomodor;
    
    return self;
}


- (void)setUiTimer:(NSTimeInterval)uiTimer
{
    _uiTimer = uiTimer;
    [self.delegate coordinatorController:self timerDidChanged:uiTimer];
}

#pragma mark - ohter metods

- (NSInteger)giveCurentDurationPomodor
{
    NSInteger durationPomodor = [self.defaulTimeSetting integerForKey:titleDurationPomodor];
    return durationPomodor;
}


- (void)changeCurrentDurationPomodor:(NSInteger)newCurrentDurationPomodor
{
    self.durationPomodor = newCurrentDurationPomodor;
    [self.defaulTimeSetting setInteger:newCurrentDurationPomodor forKey:titleDurationPomodor];
    [self.defaulTimeSetting synchronize];
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

// init current state???
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
            
            NSTimeInterval timeIntervalLost = (NSTimeInterval)lround([[NSDate date] timeIntervalSinceDate:self.pomodor.createTime]);
            
            if (timeIntervalLost >= (NSTimeInterval)self.durationPomodor){
            
                self.currentState = statePrepareToCountBreak;
                
                
            } else {
                
                self.uiTimer = self.durationPomodor - timeIntervalLost;
            }
            
            break;
        }
            
        case statePrepareToCountBreak:{
            
            [self stopTimer];
            
            if ((self.task.pomodors.count % AMOUNT_POMODOR_FOR_LONG_BREAK) == 0){
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
            
            self.uiTimer = [self.pomodor.duration integerValue];
            
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
