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
   
   /*
    [self deleteObjectFromCoreData:self.contextPomodoro];
    [self createObjectWithContext:self.contextPomodoro];
    [self createObjectWithContext:self.contextPomodoro];
    [self printAllObjects:self.contextPomodoro];
    [self.contextPomodoro save:nil];
*/
    
    [self requestAuthorizationForNotification];
    
    //changed 25.f*60.f
    [[TimerController sharedInstance] installTimerDuration:25.f*60.f] ; //create once TimerController
    
    return YES;
}


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


- (NSManagedObjectContext *)contextPomodoro
{
    if (!_contextPomodoro)
        _contextPomodoro = [[self persistentContainer] newBackgroundContext];
    
    return _contextPomodoro;
}


- (void)createObjectWithContext:(NSManagedObjectContext *)context
{
    GRTask *task1 = [NSEntityDescription insertNewObjectForEntityForName:@"GRTask"
                                                  inManagedObjectContext:context];
    
    [task1 setValue:@"progrCoreDataTask" forKey:@"name"];
    task1.plannedPomedors = 1 + arc4random_uniform(8);
    task1.createTime = [NSDate dateWithTimeIntervalSinceNow:30];
    
    [task1.managedObjectContext save:nil];
    
    NSLog(@"===========created task1");
    NSLog(@"%@", task1);
}


- (void)deleteObjectFromCoreData:(NSManagedObjectContext *)context
{
    NSArray *allObjects = [self giveObjectsFromCoreData:context];
    
    for (id object in allObjects) {
        [context deleteObject:object];
        NSLog(@"=== all objects are delete === ");
    }
    
}


- (void)printAllObjects:(NSManagedObjectContext *)context
{
    NSArray *allObjects = [self giveObjectsFromCoreData:context];
    
    int i = 0;
    for (id object in allObjects) {
        NSLog(@"===%@", object);
        i++;
    }
    NSLog(@"=== all elements in DB %i", i);
}


- (NSArray *)giveObjectsFromCoreData:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"GRTask" inManagedObjectContext:context];
    [request setEntity:description];
    
    NSError *requestErr = nil;
    NSArray *resultArray = [context executeFetchRequest:request error: &requestErr];
    
    return resultArray;
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
