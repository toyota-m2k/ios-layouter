//
//  MICUiBaseLayout.m
//
//  レイアウターの基底クラス
//
//  Created by @toyota-m2k on 2014/11/10.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiBaseLayout.h"

//---------------------------------------------------------------------------------------------------
#pragma mark - セル情報基底クラス

/**
 * セル情報基底クラス
 */
@implementation MICUiLayoutCell

/**
 * セルはドラッグ可能か
 *  ドラッグ禁止セルを作る場合は、サブクラスでオーバーライド
 * @return  true: ドラッグ可能 / false:ドラッグ禁止
 */
- (BOOL)draggable {
    return true;
}

/**
 * 引数なしの初期化は禁止
 */
- (MICUiLayoutCell*)init {
    return [self initWithView:nil];
}

/**
 * 初期化
 */
- (MICUiLayoutCell*)initWithView:(UIView*)view {
    self = [super init];
    if(nil!=self) {
        _view = view;
        _dragging = false;
        _orgViewSize = view.frame.size;
        _reservedLocation = CGRectNull;
    }
    return self;
}

/**
 * セルをドラッグ中状態へ移行する。
 *  @return true:移行した　/ false:セルは移動禁止
 */
- (BOOL) beginDrag {
    if(!self.draggable) {
        return false;
    }
    _dragging = true;
    return true;
}

/**
 * ドラッグ状態のセルを通常状態に戻す。
 *  @return true:移行した　/ false:もともとセルはドラッグされていなかった。
 */
- (BOOL) endDrag {
    if( !_dragging) {
        return false;
    }
    _dragging = false;
    return true;
}


- (void)reserveLocation:(CGRect)location {
    _reservedLocation = location;
}

- (void)cancelLocationReservation {
    _reservedLocation = CGRectNull;
}

- (BOOL)isLocationReserved {
    return !CGRectIsNull(_reservedLocation);
}

@end

//---------------------------------------------------------------------------------------------------
#pragma mark - ドラッグ情報基底クラス（MICUiCellDraggingInfo）

/**
 * ドラッグ情報基底クラス
 */
@implementation MICUiCellDraggingInfo {
}

/**
 * セル持ち込み中か？（ドラッグを開始したレイアウター以外）
 */
- (bool)isIncoming {
    return _dragState == DRAG_INCOMING;
}

/**
 * セル持ち出し中か？（ドラッグを開始したレイアウターのみ）
 */
- (bool)isOutgoing {
    return _dragState == DRAG_OUTGOING;
}

/**
 * 同一レイアウター内でのドラッグ中か？（ドラッグ開始レイアウター内でドラッグ中）
 */
- (bool)isDomestic {
    return _dragState == DRAG_DOMESTIC;
}

/**
 * 初期化
 */
- (MICUiCellDraggingInfo*)init {
    return [self initWithCell:nil originalIndex:-1 children:nil];
}


/**
 * オブジェクト生成
 */
- (MICUiCellDraggingInfo *)initWithCell:(MICUiLayoutCell*)cell
                          originalIndex:(int)index
                               children:(NSMutableArray*) children {
    self = [super init];
    if(nil!=self){
        _draggingCell = cell;
        _orgIndex = _currentIndex = index;
        _prevVisibleRect = CGRectZero;
        _dragState = DRAG_DOMESTIC;
        _masterChildren = children;
    }
    return self;
}

/**
 * セルをレイアウター外へ持ち出す
 */
- (bool) takeout {
    if( self.isOutgoing) {
        [NSException raise:@"MICUiGridDraggingInfo.takeout" format:@"cell already outgoing."];
    }
    
    // セル配列からドラッグセルを削除
    [_masterChildren removeObject:_draggingCell];
    if(self.isIncoming) {
        // 外部から持ち込まれたセルが、再び持ち出される。
        _dragState = DRAG_DOMESTIC;
    } else {
        // このレイアウターをソースとして、初めてセルを持ち出すので、outgoingにセット
        _dragState = DRAG_OUTGOING;
    }
    return true;
}

/**
 * セルをレイアウター内へ持ち込む。
 */
- (bool) takein{
    if( self.isIncoming ) {
        [NSException raise:@"MICUiGridDraggingInfo.takein" format:@"cell already incoming."];
    }
    
    // セル配列にドラッグセルを追加
    _orgIndex = _currentIndex = (int)_masterChildren.count;
    [_masterChildren addObject:_draggingCell];
    
    if(self.isOutgoing) {
        // 外部へ持ちだされていたセルが、ソースレイアウトに戻ってくる
        _dragState = DRAG_DOMESTIC;
    } else {
        // 外部から、セルが持ち込まれる
        _dragState = DRAG_INCOMING;
    }
    return true;
}


