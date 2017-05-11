//
//  HTTPCommunication.m
//  PomodoroTech
//
//  Created by Kronan on 5/8/17.
//  Copyright © 2017 Kronan. All rights reserved.
//

#import "HTTPCommunication.h"

const NSString *apiKey = @"DC46E864-3279-EE85-FF47-C1D862157C00";
const NSString *restKey = @"02A7A81F-2F3C-99DF-FFC6-2239C39EBF00";


@interface HTTPCommunication()

@property (nonatomic, strong) NSURLSession *session;

@end


@implementation HTTPCommunication


+ (instancetype)sharedInstance
{
    static HTTPCommunication *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HTTPCommunication alloc] init];
   });
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self createSession];
    }
    
    return self;
}


- (void) createSession
{
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf];
    self.session = session;
}

#pragma mark - request

-(void)doGETWithURL:(NSURL *)url successBlock:(void(^)(NSData *data))successBlock
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [self dataWithRequest:request successBlock:successBlock];
}


-(void)doPOSTWithURL:(NSURL *)url andJSONData:(NSData *)data andUserToken:(NSString *)userToken successBlock:(void(^)(NSData *data))successBlock
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:userToken forHTTPHeaderField:@"user-token"];
    
    [self dataWithRequest:request successBlock:successBlock];
}


-(void)dataWithRequest:(NSURLRequest *)request successBlock:(void(^)(NSData *))successBlock
{
    if (!successBlock) {
        return;
    }
    
    NSURLSessionDataTask * dataTask = [self.session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
     
                                                        successBlock(data);
                                                   
                                                    }];
    
    [dataTask resume];
}


- (NSURL *)urlWithPath:(NSString *)path
{
    NSString *stringURL = [NSString stringWithFormat:@"https://api.backendless.com/%@/%@/%@",apiKey,restKey,path];
    
    NSURL *url = [NSURL URLWithString:stringURL];
    
    return url;
}


#pragma mark - functional

-(void)registerUserWithName:(NSString *)name email:(NSString *)email password:(NSString *)password successBlock:(void(^)(BOOL success, NSString *userToken))successBlock
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"name":name,
                                                                 @"email":email,
                                                                 @"password":password}
                                                       options:0
                                                         error:nil];
    
    NSURL *url = [self urlWithPath:@"users/register"];
 
    [self doPOSTWithURL:url andJSONData:jsonData andUserToken:nil successBlock:^(NSData *data) {
        if (!data){
            successBlock(NO, nil);
            return;
        }
        
        NSArray *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (!userData) {
            successBlock(NO, nil);
            return;
        }
        
        //login
        [self loginUserWithEmail:email password:password successBlock:successBlock];
        
    }];
}


-(void)loginUserWithEmail:(NSString *)email password:(NSString *)password successBlock:(void(^)(BOOL success, NSString *userToken))successBlock
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"login":email,
                                                                 @"password":password}
                                                       options:0
                                                         error:nil];
    
    NSURL *url = [self urlWithPath:@"users/login"];
    
    [self doPOSTWithURL:url andJSONData:jsonData andUserToken:nil successBlock:^(NSData *data) {
        if (!data){
            successBlock(NO, nil);
            return;
        }
        
        NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (!userData) {
            successBlock(NO, nil);
            return;
        }
        
        successBlock(YES, userData[@"user-token"]);
        
    }];

    
}



-(void)validateUserWithToken:(NSString *)token successBlock:(void(^)(BOOL success, BOOL isValidUser))successBlock
{
    if (!token) {
        successBlock(NO, nil);
        NSLog(@"missing token");
        return;
    }
    
    NSString *pathStringUrl = [NSString stringWithFormat:@"users/isvalidusertoken/%@",token];
    NSURL *url = [self urlWithPath:pathStringUrl];
    
    [self doGETWithURL:url successBlock:^(NSData *data) {
        if (!data){
            successBlock(NO, nil);
            return;
        }
        
        // return data with NSString
        NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        BOOL isValid = [strData boolValue];
        
        successBlock(YES, isValid);
        
        
    }];
    
    
}

//  should I get name Entity in method???
//  should I return the objectID in successBlock???
-(void)createObjectWithData:(NSDictionary *)data token:(NSString *)userToken successBlock:(void(^)(BOOL success))successBlock
{
    NSString *pathSrtingUrl =[NSString stringWithFormat:@"data/Tasks"];
    NSURL *url = [self urlWithPath:pathSrtingUrl];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    
    [self doPOSTWithURL:url andJSONData:jsonData andUserToken:userToken successBlock:^(NSData *data) {
        if (!data){
            successBlock(NO);
            return;
        }
        
        NSDictionary *objectData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"createObjectWithData:: created objectID = %@",objectData[@"objectId"]);
        
        successBlock(YES);
    }];

    /*
     if created then return from server: json (dictionary)
     where there is:
     "objectId": "D4A9D5C9-CE2A-6079-FF51-39D695310500"
     */
}


-(void)updateObjectWithData:(NSDictionary *)data successBlock:(void(^)(BOOL success))successBlock
{
    
    
}

// for time???
// for entity???
-(void)retrieveObjectsWithSuccessBlock:(void(^)(BOOL succes, NSArray *objects))successBlock
{
    NSString *pathSrtingUrl =[NSString stringWithFormat:@"data/Tasks"];
    NSURL *url = [self urlWithPath:pathSrtingUrl];
    
    [self doGETWithURL:url successBlock:^(NSData *data) {
        if (!data){
            successBlock(NO, nil);
            return;
        };
        
        NSArray *objectsData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        successBlock(YES, objectsData);
        
        
    }];
}


@end
