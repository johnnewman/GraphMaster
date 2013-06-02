//
//  GMAlgorithmSolver.h
//  GraphMaster
//
//  Created by John Newman on 6/2/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMAlgorithmSolver : NSObject

+ (GMAlgorithmSolver*)sharedInstance;
- (void)runDijkstrasWithNodes:(NSArray*)nodes;

@end
