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


- (void)saveContext;

- (CDUser *)getCurrentUser;
- (CDTask *)getCurrentTask;

- (CDUser *)createUserWithLogin:(NSString *)login;
- (CDTask *)createTaskWithName:(NSString *)name;

- (CDPomodor *)createPomodorWithDuration:(NSInteger)pomodorDuration;
- (CDBreak *)createBreakWithDuration:(NSInteger)breakDuration;

@end
