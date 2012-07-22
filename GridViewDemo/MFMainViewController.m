//
//  MFMainViewController.m
//  GridViewDemo
//
//  Created by Maxim Pervushin on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MFMainViewController.h"
#import "MFCustomGridViewCell.h"

@interface MFMainViewController ()
{
    MFGridView *_gridView;
}

@end

@implementation MFMainViewController

- (void)dealloc
{
    [_gridView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _gridView = [[MFGridView alloc] initWithOrientation:MFGridViewOrientationVertical];
    _gridView.frame = self.view.frame;
    _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _gridView.dataSource = self;
    _gridView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_gridView];
    
    [_gridView reloadData];
    
    self.title = @"FooBarBaz";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - MFGridViewDataSource

- (NSUInteger)gridViewNumberOfRows:(MFGridView *)gridView
{
    return 100;
}

- (NSUInteger)gridViewNumberOfColumns:(MFGridView *)gridView
{
    return 100;
}

- (CGSize)gridViewCellSize:(MFGridView *)gridView
{
    return CGSizeMake(100, 100);
}

- (MFGridViewCell *)gridView:(MFGridView *)gridView cellForIndex:(MFGridViewIndex *)index
{
    MFCustomGridViewCell *cell = (MFCustomGridViewCell *)[gridView dequeueReusableItemView];
    
    if (cell == nil) {
        cell = [[[MFCustomGridViewCell alloc] init] autorelease];
    }
    
    return cell;
}


@end
