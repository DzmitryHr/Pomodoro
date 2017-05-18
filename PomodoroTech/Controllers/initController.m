//
//  initController.m
//  PomodoroTech
//
//  Created by Kronan on 5/18/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "initController.h"
#import "CoreDataController.h"
//#import <CoreData/CoreData.h>

@interface initController()

@property (nonatomic, strong) NSManagedObjectContext *contextCD;

@end


@implementation initController

-(NSManagedObjectContext*)contextCD
{
    if (!_contextCD){
        _contextCD = [[CoreDataController sharedInstance] contextPomodoro];
    }
    return _contextCD;
}

+ (void)start
{
    
}


@end
