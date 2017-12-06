//
//  MICUiSwitchingViewMediator.m
//
//  予め設定しておいたルールにしたがって、複数のビュー（ペイン）の表示非表示を自動的に切り替える仲介者クラス
//
//  Created by 豊田 光樹 on 2014/12/24.
//  Copyright (c) 2014年 M.TOYOTA. All rights reserved.
//

#import "MICUiSwitchingViewMediator.h"

/**
 * 内部状態
 */
typedef enum _ItemState {
    INVALID,
    SHOWN,
    HIDDEN,
    REQ_SHOWN,
    REQ_HIDDEN,
} ItemState;

/**
 * 状態を保持するクラス
 */
@interface MICUiSwitchingViewInfo : NSObject

@property (nonatomic,weak)  UIView* view;
@property (nonatomic) NSString* name;
@property (nonatomic,weak) id<MICUiViewVisibilityDelegate> delegate;
@property (nonatomic) ItemState state;

- (instancetype) initWithView:(UIView*)view forName:(NSString*)name delegate:(id<MICUiViewVisibilityDelegate>)delegate;

- (void) updateVisibility:(void (^)(BOOL)) onCompleted;

@end

@implementation MICUiSwitchingViewInfo

-(instancetype)initWithView:(UIView*)view forName:(NSString*)name delegate:(id<MICUiViewVisibilityDelegate>)delegate {
    self = [super init];
    if(nil!=self) {
        _view = view;
        _name = name;
        _delegate = delegate;
        _state = INVALID;
    }
    return self;
}

- (bool) isVisible {
    if(nil!=_delegate) {
        return [_delegate isViewVisible:_view];
    } else {
        return !_view.isHidden;
    }
}

- (void)updateVisibility:(void (^)(BOOL)) onCompleted {
    bool result = false;
    if(_state == REQ_SHOWN) {
        if(nil!=_delegate) {
            if(![_delegate isViewVisible:_view]) {
                [_delegate setViewVisibility:_view visible:true onCompleted:onCompleted];
                result = true;
            }
        } else {
            if(_view.isHidden) {
                _view.hidden = false;
            }
        }
        _state = SHOWN;
    }
    else if(_state == REQ_HIDDEN) {
        if(nil!=_delegate) {
            if([_delegate isViewVisible:_view]) {
                [_delegate setViewVisibility:_view visible:false onCompleted:onCompleted];
                result = true;
            }
        } else {
            if(!_view.isHidden) {
                _view.hidden = true;
            }
        }
        _state = HIDDEN;
    } else if(_state==INVALID){
        bool visible = false;
        if(nil!=_delegate) {
            visible = [_delegate isViewVisible:_view];
        } else {
            visible = !_view.isHidden;
        }
        _state = (visible) ? SHOWN : HIDDEN;
    }
    if(!result && nil!=onCompleted) {
        onCompleted(false);
    }
}

@end

@interface MICUiSwitchingRule : NSObject
@property (nonatomic)   NSMutableArray* exclusives;
@property (nonatomic)   NSMutableArray* companions;
@property (nonatomic)   NSMutableArray* alternatives;
@end

@implementation MICUiSwitchingRule

- (instancetype)init {
    self = [super init];
    if(nil!=self){
        _exclusives = [[NSMutableArray alloc] init];
        _companions = [[NSMutableArray alloc] init];
        _alternatives = [[NSMutableArray alloc] init];
    }
    return self;
}

@end


/**
 * ビューの表示・非表示（開閉）を調停するためのメディエーター
 */
@implementation MICUiSwitchingViewMediator {
    NSMutableDictionary* _views;
//    NSMutableArray* _exclusives;
//    NSMutableArray* _companions;
//    NSMutableArray* _alternatives;
    MICUiSwitchingRule* _rule;
    NSMutableDictionary* _stockedRules;
    int _updating;
    bool _changed;
}

/**
 * 初期化
 */
