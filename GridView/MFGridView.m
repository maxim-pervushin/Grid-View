
#import "MFGridView.h"

#import "MFGridViewCell.h"
#import "MFGridViewIndex.h"


@interface MFGridView ()
{
    NSUInteger _numberOfRows;
    NSUInteger _numberOfColumns;
    CGSize _cellSize;
    NSMutableSet *_reusableCells;
}

- (void)updateSubviews;
- (MFGridViewCell *)getSubviewForIndex:(MFGridViewIndex *)index;
- (void)enqueueReusableItemView:(MFGridViewCell *)itemView;
- (void)tapGesture:(UITapGestureRecognizer *)recognizer;
- (MFGridViewIndex *)indexAtPoint:(CGPoint)point;

#pragma mark delegate
- (void)didSelectCellAtIndex:(MFGridViewIndex *)index;
#pragma mark data source
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
    [_reusableCells release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        _numberOfRows = 0;
        _numberOfColumns = 0;
        _cellSize = CGSizeZero;
        _reusableCells = [[NSMutableSet alloc] init];

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

#pragma mark - private methods

- (void)updateSubviews
{
    if (_cellSize.width == 0 || _cellSize.height == 0) {
        return;
    }

    CGRect visibleRect = CGRectMake(self.contentOffset.x, 
                                    self.contentOffset.y, 
                                    self.bounds.size.width, 
                                    self.bounds.size.height); 
    
    NSMutableArray *subviews = [self.subviews mutableCopy];
    
    CGFloat leftf = visibleRect.origin.x / _cellSize.width;
    CGFloat rightf = (MIN(visibleRect.origin.x + self.bounds.size.width, self.contentSize.width - 1)) / _cellSize.width;
    CGFloat topf = visibleRect.origin.y / _cellSize.height;
    CGFloat bottomf = (MIN(visibleRect.origin.y + self.bounds.size.height, self.contentSize.height - 1)) / _cellSize.height;
    
    NSUInteger left = leftf >= 0 ? leftf : 0;
    NSUInteger right = rightf >= 0 ? rightf : 0;
    NSUInteger top = topf >= 0 ? topf : 0;
    NSUInteger bottom = bottomf >= 0 ? bottomf : 0;
    
    for (NSUInteger column = left; column <= right; ++column) {
        for (NSUInteger row = top; row <= bottom ; ++row) {
            
            CGFloat x = column * _cellSize.width;
            CGFloat y = row * _cellSize.height;
            CGRect cellFrame = CGRectMake(x, y, _cellSize.width, _cellSize.height);
            
            MFGridViewIndex *index =[[[MFGridViewIndex alloc] init] autorelease];
            index.column = column;
            index.row = row;
            
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
            if (cell != nil) {
                [subviews removeObject:cell];
            }
    }
}
    
    for (MFGridViewCell *subview in subviews) {
        [self enqueueReusableItemView:(MFGridViewCell *)subview];
    }
    
    [subviews release];
}

- (MFGridViewCell *)getSubviewForIndex:(MFGridViewIndex *)index
{
    NSArray *cells = self.subviews;
    
    for (MFGridViewCell *cell in cells) {

        if (cell.index == nil) {
            continue;
        }
        
        if (cell.index != nil && cell.index.row == index.row && cell.index.column == index.column) {
            return cell;
        }
    
    }
    
    return nil;
}

- (void)enqueueReusableItemView:(MFGridViewCell *)itemView
{
    itemView.index = nil;
    itemView.hidden = YES;
    [_reusableCells addObject:itemView];
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
            
            MFGridViewIndex *index = [self indexAtPoint:location];
            
            if (index != nil) {
                [self didSelectCellAtIndex:index];
            }
            
            break;
        }
    }
}

- (MFGridViewIndex *)indexAtPoint:(CGPoint)point
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

#pragma mark - public methods

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

- (MFGridViewCell *)dequeueReusableItemView
{
    if (_reusableCells.count == 0) {
        return nil;
    }
    
    MFGridViewCell *reusableView = [_reusableCells anyObject];
    [_reusableCells removeObject:reusableView];
    
    return reusableView;
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