@end




//---------------------------------------------------------------------------------------------------
#pragma mark - レイアウター基底クラス（MICUiBaseLayout）

/**
 * レイアウター基底クラス
 */
@implementation MICUiBaseLayout

//---------------------------------------------------------------------------------------------------
#pragma mark - プロパティ

@synthesize marginLeft = _marginLeft;                   ///< グリッドレイアウター全体のマージン（左）
@synthesize marginRight = _marginRight;                 ///< グリッドレイアウター全体のマージン（右）
@synthesize marginTop = _marginTop;                     ///< グリッドレイアウター全体のマージン（上）
@synthesize marginBottom = _marginBottom;               ///< グリッドレイアウター全体のマージン（下）
@synthesize layoutDelegate = _layoutDelegate;                       ///< イベントリスナー
@synthesize parentView = _parentView;                   ///< addSubviewを自動化する
@synthesize dropAcceptorDelegate = _dropAcceptorDelegate;
@synthesize children = _children;
@synthesize animDuration = _animDuration;

#define CHK_SET(vo,vn) {if((vo)!=(vn)){(vo)=(vn), _needsRecalcLayout=/*_contentSizeChanged=*/true;}}

/**
 * レイアウター周囲のマージン
 */
- (void)setMarginTop:(CGFloat)marginTop {
    CHK_SET(_marginTop,marginTop);
}

- (void)setMarginBottom:(CGFloat)marginBottom {
    CHK_SET(_marginBottom, marginBottom);
}
- (void)setMarginLeft:(CGFloat)marginLeft {
    CHK_SET(_marginLeft, marginLeft);
}

- (void)setMarginRight:(CGFloat)marginRight {
    CHK_SET(_marginRight, marginRight);
}

- (UIEdgeInsets) margin {
    return UIEdgeInsetsMake(_marginTop, _marginLeft, _marginBottom, _marginRight);
}

- (void) setMargin:(UIEdgeInsets)margin {
    CHK_SET(_marginTop,margin.top);
    CHK_SET(_marginBottom, margin.bottom);
    CHK_SET(_marginLeft, margin.left);
    CHK_SET(_marginRight, margin.right);
}

/**
 * ドラッグ可能な方向
 */
- (int)draggableOrientation {
    return MICUiOrientationBOTH;
}

/**
 * ドラッグ中か？
 */
- (BOOL)dragging {
    return nil!=_draggingInfo;
}

- (NSString *)description {
    if(nil==_name) {
        static int sSerialNo = 1;
        _name = [NSString stringWithFormat:@"(%d)",sSerialNo];
        sSerialNo++;
    }
    return [NSString stringWithFormat:@"Layout:%@:%@",_name, [super description]];
}

//---------------------------------------------------------------------------------------------------
#pragma mark - 初期化
- (MICUiBaseLayout*) init {
    self = [super init];
    if(nil!=self) {
        _marginTop =
        _marginBottom =
        _marginLeft =
        _marginRight = 0;
        _animDuration = MICUI_DEFAULT_ANIM_DURATION;
        _needsRecalcLayout = false;
        _children = [[NSMutableArray alloc] init];
        _draggingInfo = nil;
//        _scrollingTimer = nil;
        _parentView = nil;
        _layoutDelegate = nil;
        _dropAcceptorDelegate = nil;
    }
    return self;
}

//---------------------------------------------------------------------------------------------------
#pragma mark - オーバーライドが必要なメソッド

/**
 * レイアウターの表示サイズを取得する。
 * @return マージンを含むレイアウター全体のサイズ（スクロール領域の計算に使用することを想定）
 */
- (CGSize) getSize {
    [NSException raise:@"MICUiBaseLayout.getSize" format:@"must be overridden by subclasses." ];
    return CGSizeZero;
}

/**
 * レイアウターのマージンを除く、正味のコンテント領域の領域を取得する。
 *
 * @return  コンテナビュー座標系（bounds内）での矩形領域（ヒットテストなどに利用されることを想定）。
 */
- (CGRect) getContentRect {
    [NSException raise:@"MICUiBaseLayout.getContentRect" format:@"must be overridden by subclasses." ];
    return CGRectZero;
}

/**
 * セル情報インスタンスを生成する。
 */
