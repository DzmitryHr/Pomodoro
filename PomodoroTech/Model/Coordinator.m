//
//  Coordinator.m
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "Coordinator.h"


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


@interface Coordinator()


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


@property (nonatomic, strong, readwrite) CoreData *coreData;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, readwrite, assign) NSTimeInterval uiTimer;


@end



@implementation Coordinator

#pragma mark - Lifecycle

- (instancetype)initWithLoader:(Loader *)loader coreData:(CoreData *)coreData delegate:(id)delegate
{
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminateNotification:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    return self;
}


- (void)dealloc
{
    userLogin = self.user.login;
    taskName = self.task.name;
    
    //  ???
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
}


#pragma mark - Custom Accessors

- (void)setUiTimer:(NSTimeInterval)uiTimer
{
    _uiTimer = uiTimer;
    [self.delegate coordinatorController:self timerDidChanged:uiTimer];
}


#pragma mark - Public

- (NSInteger)giveCurentDurationPomodor
{
   return(self.pomodor ? (NSTimeInterval)[self.pomodor.duration integerValue] : self.durationPomodor);
}


- (CDUser *)giveCurrentUser
{
    return self.user;
}


- (CDTask *)giveCurrentTask
{
    return  self.task;
}


- (NSString *)giveCurrentStage
{
    return [NSString stringWithFormat:@"%li", (long)self.currentStage];
}


- (void)changeCurrentTask:(CDTask *)task
{
    task.lastUseTime = [NSDate date];
    self.task = task;
}


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


#pragma mark - Private

- (void)changeCurrentDurationPomodor:(NSInteger)newCurrentDurationPomodor
{
    durationPomodor = newCurrentDurationPomodor;
    self.uiTimer = newCurrentDurationPomodor;
}


- (void)saveCoreDataForEntity:(NSManagedObject *)entity
{
    [entity.managedObjectContext save:nil];
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


#pragma mark - Delegate: TimerVCNavigation

// init TasksViewController and TasksDataManager
// transition to TasksViewController
- (void)goToTasksVCFromTimerVC:(TimerViewController *)timerVC
{
    TasksDataManager *tasksDM = [[TasksDataManager alloc] initWithManagedObjectContext:self.coreData.mainContext];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    TasksViewController *tasksVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TasksViewController"];
    
    tasksVC.delegate = self;
    tasksVC.dataSource = tasksDM;
    tasksVC.navigationCoordinator = self;
    
    tasksDM.delegate = tasksVC;
    
    [timerVC.navigationController pushViewController:tasksVC animated:YES];
}


#pragma mark - DataSource: TimerVCDataSource

- (CDUser *)currentUserForTimerVC:(TimerViewController *)timerVC
{
    return self.user;
}


- (CDTask *)currentTaskForTimerVC:(TimerViewController *)timerVC
{
    return self.task;
}


- (NSString *)currentStageForTimerVC:(TimerViewController *)timerVC
{
    return [NSString stringWithFormat:@"%li", (long)self.currentStage];
}


- (void)changeDurationPomodor:(NSTimeInterval)pomodorDuration{
    [self changeCurrentDurationPomodor:pomodorDuration];
}


- (void)runWorkCycleFromTimerVC
{
    [self runWorkCycle];
}


- (void)stopWorkCycleFromTimerVC
{
    [self stopWorkCycle];
}


#pragma mark - Delegate: TasksVCDelegate

- (void)tasksVC:(TasksViewController *)tasksVC changeCurrentTask:(NSManagedObject *)task
{
    [self changeCurrentTask:(CDTask *)task];
}


- (void)tasksVC:(TasksViewController *)tasksVC didPushDelButtonInCellWithTask:(NSManagedObject *)task
{
    // del task
    [self.coreData delTaskInMainContext:(CDTask *)task];
    NSLog(@"del task");
}

#pragma mark - Navigation: TasksVCNavigation

// init addTaskViewController
// go to addTaskViewController
- (void)goToAddTasksVCformTasksVC:(TasksViewController *)tasksVC
{
    UIStoryboard *mainStotyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddTaskViewController *addTaskVC = [mainStotyboard instantiateViewControllerWithIdentifier:@"AddTaskVC"];
    
    addTaskVC.delegate = self;
    addTaskVC.navigationCoordinator = self;
    
    [tasksVC.navigationController pushViewController:addTaskVC animated:YES];
}

- (void)goToBackFromTasksVC:(TasksViewController *)tasksVC
{
     [tasksVC.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Delegate: AddTaskVCDelegate

- (void)vc:(AddTaskViewController *)taskVC createNewTaskWithTaskName:(NSString *)nameOfTask andAmountOfPomodors:(NSInteger)amountOfPomodors
{
    [self.coreData createTaskInMainContextWithName:nameOfTask forUser:self.user];
}


#pragma mark - Navigation: AddTaskVCNavigation

- (void)popVCfromVC:(AddTaskViewController *)taskVC
{
    [taskVC.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notifications: exiting the application

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    userLogin = self.user.login;
    taskName = self.task.name;
    
    [self.loader saveSettings];
    
    NSLog(@"appWillTerminate");
}

@end
