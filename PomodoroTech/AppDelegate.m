//
//  AppDelegate.m
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

@import UserNotifications;
#import "AppDelegate.h"
#import "TimerViewController.h"
#import "CoordinatorController.h"
#import "CoreData.h"
#import "Loader.h"

#import "TasksDataManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame: UIScreen.mainScreen.bounds];
   
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *rootNavigationController = (UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"rootNavigationController"];
    
    
// ???  how can assign rootVC to navigationController in code ???
    
    self.loader = [[Loader alloc] init];
    
    CoreData *coreData = [[CoreData alloc] init];
    
    CoordinatorController *coordinator = [[CoordinatorController alloc] initWithLoader:self.loader
                                                                              coreData:coreData];

    TimerViewController *timerViewController = (TimerViewController *)rootNavigationController.topViewController;
    timerViewController.coordinator = coordinator;
    
    // ???
    TasksDataManager *tasksDataManager = [[TasksDataManager alloc] initWithManagedObjectContext:coreData.mainContext];
    
    self.window.rootViewController = rootNavigationController;
    [self.window makeKeyAndVisible];
    
    
    
    
    
    
    // Notification
    [self requestAuthorizationForNotification];
    
    return YES;
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
    
    [self.loader saveSettings];
    
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
    
 //   [[CoreData sharedInstance] saveContext];
}



@end
