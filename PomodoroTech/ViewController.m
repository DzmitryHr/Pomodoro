//
//  ViewController.m
//  PomodoroTech
//
//  Created by Kronan on 4/28/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "ViewController.h"
#import "HTTPCommunication.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *userToken;

@property (weak, nonatomic) IBOutlet UITextField *login;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *informLable;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
      NSLog(@"ViewController viewDidLoad");
}



- (IBAction)registerUserButton:(UIButton *)sender {
    NSLog(@"= %@", self.login.text);
    NSLog(@"= %@", self.password.text);
    
 
    [[HTTPCommunication sharedInstance] registerUserWithName:@"user7" email:@"user7@gmail.com" password:@"no"
                                                successBlock:^(BOOL success, NSString *userToken) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.informLable.text = userToken;
            self.userToken = userToken;
        });
        
    }];
}


- (IBAction)signInButton:(UIButton *)sender {
    [[HTTPCommunication sharedInstance] loginUserWithEmail:@"user7@gmail.com" password:@"no" successBlock:^(BOOL success, NSString *userToken) {
  
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userToken = userToken;
            self.informLable.text = [NSString stringWithFormat:@" token = %@,\n user is LogIn = %d", userToken, success];
        });
        
    }];
    
}


- (IBAction)validateUserButton:(UIButton *)sender
{
    [[HTTPCommunication sharedInstance] validateUserWithToken:self.userToken
                                                 successBlock:^(BOOL success, BOOL isValidUser) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.informLable.text = [NSString  stringWithFormat:@"userValidate is = %d",isValidUser];
                                                         
        });
                                                     
                                
    }];
    
}


- (IBAction)createData:(UIButton *)sender
{
    if (!self.userToken){
        self.informLable.text = @"userToken is missing";
        return;
    }
    NSDictionary *dict = @{
                           @"name" : @"task1",
                           @"plannedPomodors" : @5,
                           @"eatenPomodors" : @3
                           };
    
    [[HTTPCommunication sharedInstance] createObjectWithData:dict token:self.userToken successBlock:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(),^{
            if (success) {
                self.informLable.text = @"objectCreatedServer";
            }
            
        });
    }];
    
}


- (IBAction)retrieveData:(UIButton *)sender
{
    [[HTTPCommunication sharedInstance] retrieveObjectsWithSuccessBlock:^(BOOL succes, NSArray *objects) {
        dispatch_async(dispatch_get_main_queue(),^{
            if (succes){
                NSLog(@"retrieveData:: I have array of objects from server = %lu", (unsigned long)objects.count);
                self.informLable.text = [NSString stringWithFormat:@"retrieveData:: I have array of objects from server = %lu", (unsigned long)objects.count];
            }
        });
    }];
}



//realize updating data - put method - 


@end
