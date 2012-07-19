
#import "MFGridViewCell.h"

#import "MFGridViewIndex.h"

@implementation MFGridViewCell
@synthesize index = _index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _index = nil;
 
        static NSUInteger instanceCount = 0;
        NSLog(@"instanceCount = %u", ++instanceCount);
    }
    return self;
}

@end
