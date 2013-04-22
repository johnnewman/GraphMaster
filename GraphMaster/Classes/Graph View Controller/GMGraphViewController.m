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
#import "WEPopoverController.h"


@interface GMGraphViewController ()

- (IBAction)drawStyleChanged;
- (IBAction)canvassTapGesture:(UITapGestureRecognizer*)tapGestureRecognizer;
- (void)addNewNodeAtPoint:(CGPoint)point;
- (void)drawNewEdgeIfNeededForPoint:(CGPoint)point;
- (GMNodeView*)nodeInPoint:(CGPoint)point;
- (WEPopoverContainerViewProperties *)improvedContainerViewProperties;

@property (nonatomic, weak) IBOutlet GMGraphCanvass *graphCanvass;
@property (nonatomic, weak) IBOutlet UISegmentedControl *drawTypeSegControl;
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


#pragma mark -
#pragma mark Draw Style Action

- (IBAction)drawStyleChanged {
    NSUInteger selectedDrawType = _drawTypeSegControl.selectedSegmentIndex;
    currentDrawType = selectedDrawType;
}


#pragma mark -
#pragma mark New Node Methods

- (IBAction)canvassTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {    
    if (currentDrawType == NODE_TYPE)
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
    longPressGesture.minimumPressDuration = 1.0;
    
    [node addGestureRecognizer:longPressGesture];
    [_graphCanvass addSubview:node];
    [_graphCanvass bringSubviewToFront:_drawTypeSegControl];
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
    if (destinationNode && destinationNode != _graphCanvass.nodeWithTouches) {
        int randWeight = arc4random() % 100;
        GMEdge *newEdge = [[GMEdge alloc] initWithWeight:randWeight startNode:_graphCanvass.nodeWithTouches destNode:destinationNode];
        newEdge.delegate = self;
        [_graphCanvass addSubview:newEdge.weightButton];
        [_graphCanvass.nodeWithTouches addOutgoingEdge:newEdge];
        [destinationNode addIncomingEdge:newEdge];
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

- (void)nodeViewTouchesBegan:(GMNodeView *)nodeView {
    _graphCanvass.nodeWithTouches = nodeView;
}

- (void)nodeViewIsMovingOrigin:(GMNodeView *)nodeView {
    [_graphCanvass setNeedsDisplay];
}


#pragma mark -
#pragma mark GMEdgeSelectionDelegate

- (void)edgeSelected:(GMEdge *)edge {
    selectedEdge = edge;
    
    GMEdgeOptionsViewController *weightPickerViewController = [[GMEdgeOptionsViewController alloc] initWithNibName:nil bundle:nil];
    weightPickerViewController.delegate = self;
    popoverController = [[WEPopoverController alloc] initWithContentViewController:weightPickerViewController];
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
    [selectedEdge.destNode removeIncomingEdge:selectedEdge];
    [selectedEdge.weightButton removeFromSuperview];
    [_graphCanvass setNeedsDisplay];
}

@end
