//
//  GMGraphOptionsViewsSelectionDelegate.h
//  GraphMaster
//
//  Created by John Newman on 5/13/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMGraphOptionsView;

typedef enum {
    kDIJKSTRAS = 0,
    kBELLMAN_FORD,
    kPRIMS,
    kKRUSKALS,
    kDEPTH_FIRST,
    kBREADTH_FIRST
}AlgorithmType;

@protocol GMGraphOptionsViewsSelectionDelegate <NSObject>
- (void)graphOptionsView:(GMGraphOptionsView*)optionsView didSelectAlgorithm:(AlgorithmType)type;
@end