- (MICUiLayoutCell*)createCell:(UIView*)view {
    [NSException raise:@"MICUiBaseLayout.createCell" format:@"must be overridden by subclasses." ];
    return nil;
}

/**
 * セル配置の再計算
 */
- (void) calcLayout {
    [NSException raise:@"MICUiBaseLayout.calcLayout" format:@"must be overridden by subclasses." ];
}

/**
 * セルの位置・サイズの計算値を取得する
 */
- (CGRect) getCellRect:(MICUiLayoutCell*)cell {
    [NSException raise:@"MICUiBaseLayout.getCellPosition" format:@"must be overridden by subclasses." ];
    return CGRectZero;
}

/**
 * 指定された座標位置のセルを取得する。
 */
- (MICUiLayoutCell*) hitTestAtX:(CGFloat)x andY:(CGFloat)y {
    [NSException raise:@"MICUiBaseLayout.hitTestAtX" format:@"must be overridden by subclasses." ];
    return nil;
}

/**
 * ドラッグ情報クラスのインスタンスを作成する。
 */
- (MICUiCellDraggingInfo*) createCellDraggingInfo:(MICUiLayoutCell*) cell  event:(id<MICUiDragEventArg>) eventArg {
    [NSException raise:@"MICUiBaseLayout.createCellDraggingInfo" format:@"must be overridden by subclasses." ];
    return nil;
}


/**
 * ドラッグ前の状態に戻す
 * @return true:レイアウトが変更された / false:変更されなかった（再レイアウトの必要なし）
 */
- (BOOL) resetDrag:(id<MICUiDragEventArg>) eventArg {
    [NSException raise:@"MICUiBaseLayout.resetDrag" format:@"must be overridden by subclasses." ];
    return false;
}

/**
 * ドラッグ操作の中の人
 * @return true:レイアウトが変更された / false:変更されなかった（再レイアウトの必要なし）
 */
- (BOOL) doDrag:(id<MICUiDragEventArg>) eventArg {
    [NSException raise:@"MICUiBaseLayout.doDrag" format:@"must be overridden by subclasses." ];
    return false;
}

/**
 * セルが画面内に入るようスクロールする。
 */
- (void) ensureCellVisible:(MICUiLayoutCell*)cell {
}

#pragma mark - レンダリング

/**
 * セルのViewを指定位置に移動する
 *
 * @param cell  移動するセル
 * @param rc    指定位置
 * @param animation true:アニメーションして移動
 */
- (BOOL) setCellPosition:(MICUiLayoutCell*)cell to:(CGRect)rc animation:(BOOL)animation onCompleted:(void (^)(BOOL)) onCompleted{
    if(cell.isLocationReserved || CGRectIsNull(rc) || CGRectEqualToRect(rc, cell.view.frame)) {
        if(nil!=onCompleted){
            onCompleted(false);
        }
        return false;
    }
    
    if(animation) {
        [UIView animateWithDuration:_animDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{cell.view.frame=rc;} completion:onCompleted];
    } else {
        cell.view.frame = rc;
        if(nil!=onCompleted){
            onCompleted(true);
        }
    }
    return true;
}

/**
 * セルを再配置して、ビューを更新する。
 */
- (BOOL) updateLayout:(BOOL)animation onCompleted:(void (^)(BOOL)) onCompleted {
    if(_needsRecalcLayout) {
        [self calcLayout];
    }
    
    BOOL result = false;
    __block int latch = (int)_children.count;
    for(MICUiLayoutCell* cell in _children) {
        if(nil!=cell.view && !cell.dragging) {
            CGRect rc = [self getCellRect:cell];
            result |= [self setCellPosition:cell to:rc animation:animation onCompleted:^(BOOL f) {
                latch--;
                if(nil!=onCompleted&&latch<=0) {
                    // すべてのセルのアニメーションが終わったら onCompletedを呼び出す
                    onCompleted(result);
                }
            }];
        }
    }
                       
    if(_contentSizeChanged && nil!=_layoutDelegate) {
        _contentSizeChanged = false;
        [_layoutDelegate onContentSizeChanged:self size:[self getSize]];
    }
    return result;
}

/**
 * 配置再計算フラグを立てる
 */
- (void) requestRecalcLayout {
    _needsRecalcLayout = true;
    //_contentSizeChanged = true;
}


//---------------------------------------------------------------------------------------------------
#pragma mark - 子ビュー管理

