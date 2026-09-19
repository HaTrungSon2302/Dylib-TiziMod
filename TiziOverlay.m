#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const kOverlayText = @"Telegram_@TiziMod";
static const NSInteger kOverlayTag = 987654321;

// Vị trí từ mép trên. Tăng số để hạ chữ xuống, giảm để đưa lên.
static const CGFloat kTopY = 60.0;

// Cỡ chữ.
static const CGFloat kFontSize = 16.0;

static UIWindow *TiziFindActiveWindow(void) {
    UIApplication *app = UIApplication.sharedApplication;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in app.connectedScenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive) {
                continue;
            }

            if (![scene isKindOfClass:UIWindowScene.class]) {
                continue;
            }

            UIWindowScene *windowScene = (UIWindowScene *)scene;

            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }

            for (UIWindow *window in windowScene.windows) {
                if (!window.hidden && window.alpha > 0.0) {
                    return window;
                }
            }
        }
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (app.keyWindow) {
        return app.keyWindow;
    }
#pragma clang diagnostic pop

    for (UIWindow *window in app.windows) {
        if (!window.hidden && window.alpha > 0.0) {
            return window;
        }
    }

    return nil;
}

static void TiziInstallOverlay(void) {
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TiziInstallOverlay();
        });
        return;
    }

    UIWindow *window = TiziFindActiveWindow();

    if (!window) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            TiziInstallOverlay();
        });
        return;
    }

    UIView *old = [window viewWithTag:kOverlayTag];
    if (old) {
        [old removeFromSuperview];
    }

    CGFloat width = CGRectGetWidth(window.bounds);

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                               kTopY,
                                                               width,
                                                               28.0)];
    label.tag = kOverlayTag;
    label.text = kOverlayText;
    label.textAlignment = NSTextAlignmentCenter;

    // Xanh nước biển sáng: RGB(0, 170, 255)
    label.textColor = [UIColor colorWithRed:0.0
                                     green:(170.0 / 255.0)
                                      blue:1.0
                                     alpha:1.0];

    label.font = [UIFont boldSystemFontOfSize:kFontSize];

    // Bóng đen nhẹ để chữ nổi hơn trên nền sáng.
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.85];
    label.shadowOffset = CGSizeMake(1.0, 1.0);

    label.backgroundColor = UIColor.clearColor;
    label.userInteractionEnabled = NO;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                             UIViewAutoresizingFlexibleBottomMargin;

    label.layer.zPosition = CGFLOAT_MAX;

    [window addSubview:label];
    [window bringSubviewToFront:label];
}

static void TiziScheduleOverlay(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        TiziInstallOverlay();

        // Game có thể đổi keyWindow trong lúc khởi động,
        // nên cài lại overlay vài lần.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            TiziInstallOverlay();
        });

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            TiziInstallOverlay();
        });
    });
}

__attribute__((constructor))
static void TiziOverlayInit(void) {
    @autoreleasepool {
        TiziScheduleOverlay();

        [[NSNotificationCenter defaultCenter]
            addObserverForName:UIApplicationDidBecomeActiveNotification
                        object:nil
                         queue:NSOperationQueue.mainQueue
                    usingBlock:^(__unused NSNotification *note) {
            TiziInstallOverlay();
        }];
    }
}
