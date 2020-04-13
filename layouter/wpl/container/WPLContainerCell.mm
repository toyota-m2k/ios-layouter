//
//  WPLContainerCell.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLContainerCell.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"

@implementation WPLContainerCell {
    NSMutableArray* _cells;
    bool _needsLayoutChildren;
}

#pragma mark - 初期化・解放

/**
 * WPLCell.initWithViewのオーバーライド
 */
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                    limitWidth:(WPLMinMax) limitWidth
                   limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility {
    self = [super initWithView:view
                          name:name
                        margin:margin
               requestViewSize:requestViewSize
                    limitWidth:limitWidth
                   limitHeight:limitHeight
                    hAlignment:hAlignment
                    vAlignment:vAlignment
                    visibility:visibility];
             
    if(nil!=self) {
        _cells = [NSMutableArray array];
        _needsLayoutChildren = true;
    }
    return self;
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

#pragma mark - グリッドセル管理

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
 * セルを削除（セルはDisposeされる）
 */
- (void) removeCell:(id<IWPLCell>) cell {
    cell.containerDelegate = nil;
    [cell.view removeFromSuperview];
    [cell dispose];
    [_cells removeObject:cell];
    self.needsLayoutChildren = true;
}

- (id<IWPLCell>)detachCell:(id<IWPLCell>) cell {
    cell.containerDelegate = nil;
    [cell.view removeFromSuperview];
    [_cells removeObject:cell];
    self.needsLayoutChildren = true;
    cell.extension = nil;
    return cell;
}



#pragma mark - レンダリング

/**
 * 子セルの再レイアウトが必要か？
 */
- (bool) needsLayoutChildren {
    return _needsLayoutChildren;
}

- (void) setNeedsLayoutChildren:(bool) v {
    _needsLayoutChildren = v;
    if(v) {
        self.needsLayout = true;        // 自身も再レイアウトが必要
    }
}

- (void)beginRendering:(WPLRenderingMode)mode {
    if(self.visibility!=WPLVisibilityCOLLAPSED) {
        for(id<IWPLCell> cell in self.cells) {
            [cell beginRendering:mode];
        }
    }
}

- (void)endRendering:(CGRect)finalCellRect {
    [super endRendering:finalCellRect];
    self.needsLayoutChildren = false;
}

@end

