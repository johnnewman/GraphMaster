//
//  GMGraphViewController.h
//  GraphMaster
//
//  Created by John Newman on 3/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMNodeViewSelectionDelegate.h"
#import "GMEdgeSelectionDelegate.h"
#import "GMWeightPickerDelegate.h"

@class GMGraphCanvass;
@class WEPopoverController;

typedef enum {
    NODE_TYPE,
    EDGE_TYPE
}DrawType;

DrawType currentDrawType;

@interface GMGraphViewController : UIViewController <GMNodeViewSelectionDelegate, GMEdgeSelectionDelegate, GMWeightPickerDelegate> {
    NSMutableArray *nodes;
    WEPopoverController *popoverController;
    GMEdge *selectedEdge;
}

@end
