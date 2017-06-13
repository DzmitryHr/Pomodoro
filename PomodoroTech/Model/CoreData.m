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
@property (nonatomic, strong) NSManagedObjectContext *localMainContext;


@end


@implementation CoreData


#pragma mark - init


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.localMainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
# warning - coordinator???
        self.localMainContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator;
    }
    
    return self;
}


@dynamic mainContext;
- (NSManagedObjectContext *)mainContext
{
    return self.persistentContainer.viewContext;
}


#pragma mark - CoreData

- (CDUser *)createUserInMainContextWithLogin:(NSString *)login
{
    NSString *entityName = @"CDUser";
    CDUser *user = (CDUser *)[self createObject:self.localMainContext withEntityName:entityName];
    
    user.createTime = [NSDate date];
    user.login = login;
    
    [user.managedObjectContext save:nil];
    
    return user;
}


- (void)createUserWithLogin:(NSString *)login withBlock:(void(^)(CDUser *))block
{
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        NSString *entityName = @"CDUser";
        CDUser *user = (CDUser *)[self createObject:context withEntityName:entityName];
        
        user.createTime = [NSDate date];
        user.login = login;
        
        [user.managedObjectContext save:nil];
        
        NSManagedObjectID *userID = user.objectID;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CDUser *user = [self.mainContext objectWithID:userID];
           
            if (block){
                block(user);
            };
        });
        
        
    }];
}


- (CDTask *)createTaskInMainContextWithName:(NSString *)name forUser:(CDUser *)user
{
    NSString *entityName = @"CDTask";
    CDTask *task = (CDTask *)[self createObject:self.localMainContext withEntityName:entityName];
    
    task.createTime = [NSDate date];
    task.name = name;
    task.whoseUser = user;
    
    [user.managedObjectContext save:nil];
    
    return task;
}


- (void)createTaskWithName:(NSString *)name forUser:(CDUser *)user withBlock:(void(^)(CDTask *))block
{
    NSManagedObjectID *userID = user.objectID;
    
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        NSString *entityName = @"CDTask";
        CDTask *task = (CDTask *)[self createObject:context withEntityName:entityName];
        
        task.createTime = [NSDate date];
        task.lastUseTime = nil;
        task.name = name;
        task.whoseUser = [context objectWithID:userID];
        
        NSManagedObjectID *taskID = task.objectID;
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CDTask *task = [self.mainContext objectWithID:taskID];
            
            if (block){
                block(task);
            };
        });
    }];
    
}


- (CDPomodor *)createPomodorInMainContextWithDuration:(NSInteger)pomodorDuration
                                              forTask:(CDTask *)task
{
    NSString *entityName  = @"CDPomodor";
    
    CDPomodor *pomodor = (CDPomodor *)[self createObject:self.localMainContext withEntityName:entityName];
    
    pomodor.createTime = [NSDate date];
    pomodor.duration = @(pomodorDuration);
    
# warning - other context???
    NSManagedObjectID *taskID = [task objectID];
    CDTask *taskInThisContext = (CDTask *)[self.localMainContext objectWithID:taskID];
    
    pomodor.whoseTask = taskInThisContext;
    
    [pomodor.managedObjectContext save:nil];
    [task.managedObjectContext save:nil];
    
    return pomodor;
};


- (CDPomodor *)createPomodorWithDuration:(NSInteger)pomodorDuration
                                 forTask:(CDTask *)task
{
    __block CDPomodor *pomodor = nil;
    
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        NSString *entityName = @"CDPomodor";
        pomodor = (CDPomodor *)[self createObject:context withEntityName:entityName];
        
        pomodor.createTime = [NSDate date];
        pomodor.duration = @(pomodorDuration);
        pomodor.complit = @(NO);
        pomodor.whoseTask = task;
    }];
    
    return pomodor;
}


// ??? maybe not use ???
- (void)createPomodorWithDuration:(NSInteger)pomodorDuration
                          forTask:(CDTask *)task
                        withBlock:(void (^)(CDPomodor *))block
{
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        NSString *entityName = @"CDPomodor";
        CDPomodor *pomodor = (CDPomodor *)[self createObject:context withEntityName:entityName];
        
        pomodor.createTime = [NSDate date];
        pomodor.duration = @(pomodorDuration);
        pomodor.complit = @(NO);
        pomodor.whoseTask = task;
        
        NSManagedObjectID *pomodorID = pomodor.objectID;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CDPomodor *pomodor = [self.mainContext objectWithID:pomodorID];
            
            block(pomodor);
        });
        
    }];
}


