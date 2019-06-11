//
//  MICSortedArray.h
//
//  C#のSortedListのようなものを作りたかったが、NSMutableArrayを継承するのは、いろいろハードルが高いので、これを内包する形にした。
//
//  Created by @toyota-m2k on 2019/04/23.
//  Copyright  2019 @toyota-m2k Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _MICSortedArrayPosition {
    NSInteger hit;
    NSInteger prev;
    NSInteger next;
} MICSortedArrayPosition;

#if defined(__cplusplus)
class CMICSortedArrayPosition : public MICSortedArrayPosition {
public:
    CMICSortedArrayPosition() {
        reset();
    }
    void reset() {
        hit = prev = next = -1;
    }
    static void reset(MICSortedArrayPosition* s) {
        if(NULL!=s) {
            s->hit = s->prev = s->next = -1;
        }
    }
};
#endif

@interface MICSortedArray : NSObject

@property (nonatomic,readonly) NSArray* array;
@property (nonatomic) bool allowDuplication;        // キーの重複を許可する(true）か、許可しない(false：デフォルト)か

/**
 * ソート関数を指定してオブジェクトを初期化
 */
- (instancetype) initWithComparator:(NSComparisonResult(^)(id o1, id o2)) comparator ascending:(bool) ascending;
- (instancetype) initWithComparator:(NSComparisonResult(^)(id o1, id o2)) comparator ascending:(bool) ascending allowDuplication:(bool) allowDuplication capacity:(NSInteger)capacity;

/**
 * ソート関数を変更して、ソートし直す。
 */
- (void) sortWithComparator:(NSComparisonResult(^)(id o1, id o2)) fn ascending:(bool) ascending;

/**
 * ソートされた配列の適切な位置に値を挿入
 * @return 挿入位置のインデックス
 */
- (NSInteger) addElement:(id) element;

/**
 * エレメントまたは、エレメント挿入位置を探す
 */
- (NSInteger) findElement:(id) element result:(MICSortedArrayPosition*)result;

- (MICSortedArrayPosition) findElement:(id) element;

- (void) removeAll;

- (void) removeAt:(NSInteger)index;

- (NSInteger) indexOf:(id)element;
@end
