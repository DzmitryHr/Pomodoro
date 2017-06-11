//
//  CoreData.m
//  PomodoroTech
//
//  Created by Kronan on 5/17/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "CoreData.h"

@interface CoreData()

@property (nonatomic, strong, readwrite) NSPersistentContainer *persistentContainer;

@property (nonatomic, strong) CDUser *user;
@property (nonatomic, strong) CDTask *task;
@property (nonatomic, strong) CDPomodor *pomodor;
@property (nonatomic, strong) CDBreak   *breakP;

@end


@implementation CoreData

#pragma mark - init


- (CDUser *)user
{
    if (!_user){
        
        NSString *entityName = @"CDUser";
        _user = (CDUser*)[self getLastObject:self.mainContext withEntityName:entityName];
    }
    
    return _user;
}


- (CDTask *)task
{
    if (!_task){
        
        NSString *entityName = @"CDTask";
        _task = (CDTask*)[self getLastObject:self.mainContext withEntityName:entityName];;
    }
    
    return _task;
}


- (CDPomodor *)pomodor
{
    if (!_pomodor){
        NSString *entityName = @"CDPomodor";
        _pomodor = (CDPomodor*)[self createObject:self.mainContext withEntityName:entityName];
    }

    return _pomodor;
}


- (NSManagedObjectContext *)mainContext
{
    if (!_mainContext){
        _mainContext = self.persistentContainer.viewContext;
    }
    
    return _mainContext;
}


#pragma mark - CoreData


- (CDUser *)createUserWithLogin:(NSString *)login
{
    NSString *entityName = @"CDUser";
    CDUser *user = (CDUser *)[self createObject:self.mainContext withEntityName:entityName];
    
    self.user = user;
    
    user.createTime = [NSDate date];
    user.login = login;
    
    return user;
}


- (CDTask *)createTaskWithName:(NSString *)name
{
    NSString *entityName = @"CDTask";
    CDTask *task = (CDTask *)[self createObject:self.mainContext withEntityName:entityName];
    
    self.task = task;
    
    task.createTime = [NSDate date];
    task.name = name;
    
    if (self.user){
        task.whoseUser = self.user;
    }
    
    return task;
}


- (void)createPomodorWithDuration:(NSInteger)pomodorDuration withBlock:(void(^)(CDPomodor *pomodor))block
{
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
      
        NSString *entityName = @"CDPomodor";
        CDPomodor *pomodor = (CDPomodor *)[self createObject:self.mainContext withEntityName:entityName];
        
        self.pomodor = pomodor;
        
        pomodor.createTime = [NSDate date];
        pomodor.duration = @(pomodorDuration);
        pomodor.complit = @(NO);
        
        NSManagedObjectID *pomodorID = pomodor.objectID;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CDPomodor *pomodor = [self.persistentContainer.viewContext objectWithID:pomodorID];
            
            if (self.task){
                pomodor.whoseTask = self.task;
            }
            
            block(pomodor);
            
        });
        
    }];
    
}


- (CDBreak *)createBreakWithDuration:(NSInteger)breakDuration
{
    NSString *entityName = @"CDBreak";
    CDBreak *breaK = (CDBreak *)[self createObject:self.mainContext withEntityName:entityName];
    
    breaK.createTime = [NSDate date];
    breaK.duration = @(breakDuration);
    breaK.complit = @(NO);
    
    if (self.task){
        breaK.whoseTask = self.task;
    }
    
    [breaK.managedObjectContext save:nil];
    
    return breaK;
}


- (NSManagedObject *)createObject:(NSManagedObjectContext *)context
                   withEntityName:(NSString *)entityName
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:context];
    
    [object.managedObjectContext save:nil];
    
    return object;
}


- (void)deleteAllObjectFromCoreData:(NSManagedObjectContext *)context withEntityName:entityName
{
    NSArray *allObjects = [self getObjectsFromCoreData:context withEntityName:entityName];
    
    for (id object in allObjects) {
        [context deleteObject:object];
        NSLog(@"=== all objects are delete === ");
    }
    
}


- (void)printObjects:(NSManagedObjectContext *)context withEntityName:entityName
{
    NSArray *allObjects = [self getObjectsFromCoreData:context withEntityName:entityName];
    
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
 
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName
                                                   inManagedObjectContext:context];
    
    [request setEntity:description];
    
    NSError *requestErr = nil;
    NSArray *resultArray = [context executeFetchRequest:request error: &requestErr];
    if (requestErr){
        NSLog(@"giveObjectsFromCoreData err = %@", [requestErr localizedDescription]);
    }
    
    return resultArray;
}


- (NSManagedObjectContext *)getLastObject:(NSManagedObjectContext *)context
                           withEntityName:(NSString *)entityName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    [request setEntity:description];

    [request setFetchLimit:1];
    
    // sorting no createTime
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *requestErr = nil;
    NSArray *resultArray = [context executeFetchRequest:request error: &requestErr];
    
    
    return [resultArray lastObject];
}


- (CDUser *)getCurrentUser
{
    return self.user;
}


- (CDTask *)getCurrentTask
{
    return self.task;
}


#pragma mark - Core Data stack

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