- (CDBreak *)createBreakInMainContextWithDuration:(NSInteger)breakDuration
                                          forTask:(CDTask *)task
{
    NSString *entityName = @"CDBreak";
    CDBreak *breaK = (CDBreak *)[self createObject:self.localMainContext withEntityName:entityName];
    
    breaK.createTime = [NSDate date];
    breaK.whoseTask = task;
    
    [breaK.managedObjectContext save:nil];
    
    return breaK;
}


- (void)createBreakWithDuration:(NSInteger)breakDuration
                        forTask:(CDTask *)task
                      withBlock:(void (^)(CDBreak *))block
{
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * context) {
        NSString *entityName = @"CDBreak";
        CDBreak *breaK = (CDBreak *)[self createObject:context withEntityName:entityName];
        
        breaK.createTime = [NSDate date];
        breaK.duration = @(breakDuration);
        breaK.complit = @(NO);
        breaK.whoseTask = task;
        
        NSManagedObjectID *breaKID = breaK.objectID;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CDBreak *breaK = [self.mainContext objectWithID:breaKID];
            block(breaK);
        });
        
    }];
}


- (NSManagedObject *)createObject:(NSManagedObjectContext *)context
                   withEntityName:(NSString *)entityName
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:context];
    
    return object;
}


- (CDUser *)getUserWithLogin:(NSString *)login;
{
    NSString *entityName = @"CDUser";
    NSString *predicateName = @"login";
    return (CDUser *)[self getObjectWithEntityName:entityName andName:login forPredicate:predicateName];
}


- (CDTask *)getTaskWithName:(NSString *)name;
{
    NSString *entityName = @"CDTask";
    NSString *predicateName = @"name";
    return (CDTask *)[self getObjectWithEntityName:entityName andName:name forPredicate:predicateName];
}


- (NSManagedObject *)getObjectWithEntityName:(NSString *)entityName
                                     andName:(NSString *)name
                                forPredicate:(NSString *)predicateName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
 
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName
                                                   inManagedObjectContext:self.mainContext];
    request.entity = description;
    //request.predicate = [NSPredicate predicateWithFormat:@"%@ == %@", predicateName, name];
    
    NSError *requestErr = nil;
    NSArray *objectsCD = [self.mainContext executeFetchRequest:request error: &requestErr];
    if (requestErr){
        NSLog(@"giveObjectsFromCoreData err = %@", [requestErr localizedDescription]);
    }
    
//    [self printObjects:self.mainContext withEntityName:entityName];
    
    return [objectsCD firstObject];
}

/*
 - (void)deleteAllObjectFromCoreData:(NSManagedObjectContext *)context withEntityName:entityName
 {
 NSArray *allObjects = [self getObjectsFromCoreData:context withEntityName:entityName];
 
 for (id object in allObjects) {
 [context deleteObject:object];
 NSLog(@"=== all objects are delete === ");
 }
 
 }
 
 */
 - (void)printObjects:(NSManagedObjectContext *)context withEntityName:entityName
 {
     
     NSFetchRequest *request = [[NSFetchRequest alloc] init];
     
     NSEntityDescription *description = [NSEntityDescription entityForName:entityName
                                                    inManagedObjectContext:self.mainContext];
     request.entity = description;
   //  request.predicate = [NSPredicate predicateWithFormat:@"%@ == %@", predicateName, name];
     
     NSError *requestErr = nil;
     NSArray *allObjects = [self.mainContext executeFetchRequest:request error: &requestErr];
     if (requestErr){
         NSLog(@"giveObjectsFromCoreData err = %@", [requestErr localizedDescription]);
     }
    
     int i = 0;
     for (id object in allObjects) {
         NSLog(@"===%@", object);
         i++;
     }
    
     
     NSLog(@"=== all elements in DB %i", i);
 }




/*
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
*/

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
