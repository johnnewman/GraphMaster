//
//  GMEdgeSelectionDelegate.h
//  GraphMaster
//
//  Created by John Newman on 4/17/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMEdge;

@protocol GMEdgeSelectionDelegate <NSObject>
- (void)edgeSelected:(GMEdge*)edge;
@end
