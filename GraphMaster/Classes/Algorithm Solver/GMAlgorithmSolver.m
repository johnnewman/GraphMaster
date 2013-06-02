//
//  GMAlgorithmSolver.m
//  GraphMaster
//
//  Created by John Newman on 6/2/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMAlgorithmSolver.h"
#import "GMNodeView.h"
#import "GMEdge.h"

static GMAlgorithmSolver *sharedInstance;

@implementation GMAlgorithmSolver


- (id)init {
    if (self = [super init]) {
    }
    return self;
}

+ (GMAlgorithmSolver*)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[GMAlgorithmSolver alloc] init];
        return sharedInstance;
    }
}

- (void)runDijkstrasWithNodes:(NSArray*)nodes
{
    GMNodeView *startNode = [nodes objectAtIndex:0];
    
    for (GMNodeView *node in nodes) {
        node.distance = INT32_MAX;
        node.previousNode = nil;
    }
    startNode.distance = 0;
    
    NSMutableArray *queue = [NSMutableArray arrayWithArray:nodes];
    
    NSComparisonResult (^distanceComparator)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2) {
        NSInteger difference = ((GMNodeView*)obj1).distance - ((GMNodeView*)obj2).distance;
        if (difference == 0)
            difference = ((GMNodeView*)obj1).number - ((GMNodeView*)obj2).number;
        if (difference > 0)
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    };
    
    [queue sortUsingComparator:distanceComparator];
    GMNodeView *currentNode;
    while (queue.count > 0) {
        currentNode = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        for (GMEdge *edge in currentNode.outgoingEdges) {
            GMNodeView *otherNodeOnEdge = edge.destNode;
            if (otherNodeOnEdge.distance > currentNode.distance + edge.weight) {
                otherNodeOnEdge.distance = currentNode.distance + edge.weight;
                otherNodeOnEdge.previousNode = currentNode;
                [queue sortUsingComparator:distanceComparator];
            }
        }
    }
    
    //color the used edges
    for (GMNodeView *node in nodes) {
        if (node.previousNode != nil) {  //will be null on start node
            for (GMEdge *edge in node.previousNode.outgoingEdges) {
                if (edge.destNode == node){
                    edge.isTraveled = YES;
                    break;
                }
            }
        }
    }

}

@end
