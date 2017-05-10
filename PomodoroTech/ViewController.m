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


- (IBAction)getDataButton:(UIButton *)sender {
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


- (IBAction)validateUserButton:(UIButton *)sender
{
    [[HTTPCommunication sharedInstance] validateUserWithToken:self.userToken
                                                 successBlock:^(BOOL success, BOOL isValidUser) {
            self.informLable.text = [NSString  stringWithFormat:@"userValidate is = %@",isValidUser];
    }];
    
}










@end
