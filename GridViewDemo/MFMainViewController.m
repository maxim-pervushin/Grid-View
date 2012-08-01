//
//  MFMainViewController.m
//  GridViewDemo
//
//  Created by Maxim Pervushin on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MFMainViewController.h"
#import "MFCustomGridViewCell.h"
#import "MFGridViewIndex.h"

@interface MFMainViewController ()
{
    MFGridView *_gridView;
}

- (void)gridViewCellInstanceCountChanged:(NSNotification *)notification;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(gridViewCellInstanceCountChanged:) 
                                                 name:@"GridViewCellInstanceCountChanged" 
                                               object:nil];
    
    _gridView = [[MFGridView alloc] init];
    _gridView.frame = self.view.bounds;
    _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _gridView.dataSource = self;
    _gridView.delegate = self;
    _gridView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_gridView];
    
    [_gridView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)gridViewCellInstanceCountChanged:(NSNotification *)notification
{
    NSNumber *gridViewCellInstanceCount = (NSNumber *)notification.object;
    
    self.title = [NSString stringWithFormat:@"Cell instances number: %@", gridViewCellInstanceCount];
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
    MFCustomGridViewCell *cell = (MFCustomGridViewCell *)[gridView dequeueReusableCell];
    
    if (cell == nil) {
        cell = [[[MFCustomGridViewCell alloc] init] autorelease];
    }
    
    return cell;
}

#pragma mark - MFGridViewDelegate

- (void)gridView:(MFGridView *)gridView didSelectCellAtIndex:(MFGridViewIndex *)index
{
    NSLog(@"didSelectCellAtIndex:%@", index);
}

@end
