#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static NSString * const kOldText = @"PennyIOS & EreenModz";
static NSString * const kNewText = @"Telegram_@TiziMod";

// Vị trí mong muốn của label sau khi thay.
static const CGFloat kTopY = 60.0;
static const CGFloat kLabelHeight = 30.0;
static const CGFloat kFontSize = 16.0;

static BOOL TiziMatchesOldText(NSString *text) {
    if (text.length == 0) return NO;

    if ([text isEqualToString:kOldText]) return YES;

    // Fallback nếu menu thêm khoảng trắng / ký tự phụ.
    return ([text rangeOfString:@"PennyIOS" options:NSCaseInsensitiveSearch].location != NSNotFound &&
            [text rangeOfString:@"EreenModz" options:NSCaseInsensitiveSearch].location != NSNotFound);
}

static void TiziStyleLabel(UILabel *label) {
    if (!label) return;

    label.text = kNewText;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.0
                                     green:(170.0 / 255.0)
                                      blue:1.0
                                     alpha:1.0];
    label.font = [UIFont boldSystemFontOfSize:kFontSize];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.85];
    label.shadowOffset = CGSizeMake(1.0, 1.0);
    label.backgroundColor = UIColor.clearColor;

    UIWindow *window = label.window;
    if (!window) return;

    // Đưa label về giữa theo chiều ngang của window.
    // Chuyển frame thông qua superview để không phụ thuộc hierarchy.
    UIView *parent = label.superview;
    if (!parent) return;

    CGRect windowRect = CGRectMake(0.0, kTopY, CGRectGetWidth(window.bounds), kLabelHeight);
    CGRect target = [window convertRect:windowRect toView:parent];

    label.frame = target;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                             UIViewAutoresizingFlexibleBottomMargin;

    [parent bringSubviewToFront:label];
}

static void TiziStyleButton(UIButton *button) {
    if (!button) return;

    NSString *title = [button titleForState:UIControlStateNormal];
    if (!TiziMatchesOldText(title)) return;

    [button setTitle:kNewText forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.0
                                         green:(170.0 / 255.0)
                                          blue:1.0
                                         alpha:1.0]
                 forState:UIControlStateNormal];

    button.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;

    UIWindow *window = button.window;
    UIView *parent = button.superview;
    if (window && parent) {
        CGRect windowRect = CGRectMake(0.0, kTopY, CGRectGetWidth(window.bounds), kLabelHeight);
        button.frame = [window convertRect:windowRect toView:parent];
        [parent bringSubviewToFront:button];
    }
}

static void TiziScanView(UIView *view) {
    if (!view) return;

    if ([view isKindOfClass:UILabel.class]) {
        UILabel *label = (UILabel *)view;

        NSString *plain = label.text;
        NSString *attr = label.attributedText.string;

        if (TiziMatchesOldText(plain) || TiziMatchesOldText(attr)) {
            TiziStyleLabel(label);
        }
    }
    else if ([view isKindOfClass:UIButton.class]) {
        TiziStyleButton((UIButton *)view);
    }

    for (UIView *subview in view.subviews) {
        TiziScanView(subview);
    }
}

static void TiziScanAllWindows(void) {
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TiziScanAllWindows();
        });
        return;
    }

    UIApplication *app = UIApplication.sharedApplication;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in app.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;

            UIWindowScene *ws = (UIWindowScene *)scene;
            for (UIWindow *window in ws.windows) {
                TiziScanView(window);
            }
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        for (UIWindow *window in app.windows) {
            TiziScanView(window);
        }
#pragma clang diagnostic pop
    }
}

// ---------- UILabel setText swizzle ----------

@interface UILabel (TiziReplace)
- (void)tizi_setText:(NSString *)text;
@end

@implementation UILabel (TiziReplace)

- (void)tizi_setText:(NSString *)text {
    if (TiziMatchesOldText(text)) {
        [self tizi_setText:kNewText];

        dispatch_async(dispatch_get_main_queue(), ^{
            TiziStyleLabel(self);
        });
        return;
    }

    [self tizi_setText:text];
}

@end

static void TiziSwizzleUILabel(void) {
    Class cls = UILabel.class;

    Method original = class_getInstanceMethod(cls, @selector(setText:));
    Method replacement = class_getInstanceMethod(cls, @selector(tizi_setText:));

    if (original && replacement) {
        method_exchangeImplementations(original, replacement);
    }
}

static void TiziStartRescans(void) {
    // Scan nhiều lần lúc app khởi động vì menu có thể được tạo muộn.
    const double delays[] = {0.2, 0.8, 1.5, 3.0, 5.0, 8.0};

    for (NSUInteger i = 0; i < sizeof(delays)/sizeof(delays[0]); i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(delays[i] * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            TiziScanAllWindows();
        });
    }
}

__attribute__((constructor))
static void TiziReplaceInit(void) {
    @autoreleasepool {
        TiziSwizzleUILabel();

        dispatch_async(dispatch_get_main_queue(), ^{
            TiziStartRescans();

            [[NSNotificationCenter defaultCenter]
                addObserverForName:UIApplicationDidBecomeActiveNotification
                            object:nil
                             queue:NSOperationQueue.mainQueue
                        usingBlock:^(__unused NSNotification *note) {
                TiziScanAllWindows();
            }];
        });
    }
}
