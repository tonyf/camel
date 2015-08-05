//
//  ProcessedDirection.h
//  Sidekick
//
//  Created by Tony Francis on 7/13/15.
//  Copyright (c) 2015 thesquad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProcessedDirection : NSObject
@property (nonatomic, strong) NSString *instruction;
@property (nonatomic, strong) NSString *turnDirection;
@property (nonatomic, strong) NSString *turnStreet;

- (instancetype)initWithInstruction:(NSString *)instruction turnDirection:(NSString *)turnDirection street:(NSString *)turnStreet;

@end
