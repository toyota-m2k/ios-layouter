//
//  WPLObservableDef.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MICTargetSelector.h"

/**
 * 監視可能なデータオブジェクトの基底i/f
 * value は他の値/関数にデリゲートされることを前提とし、外部からの直接変更を禁止。
 */
@protocol IWPLObservableData <NSObject>
    /**
     * 値属性
     */
    @property (nonatomic,readonly) id value;
    @property (nonatomic,readonly) NSString* stringValue;
    @property (nonatomic,readonly) CGFloat floatValue;
    @property (nonatomic,readonly) bool boolValue;
    @property (nonatomic,readonly) NSInteger intValue;

    /**
     * 値が変化したことを通知する
     */
    - (void) valueChanged;

    /**
     * 値変更が影響する属性のリスト
     */
    // @property (nonatomic,readonly) NSMutableArray<id<IWPLObservableData>>* relations

    - (void) addRelation:(id<IWPLObservableData>)relation;

    - (void) addRelations:(NSArray<id<IWPLObservableData>>*) relations;

    - (void) removeRelation:(id<IWPLObservableData>)relation;

    /**
     * 値変更監視リスナーを追加する
     * @param target     通知先
     * @param selector   メソッドのセレクタ
     * @return 登録されたリスナーを識別するキー --> removeValueChangedListener に渡して登録解除する
     */
    - (id) addValueChangedListener:(id)target selector:(SEL)selector;

    /**
     * リスナーを登録解除する
     * @param key   addValueChangedListener の戻り値
     */
    - (void) removeValueChangedListener:(id)key;

    /**
     * for debug
     */
    - (bool) cyclicRelationCheck:(id<IWPLObservableData>)ob;

    /**
     * 解放
     */
    - (void) dispose;
@end

/**
 * 普通の変更可能なvalue属性を持つデータオブジェクトのi/f
 */
@protocol IWPLObservableMutableData  <IWPLObservableData>
    /**
     * 値属性（R/W)
     */
    @property (nonatomic) id value;
    @property (nonatomic) NSString* stringValue;
    @property (nonatomic) CGFloat floatValue;
    @property (nonatomic) bool boolValue;
    @property (nonatomic) NSInteger intValue;
@end

@protocol IWPLDelegatedDataSource;

typedef id (^WPLSourceDelegateProc)(id<IWPLDelegatedDataSource>);

/**
 * valueを外部にデリゲートするデータオブジェクトの i/f
 */
@protocol IWPLDelegatedDataSource   <IWPLObservableData>
    //var sourceDelegate: (()->Any?)
    // Block または、TargetSelector を指定。
    // 両方設定している場合は blockの方を優先。
    @property (nonatomic) WPLSourceDelegateProc sourceDelegateBlock;
    @property (nonatomic) MICTargetSelector* sourceDelegateSelector;
@end