- (instancetype)init {
    self = [super init];
    if(nil!=self) {
        _views = [[NSMutableDictionary alloc] init];
        _rule = [[MICUiSwitchingRule alloc] init];
        _stockedRules = [[NSMutableDictionary alloc] init];
//        _exclusives = [[NSMutableArray alloc] init];
//        _companions = [[NSMutableArray alloc] init];
//        _alternatives = [[NSMutableArray alloc] init];
        _updating = 0;
        _changed = false;
    }
    return self;
}

- (void) startUpdate {
    if(0==_updating && nil!=_delegate) {
        _changed = false;
        [_delegate willSwitchViewVisibility:self];
    }
    _updating++;
}

- (void) endUpdate :(bool)changed {
    _updating--;
    _changed |= changed;
    if(0==_updating && nil!=_delegate) {
        [_delegate didSwitchViewVisibility:self changed:_changed];
        _changed = false;
    }
}

/**
 * 管理対象ビューを登録する
 *  @param  view        ビュー
 *  @param  name        ビューの名前
 *  @param  callback    ビュー開閉操作用デリゲート（nilなら、Viewの hidden 属性を操作する）
 */
- (void)registerView:(UIView *)view ofName:(NSString *)name callback:(id<MICUiViewVisibilityDelegate>)callback {
    MICUiSwitchingViewInfo* info = [[MICUiSwitchingViewInfo alloc] initWithView:view forName:name delegate:callback];
    [_views setObject:info forKey:name];
    
}

/**
 * 管理対象ビューの登録を解除する
 * @param name  解除するビューの名前
 */
- (void)unregisterView:(NSString *)name {
    [_views removeObjectForKey:name];
}

/**
 * このリスト内のビューが１つ表示されたら、残りは非表示にする。
 */
- (void)setExclusiveViewGroup:(NSArray *)namelist {
    [_rule.exclusives addObject:namelist];
}

/**
 * このリスト内のビューが１つ表示されたら、残りも表示する。
 */
- (void)setCompanionViewGroup:(NSArray *)namelist {
    [_rule.companions addObject:namelist];
}

/**
 * このリスト内の片方のビューが表示されたら、もう片方を非表示にする。
 * 逆に、片方が非表示になったら、もう片方を表示する。
 */
- (void)setAlternativeViewGroup:(NSArray *)namelistA andAnotherGroup:(NSArray *)namelistB {
    NSArray* pair = [NSArray arrayWithObjects:namelistA, namelistB, nil];
    [_rule.alternatives addObject:pair];
}

/**
 * 現在設定中のルールをクリアする。
 */
- (void) clearRule {
    _rule = [[MICUiSwitchingRule alloc] init];
}

/**
 * 現在設定中のルールに名前をつける。この名前を使って、activateRuleメソッドが使用可能になる。
 */
- (void) stockRuleAs:(NSString *)rulename {
    [_stockedRules setObject:_rule forKey:rulename];
}

/**
 * 現在設定中のルールをクリアして、対比されているルールのなかから名前で指定されたルールを有効化する。
 */
- (void) activateRule:(NSString *)rulename {
    id rule = _stockedRules[rulename];
    if(nil!=rule){
        _rule = rule;
    } else {
        NSLog(@"MICUiSwichingViewMediator.activateRule: no such rule: %@", rulename);
        [self clearRule];
    }
}



/**
 * ビューの名前を返す（NSDictionaryの逆引きのため、数が増えると効率が悪いので注意）
 */
- (NSString*) getViewName:(UIView*)view {
    for(NSString* name in _views.keyEnumerator) {
        if(view == ((MICUiSwitchingViewInfo*)_views[name]).view) {
            return name;
        }
    }
    return nil;
}

- (UIView*) getViewByName:(NSString*)name {
    return ((MICUiSwitchingViewInfo*)_views[name]).view;
}

/**
 * 配列にビューが含まれているか？
 */
- (bool) containsView:(NSString*)name inArray:(NSArray*)ary {
    for(NSString* k in ary) {
        if([name isEqualToString:k]) {
            return true;
        }
    }
    return false;
}

