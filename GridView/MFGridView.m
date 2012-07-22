
#import "MFGridView.h"

#import "MFGridViewCell.h"
#import "MFGridViewIndex.h"


@interface MFGridView ()
{
    NSUInteger _numberOfRows;
    NSUInteger _numberOfColumns;
    CGSize _cellSize;
    MFGridViewOrientation _orientation;
    NSMutableArray *_reusableViews;
}

- (void)updateSubviews;
//- (MFGridViewCell *)getSubviewForIndex:(NSUInteger)index;
- (MFGridViewCell *)getSubviewForIndex:(MFGridViewIndex *)index;
- (void)enqueueReusableItemView:(MFGridViewCell *)itemView;
- (void)tapGesture:(UITapGestureRecognizer *)recognizer;
- (MFGridViewIndex *)indexForPoint:(CGPoint)point;

// delegate
- (void)didSelectCellAtIndex:(MFGridViewIndex *)index;
// data source
- (NSUInteger)numberOfRows;
- (NSUInteger)numberOfColumns;
- (CGSize)cellSize;
- (MFGridViewCell *)cellForIndex:(MFGridViewIndex *)index;

@end

@implementation MFGridView
@synthesize delegate;
@synthesize dataSource;

- (void)dealloc
{
    [_reusableViews release];
    [super dealloc];
}

- (id)initWithOrientation:(MFGridViewOrientation)orientation
{
    self = [self initWithFrame:CGRectZero];
    
    if (self != nil) {
        _numberOfRows = 0;
        _cellSize = CGSizeZero;
        _orientation = orientation;
        _reusableViews = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] 
                                                        initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    
    [self updateSubviews];
}

- (void)reloadData
{
    NSArray *items = self.subviews;
    for (MFGridViewCell *item in items) {
        [self enqueueReusableItemView:item];
    }
    
    _numberOfRows = [self numberOfRows];
    _numberOfColumns = [self numberOfColumns];
    _cellSize = [self cellSize];
    
    self.contentSize = CGSizeMake(_numberOfColumns * _cellSize.width, 
                                  _numberOfRows * _cellSize.height);
    
    [self updateSubviews];
}

- (void)updateSubviews
{
    CGRect visibleRect = CGRectMake(self.contentOffset.x, 
                                    self.contentOffset.y, 
                                    self.bounds.size.width, 
                                    self.bounds.size.height); 
    
    NSMutableArray *subviews = [self.subviews mutableCopy];
    
    NSUInteger left = visibleRect.origin.x / _cellSize.width;
    NSUInteger right = (NSUInteger)(visibleRect.origin.x + self.bounds.size.width) / (NSUInteger)_cellSize.width;
    NSUInteger top = visibleRect.origin.y / _cellSize.height;
    NSUInteger bottom = (NSUInteger)(visibleRect.origin.y + self.bounds.size.height) / (NSUInteger)_cellSize.height;
    
//    NSLog(@"left = %u right = %u top = %u bottom = %u", left, right, top, bottom);
    
//    for (NSUInteger column = 0; column < _numberOfColumns; ++column) {
//        for (NSUInteger row = 0; row < _numberOfRows; ++row) {
    for (NSUInteger column = left; column <= right; ++column) {
        for (NSUInteger row = top; row <= bottom ; ++row) {
            
//            NSLog(@"column = %u row = %u", column, row);
            
            CGFloat x = column * _cellSize.width;
            CGFloat y = row * _cellSize.height;
            CGRect cellFrame = CGRectMake(x, y, _cellSize.width, _cellSize.height);

            MFGridViewIndex *index =[[[MFGridViewIndex alloc] init] autorelease];
            index.column = column;
            index.row = row;
            
//            if (CGRectIntersectsRect(visibleRect, cellFrame)) {
                MFGridViewCell *cell = [self getSubviewForIndex:index];
                if (cell == nil) {
                    cell = [self cellForIndex:index];
                }
                
                if (cell != nil) {
                    cell.index = index;
                    cell.frame = cellFrame;
                    cell.hidden = NO;
                    
                    if (![self.subviews containsObject:cell]) {
                        [self addSubview:cell];
                    }
                }
//            } else {
//                NSLog(@"offscreen subview");
                
//                MFGridViewCell *cell = [self getSubviewForIndex:index];
//                if (cell != nil) {
//                    [self enqueueReusableItemView:cell];
//                }
            if (cell != nil) {
                [subviews removeObject:cell];
            }
//            }
        }
    }
    
    for (UIView *subview in subviews) {
        [self enqueueReusableItemView:subview];
    }
    
    [subviews release];
}