-(void)setOrgSize:(CGSize)size ofChild:(UIView *)child {
    MICUiLayoutCell* cell = [self findCell:child];
    if( nil!=cell) {
        cell.orgViewSize = size;
    }
}

/**
 * Viewを保持しているセルを取得
 */
- (MICUiLayoutCell*) findCell:(UIView*)view {
    int idx = [self indexOfChild:view];
    return (idx>=0) ? _children[idx] : nil;
}

/**
 * viewを子要素に持っているか？
 */
- (bool) containsChild:(UIView*)view {
    return [self indexOfChild:view]>=0;
}

/**
 * 管理している子ビューの数
 */
- (int) childCount {
    return (int)_children.count;
}

/**
 * インデックスを指定して子ビューを取得
 */
- (UIView*) childAt : (int)index{
    if(index<0 || _children.count<=index){
        return nil;
    }
    return ((MICUiLayoutCell*)_children[index]).view;
}

/**
 * (PROTECTED) 指定インデックスのセルを取得
 */
- (MICUiLayoutCell*) cellAt:(int)index {
    if(index<0 || _children.count<=index){
        return nil;
    }
    return _children[index];
}

/**
 * (PROTECTED) セルのインデクス
 */
- (int) indexOfCell : (MICUiLayoutCell*)cell {
    NSUInteger index = [_children indexOfObject:cell];
    return (index == NSNotFound ) ? -1 : (int)index;
}

/**
 * Viewを保持しているセルのインデックスを取得
 * @return 見つかったセルのインデックス　（見つからなければ−１）
 */
- (int) indexOfChild:(UIView*)view {
    __block int found = -1;
    if(nil!=view) {
        [_children enumerateObjectsUsingBlock:^(MICUiLayoutCell *cell, NSUInteger idx, BOOL *stop){
            if(cell.view == view) {
                *stop = YES;
                found = (int)idx;
            }
        }];
    }
    return found;
}

/**
 * ビューを検索
 */
- (UIView *)findView:(bool (^)(UIView *))matcher {
    for(MICUiLayoutCell* cell in _children) {
        if(matcher(cell.view)) {
            return cell.view;
        }
    }
    return nil;
}

/**
 * レイアウターにセル（ビュー）を追加する
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加するビュー
 */
- (void) addChild:(UIView*)view {
    [self insertChild:view before:nil];
}

/**
 * レイアウターの指定位置にセルを挿入する。
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加（挿入）するビュー
 * @param siblingView 挿入位置のビュー（このビューの位置＝このビューの１つ前に挿入する）: nil なら末尾（＝＝addChild)
 */
- (void) insertChild:(UIView*)view
              before:(UIView*)siblingView {

    if ([self containsChild:view]) {
        return;
    }
    MICUiLayoutCell* cell = [self createCell:view];
    int idx = (nil!=siblingView) ? [self indexOfChild:siblingView] : -1;
    [self insertCell:cell atIndex:idx];
}

/**
 * （PROTECTED) セルを指定位置に挿入する
 */
- (void) insertCell:(MICUiLayoutCell*)cell atIndex:(int)idx {
    if(nil!=_parentView&&nil!=cell.view) {
        [_parentView addSubview:cell.view];
    }
    
    if(idx<0) {
        [_children addObject:cell];
    } else {
        [_children insertObject:cell atIndex:idx];
    }
    _needsRecalcLayout = true;
}


/**
 * セルを削除する。
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 */
- (void) removeChild:(UIView*)child {
    int idx = [self indexOfChild:child];
    if(idx>=0) {
        [_children removeObjectAtIndex:idx];
        _needsRecalcLayout = true;
        if(nil!=_parentView) {
            [child removeFromSuperview];
        }
    }
}

/**
 * すべてのセルを削除する。
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 */
- (void) removeAllChildren{
    if(_children.count==0) {
        return;
    }
    if(nil!=_parentView) {
        for(MICUiLayoutCell* cell in _children) {
            [cell.view removeFromSuperview];
        }
    }
    [_children removeAllObjects];
    _needsRecalcLayout = true;
}

/**
 * セルの位置・サイズを固定する
 */
- (void) reserveCell:(UIView *)view toLocation:(CGRect)frame {
    MICUiLayoutCell* cell = [self findCell:view];
    if( nil!=cell) {
        [cell reserveLocation:frame];
    }
}

/**
 * セルの位置・サイズ固定を解除する。
 */
- (void) cancelCellLocationReservation:(UIView *)view {
    MICUiLayoutCell* cell = [self findCell:view];
    if( nil!=cell) {
        [cell cancelLocationReservation];
    }
}

