//
//  WPLFrame.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/08.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLFrame.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

#ifdef DEBUG
@interface WPLInternalFrameView : UIView
@end
@implementation WPLInternalFrameView
@end
#else
#define WPLInternalFrameView UIView
#endif

@implementation WPLFrame {
    MICSize _cachedSize;
    bool _cacheHorz;
    bool _cacheVert;
}

- (instancetype)initWithView:(UIView *)view name:(NSString *)name margin:(UIEdgeInsets)margin requestViewSize:(CGSize)requestViewSize limitWidth:(WPLMinMax)limitWidth limitHeight:(WPLMinMax)limitHeight hAlignment:(WPLCellAlignment)hAlignment vAlignment:(WPLCellAlignment)vAlignment visibility:(WPLVisibility)visibility {
    if(nil==view) {
        view = [WPLInternalFrameView new];
    }
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize limitWidth:limitWidth limitHeight:limitHeight hAlignment:hAlignment vAlignment:vAlignment visibility:visibility];
    if(nil!=self) {
        _cacheVert = false;
        _cacheHorz = false;
    }
    return self;
}


- (instancetype)initWithView:(UIView *)view name:(NSString *)name params:(WPLCellParams)params {
    return [self initWithView:view
                         name:name
                       margin:params._margin
              requestViewSize:params._requestViewSize
                   limitWidth:params._limitWidth
                  limitHeight:params._limitHeight
                   hAlignment:params._align.horz
                   vAlignment:params._align.vert
                   visibility:params._visibility];
}

+ (instancetype) frameWithName:(NSString*)name
                        params:(WPLCellParams) params {
    return [self newCellWithView:nil name:name params:params];
}

+ (instancetype) frameWithView:(UIView*)view
                        name:(NSString*)name
                        params:(WPLCellParams) params {
    return [self newCellWithView:view name:name params:params];
}

- (void)beginRendering:(WPLRenderingMode)mode {
    if(self.needsLayoutChildren || mode!=WPLRenderingNORMAL) {
        _cachedSize.setEmpty();
        _cacheHorz = false;
        _cacheVert = false;
    }
    [super beginRendering:mode];
}

class FRAccessor {
public:
    enum Orientation { HORZ, VERT };
    Orientation orientation;
    
    FRAccessor(Orientation orientation_) {
        orientation = orientation_;
    }
    
    CGFloat calcSize(id<IWPLCell>cell, CGFloat regulatingSize) const {
        if(orientation==HORZ) {
            return [cell calcCellWidth:regulatingSize];
        } else {
            return [cell calcCellHeight:regulatingSize];
        }
    }
    
    CGFloat requestedSize(id<IWPLCell> cell) const {
        if(orientation==HORZ) {
            return cell.requestViewSize.width;
        } else {
            return cell.requestViewSize.height;
        }
    }
    
    NSString* orientationName() const {
        if(orientation==HORZ) {
            return @"X";
        } else {
            return @"Y";
        }
    }
};

/**
 * ビューサイズ（マージンを含まない）を計算
 */
- (CGFloat)calcCellSize:(CGFloat) regulatingSize    // マージンを含まない
                    acc:(const FRAccessor&)acc {
    let requestedSize = acc.requestedSize(self);
    CGFloat fixedSize = 0;
    if(requestedSize>0) {
        // Any > FIXED
        // Independent | BottomUp
        fixedSize = requestedSize;
    } else if(regulatingSize>0 && requestedSize<0) {
        // STRC|FIXED > STRC
        fixedSize =  regulatingSize;
    } else if(regulatingSize==0 && requestedSize<0) {
        // AUTO > STRC ... 問題のやつ
        WPLOG(@"WPL-CAUTION:%@ -<%@>- AUTO > STRC", self.description, acc.orientationName());
    } else {
        // Any > AUTO
    }
    
    if(fixedSize>0) {
        // FIXED|STRC
        for(id<IWPLCell>cell in self.cells) {
            acc.calcSize(cell, fixedSize);
        }
        return fixedSize;
    } else {
        // AUTO sizing
        CGFloat size = 0;
        int stretchCount = 0;
        for(id<IWPLCell>cell in self.cells) {
            if(acc.requestedSize(cell)<0) {
                // STRC cell
                if(fixedSize>0) {
                    // FIXED|STRC > STRC
                    acc.calcSize(cell, fixedSize);
                } else {
                    // AUTO > STRC ... 他のサイズが決まるまで保留
                    stretchCount++;
                }
            } else {
                // ANY > FIXED|AUTO
                size = MAX(size, acc.calcSize(cell,regulatingSize));
            }
        }
        if(stretchCount>0) {
            // AUTO > STRC
            // 1) size >0: STRCでないセルによってサイズが確定できた --> STRCなセルはそのサイズに合わせる
            // 2) size==0: すべてがSTRC --> AUTOとしてレイアウト（sizeを更新）
            CGFloat size2 = 0;  // 2)のケースのsize更新用
            for(id<IWPLCell>cell in self.cells) {
                if(acc.requestedSize(cell)<0) {
                    size2 = MAX(size2, acc.calcSize(cell, size));
                }
            }
            if(size==0) {
                size = size2;
            }
        }
        return size;
    }
}


- (CGFloat) calcCellWidth:(CGFloat)regulatingWidth {
    if(!_cacheHorz) {
        FRAccessor acc(FRAccessor::HORZ);
        _cachedSize.width = [self calcCellSize:regulatingWidth - MICEdgeInsets::dw(self.margin) acc:acc];
        _cacheHorz = true;
    }
    // 最小・最大サイズでクリップして、マージンを追加
    return WPLCMinMax(self.limitWidth).clip(_cachedSize.width) + MICEdgeInsets::dw(self.margin);
}

- (CGFloat) calcCellHeight:(CGFloat)regulatingHeight {
    if(!_cacheVert) {
        FRAccessor acc(FRAccessor::VERT);
        _cachedSize.height = [self calcCellSize:regulatingHeight - MICEdgeInsets::dh(self.margin) acc:acc];
        _cacheVert = true;
    }
    // 最小・最大サイズでクリップして、マージンを追加
    return WPLCMinMax(self.limitHeight).clip(_cachedSize.height) + MICEdgeInsets::dh(self.margin);
}

- (CGFloat)recalcCellWidth:(CGFloat)regulatingWidth {
    _cacheHorz = false;
    return [self calcCellWidth:regulatingWidth];
}

- (CGFloat)recalcCellHeight:(CGFloat)regulatingHeight {
    _cacheVert = false;
    return [self calcCellHeight:regulatingHeight];
}


- (void)endRendering:(CGRect)finalCellRect {
    if(self.visibility!=WPLVisibilityCOLLAPSED) {
        MICRect panelRect([self calcCellWidth:0]-MICEdgeInsets::dw(self.margin), [self calcCellHeight:0]-MICEdgeInsets::dh(self.margin));
        for(id<IWPLCell> cell in self.cells) {
            [cell endRendering:panelRect];
        }
    }
    [super endRendering:finalCellRect];
}


@end