- (MFGridViewCell *)getSubviewForIndex:(MFGridViewIndex *)index
{
    // TODO: search in self.subviews subview with corresponding index
    CGFloat x = index.column * _cellSize.width;
    CGFloat y = index.row * _cellSize.height;
   // CGRect cellFrame = CGRectMake(x, y, _cellSize.width, _cellSize.height);
    
    NSArray *cells = self.subviews;
    for (MFGridViewCell *cell in cells) {
       // if ([_reusableViews containsObject:cell]) {
       //     continue;
       // }
        if (cell.hidden) { // TODO: make @property BOOL reusable for index;
            continue;
        }
        
       // if (CGRectEqualToRect(cell.frame, cellFrame)) {
       //     return cell;
       // }
        CGPoint cellFrameOrigin = cell.frame.origin;
        if (x == cellFrameOrigin.x && y == cellFrameOrigin.y) {
            return cell;
        }
    }
    
    return nil;
}

- (void)enqueueReusableItemView:(MFGridViewCell *)itemView
{
    itemView.index = nil;
    itemView.hidden = YES;
    [_reusableViews addObject:itemView];
}

- (MFGridViewCell *)dequeueReusableItemView
{
    if (_reusableViews.count == 0) {
        return nil;
    }
    
    MFGridViewCell *reusableView = [_reusableViews objectAtIndex:0];
    [_reusableViews removeObject:reusableView];
    
    return reusableView;
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if (CGRectContainsPoint(subview.frame, location)) {
            UIColor *originalColor = subview.backgroundColor;
            
            [UIView animateWithDuration:0.3f 
                             animations:^{
                                 subview.backgroundColor = [UIColor whiteColor];
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.3f 
                                                  animations:^{
                                                      subview.backgroundColor = originalColor;
                                                  }];
                             }];
            
            MFGridViewIndex *index = [self indexForPoint:location];
            
            if (index != nil) {
                [self didSelectCellAtIndex:index];
            }
            
            break;
        }
    }
}

- (MFGridViewIndex *)indexForPoint:(CGPoint)point
{
    NSArray *subviews = self.subviews;
    for (MFGridViewCell *subview in subviews) {
        if (CGRectContainsPoint(subview.frame, point)) {
            if (subview.index != nil) {
                return subview.index;
            }
            
            return nil;
        }
    }
    
    return nil;
}

#pragma mark - delegate

- (void)didSelectCellAtIndex:(MFGridViewIndex *)index
{
    if ([self.delegate respondsToSelector:@selector(gridView:didSelectCellAtIndex:)]) {
        [self.delegate gridView:self didSelectCellAtIndex:index];
    }
}

#pragma mark - data source

- (NSUInteger)numberOfRows
{
    if ([self.dataSource respondsToSelector:@selector(gridViewNumberOfRows:)]) {
        return [self.dataSource gridViewNumberOfRows:self];
    }
    
    return 0;
}

- (NSUInteger)numberOfColumns
{
    if ([self.dataSource respondsToSelector:@selector(gridViewNumberOfColumns:)]) {
        return [self.dataSource gridViewNumberOfColumns:self];
    }
    
    return 0;
}

- (CGSize)cellSize
{
    if ([self.dataSource respondsToSelector:@selector(gridViewCellSize:)]) {
        return [self.dataSource gridViewCellSize:self];
    }
    
    return CGSizeZero;
}

- (MFGridViewCell *)cellForIndex:(MFGridViewIndex *)index
{
    if ([self.dataSource respondsToSelector:@selector(gridView:cellForIndex:)]) {
        return [self.dataSource gridView:self cellForIndex:index];
    }
    
    return nil;
}

@end
