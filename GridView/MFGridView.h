
#import <UIKit/UIKit.h>

@class MFGridView;
@class MFGridViewCell;
@class MFGridViewIndex;

@protocol MFGridViewDelegate <UIScrollViewDelegate>
@optional
- (void)gridView:(MFGridView *)gridView didSelectCellAtIndex:(MFGridViewIndex *)index;

@end


@protocol MFGridViewDataSource <NSObject>

- (NSUInteger)gridViewNumberOfRows:(MFGridView *)gridView;
- (NSUInteger)gridViewNumberOfColumns:(MFGridView *)gridView;
- (CGSize)gridViewCellSize:(MFGridView *)gridView;
- (MFGridViewCell *)gridView:(MFGridView *)gridView cellForIndex:(MFGridViewIndex *)index;

@end


@interface MFGridView : UIScrollView

@property (assign, nonatomic) id<MFGridViewDelegate> delegate;
@property (assign, nonatomic) id<MFGridViewDataSource> dataSource;

- (void)reloadData;
- (MFGridViewCell *)dequeueReusableCell;

@end
