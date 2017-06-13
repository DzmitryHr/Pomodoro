//
//  CoreData.h
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

@interface CoreData : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;

// give objects from main context
- (CDUser *)getUserWithLogin:(NSString *)login;
- (CDTask *)getTaskWithName:(NSString *)name;

- (CDUser *)createUserInMainContextWithLogin:(NSString *)login;
- (CDTask *)createTaskInMainContextWithName:(NSString *)name forUser:(CDUser *)user;
- (CDPomodor *)createPomodorInMainContextWithDuration:(NSInteger)pomodorDuration
                                 forTask:(CDTask *)task;
- (CDBreak *)createBreakInMainContextWithDuration:(NSInteger)breakDuration
                                              forTask:(CDTask *)task;



- (void)createUserWithLogin:(NSString *)login withBlock:(void(^)(CDUser *))block;
- (void)createTaskWithName:(NSString *)name forUser:(CDUser *)user withBlock:(void(^)(CDTask *))block;

- (CDPomodor *)createPomodorWithDuration:(NSInteger)pomodorDuration
                          forTask:(CDTask *)task;

- (void)createPomodorWithDuration:(NSInteger)pomodorDuration
                         forTask:(CDTask *)task
                        withBlock:(void(^)(CDPomodor *pomodor))block;
- (void)createBreakWithDuration:(NSInteger)breakDuration
                            forTask:(CDTask *)task
                      withBlock:(void(^)(CDBreak *breaK))block;

@end
