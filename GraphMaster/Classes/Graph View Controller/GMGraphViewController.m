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
#import "GMWeightPickerViewController.h"
#import "WEPopoverController.h"


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
    selectedEdge = edge;
    [_graphCanvass setNeedsDisplay];
    
    GMWeightPickerViewController *weightPickerViewController = [[GMWeightPickerViewController alloc] initWithNibName:nil bundle:nil];
    weightPickerViewController.delegate = self;
    popoverController = [[WEPopoverController alloc] initWithContentViewController:weightPickerViewController];
    [popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
    [popoverController presentPopoverFromRect:edge.weightButton.frame inView:_graphCanvass permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

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

- (void)weightPickerViewController:(GMWeightPickerViewController *)weightPickerViewController didSelectWeight:(NSInteger)weight {
    selectedEdge.weight = weight;
}

@end