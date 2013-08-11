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
#import "GMAlgorithmSolver.h"


@interface GMGraphViewController ()

- (void)setupAnimationTimer:(dispatch_source_t __strong *)timer;
- (void)startAnimationTimer:(dispatch_source_t)timer;
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
    
    [self setupAnimationTimer:&popOutAnimationTimer];
    [self setupAnimationTimer:&popInAnimationTimer];
}

//Used to refresh the graph canvass while the "pop out" or "pop in" node animations are occurring.
//  These animations will happen whenever the user begins or ends moving a node around the canvass.
//  The canvass is refreshed during these pop animations to show any incoming edge arrows move with
//  in/out with the edge of the node.
- (void)setupAnimationTimer:(dispatch_source_t __strong *)timer
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    *timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (*timer)
    {
        double timerDelayInSeconds = kNODE_POP_ANIMATION_TIME / 5;
        dispatch_source_set_timer(*timer, DISPATCH_TIME_NOW, (int64_t)(timerDelayInSeconds * NSEC_PER_SEC), 0);
        dispatch_source_set_event_handler(*timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_graphCanvass setNeedsDisplay];
            });
        });
    }
    else
        NSLog(@"timer could not be created!");
}

- (void)startAnimationTimer:(dispatch_source_t)timer
{
    if (timer)
    {
        dispatch_resume(timer);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kNODE_POP_ANIMATION_TIME * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            dispatch_suspend(timer);
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)graphOptionsView:(GMGraphOptionsView *)optionsView didSelectAlgorithm:(AlgorithmType)type {
    [self doneShowingOptionsView];
    if (type == kDIJKSTRAS) {
        GMAlgorithmSolver *solver = [GMAlgorithmSolver sharedInstance];
        [solver runDijkstrasWithNodes:nodes];
    }
    [_graphCanvass setNeedsDisplay];
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
    [_graphCanvass addSubview:node];
}


#pragma mark -
#pragma mark New Edge Methods

- (void)drawNewEdgeIfNeededForPoint:(CGPoint)point {
    GMNodeView *destinationNode = [self nodeInPoint:point];
    if (destinationNode && destinationNode != _graphCanvass.nodeWithNewEdge && ![_graphCanvass.nodeWithNewEdge.outgoingNodes containsObject:destinationNode]) {
        int randWeight = arc4random() % 100;
        GMEdge *newEdge = [[GMEdge alloc] initWithWeight:randWeight startNode:_graphCanvass.nodeWithNewEdge destNode:destinationNode];
        newEdge.delegate = self;
        [_graphCanvass addSubview:newEdge.weightButton];
        [_graphCanvass.nodeWithNewEdge addOutgoingEdge:newEdge];
        
        //show the weight selector after the edge has been drawn
        //[self performSelector:@selector(edgeSelected:) withObject:newEdge afterDelay:0.25];
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

- (void)nodeViewDidBeginDrawingEdge:(GMNodeView *)nodeView
{
    _graphCanvass.nodeWithNewEdge = nodeView;
}

- (void)nodeView:(GMNodeView *)nodeView isDrawingEdgeToPoint:(CGPoint)point
{
    _graphCanvass.edgeEndPoint = point;
    [_graphCanvass setNeedsDisplay];
}

- (void)nodeView:(GMNodeView *)nodeView didEndDrawingEdgeToPoint:(CGPoint)point
{
    [self drawNewEdgeIfNeededForPoint:point];
    _graphCanvass.nodeWithNewEdge = nil;
    [_graphCanvass setNeedsDisplay];
}


- (void)nodeViewDidBeginMovingOrigin:(GMNodeView *)nodeView
{
    [self startAnimationTimer:popOutAnimationTimer];
}

- (void)nodeViewIsMovingOrigin:(GMNodeView *)nodeView {
    [_graphCanvass setNeedsDisplay];
}

- (void)nodeViewDidEndMovingOrigin:(GMNodeView *)nodeView
{
    [self startAnimationTimer:popInAnimationTimer];
}

- (void)nodeViewNeedsOptionsDialog:(GMNodeView*)nodeView
{
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
    edgeOptionsViewController.selectedWeight = selectedEdge.weight;
    popoverController = [[WEPopoverController alloc] initWithContentViewController:edgeOptionsViewController];
    [popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
    [popoverController presentPopoverFromRect:edge.weightButton.frame inView:_graphCanvass permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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

@end






