//
//  CoreDataController.m
//  PomodoroTech
//
//  Created by Kronan on 5/17/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "CoreDataController.h"

@interface CoreDataController()


@end


@implementation CoreDataController

#pragma mark - init


- (CDUser *)user
{
    if (!_user){
        
            NSString *entityName = @"CDUser";
            _user = (CDUser*)[self createObject:self.contextPomodoro withEntityName:entityName];
            _user.login = @"defaultUser";
    }
    
    [_user.managedObjectContext save:nil];
    
    return _user;
}


- (CDTask *)task
{
    if (!_task){
        
        NSString *entityName = @"CDTask";
        _task = (CDTask*)[self createObject:self.contextPomodoro withEntityName:entityName];
        _task.name = @"defaultTask";
        _task.createTime = [NSDate date];
    
    }

    [_task.managedObjectContext save:nil];
    
    return _task;
}

// rewrite
- (CDPomodor *)pomodor
{
    if (!_pomodor){
        _pomodor = [self selectActivePomodor];
    }
    
    _pomodor.whoseTask = self.task;
    
    return _pomodor;
}


- (CDCondition *)condition
{
    if (!_condition){
        NSString *entityName = @"CDCondition";
        NSArray *conditionObjects = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:entityName];
        // We must have one CONDITION in CoreData;
        switch (conditionObjects.count) {
            case 0:
                _condition = (CDCondition*)[self createObject:self.contextPomodoro withEntityName:entityName];
                break;
            case 1:
                _condition = (CDCondition *)[conditionObjects firstObject];
                break;
            default:
                _condition = nil;
                
                @throw [NSException exceptionWithName:NSStringFromClass([self class]) reason:@"invalid Condition objects from CoreData" userInfo:nil];
                break;
        }
    }
    
    [_condition.managedObjectContext save:nil];
    
    return _condition;
}


- (NSManagedObjectContext *)contextPomodoro
{
    if (!_contextPomodoro){
        _contextPomodoro = [[self persistentContainer] newBackgroundContext];
    }
    
    return _contextPomodoro;
}


+ (instancetype)sharedInstance
{
    static CoreDataController *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CoreDataController alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - CoreData

// Select or Create defaultUSER
// We must have one user with an activeAttribute = YES
- (CDUser *)selectActiveUser
{
    NSString *stringName = @"CDUser";
    
    NSArray *activeUsers = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:stringName andActiveAttribute:YES];
    [self printObjects:self.contextPomodoro withEntityName:stringName];
    
    switch (activeUsers.count) {
        case 0:
            [self createObject:self.contextPomodoro withEntityName:stringName withName:@"defaultUser"];
            activeUsers = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:stringName andActiveAttribute:YES];
            break;
        case 1:
            nil;
            break;
        default:
            NSLog(@"Bad UsersData, more than one User have attributeActive = YES");
            break;
    }
    CDUser *user = [activeUsers firstObject];
    NSLog(@" user name = %@", [user valueForKey:@"login"]);
    
    return user;
}


// Select or Create defaultTASK
// We must have one task with an activeAttribute = YES
- (CDTask *)selectActiveTask
{
    NSString *stringName = @"CDTask";

    NSArray *activeTasks = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:stringName andActiveAttribute:YES];
    [self printObjects:self.contextPomodoro withEntityName:stringName];
    
    switch (activeTasks.count) {
        case 0:
            [self createObject:self.contextPomodoro withEntityName:stringName withName:@"defaultTask"];
            activeTasks = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:stringName andActiveAttribute:YES];
            break;
        case 1:
            nil;
            break;
        default:
            NSLog(@"Bad TasksData, more than one User have attributeActive = YES");
            break;
    }
    CDTask *task = [activeTasks firstObject];
    NSLog(@" task name = %@", [task valueForKey:@"name"]);
    
    
    return task;
}


- (CDPomodor *)selectActivePomodor
{
    NSString *stringName = @"CDPomodor";
    
    NSArray *activePomodors = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:stringName andActiveAttribute:YES];
    
    switch (activePomodors.count) {
        case 0:
            [self createObject:self.contextPomodoro withEntityName:stringName withName:nil];
            activePomodors = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:stringName andActiveAttribute:YES];
            break;
        case 1:
            nil;
            break;
        default:
            NSLog(@"Bad PomodorData, more than one Pomodor have attributeActive = YES");
            break;
    }
    
    CDPomodor *pomodor = [activePomodors firstObject];
    NSLog(@" pomodor create time = %@", pomodor.createTime);
    
    return pomodor;
}


- (NSManagedObject *)createObject:(NSManagedObjectContext *)context
                   withEntityName:(NSString *)entityName
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:context];
    
    [object.managedObjectContext save:nil];
    
    return object;
}


- (void)createObject:(NSManagedObjectContext *)context
             withEntityName:(NSString *)entityName
                   withName:(NSString *)name
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:context];
    
    if ([entityName isEqualToString: @"CDTask"]){
        [object setValue:name forKey:@"name"];
        [object setValue:@YES forKey:@"active"];
        [object setValue:[NSDate date] forKey:@"createTime"];
        
    }
    
    
    if ([entityName isEqualToString: @"CDUser"]){
        [object setValue:name forKey:@"login"];
        [object setValue:@YES forKey:@"active"];
    }

    if ([entityName isEqualToString:@"CDPomodor"])
    {
        CDPomodor *pomodorObject = (CDPomodor *)object;
        pomodorObject.active = @YES;
        pomodorObject.createTime = [NSDate date];
//        pomodorObject.duration = nil;
        pomodorObject.complit = nil; // complit or destroy
    }

    [object.managedObjectContext save:nil];
    
    NSLog(@"===========created = %@", entityName);
}


- (void)deleteObjectFromCoreData:(NSManagedObjectContext *)context withEntityName:entityName
{
    NSArray *allObjects = [self getObjectsFromCoreData:context withEntityName:entityName andActiveAttribute:NO];
    
    for (id object in allObjects) {
        [context deleteObject:object];
        NSLog(@"=== all objects are delete === ");
    }
    
}


- (void)printObjects:(NSManagedObjectContext *)context withEntityName:entityName
{
    NSArray *allObjects = [self getObjectsFromCoreData:context withEntityName:entityName andActiveAttribute:NO];
    
    int i = 0;
    for (id object in allObjects) {
        NSLog(@"===%@", object);
        i++;
    }
    NSLog(@"=== all elements in DB %i", i);
}


- (NSArray *)getObjectsFromCoreData:(NSManagedObjectContext *)context
                     withEntityName:(NSString *)entityName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    [request setEntity:description];
    
    NSError *requestErr = nil;
    NSArray *resultArray = [context executeFetchRequest:request error: &requestErr];
    if (requestErr){
        NSLog(@"giveObjectsFromCoreData err = %@", [requestErr localizedDescription]);
    }
    
    return resultArray;
}


- (NSArray *)getObjectsFromCoreData:(NSManagedObjectContext *)context
                     withEntityName:(NSString *)entityName
                 andActiveAttribute:(BOOL)isActive
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    [request setEntity:description];
    //[request setResultType:(NSDictionaryResultType)];
    
    if (isActive){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"active == YES"];
        request.predicate = predicate;
    }
    
    
    NSError *requestErr = nil;
    NSArray *resultArray = [context executeFetchRequest:request error: &requestErr];
    if (requestErr){
        NSLog(@"giveObjectsFromCoreData err = %@", [requestErr localizedDescription]);
    }
    
    return resultArray;
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"PomodoroTech"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


@end
