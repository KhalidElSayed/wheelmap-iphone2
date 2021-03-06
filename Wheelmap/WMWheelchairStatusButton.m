//
//  WMWheelchairStatusButton.m
//  Wheelmap
//
//  Created by npng on 11/28/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMWheelchairStatusButton.h"

@implementation WMWheelchairStatusButton
@synthesize selectedGreenDot = _selectedGreenDot;
@synthesize selectedYellowDot = _selectedYellowDot;
@synthesize selectedRedDot = _selectedRedDot;
@synthesize selectedNoneDot = _selectedNoneDot;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // normalView
        UIImageView* normalView = [[UIImageView alloc] initWithFrame:self.bounds];
        normalView.image = [UIImage imageNamed:@"toolbar_button.png"];
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 10, 30, 30)];
        icon.image = [UIImage imageNamed:@"toolbar_icon-filter.png"];
        [normalView addSubview:icon];
        dotGreen = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, 6, 8)];
        dotGreen.image = [UIImage imageNamed:@"toolbar_indicator-green.png"];
        [normalView addSubview:dotGreen];
        dotYellow = [[UIImageView alloc] initWithFrame:CGRectMake(dotGreen.topRightX+2, 40, 6, 8)];
        dotYellow.image = [UIImage imageNamed:@"toolbar_indicator-orange.png"];
        [normalView addSubview:dotYellow];
        dotRed = [[UIImageView alloc] initWithFrame:CGRectMake(dotYellow.topRightX+2, 40, 6, 8)];
        dotRed.image = [UIImage imageNamed:@"toolbar_indicator-red.png"];
        [normalView addSubview:dotRed];
        dotNone = [[UIImageView alloc] initWithFrame:CGRectMake(dotRed.topRightX+2, 40, 6, 8)];
        dotNone.image = [UIImage imageNamed:@"toolbar_indicator-grey.png"];
        [normalView addSubview:dotNone];
        
        [self setView:normalView forControlState:UIControlStateNormal];
        
    }
    return self;
}

#pragma mark - Dots Management
-(void)setSelectedGreenDot:(BOOL)selectedGreenDot
{
    _selectedGreenDot = selectedGreenDot;
    if (!_selectedGreenDot) {
        [self deselectDot:dotGreen];
    } else {
        [self selectdot:dotGreen];
    }
}

-(BOOL)selectedGreenDot
{
    return _selectedGreenDot;
}

-(void)setSelectedYellowDot:(BOOL)selectedYellowDot
{
    _selectedYellowDot = selectedYellowDot;
    if (!_selectedYellowDot) {
        [self deselectDot:dotYellow];
    } else {
        [self selectdot:dotYellow];
        
    }
}

-(BOOL)selectedYellowDot
{
    return _selectedYellowDot;
}

-(void)setSelectedRedDot:(BOOL)selectedRedDot
{
    _selectedRedDot = selectedRedDot;
    if (!_selectedRedDot) {
        [self deselectDot:dotRed];
    } else {
        [self selectdot:dotRed];
    }
}

-(BOOL)selectedRedDot
{
    return _selectedRedDot;
}

-(void)setSelectedNoneDot:(BOOL)selectedNoneDot
{
    _selectedNoneDot = selectedNoneDot;
    if (!_selectedNoneDot) {
        [self deselectDot:dotNone];
    } else {
        [self selectdot:dotNone];
    }
}

-(BOOL)selectedNoneDot
{
    return _selectedNoneDot;
}

-(void)deselectDot:(UIImageView*)dot
{
    // deselection effect here
    dot.hidden = YES;
}
-(void)selectdot:(UIImageView*)dot
{
    // selection effect here
    dot.hidden = NO;
}

@end
