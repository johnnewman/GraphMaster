//
//  GMGraphViewController.h
//  GraphMaster
//
//  Created by John Newman on 3/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGraphOptionsViewsSelectionDelegate.h"
#import "GMNodeViewSelectionDelegate.h"
#import "GMEdgeSelectionDelegate.h"
#import "GMEdgeOptionsDelegate.h"

@class GMGraphCanvass;
@class GMGraphOptionsView;
@class XBPageDragView;
@class WEPopoverController;

typedef enum {
    NODE_TYPE = 0,
    EDGE_TYPE
}DrawType;

DrawType currentDrawType;

@interface GMGraphViewController : UIViewController <GMGraphOptionsViewsSelectionDelegate, GMNodeViewSelectionDelegate, GMEdgeSelectionDelegate, GMEdgeOptionsDelegate> {
    NSMutableArray *nodes;
    WEPopoverController *popoverController;
    GMEdge *selectedEdge;
}

@property (nonatomic, weak, readonly) IBOutlet GMGraphCanvass *graphCanvass;
@property (nonatomic, weak, readonly) IBOutlet GMGraphOptionsView *graphOptionsView;
@property (nonatomic, weak, readonly) IBOutlet UISegmentedControl *drawTypeSegControl;
@property (nonatomic, weak, readonly) IBOutlet XBPageDragView *pageDragView;

@end
