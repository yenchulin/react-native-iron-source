#import "IronSource/IronSource.h"
#import "React/RCTConvert.h"
#import "RCTUtils.h"
#import "RNIronSourceBannerManager.h"

NSString *const kIronSourceBannerDidLoad = @"ironSourceBannerDidLoad";
NSString *const kIronSourceBannerDidFailToLoadWithError = @"ironSourceBannerDidFailToLoadWithError";
NSString *const kIronSourceBannerDidDismissScreen = @"ironSourceBannerDidDismissScreen";
NSString *const kIronSourceBannerWillLeaveApplication = @"ironSourceBannerWillLeaveApplication";
NSString *const kIronSourceBannerWillPresentScreen = @"ironSourceBannerWillPresentScreen";
NSString *const kIronSourceDidClickBanner = @"ironSourceDidClickBanner";

@interface BannerComponent : UIView <ISBannerDelegate>

@property ISBannerView *banner;
@property(nonatomic, copy) ISBannerSize *size;

@property(nonatomic, copy) RCTBubblingEventBlock onNativeEvent;

@end

@implementation BannerComponent
{
    bool initialized;
    bool hasListeners;
    RCTPromiseResolveBlock resolveLoadBanner;
    RCTPromiseRejectBlock rejectLoadBanner;
    bool scaleToFitWidth;
    NSString *position;
}

- (void)initBanner {
    [IronSource setBannerDelegate:self];
    [IronSource loadBannerWithViewController:RCTPresentedViewController() size:_size];
}


- (void)setSize:(NSString *)size {
    _size = [self getBannerSizeFromDescription:size];
}


- (void)bannerDidLoad:(ISBannerView *)bannerView {
    
    if (hasListeners) {
        [self sendEvent:kIronSourceBannerDidLoad payload:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *viewController = RCTPresentedViewController();

        self.banner = bannerView;

        CGSize bannerSize = self->scaleToFitWidth ? [self getScaledBannerSize:bannerView] : [self getBannerSize:bannerView];

        CGFloat bannerX = viewController.view.center.x;
        CGFloat bannerY = 0;

        if ([self->position isEqualToString:@"bottom"]) {
            CGFloat bottomSafeAreaLength = [self getBottomSafeAreaLength];
            bannerY = viewController.view.frame.size.height - bannerSize.height / 2 - bottomSafeAreaLength;
        } else if ([self->position isEqualToString:@"top"]) {
            CGFloat topSafeAreaLength = [self getTopSafeAreaLength];
            bannerY = topSafeAreaLength + bannerSize.height / 2;
        }

        self.banner.center = CGPointMake(bannerX, bannerY);
        if (self->scaleToFitWidth) {
            CGFloat bannerScale = [self getBannerScale:bannerView];
            self.banner.transform = CGAffineTransformMakeScale(bannerScale, bannerScale);
        }
        self.banner.hidden = YES;
        [viewController.view addSubview:self.banner];

        self->resolveLoadBanner(@{
                                  @"width": [NSNumber numberWithFloat:bannerSize.width],
                                  @"height": [NSNumber numberWithFloat:bannerSize.height],
                                  });
    });
}

- (void)bannerDidFailToLoadWithError:(NSError *)error {
    if (hasListeners) {
        [self sendEvent:kIronSourceBannerDidFailToLoadWithError payload:nil];
    }
    self->rejectLoadBanner(@"Error", @"Failed to load banner", error);
}

- (void)bannerDidDismissScreen {
    if (hasListeners) {
        [self sendEvent:kIronSourceBannerDidDismissScreen payload:nil];
    }
}


- (void)bannerWillLeaveApplication {
    if (hasListeners) {
        [self sendEvent:kIronSourceBannerWillLeaveApplication payload:nil];
    }
}


- (void)bannerWillPresentScreen {
    if (hasListeners) {
        [self sendEvent:kIronSourceBannerWillPresentScreen payload:nil];
    }
}


- (void)didClickBanner {
    if (hasListeners) {
        [self sendEvent:kIronSourceDidClickBanner payload:nil];
    }
}

- (NSArray<NSString *> *)supportedEvents {
    return @[kIronSourceBannerDidLoad,
             kIronSourceBannerDidFailToLoadWithError,
             kIronSourceBannerDidDismissScreen,
             kIronSourceBannerWillLeaveApplication,
             kIronSourceBannerWillPresentScreen,
             kIronSourceDidClickBanner,
             ];
}

