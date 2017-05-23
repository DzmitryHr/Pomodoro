//
//  CoreDataController.h
//  PomodoroTech
//
//  Created by Kronan on 5/17/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDUser+CoreDataClass.h"
#import "CDTask+CoreDataClass.h"
#import "CDPomodor+CoreDataClass.h"
#import "CDBreak+CoreDataClass.h"

@interface CoreDataController : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (nonatomic, strong) NSManagedObjectContext *contextPomodoro;

//@property (nonatomic, strong) CDUser *currentUser;
//@property (nonatomic, strong) CDTask *currentTask;
//@property (nonatomic, strong) CDPomodor *currentPomodor;
//@property (nonatomic, strong) CDBreak   *currentBreakP;

- (void)saveContext;

- (CDUser *)getActiveUser;
- (CDTask *)getActiveTask;

- (CDUser *)createUserWithLogin:(NSString *)login;
- (CDTask *)createTaskWithName:(NSString *)name;

- (CDPomodor *)createPomodorWithDuration:(NSInteger)pomodorDuration;
- (CDBreak *)createBreakWithDuration:(NSInteger)breakDuration;

@end
