//
//  GMWeightPickerDelegate.h
//  GraphMaster
//
//  Created by John Newman on 4/21/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GMWeightPickerViewController;

@protocol GMWeightPickerDelegate <NSObject>
- (void)weightPickerViewController:(GMWeightPickerViewController*)weightPickerViewController didSelectWeight:(NSInteger)weight;
- (void)weightPickerViewControllerDeleteButtonSelected:(GMWeightPickerViewController*)weightPickerViewController;
@end
