//
//  GMGraphViewController.m
//  GraphMaster
//
//  Created by John Newman on 3/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMGraphViewController.h"
#import "GMGraphCanvass.h"
#import "GMNodeView.h"
#import "GMEdge.h"
#import <QuartzCore/QuartzCore.h>


@interface GMGraphViewController ()
- (IBAction)canvassTapGesture:(UITapGestureRecognizer*)tapGestureRecognizer;
- (IBAction)nodeButtonSelected;
- (IBAction)edgeButtonSelected;

- (void)addNewNodeToTapLocation:(CGPoint)tapLocation;

@property (nonatomic, weak) IBOutlet GMGraphCanvass *graphCanvass;
@end

@implementation GMGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    nodes = [NSMutableArray arrayWithCapacity:10];
    _graphCanvass.nodes = nodes;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)canvassTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {    
    if (currentDrawType == NODE_TYPE)
        [self addNewNodeToTapLocation:[tapGestureRecognizer locationInView:_graphCanvass]];
}

- (void)addNewNodeToTapLocation:(CGPoint)tapLocation {
    GMNodeView *node = [[GMNodeView alloc] initWithNumber:[nodes count]];
    node.delegate = self;
    [nodes addObject:node];
    node.frame = CGRectMake(tapLocation.x - kNODE_RADIUS, tapLocation.y - kNODE_RADIUS, kNODE_RADIUS*2, kNODE_RADIUS*2);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:node action:@selector(tapOccurred:)];
    [node addGestureRecognizer:tapGesture];
    [_graphCanvass addSubview:node];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touches began controller");
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_graphCanvass.isDrawingNewEdge) {
        CGPoint endPoint = [[touches anyObject] locationInView:_graphCanvass];
        GMNodeView *destinationNode = [self nodeInPoint:endPoint];
        if (destinationNode && destinationNode != _graphCanvass.nodeWithTouches) {
            NSLog(@"edge destination: %d", destinationNode.number);
            GMEdge *newEdge = [[GMEdge alloc] initWithWeight:5 startNode:_graphCanvass.nodeWithTouches destNode:destinationNode];
            newEdge.delegate = self;
            [_graphCanvass addSubview:newEdge.weightButton];
            [_graphCanvass.nodeWithTouches addOutgoingEdge:newEdge];
            [destinationNode addIncomingEdge:newEdge];
            [_graphCanvass setNeedsDisplay];
        }
    }
    _graphCanvass.isDrawingNewEdge = NO;
    [super touchesEnded:touches withEvent:event];
}

- (GMNodeView*)nodeInPoint:(CGPoint)point {
    for (GMNodeView *nodeView in nodes)
        if (CGRectContainsPoint(nodeView.frame, point))
            return nodeView;
    return nil;
}

- (IBAction)nodeButtonSelected {
    currentDrawType = NODE_TYPE;
}

- (IBAction)edgeButtonSelected {
    currentDrawType = EDGE_TYPE;
}

#pragma mark -
#pragma mark GMNodeViewSelectionDelegate

- (void)nodeViewTouchesBegan:(GMNodeView *)nodeView {
    _graphCanvass.nodeWithTouches = nodeView;
}

- (void)nodeViewIsMovingOrigin:(GMNodeView *)nodeView {
    [_graphCanvass setNeedsDisplay];
}

#pragma mark -
#pragma mark GMEdgeSelectionDelegate

- (void)edgeSelected:(GMEdge *)edge {
    NSLog(@"edge selected: %d", edge.weight);
    [_graphCanvass setNeedsDisplay];
}

@end
