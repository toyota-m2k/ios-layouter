//
//  WPLContainerCell.m
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLContainerCell.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"

@implementation WPLContainerCell {
    NSMutableArray* _cells;
    bool _needsLayoutChildren;
}

/**
 * WPLCell.initWithViewのオーバーライド
 */
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:containerDelegate];
    if(nil!=self) {
        _cells = [NSMutableArray array];
        _needsLayoutChildren = true;
    }
    return self;
}


- (NSArray<id<IWPLCell>>*) cells {
    return _cells;
}

/**
 * セルの名前で検索
 */
- (id<IWPLCell>) findByName:(NSString*) name {
    for(id<IWPLCell> c in self.cells) {
        if([c.name isEqualToString:name]) {
            return c;
        }
        if([c conformsToProtocol:@protocol(IWPLContainerCell)]) {
            let cc = [(id<IWPLContainerCell>)c findByName:name];
            if(cc!=nil) {
                return cc;
            }
        }
    }
    return nil;
}

/**
 * ビューでセルを検索
 */
- (id<IWPLCell>) findByView:(UIView*) view {
    for(id<IWPLCell> c in self.cells) {
        if(c.view == view) {
            return c;
        }
        if([c conformsToProtocol:@protocol(IWPLContainerCell)]) {
            let cc = [(id<IWPLContainerCell>)c findByView:view];
            if(cc!=nil) {
                return cc;
            }
        }
    }
    return nil;
}

/**
 * 自身とコンテントの子セルを解放する
 */
- (void) dispose {
    [super dispose];
    for(id<IWPLCell> c in self.cells) {
        [c dispose];
    }
    [_cells removeAllObjects];
}

/**
 * 子セルの再レイアウトが必要か？
 */
- (bool) needsLayoutChildren {
    return _needsLayoutChildren;
}

- (void) setNeedsLayoutChildren:(bool) v {
    _needsLayoutChildren = v;
    if(v) {
        self.needsLayout = true;
    }
}

/**
 * 子モデルのサイズなどが変化した (IContainerCellDelegate i/f)
 */
- (void) onChildCellModified:(id<IWPLCell>) cell {
    self.needsLayoutChildren = true;
}

/**
 * セルを追加
 */
- (void) addCell:(id<IWPLCell>) cell {
    cell.containerDelegate = self;
    [_cells addObject:cell];
    [self.view addSubview:cell.view];
    self.needsLayoutChildren = true;
}

/**
 * セルを削除
 */
- (void) removeCell:(id<IWPLCell>) cell {
    [cell dispose];
    [_cells removeObject:cell];
}

/**
 * レイアウトを実行開始（ルートコンテナセルに対してのみ呼び出す）
 */
- (CGSize) layout {
    // サブクラスで実装すること。
    return MICSize();
}

@end

