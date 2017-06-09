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

@property (nonatomic, strong) NSManagedObjectContext *mainContext;

- (void)saveContext;

- (CDUser *)getCurrentUser;
- (CDTask *)getCurrentTask;

- (CDUser *)createUserWithLogin:(NSString *)login;
- (CDTask *)createTaskWithName:(NSString *)name;

- (void)createPomodorWithDuration:(NSInteger)pomodorDuration withBlock:(void(^)(CDPomodor *pomodor))block;
- (CDBreak *)createBreakWithDuration:(NSInteger)breakDuration;

@end
