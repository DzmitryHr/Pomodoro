//
//  AppDelegate.m
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

@import UserNotifications;
#import "AppDelegate.h"
#import "TimerController.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSManagedObjectContext *contextPomodoro;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
    [self deleteObjectFromCoreData:self.contextPomodoro withEntityName:@"Task"];
    
    NSManagedObject *user = [self selectUser];
    NSLog(@" user name = %@", [user valueForKey:@"login"]);
    

    NSManagedObject *task = [self selectTask];
    if (![task valueForKey:@"whoseUser"]){
        [task setValue:user forKey:@"whoseUser"];
    }
    NSLog(@" task name = %@", [task valueForKey:@"name"]);
    
    
    
    
    [self createObjectContext:self.contextPomodoro withEntityName:@"User" withName:@"TwoUser"];
    
    
    [self printObjects:self.contextPomodoro withEntityName:@"User"];
    
    
    // Notification
    [self requestAuthorizationForNotification];

    //changed 25.f*60.f
    [[TimerController sharedInstance] installTimerDuration:25.f*60.f] ; //create once TimerController
    
    return YES;
}


#pragma mark - CoreData

// Select or Create defaultUSER
// We must have one user with an activeAttribute = YES
- (NSManagedObject *)selectUser
{
    NSArray *activeUsers = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:@"User" andActiveAttribute:YES];
    [self printObjects:self.contextPomodoro withEntityName:@"User"];
    
    switch (activeUsers.count) {
        case 0:
            [self createObjectContext:self.contextPomodoro withEntityName:@"User" withName:@"defaultUser"];
            activeUsers = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:@"User" andActiveAttribute:YES];
            break;
        case 1:
            nil;
            break;
        default:
            NSLog(@"Bad UsersData, more than one User have attributeActive = YES");
            break;
    }
    NSManagedObject *user = [activeUsers firstObject];
    NSLog(@" user name = %@", [user valueForKey:@"login"]);
   
    return user;
}


// Select or Create defaultTASK
// We must have one task with an activeAttribute = YES
- (NSManagedObject *)selectTask
{
    NSArray *activeTasks = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:@"Task" andActiveAttribute:YES];
    [self printObjects:self.contextPomodoro withEntityName:@"Task"];
    
    switch (activeTasks.count) {
        case 0:
            [self createObjectContext:self.contextPomodoro withEntityName:@"Task" withName:@"defaultTask"];
            activeTasks = [self getObjectsFromCoreData:self.contextPomodoro withEntityName:@"Task" andActiveAttribute:YES];
            break;
        case 1:
            nil;
            break;
        default:
            NSLog(@"Bad TasksData, more than one User have attributeActive = YES");
            break;
    }
    NSManagedObject *task = [activeTasks firstObject];
    NSLog(@" task name = %@", [task valueForKey:@"name"]);
    
    return task;
}

- (NSManagedObjectContext *)contextPomodoro
{
    if (!_contextPomodoro)
        _contextPomodoro = [[self persistentContainer] newBackgroundContext];
    
    return _contextPomodoro;
}


- (void)createObjectContext:(NSManagedObjectContext *)context
             withEntityName:(NSString *)entityName
                   withName:(NSString *)name
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:context];
    
    if ([entityName isEqualToString: @"Task"]){
        [object setValue:name forKey:@"name"];
        [object setValue:@YES forKey:@"active"];
        [object setValue:[NSDate date] forKey:@"createTime"];
        
    }
        
    
    if ([entityName isEqualToString: @"User"]){
        [object setValue:name forKey:@"login"];
        [object setValue:@YES forKey:@"active"];
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


#pragma mark - Notification
- (void)requestAuthorizationForNotification
{
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNAuthorizationOptions option = UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge;
    
    [center requestAuthorizationWithOptions:option
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!granted){
                                  NSLog(@"requestAuthorization: Something went wrong");
                              };
                          }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
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
