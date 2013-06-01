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
#import "GMEdgeOptionsViewController.h"
#import "GMNodeOptionsViewController.h"
#import "WEPopoverController.h"
#import "GMGraphOptionsView.h"
#import "XBPageDragView.h"


@interface GMGraphViewController ()

- (IBAction)doneShowingOptionsView;
- (IBAction)canvassTapGesture:(UITapGestureRecognizer*)tapGestureRecognizer;
- (void)addNewNodeAtPoint:(CGPoint)point;
- (void)drawNewEdgeIfNeededForPoint:(CGPoint)point;
- (GMNodeView*)nodeInPoint:(CGPoint)point;
- (WEPopoverContainerViewProperties *)improvedContainerViewProperties;

@property (nonatomic, weak) IBOutlet GMGraphCanvass *graphCanvass;
@property (nonatomic, weak) IBOutlet GMGraphOptionsView *graphOptionsView;
@property (nonatomic, weak) IBOutlet XBPageDragView *pageDragView;
@end

@implementation GMGraphViewController

@synthesize graphCanvass = _graphCanvass;
@synthesize graphOptionsView = _graphOptionsView;
@synthesize pageDragView = _pageDragView;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    nodes = [NSMutableArray arrayWithCapacity:10];
    _graphCanvass.nodes = nodes;
    
    _graphOptionsView.tableView.layer.cornerRadius = 10.0;
    _graphOptionsView.selectionDelegate = self;
    
    XBSnappingPoint *point = [[XBSnappingPoint alloc] initWithPosition:CGPointMake(_pageDragView.viewToCurl.frame.size.width*0.1, _pageDragView.viewToCurl.frame.size.height*0.1) angle:7*M_PI/8 radius:80 weight:0.5];
    [_pageDragView.pageCurlView addSnappingPoint:point];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)graphOptionsView:(GMGraphOptionsView *)optionsView didSelectAlgorithm:(AlgorithmType)type {
    if (type == kDIJKSTRAS) {
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
        [_graphCanvass setNeedsDisplay];
    }
}



- (IBAction)doneShowingOptionsView {
    [_pageDragView uncurlPageAnimated:YES completion:nil];
}



#pragma mark -
#pragma mark New Node Methods


- (IBAction)canvassTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {    
    [self addNewNodeAtPoint:[tapGestureRecognizer locationInView:_graphCanvass]];
}

- (void)addNewNodeAtPoint:(CGPoint)point {
    GMNodeView *node = [[GMNodeView alloc] initWithNumber:[nodes count]];
    node.delegate = self;
    [nodes addObject:node];
    node.frame = CGRectMake(point.x - kNODE_RADIUS, point.y - kNODE_RADIUS, kNODE_RADIUS*2, kNODE_RADIUS*2);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:node action:@selector(tapOccurred:)];
    [node addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:node action:@selector(longPressOccurred:)];
    [node addGestureRecognizer:longPressGesture];
    [_graphCanvass addSubview:node];
}


#pragma mark -
#pragma mark New Edge Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_graphCanvass.isDrawingNewEdge) {
        [self drawNewEdgeIfNeededForPoint:[[touches anyObject] locationInView:_graphCanvass]];
        _graphCanvass.isDrawingNewEdge = NO;
    }
    [_graphCanvass setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}

- (void)drawNewEdgeIfNeededForPoint:(CGPoint)point {
    GMNodeView *destinationNode = [self nodeInPoint:point];
    if (destinationNode && destinationNode != _graphCanvass.nodeWithNewEdge && ![_graphCanvass.nodeWithNewEdge.outgoingNodes containsObject:destinationNode]) {
        int randWeight = arc4random() % 100;
        GMEdge *newEdge = [[GMEdge alloc] initWithWeight:randWeight startNode:_graphCanvass.nodeWithNewEdge destNode:destinationNode];
        newEdge.delegate = self;
        [_graphCanvass addSubview:newEdge.weightButton];
        [_graphCanvass.nodeWithNewEdge addOutgoingEdge:newEdge];
        [_graphCanvass setNeedsDisplay];
    }
}

- (GMNodeView*)nodeInPoint:(CGPoint)point {
    for (GMNodeView *nodeView in nodes)
        if (CGRectContainsPoint(nodeView.frame, point))
            return nodeView;
    return nil;
}


#pragma mark -
#pragma mark GMNodeViewSelectionDelegate

- (void)nodeView:(GMNodeView *)nodeView isDrawingEdgeToPoint:(CGPoint)point {
    NSLog(@"nodeView isDrawingEdgeToPoint");
    _graphCanvass.isDrawingNewEdge = YES;
    [_graphCanvass drawNewEdgeFromNode:nodeView toPoint:point];
}

- (void)nodeViewIsMovingOrigin:(GMNodeView *)nodeView {
    [_graphCanvass setNeedsDisplay];
}

- (void)nodeViewNeedsOptionsDialog:(GMNodeView*)nodeView {
    NSLog(@"node view needs option dialog: %d", nodeView.number);
    
    GMNodeOptionsViewController *nodeOptionsViewController = [[GMNodeOptionsViewController alloc] initWithNibName:nil bundle:nil];
    popoverController = [[WEPopoverController alloc] initWithContentViewController:nodeOptionsViewController];
    [popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
    [popoverController presentPopoverFromRect:nodeView.frame inView:_graphCanvass permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}


#pragma mark -
#pragma mark GMEdgeSelectionDelegate

- (void)edgeSelected:(GMEdge *)edge {
    selectedEdge = edge;
    
    GMEdgeOptionsViewController *edgeOptionsViewController = [[GMEdgeOptionsViewController alloc] initWithNibName:nil bundle:nil];
    edgeOptionsViewController.delegate = self;
    popoverController = [[WEPopoverController alloc] initWithContentViewController:edgeOptionsViewController];
    [popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
    [popoverController presentPopoverFromRect:edge.weightButton.frame inView:_graphCanvass permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}


#pragma mark -
#pragma mark Popover Properties

- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] init];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin;
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;
}





#pragma mark -
#pragma mark GMEdgeOptionsDelegate Methods

- (void)weightPickerViewController:(GMEdgeOptionsViewController *)weightPickerViewController didSelectWeight:(NSInteger)weight {
    selectedEdge.weight = weight;
}

- (void)weightPickerViewControllerDeleteButtonSelected:(GMEdgeOptionsViewController *)weightPickerViewController {
    [popoverController dismissPopoverAnimated:YES];
    [selectedEdge.startNode removeOutgoingEdge:selectedEdge];
    [selectedEdge.weightButton removeFromSuperview];
    [_graphCanvass setNeedsDisplay];
}

@end






