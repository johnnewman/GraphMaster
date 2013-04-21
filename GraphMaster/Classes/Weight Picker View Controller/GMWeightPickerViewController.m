//
//  GMWeightPickerViewController.m
//  GraphMaster
//
//  Created by John Newman on 4/17/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMWeightPickerViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kPICKER_WIDTH 75
#define kPICKER_HEIGHT 162
#define kMAX_VALUE 100

@interface GMWeightPickerViewController ()
- (void)addWeightPicker;
@end

@implementation GMWeightPickerViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.contentSizeForViewInPopover = CGSizeMake(kPICKER_WIDTH, kPICKER_HEIGHT);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self addWeightPicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addWeightPicker {
    weightPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, kPICKER_WIDTH, kPICKER_HEIGHT)];
    weightPicker.showsSelectionIndicator = YES;
    
    CALayer* mask = [[CALayer alloc] init];
    [mask setBackgroundColor: [UIColor blackColor].CGColor];
    [mask setFrame:weightPicker.frame];
    [mask setCornerRadius: 5.0f];
    [weightPicker.layer setMask: mask];
    
    weightPicker.delegate = self;
    weightPicker.dataSource = self;
    [self.view addSubview:weightPicker];
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return kMAX_VALUE;
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([_delegate respondsToSelector:@selector(weightPickerViewController:didSelectWeight:)])
        [_delegate weightPickerViewController:self didSelectWeight:row];
}


@end