- (void)startObserving {
    hasListeners = YES;
}

- (void)stopObserving {
    hasListeners = NO;
}

- (void)handleRCTBridgeWillReloadNotification:(NSNotification *)notification
{
    [self destroyBannerInner];
}

RCT_EXPORT_METHOD(loadBanner:(NSString *)bannerSizeDescription
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejector:(RCTPromiseRejectBlock)reject) {
    [self initBanner];
    scaleToFitWidth = [RCTConvert BOOL:options[@"scaleToFitWidth"]];
    position = [RCTConvert NSString:options[@"position"]];
    resolveLoadBanner = resolve;
    rejectLoadBanner = reject;
    if (self.banner) {
        [self destroyBanner];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTBridgeWillReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRCTBridgeWillReloadNotification:)
                                                 name:RCTBridgeWillReloadNotification
                                               object:nil];
}

- (ISBannerSize *) getBannerSizeFromDescription:(NSString *)description
{
    if ([description isEqualToString:@"LARGE"]) {
        return ISBannerSize_LARGE;
    }
    if ([description isEqualToString:@"RECTANGLE"]) {
        return ISBannerSize_RECTANGLE;
    }
    if ([description isEqualToString:@"SMART"]) {
        return ISBannerSize_SMART;
    }
    return ISBannerSize_BANNER;
}

RCT_EXPORT_METHOD(showBanner) {
    if (self.banner) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.banner.hidden = NO;
        });
    }
}

RCT_EXPORT_METHOD(hideBanner) {
    if (self.banner) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.banner.hidden = YES;
        });
    }
}

- (void)destroyBannerInner {
    if (self.banner) {
        [IronSource destroyBanner:self.banner];
        self.banner = nil;
    }
}

RCT_EXPORT_METHOD(destroyBanner) {
    [self destroyBannerInner];
}


- (CGSize)getBannerSize:(ISBannerView *)bannerView {
    CGSize bannerSize = CGSizeMake(100, 100);
    for (UIView *view in bannerView.subviews){
        bannerSize = view.frame.size;
    }
    return bannerSize;
}


- (CGSize)getScaledBannerSize:(ISBannerView *)bannerView {
    CGSize bannerSize = [self getBannerSize:bannerView];
    CGFloat scale = [self getBannerScale:bannerView];
    return CGSizeMake(bannerSize.width * scale, bannerSize.height * scale);
}

- (CGFloat)getBottomSafeAreaLength {
    UIViewController *viewController = RCTPresentedViewController();
    CGFloat bottomSafeAreaLength = 0;
    if (@available(iOS 11.0, *)) {
        bottomSafeAreaLength = viewController.view.safeAreaInsets.bottom;
    } else {
        bottomSafeAreaLength = viewController.bottomLayoutGuide.length;
    }
    return bottomSafeAreaLength;
}

- (CGFloat)getTopSafeAreaLength {
    UIViewController *viewController = RCTPresentedViewController();
    CGFloat topSafeAreaLength = 0;
    if (@available(iOS 11.0, *)) {
        topSafeAreaLength = viewController.view.safeAreaInsets.top;
    } else {
        topSafeAreaLength = viewController.topLayoutGuide.length;
    }
    return topSafeAreaLength;
}

- (CGFloat)getBannerScale:(ISBannerView *)bannerView {
    CGSize bannerSize = [self getBannerSize:bannerView];
    UIViewController *viewController = RCTPresentedViewController();
    return viewController.view.frame.size.width / bannerSize.width;
}

- (void)sendEvent:(NSString *)type payload:(NSDictionary *_Nullable)payload {
  if (!self.onNativeEvent) {
    return;
  }

  NSMutableDictionary *event = [@{
      @"type": type,
  } mutableCopy];

  if (payload != nil) {
    [event addEntriesFromDictionary:payload];
  }

  self.onNativeEvent(event);
}

@end






@implementation RNIronSourceBannerManager

RCT_EXPORT_MODULE(RNIronSourceBanner)

RCT_EXPORT_VIEW_PROPERTY(size, NSString);

RCT_EXPORT_VIEW_PROPERTY(unitId, NSString);

RCT_EXPORT_VIEW_PROPERTY(request, NSDictionary);

RCT_EXPORT_VIEW_PROPERTY(onNativeEvent, RCTBubblingEventBlock);

@synthesize bridge = _bridge;

- (UIView *)view {
    BannerComponent *banner = [BannerComponent new];
    return banner;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
