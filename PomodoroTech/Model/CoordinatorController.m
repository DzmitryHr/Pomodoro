//
//  CoordinatorController.m
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//



#import "CoordinatorController.h"
#import "CoreData.h"



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

@property (nonatomic, strong) Loader *loader;

#define     durationPomodor             self.loader.lastDurationPomodor
#define     durationShortBreak          self.loader.lastDurationShortBreak
#define     durationLongBreak           self.loader.lastDurationLongBreak
#define     amountPomodorsForLongBreak  self.loader.lastAmountPomodorsForLongBreak
#define     userLogin                   self.loader.lastUserLogin
#define     taskName                    self.loader.lastTaskName


@property (nonatomic, strong) CoreData *coreData;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, readwrite, assign) NSTimeInterval uiTimer;


@end



@implementation CoordinatorController

#pragma mark - init

// initialization

- (instancetype)initWithLoader:(Loader *)loader coreData:(CoreData *)coreData
{
    self = [super init];
    if (self) {
        
        self.loader = loader;
        self.coreData = coreData;
        
        CDUser *user = [self.coreData getUserWithLogin:userLogin];
        if (!user){
            user = [self.coreData createUserInMainContextWithLogin:userLogin];
        }
        self.user = user;
        
        CDTask *task = [self.coreData getTaskWithName:taskName];
        if (!task){
            task = [self.coreData createTaskInMainContextWithName:taskName forUser:self.user];
        }
        self.task = task;
        
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
            
                self.pomodor.complit = @(YES);
                
                self.currentStage = statePrepareToCountBreak;
                
            } else {
                
                self.uiTimer = durationCurrentPomodor - timeIntervalLost;
            }
            
            break;
        }
            
        case statePrepareToCountBreak:{

            [self stopTimer];
            
            self.breaK = [self createNewBreak];
            
            self.uiTimer = [self.breaK.duration integerValue];
            
            [self startTimer];
            
            self.currentStage = stateCountingBreak;
            
            break;
        }
            
        case stateCountingBreak:{
            
            NSTimeInterval durationBreak = (NSTimeInterval)([self.breaK.duration integerValue]);
            
            NSTimeInterval timeIntervalLost = (NSTimeInterval)lround([[NSDate date] timeIntervalSinceDate:self.breaK.createTime]);
            
            if (timeIntervalLost >= durationBreak){
                
                self.breaK.complit = @(YES);
                
                self.currentStage = stateStopCount;
                
            } else {
                
                self.uiTimer = durationBreak - timeIntervalLost;
            }
            
            break;
        }
            
            
# warning - stop this???
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
    CDPomodor *pomodor = [self.coreData createPomodorInMainContextWithDuration:durationPomodor forTask:self.task];
    return pomodor;
};


// create LONG break or SHORT
- (CDBreak *)createNewBreak
{
    CDBreak *breaK = nil;
    
    if ((self.task.pomodors.count % amountPomodorsForLongBreak) == 0){
        breaK = [self.coreData createBreakInMainContextWithDuration:durationLongBreak forTask:self.task];
    } else {
        breaK = [self.coreData createBreakInMainContextWithDuration:durationShortBreak forTask:self.task];
    }
    
    return breaK;
};


/*
- (void)createNewPomodorWithBlock:(void(^)(CDPomodor *pomodor))block
{
    
    [self.coreData createPomodorWithDuration:self.durationPomodor withBlock:^(CDPomodor *pomodor) {
        if (!pomodor.whoseTask && !self.task){
            pomodor.whoseTask = self.task;
        }
        
        block(pomodor);
    }];
    
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
*/

- (void)dealloc
{
    userLogin = self.user.login;
    taskName = self.task.name;
}

@end
