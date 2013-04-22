//
//  GMEdgeOptionsDelegate.h
//  GraphMaster
//
//  Created by John Newman on 4/21/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GMEdgeOptionsViewController;

@protocol GMEdgeOptionsDelegate <NSObject>
- (void)weightPickerViewController:(GMEdgeOptionsViewController*)weightPickerViewController didSelectWeight:(NSInteger)weight;
- (void)weightPickerViewControllerDeleteButtonSelected:(GMEdgeOptionsViewController*)weightPickerViewController;
@end
