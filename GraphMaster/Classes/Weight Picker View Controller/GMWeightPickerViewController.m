//
//  GMWeightPickerViewController.m
//  GraphMaster
//
//  Created by John Newman on 4/17/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "GMWeightPickerViewController.h"

#define kPICKER_WIDTH 100
#define kPICKER_HEIGHT 200

@interface GMWeightPickerViewController ()
- (void)addWeightPicker;
@end

@implementation GMWeightPickerViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
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
    return 100;
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", row];
}


@end
