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

@property (nonatomic, strong) CDUser *user;
@property (nonatomic, strong) CDTask *task;
@property (nonatomic, strong) CDPomodor *pomodor;
@property (nonatomic, strong) CDBreak   *breakP;

- (void)saveContext;

+ (instancetype)sharedInstance;

@end