/**
 * １つのセルの位置・サイズを固定して、再配置を実行。
 *  AccordionCellViewのような、伸び縮みするビューで、それ自身がアニメーションするときに、レイアウターのアニメーションと同時に実行させるために使用する。
 *
 *  @param  view        固定するビュー
 *  @param  location    固定するビューの位置・サイズ
 *  @param  anim        アニメーションするかどうか
 *  @param  onCompleted アニメーション完了時のコールバック
 */
- (void)updateLayoutWithReservingCell:(UIView *)view atLocation:(CGRect)location animated:(BOOL)anim onCompleted:(void (^)(BOOL)) onCompleted {
    [self reserveCell:view toLocation:location];
    _needsRecalcLayout = true;
    [self updateLayout:anim onCompleted:^(BOOL r){
        [self cancelCellLocationReservation:view];
        if(nil!=onCompleted) {
            onCompleted(r);
        }
    }];
}


//---------------------------------------------------------------------------------------------------
#pragma mark - ドラッグ＆ドロップ

/**
 * D&Dによるカスタマイズを開始するときに呼び出される。
 *  このタイミングで、このセルビューに対するタップやドラッグなどのユーザ操作を無効化する。
 */
- (void) onBeginCustomizing {
    for( MICUiLayoutCell* cell in _children) {
        if( [cell.view conformsToProtocol:@protocol(MICUiDraggableCellProtocol)] ) {
            [(id<MICUiDraggableCellProtocol>)cell.view onBeginCustomizing:self];
        }
    }
}

/**
 * D&Dによるカスタマイズを終了するときに呼び出される。
 *  onBeginCustomizingで行った変更を元に戻す。
 */
- (void) onEndCustomizing {
    for( MICUiLayoutCell* cell in _children) {
        if( [cell.view conformsToProtocol:@protocol(MICUiDraggableCellProtocol)] ) {
            [(id<MICUiDraggableCellProtocol>)cell.view onEndCustomizing:self];
        }
    }
}

/**
 * ドラッグを開始する。
 *
 * @param eventArg  コンテナビュー座標でのタップ位置など
 * @return true:ドラッグを開始した　/ false:ドラッグは開始していない。
 */
- (BOOL)beginDrag:(id<MICUiDragEventArg>) eventArg {
    if( _children.count == 0) {
        return false;
    }
//    NSLog(@"beginDrag:%@", [self name]);
    CGPoint touchPos = [eventArg firstTouchPosOn:self];
    MICUiLayoutCell* cell = [self hitTestAtX:touchPos.x andY:touchPos.y];
    if( nil==cell || !cell.draggable) {
        return false;
    }

    if([cell.view conformsToProtocol:@protocol(MICUiDraggableCellProtocol)]) {
        if( ![(id<MICUiDraggableCellProtocol>)cell.view onBeginDragging:self]) {
            return false;
        }
    }
    
    if(![cell beginDrag]) {
        // ドラッグ開始が拒否された
        return false;
    }

    // スクロールサポータにビューを預ける。
    [eventArg depositView:cell.view];
    eventArg.draggingCell = cell;

    // ドラッグ情報管理用オブジェクトを作成（サブクラスで実装）
    _draggingInfo = [self createCellDraggingInfo:cell event:(id<MICUiDragEventArg>) eventArg];
    _draggingInfo.eventArgs = eventArg;

    // スクロール監視タイマーを起動
//    [self startScrollingTimer];
    return true;
}

/**
 * ドラッグ終了（ドロップ）
 */
- (void)endDrag:(id<MICUiDragEventArg>) eventArg {
//    [self stopScrollingTimer];
    if(nil==_draggingInfo){
        return;
    }

    bool itsme = eventArg.dragDestination == self;      // 自分にドロップされたか？・・・endDrag/cancelDragメッセージは、サポータが管理するすべてのレイアウタに送られる
    if(itsme) {
        // 預けていたセルビューをコンテナビューに戻してもらう。
        [eventArg bringBack:true ofLayout:self];
    }
    
    MICUiLayoutCell* cell =_draggingInfo.draggingCell;
    [_draggingInfo.draggingCell endDrag];
    _draggingInfo = nil;

    if([cell.view conformsToProtocol:@protocol(MICUiDraggableCellProtocol)]) {
        [(id<MICUiDraggableCellProtocol>)cell.view onEndDragging:self done:true];
    }
    
    if(eventArg.dragSource == self || eventArg.dragDestination == self) {
        [self updateLayout:true onCompleted:nil];
    }
    
    if(itsme && nil!=_layoutDelegate) {
        [self ensureCellVisible:cell];
    }
//    NSLog(@"endDrag:%@", [self name]);
    
}

