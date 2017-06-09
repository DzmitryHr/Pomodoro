//
//  CoordinatorController.m
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//



#import "CoordinatorController.h"
#import "CoreDataController.h"



typedef NS_ENUM(NSInteger, CoordinatorControllerStage)
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


@property (nonatomic, readwrite, assign) CoordinatorControllerStage currentStage;

@property (nonatomic, strong) CDUser *user;
@property (nonatomic, strong) CDTask *task;
@property (nonatomic, strong) CDPomodor *pomodor;
@property (nonatomic, strong) CDBreak *breaK;

@property (nonatomic, strong) Configurator *configurator;

#define     durationPomodor             self.configurator.durationPomodor
#define     durationShortBreak          self.configurator.durationShortBreak
#define     durationLongBreak           self.configurator.durationLongBreak
#define     amountPomodorsForLongBreak  self.configurator.amountPomodorsForLongBreak

@property (nonatomic, strong) CoreDataController *coreData;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, readwrite, assign) NSTimeInterval uiTimer;


@end



@implementation CoordinatorController

#pragma mark - init

// initialization

- (instancetype)initWithConfigurator:(Configurator *)configurator coreData:(CoreDataController *)coreData
{
    self = [super init];
    if (self) {
        self.configurator = configurator;
 
        self.coreData = coreData;
        
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
        self.currentStage = stateReadyForWork;
        
        self.uiTimer = durationPomodor;
    }
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
   return(self.pomodor ? (NSTimeInterval)[self.pomodor.duration integerValue] : self.durationPomodor);
}


- (void)changeCurrentDurationPomodor:(NSInteger)newCurrentDurationPomodor
{
    durationPomodor = newCurrentDurationPomodor;
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

#warning name of stage
// ??? name of stage ???
- (NSString *)giveCurrentStage
{
    return [NSString stringWithFormat:@"%li", (long)self.currentStage];
}


#pragma mark - State

- (void)runWorkCycle
{
    self.currentStage = statePrepareToCountPomodor;
    
    [self processState];
}


- (void)stopWorkCycle
{
    self.currentStage = stateStopCount;
    
    [self processState];
}


- (void)processState
{
    switch (self.currentStage) {
        
        case statePrepareToCountPomodor:{
            
            self.pomodor = [self createNewPomodor];
            
            self.uiTimer = [self.pomodor.duration integerValue];
            
            [self startTimer];
            
            self.currentStage = stateCountingPomodor;
            
            break;
        }
            
        case stateCountingPomodor:{
            
            NSTimeInterval durationCurrentPomodor = (NSTimeInterval)[self.pomodor.duration integerValue];
            
            NSTimeInterval timeIntervalLost = (NSTimeInterval)lround([[NSDate date] timeIntervalSinceDate:self.pomodor.createTime]);
            
            if (timeIntervalLost >= durationCurrentPomodor){
            
                self.currentStage = statePrepareToCountBreak;
                
                
            } else {
                
                self.uiTimer = durationCurrentPomodor - timeIntervalLost;
            }
            
            break;
        }
            
        case statePrepareToCountBreak:{

            [self stopTimer];
            
            if ((self.task.pomodors.count % amountPomodorsForLongBreak) == 0){
                self.breaK = [self createNewBreakWithDuration:durationLongBreak];
            } else {
                self.breaK = [self createNewBreakWithDuration:durationShortBreak];
            }
            
            self.uiTimer = [self.breaK.duration integerValue];
            
            [self startTimer];
            
            self.currentStage = stateCountingBreak;
            
            break;
        }
            
        case stateCountingBreak:{
            
            NSTimeInterval durationBreak = (NSTimeInterval)([self.breaK.duration integerValue]);
            
            NSTimeInterval timeIntervalLost = (NSTimeInterval)lround([[NSDate date] timeIntervalSinceDate:self.breaK.createTime]);
            
            if (timeIntervalLost >= durationBreak){
                
                self.pomodor.complit = @(YES);
                
                self.currentStage = stateStopCount;
                
            } else {
                
                self.uiTimer = durationBreak - timeIntervalLost;
            }
            
            break;
        }
            
        case stateStopCount:{
            
            [self stopTimer];
            
            self.uiTimer = durationPomodor;
            
            self.currentStage = stateReadyForWork;
            
            
            break;
        }
            
        case stateReadyForWork:{
            
            self.uiTimer = durationPomodor;
            
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
    CDPomodor *pomodor = nil;
    
    [self.coreData createPomodorWithDuration:self.durationPomodor withBlock:^(CDPomodor *pomodor) {
        if (!pomodor.whoseTask && !self.task){
            pomodor.whoseTask = self.task;
        }
        
// ??? how to return pomodor???
        self.pomodor = pomodor;

    }];
    
    
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
