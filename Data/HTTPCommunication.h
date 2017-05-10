//
//  HTTPCommunication.h
//  PomodoroTech
//
//  Created by Kronan on 5/8/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPCommunication : NSObject

+ (instancetype)sharedInstance;

-(void)registerUserWithName:(NSString *)name email:(NSString *)email password:(NSString *)password successBlock:(void(^)(BOOL success, NSString *userToken))successBlock;

-(void)loginUserWithEmail:(NSString *)email password:(NSString *)password successBlock:(void(^)(BOOL success, NSString *userToken))successBlock;

-(void)validateUserWithToken:(NSString *)token successBlock:(void(^)(BOOL success, BOOL isValidUser))successBlock;

-(void)createObjectWithData:(NSDictionary *)data successBlock:(void(^)(BOOL success))successBlock;


-(void)updateObjectWithData:(NSDictionary *)data successBlock:(void(^)(BOOL success))successBlock;


-(void)retrieveObjectsWithSuccessBlock:(void(^)(BOOL succes, NSArray *objects))successBlock;


@end
