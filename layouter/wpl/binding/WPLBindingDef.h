//
//  WPLBindingDef.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/03.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//
#import "WPLObservableDef.h"
#import "WPLCellDef.h"

/**
 * バインドモード
 */
typedef enum _WPLBindingMode {
    WPLBindingModeTWO_WAY,                   // TwoWay
    WPLBindingModeVIEW_TO_SOURCE_WITH_INIT,  // OneWayToSource   初期化時だけSOURCE->View に反映する
    WPLBindingModeSOURCE_TO_VIEW,            // OneWay
    WPLBindingModeVIEW_TO_SOURCE,            // OneWayToSource
} WPLBindingMode;

@protocol IWPLBinding;

/**
 * Custom Action function type
 */
typedef void (^WPLBindingCustomAction)(id<IWPLBinding> sender, bool fromView);

/**
 * バインドオブジェクトの基底i/f
 */
@protocol IWPLBinding <NSObject>
    /**
     * ターゲットCell
     */
    @property (nonatomic,readonly) id<IWPLCell> cell;

    /**
     * データソース
     */
    @property (nonatomic,readonly) id<IWPLObservableData> source;

    /**
     * バインドモード
     */
    @property (nonatomic,readonly) WPLBindingMode bindingMode;

    /**
     * 値変更時のカスタムアクション
     */
    @property (nonatomic,readonly) WPLBindingCustomAction customAction;

    - (void) dispose;
@end

/**
 * Bool型ソースから、Viewの状態（visibility, enabled, readonly)へのアクション指定
 */
typedef enum _WPLBoolStateActionType {
    WPLBoolStateActionTypeVISIBLE_COLLAPSED,
    WPLBoolStateActionTypeVISIBLE_INVISIBLE,
    WPLBoolStateActionTypeENABLED,
    WPLBoolStateActionTypeREADONLY,
} WPLBoolStateActionType;

/**
 * Bool型ソースとViewの状態（visibility, enabled, readonly)のBindingを実現するための i/f
 */
//@protocol IWPLBoolStateBinding <IWPLBinding>
//    @property (nonatomic, readonly) WPLBoolStateActionType actionType;
//    @property (nonatomic, readonly) bool negation;
//@end

/**
 *  
 */
typedef enum _WPLPropType {
    WPLPropTypeALPHA,
    WPLPropTypeBG_COLOR,
    WPLPropTypeFG_COLOR,
    WPLPropTypeTEXT,
} WPLPropType;

//@protocol IWPLPropBinding <IWPLBinding>
//@property (nonatomic, readonly) WPLPropertyType propType;
//@end

