#import "IronSource/IronSource.h"
#import "React/RCTConvert.h"
#import "RCTUtils.h"
#import "RNIronSourceBannerManager.h"

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#else
#import "RCTBridge.h"
#import "RCTUIManager.h"
#import "RCTEventDispatcher.h"
#endif

NSString *const kIronSourceBannerDidLoad = @"ironSourceBannerDidLoad";
NSString *const kIronSourceBannerDidFailToLoadWithError = @"ironSourceBannerDidFailToLoadWithError";
NSString *const kIronSourceBannerDidDismissScreen = @"ironSourceBannerDidDismissScreen";
NSString *const kIronSourceBannerWillLeaveApplication = @"ironSourceBannerWillLeaveApplication";
NSString *const kIronSourceBannerWillPresentScreen = @"ironSourceBannerWillPresentScreen";
NSString *const kIronSourceDidClickBanner = @"ironSourceDidClickBanner";

@interface BannerComponent : UIView <ISBannerDelegate>

@property(nonatomic) ISBannerView *banner;
@property(nonatomic, copy) NSString *adSize;
@property(nonatomic, copy) RCTBubblingEventBlock onAdLoaded;
@property(nonatomic, copy) RCTBubblingEventBlock onAdFailedToLoad;
@property(nonatomic, copy) RCTBubblingEventBlock onAdClosed;
@property(nonatomic, copy) RCTBubblingEventBlock onAdLeftApplication;
@property(nonatomic, copy) RCTBubblingEventBlock onAdOpened;
@property(nonatomic, copy) RCTBubblingEventBlock onAdClick;

- (void)loadBanner;

@end

@implementation BannerComponent
{
    RCTPromiseResolveBlock resolveLoadBanner;
    RCTPromiseRejectBlock rejectLoadBanner;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        [IronSource setBannerDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRCTBridgeWillReloadNotification:)
                                                     name:RCTBridgeWillReloadNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self destroyBannerInner];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTBridgeWillReloadNotification object:nil];
}

- (void)setAdSize:(NSString *)adSize {
    _adSize = adSize;
    [self loadBanner];
}

- (void)setBanner:(ISBannerView *)banner {
    _banner = banner;
}

- (void)loadBanner {
    [IronSource loadBannerWithViewController:RCTPresentedViewController() size: [self getBannerSizeFromDescription:self.adSize]];
}


- (void)bannerDidLoad:(ISBannerView *)bannerView {
    [self sendEvent:kIronSourceBannerDidLoad payload:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.banner = bannerView;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor],
            [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor],
//            [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor],
//            [self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor],
        ]];

        [self addSubview:self.banner];
        self.banner.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.banner.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.banner.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.banner.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.banner.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
        
        [ISIntegrationHelper validateIntegration];
    });
}

- (void)bannerDidFailToLoadWithError:(NSError *)error {
    [self sendEvent:kIronSourceBannerDidFailToLoadWithError payload:nil];
    NSLog(@"%@",error);
}

- (void)bannerDidDismissScreen {
    [self sendEvent:kIronSourceBannerDidDismissScreen payload:nil];
}


- (void)bannerWillLeaveApplication {
    [self sendEvent:kIronSourceBannerWillLeaveApplication payload:nil];
}


- (void)bannerWillPresentScreen {
    [self sendEvent:kIronSourceBannerWillPresentScreen payload:nil];
}


- (void)didClickBanner {
    [self sendEvent:kIronSourceDidClickBanner payload:nil];
}

- (void)sendEvent:(NSString *)type payload:(NSDictionary *_Nullable)payload {
    NSMutableDictionary *event = [@{
        @"type": type,
    } mutableCopy];

    if (payload != nil) {
      [event addEntriesFromDictionary:payload];
    }
    
    if ([type isEqualToString:kIronSourceBannerDidLoad]) {
        self.onAdLoaded(event);
        return;
    }
    if ([type isEqualToString:kIronSourceBannerDidFailToLoadWithError]) {
        self.onAdFailedToLoad(event);
        return;
    }
    if ([type isEqualToString:kIronSourceBannerDidDismissScreen]) {
        self.onAdClosed(event);
    }
    if ([type isEqualToString:kIronSourceBannerWillLeaveApplication]) {
        self.onAdLeftApplication(event);
    }
    if ([type isEqualToString:kIronSourceBannerWillPresentScreen]) {
        self.onAdOpened(event);
    }
    if ([type isEqualToString:kIronSourceDidClickBanner]) {
        self.onAdClick(event);
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

- (void)handleRCTBridgeWillReloadNotification:(NSNotification *)notification
{
    [self destroyBannerInner];
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

- (void)destroyBannerInner {
    if (self.banner) {
        [IronSource destroyBanner:self.banner];
        self.banner = nil;
    }
}

@end






@implementation RNIronSourceBannerManager

RCT_EXPORT_MODULE(RNIronSourceBanner)

RCT_EXPORT_VIEW_PROPERTY(adSize, NSString);

RCT_EXPORT_METHOD(loadBanner:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,BannerComponent *> *viewRegistry) {
        BannerComponent *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[BannerComponent class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting BannerComponent, got: %@", view);
        } else {
            [view loadBanner];
        }
    }];
}

RCT_EXPORT_VIEW_PROPERTY(onAdLoaded, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdFailedToLoad, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdClosed, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdLeftApplication, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdOpened, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdClick, RCTBubblingEventBlock)

@synthesize bridge = _bridge;

- (UIView *)view {
    BannerComponent *banner = [[BannerComponent alloc] init];
    return banner;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
