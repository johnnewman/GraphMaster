//
//  GMWeightPickerViewController.h
//  GraphMaster
//
//  Created by John Newman on 4/17/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMWeightPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    UIPickerView *weightPicker;
}

//@property (nonatomic, strong, readonly)UIPickerView *weightPicker;

@end
