//
//  ISVImageScrollView.m
//  ISVImageScrollView
//
//  Created by Yurii Kupratsevich on 10/23/17.
//

#import "ISVImageScrollView.h"

static void *ScrollViewBoundsChangeNotificationContext = &ScrollViewBoundsChangeNotificationContext;

@interface ISVImageScrollView ()

@property (nonatomic, readonly) CGFloat imageAspectRatio;
@property (nonatomic) CGRect initialImageFrame;

@end

@implementation ISVImageScrollView

#pragma mark - Private Methods

- (void)configure {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    [self startObservingBoundsChange];
}

- (void)setImageView:(UIImageView *)imageView {
    if (_imageView.superview == self) {
        [_imageView removeFromSuperview];
    }
    if (imageView) {
        _imageView = imageView;
        _initialImageFrame = CGRectNull;
        [self addSubview:imageView];
    }
}

- (CGFloat)imageAspectRatio {
    if (self.imageView.image) {
        return self.imageView.image.size.width / self.imageView.image.size.height;
    }
    return 1;
}

- (CGSize)rectSizeForAspectRatio:(CGFloat)ratio thatFitsSize:(CGSize)size {
    CGFloat containerWidth = size.width;
    CGFloat containerHeight = size.height;
    CGFloat resultWidth = 0;
    CGFloat resultHeight = 0;
    
    if (containerWidth / containerHeight >= ratio) {
        resultHeight = containerHeight;
        resultWidth = containerHeight * ratio;
    }
    else {
        resultWidth = containerWidth;
        resultHeight = containerWidth / ratio;
    }
    
    return CGSizeMake(resultWidth, resultHeight);
}

- (void)scaleImageForScrollViewTransitionFromBounds:(CGRect)oldBounds toBounds:(CGRect)newBounds {
    CGPoint oldContentOffset = CGPointMake(oldBounds.origin.x, oldBounds.origin.y);
    CGSize oldSize = oldBounds.size;
    CGSize newSize = newBounds.size;
    
    CGSize containedImageSizeOld = [self rectSizeForAspectRatio:self.imageAspectRatio
                                                   thatFitsSize:oldSize];
    
    CGSize containedImageSizeNew = [self rectSizeForAspectRatio:self.imageAspectRatio
                                                   thatFitsSize:newSize];
    
    CGFloat orientationRatio = containedImageSizeNew.height / containedImageSizeOld.height;
    
    CGAffineTransform t = CGAffineTransformMakeScale(orientationRatio, orientationRatio);
    self.imageView.frame = CGRectApplyAffineTransform(self.imageView.frame, t);
    
    self.contentSize = self.imageView.frame.size;
    
    CGFloat xOffset = (oldContentOffset.x + oldSize.width * 0.5) * orientationRatio - newSize.width * 0.5;
    CGFloat yOffset = (oldContentOffset.y + oldSize.height * 0.5) * orientationRatio - newSize.height * 0.5;
    
    xOffset -= MAX(xOffset + newSize.width - self.contentSize.width, 0);
    yOffset -= MAX(yOffset + newSize.height - self.contentSize.height, 0);
    xOffset += MAX(-xOffset, 0);
    yOffset += MAX(-yOffset, 0);
    
    self.contentOffset = CGPointMake(xOffset, yOffset);
}

- (void)setupInitialImageFrame {
    if (self.imageView.image && CGRectEqualToRect(self.initialImageFrame, CGRectNull)) {
        CGSize imageViewSize = [self rectSizeForAspectRatio:self.imageAspectRatio
                                               thatFitsSize:self.bounds.size];
        self.initialImageFrame = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
        self.imageView.frame = self.initialImageFrame;
        self.contentSize = self.initialImageFrame.size;
    }
}

#pragma mark - KVO

- (void)startObservingBoundsChange {
    [self addObserver:self
           forKeyPath:@"bounds"
              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:ScrollViewBoundsChangeNotificationContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == ScrollViewBoundsChangeNotificationContext) {
        CGRect oldRect = ((NSValue *)change[NSKeyValueChangeOldKey]).CGRectValue;
        CGRect newRect = ((NSValue *)change[NSKeyValueChangeNewKey]).CGRectValue;
        if (! CGSizeEqualToSize(oldRect.size, newRect.size)) {
            [self scaleImageForScrollViewTransitionFromBounds:oldRect toBounds:newRect];
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"bounds"];
}

#pragma mark - UIScrollView

- (void)setContentOffset:(CGPoint)contentOffset
{
    const CGSize contentSize = self.contentSize;
    const CGSize scrollViewSize = self.bounds.size;
    
    if (contentSize.width < scrollViewSize.width)
    {
        contentOffset.x = - (scrollViewSize.width - contentSize.width) * 0.5;
    }
    
    if (contentSize.height < scrollViewSize.height)
    {
        contentOffset.y = - (scrollViewSize.height - contentSize.height) * 0.5;
    }
    
    [super setContentOffset:contentOffset];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupInitialImageFrame];
}

@end