/**
 * 排他グループ内のビューを非表示にする。
 */
- (void) reserveExclusiveViews:(MICUiSwitchingViewInfo*) info visibility:(bool)visible {
    if(!visible) {
        return;
    }
    for(NSArray* ary in _rule.exclusives) {
        if([self containsView:info.name inArray:ary]) {
            for(NSString* ev in ary) {
                if(![info.name isEqualToString:ev]) {
                    [self reserveViewVisibility:_views[ev] visibility:false];
                }
            }
        }
    }
}

/**
 * 道連れグループ内のビューを表示/非表示にする。
 */
- (void) reserveCompanionViews:(MICUiSwitchingViewInfo*) info visibility:(bool)visible {
    for(NSArray* ary in _rule.companions) {
        if([self containsView:info.name inArray:ary]) {
            for(NSString* cv in ary) {
                if(![info.name isEqualToString:cv]) {
                    [self reserveViewVisibility:_views[cv] visibility:visible];
                }
            }
        }
    }
}

/**
 * 交代グループのビューの表示／非表示を切り替える
 */
- (void) reserveAlternativeViews:(MICUiSwitchingViewInfo*) info visibility:(bool)visible {
    for(NSArray* ary in _rule.alternatives) {
        NSArray* ary0 = ary[0];
        NSArray* ary1 = ary[1];
        if([self containsView:info.name inArray:ary0]) {
        } else if([self containsView:info.name inArray:ary1]) {
            ary1 = ary0;
        } else {
            continue;
        }
        for(NSString* av in ary1) {
            [self reserveViewVisibility:_views[av] visibility:!visible];
        }
    }
}

/**
 * ビューの表示・非表示を指定する。
 */
- (void) reserveViewVisibility:(MICUiSwitchingViewInfo*) info visibility:(bool)visible {
    ItemState current = info.state;
    ItemState requested = (visible) ? REQ_SHOWN : REQ_HIDDEN;

    if(requested == current) {
        return;
    }
    
    if(current == REQ_SHOWN || current == REQ_HIDDEN ) {
        // 依存関係更新中に、矛盾が見つかった
        [NSException raise:@"MICUiSwichingViewMediator" format:@"cannot resolve corresponding view-visibility."];
    }
    
    info.state = requested;
    [self reserveExclusiveViews:info visibility:visible];
    [self reserveCompanionViews:info visibility:visible];
    [self reserveAlternativeViews:info visibility:visible];
}

/**
 * ビューの表示/非表示状態を適用する。
 */
- (void) applyVisibilities {
    [self startUpdate];
    
    for(NSString* name in _views.keyEnumerator) {
        [self startUpdate];
        [_views[name] updateVisibility:^(BOOL s) {
            [self endUpdate:s];
        }];
    }

    [self endUpdate:false];
}

/**
 * showView/hideViewの中の人
 */
- (void)setViewVisibility:(NSString *)name visible:(bool)visible updateView:(bool)update {
    if(_updating>0) {
        return;
    }
    
    MICUiSwitchingViewInfo* info = [_views objectForKey:name];
    if(nil==info) {
        return;
    }
    [self reserveViewVisibility:info visibility:visible];
    if(update){
        [self applyVisibilities];
    }
}

/**
 * ビューを表示する
 *  @param name    表示するビューの名前
 *  @param update   true:ビューの表示状態を更新する / false:内部情報を設定するだけ（あとから明示的に applyVisibilitiesを呼ぶこと）
 */
- (void)showView:(NSString *)name updateView:(bool)update {
    [self setViewVisibility:name visible:true updateView:update];
}

/**
 * ビューを非表示する
 *  @param name    非表示にするビューの名前
 *  @param update   true:ビューの表示状態を更新する / false:内部情報を設定するだけ（あとから明示的に applyVisibilitiesを呼ぶこと）
 */
- (void)hideView:(NSString *)name  updateView:(bool)update {
    [self setViewVisibility:name visible:false updateView:update];
}

@end
