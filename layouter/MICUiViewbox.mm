//
//  MICUiViewbox.m
//  Anytime
//
//  Created by Mitsuki Toyota on 2025/03/05.
//  Copyright © 2025 toyota-m2k Corporation. All rights reserved.
//

#import "MICUiViewbox.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"
#import "MICCmLog.h"

@implementation MICUiViewbox {
    UIView* _hostView;
    UIView* _contentView;
    CGSize _contentSize;
}

- (instancetype) init {
    self = [super init];
    if(self!=nil) {
        _expandable = false;
        _horzAlign = MICUiAlignLEFT;
        _vertAlign = MICUiAlignCENTER;
        _hostView = [[UIView alloc] initWithFrame:self.bounds];
        _hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_hostView];
    }
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self!=nil) {
        _expandable = false;
        _horzAlign = MICUiAlignLEFT;
        _vertAlign = MICUiAlignCENTER;
        _hostView = [[UIView alloc] initWithFrame:self.bounds];
        _hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_hostView];
    }
    return self;
}

- (void) setExpandable:(bool)expandable {
    if(_expandable!=expandable) {
        _expandable = expandable;
        if(_contentView!=nil) {
            [self setNeedsLayout];
        }
    }
}
- (void) setHorzAlign:(MICUiAlign)horzAlign {
    if(_horzAlign!=horzAlign) {
        _horzAlign = horzAlign;
        if(_contentView!=nil) {
            [self setNeedsLayout];
        }
    }
}
- (void) setVertAlign:(MICUiAlign)vertAlign {
    if(_vertAlign!=vertAlign) {
        _vertAlign = vertAlign;
        if(_contentView!=nil) {
            [self setNeedsLayout];
        }
    }
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView != contentView) {
        if(_contentView!=nil) {
            // すでに設定されているコンテントビューを解放
            [_contentView removeFromSuperview];
            [_contentView removeObserver:self forKeyPath:@"frame"];
        }
        _contentView = contentView;
        if (_contentView != nil) {
            _contentSize = contentView.frame.size;
            [_hostView addSubview:_contentView];
            [self setNeedsLayout];
            [self.contentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.contentView && [keyPath isEqualToString:@"frame"]) {
        [self onOriginalContentSizeChanged];
    }
}

static inline bool isNearlyEqual(const CGSize& s1, const CGSize& s2) {
    const CGFloat threshold = 0.01;
    return ABS(s1.width - s2.width)<threshold && ABS(s1.height-s2.height)<threshold;
}


- (void) onOriginalContentSizeChanged {
    if (isNearlyEqual(_contentView.frame.size, _contentSize)) {
        return; // 変化なし
    }
    _contentSize = _contentView.frame.size;
    [self setNeedsLayout];
}

- (void)dealloc {
    if(_contentView !=nil) {
        [_contentView removeObserver:self forKeyPath:@"frame"];
        _contentView = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.contentView==nil) return;
    
    MICRect boundsRect(self.bounds);
    CGFloat width = boundsRect.width();
    CGFloat height = boundsRect.height();
    CGFloat scale = (self.expandable) ? CGFLOAT_MAX : 1.0;
    CGFloat contentWidth = _contentSize.width;
    CGFloat contentHeight =_contentSize.height;
    if (contentWidth>width || self.expandable) {
        scale = MIN(scale, width/contentWidth);
    }
    if (contentHeight>height || self.expandable) {
        scale = MIN(scale, height/contentHeight);
    }
    
    _hostView.frame = MICRect(_contentSize);
    _hostView.transform = CGAffineTransformMakeScale(scale, scale);
    MICRect hostViewRect(_hostView.frame.size);
    
    switch(self.horzAlign) {
        default:
        case MICUiAlignLEFT:
            break;
        case MICUiAlignCENTER:
            hostViewRect.moveToHCenterOfOuterRect(boundsRect);
            break;
        case MICUiAlignRIGHT:
            hostViewRect.moveRight(boundsRect.left());
            break;
            
    }
    switch(self.vertAlign) {
        default:
        case MICUiAlignTOP:
            break;
        case MICUiAlignCENTER:
            hostViewRect.moveToVCenterOfOuterRect(boundsRect);
            break;
        case MICUiAlignBOTTOM:
            hostViewRect.moveBottom(boundsRect.bottom());
            break;
    }
    _hostView.frame = hostViewRect;
//    if(_debugText!=nil) {
//        MICCmLogInfo(@"%@ : content(w=%f, h=%f)", _debugText, _contentSize.width, _contentSize.height);
//    }
}

@end