/**
 * ドラッグ操作をキャンセルして、ドラッグ開始時の状態に戻す。
 */
- (void)cancelDrag:(id<MICUiDragEventArg>) eventArg {
//    [self stopScrollingTimer];
    if(nil==_draggingInfo){
        return;
    }
    
    MICUiLayoutCell* cell = _draggingInfo.draggingCell;
    [cell endDrag];
    
    if(eventArg.dragSource == self) {
        if(eventArg.dragDestination!=self) {
            [_draggingInfo takein];
            _needsRecalcLayout = true;
        }
        [eventArg bringBack:true ofLayout:self];
        
        
        //      cell.view.alpha = 1.0f;
        if([self resetDrag:eventArg]) {
            [self updateLayout:true onCompleted:nil];
        }
    } else if(eventArg.dragDestination==self) {
        [_draggingInfo takeout];

        if([eventArg.draggingView conformsToProtocol:@protocol(MICUiDraggableCellProtocol)]) {
            [(id<MICUiDraggableCellProtocol>)eventArg.draggingView onEndDragging:self done:false];
        }
        
        _needsRecalcLayout = true;
        [self updateLayout:true onCompleted:nil];
    }
    _draggingInfo = nil;
}

/**
 * レイアウターにドロップは可能か？
 */
- (BOOL) canDrop:(id<MICUiDragEventArg>) eventArg {
    if(nil!=_dropAcceptorDelegate) {
        CGPoint touchPos = [eventArg touchPosOn:self];
        MICUiLayoutCell* cell = [self hitTestAtX:touchPos.x andY:touchPos.y];
        return [_dropAcceptorDelegate canDropView:[eventArg draggingView] fromLayout:[eventArg dragSource] toLayout:self onView:cell.view];
    }
    return true;
}

/**
 * ドロップ不可能なレイアウター上をしつこくホバーしている
 */
- (void)dragHover:(id<MICUiDragEventArg>)eventArg {
    if(nil!=_dropAcceptorDelegate) {
        CGPoint touchPos = [eventArg touchPosOn:self];
        MICUiLayoutCell* cell = [self hitTestAtX:touchPos.x andY:touchPos.y];
        [_dropAcceptorDelegate onHoverView:[eventArg draggingView] fromLayout:[eventArg dragSource] toLayout:self onView:cell.view];
    }
}

/**
 * アイテムがレイアウター外からドラッグされて、レイアウター内に持ち込まれる。
 */
- (void) dragEnter:(id<MICUiDragEventArg>) eventArg {
    if(nil==_draggingInfo) {
        // 外部から（初めて）セルが持ち込まれる
        _draggingInfo = [self createCellDraggingInfo:nil event:eventArg];
    }
    if([_draggingInfo takein]) {
        _needsRecalcLayout = true;
    }
    _draggingInfo.eventArgs = eventArg;
//    [self startScrollingTimer];
    [self dragTo:eventArg];
}



/**
 * アイテムがレイアウターからドラッグされてレイアウター外に持ちだされる
 */
- (void) dragLeave:(id<MICUiDragEventArg>) eventArg {
    if(nil==_draggingInfo) {
        return;
    }
    
    if([_draggingInfo takeout]) {
        _needsRecalcLayout = true;
    }
//    [self stopScrollingTimer];
    [self updateLayout:true onCompleted:nil];
}

/**
 * 指定位置へドラッグする。
 *
 * @param eventArg  コンテナビュー座標でのドラッグ位置など
 */
- (void)dragTo:(id<MICUiDragEventArg>) eventArg {
    
//    NSLog(@"dragTo: %@", [self description]);
    if(nil==_draggingInfo || eventArg.dragDestination != self){
//        NSString* s1 = (nil==_draggingInfo)?@"dinfo==nil":@"";
//        NSString* s2 = (eventArg.dragDestination != self)?@"it's not me.":@"";
//        NSLog(@"dragTo: %@ %@", s1, s2 );
        return;
    }
    
    if([self doDrag:eventArg]) {
        _needsRecalcLayout = true;
        [self updateLayout:true onCompleted:nil];
        [self ensureCellVisible:eventArg.draggingCell];
    }
}

@end
