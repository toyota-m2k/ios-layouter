//
//  WPLNamedValueHost.h
//
//  未使用
//  WPLSliderCell の min/max をNamedValueとして扱うようにしたときに、その変更を監視する仕掛けが必要になると思ったが、
//  このmin/maxは、bindingMode==SOURCE_TO_VIEW でしか使わないので、Viewの操作からキックされて変更を通知する必要がないことに気づいたので、使わなかった。
//  将来、複数のvalueをVIEW_TO_SOURCE, TWO_WAY で操作する機会があれば、これを使う時が来るかもしれない。
//
//  Created by @toyota-m2k on 2020/02/03.
//  Copyright @toyota-m2k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPLCellDef.h"

@interface WPLNamedValueHost : NSObject

- (instancetype) initWithOwner:(id<IWPLCell>) ownerCell;

- (void) setupName:(NSString*) name value:(id)initialValue;
- (void) setup:(NSDictionary<NSString*,id>*) table;
- (void) dispose;


- (id) valueForName:(NSString*)name;
- (void) setValue:(id)value forName:(NSString*)name;

/**
 * Viewへの入力が更新されたときのリスナー登録
 * @param target        listener object
 * @param selector      (cell,name)->Unit
 * @return key  removeNamedValueListenerに渡して解除する
 */
- (id) addNamed:(NSString*)name valueListener:(id)target selector:(SEL)selector;

/**
 * リスナーの登録を解除
 */
- (void) removeNamed:(NSString*)name valueListener:(id)key;

@end
