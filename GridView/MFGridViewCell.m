
#import "MFGridViewCell.h"

#import "MFGridViewIndex.h"

@implementation MFGridViewCell
@synthesize index = _index;

- (void)dealloc
{
    [_index release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        static NSUInteger instanceCount = 0;
        ++instanceCount;

        _index = nil;
    }

    return self;
}

@end
