//
//  MICAutoLayoutBuilder.h
//  AnothorWorld
//
//  Created by toyota-m2k on 2019/08/09.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MICUiRectUtil.h"
#import "MICUiLayout.h"       // MICUiAlignEx を借用

#if defined(__cplusplus)

/**
 * NSLayoutConstraint を使った　AutoLayout の指定を、ちょっと便利にするクラス。
 */
class MICAutoLayoutBuilder {
protected:
    NSMutableArray<NSLayoutConstraint *>* _constraints;
    UIView* _parentView;
    bool _autoActivate;
public:
    /**
     * コンストラクタ
     * @param parentView        NSLayoutConstraintの親となるビュー
     * @praam autoActivate      true：   デストラクタで、自動的にactivateする。
     *                          false：  明示的に activate()を呼ぶか、close()で取得した constraintsの配列を使って自力でactivateする。
     *                                  複数のconstraintセットを切り替えて使うような場合に利用することを想定。
     */
    MICAutoLayoutBuilder(UIView* parentView, bool autoActivate=true) {
        _constraints = [NSMutableArray array];
        _parentView = parentView;
        _autoActivate = true;
    }
    
    /**
     * デストラクタ
     *  autoActivate==trueの場合は作成したConstraintsをアクティブ化する。
     */
    ~MICAutoLayoutBuilder() {
        if(_autoActivate && _constraints!=nil && _constraints.count>0) {
            activate();
        }
        _constraints = nil;
        _parentView = nil;
    }
    
    /**
     * Constraintを作成して、内部の配列に蓄積する。
     * @param target        制約を付与するビュー
     * @param attr          制約を付与するビューの属性：Left/Top/Right/Bottom/Width/Height/CenterX/Y など
     * @param relatedTo     制約の基準とするビュー
     * @param attrTo        制約に紐づける、基準ビューの属性
     * @param constant      距離・サイズなどの定数値
     * @param multiplier    距離・サイズなどに掛ける倍率
     * @param relatedBy     普通は（私は）equal しか使わない
     * @param priority      普通は（私は）required しか使わない。
     */
    MICAutoLayoutBuilder&
    constraint(UIView* target, NSLayoutAttribute attr, UIView* relatedTo, NSLayoutAttribute attrTo,
                                       CGFloat constant = 0.0, CGFloat multiplier = 1.0,
                                       NSLayoutRelation relatedBy=NSLayoutRelationEqual,
                                       UILayoutPriority priority=UILayoutPriorityRequired);
    /**
     * Anchorベースの制約を作成して、内部の配列に蓄積する。 (iOS 9.0以降が必要）
     * @param anchor        制約を付与するビューのアンカー
     * @param relatedAnchor 制約の基準とするビューのアンカー
     * @param margin        アンカー間の距離など（constantに相当）
     * @param relativity    普通は（私は）ゼロ（equalToAnchor）しか使わない。
     */
    MICAutoLayoutBuilder&
    anchorConstraint(NSLayoutAnchor* anchor, NSLayoutAnchor* relatedAnchor, CGFloat margin = 0, int relativity=0);

    /**
     * 制約に固定幅を設定
     */
    MICAutoLayoutBuilder&
    setFixedWidth(UIView* target, CGFloat width) {
        return constraint(target, NSLayoutAttributeWidth, nil, NSLayoutAttributeWidth, width);
    }

    /**
     * 制約に固定高さを設定
     */
    MICAutoLayoutBuilder&
    setFixedHeight(UIView* target, CGFloat height) {
        return constraint(target, NSLayoutAttributeHeight, nil, NSLayoutAttributeHeight, height);
    }

    /**
     * 制約に他ビューに対する相対幅を設定
     */
    MICAutoLayoutBuilder&
    setRelativeWidth(UIView* target, UIView* related, CGFloat multiplier=1.0) {
        return constraint(target, NSLayoutAttributeWidth, related, NSLayoutAttributeWidth, 0, multiplier);
    }

    /**
     * 制約に他ビューに対する相対高さを設定
     */
    MICAutoLayoutBuilder&
    setRelativeHeight(UIView* target, UIView* related, CGFloat multiplier=1.0) {
        return constraint(target, NSLayoutAttributeHeight, related, NSLayoutAttributeHeight, 0, multiplier);
    }

    /**
     * ビューのセーフエリアに合わせて配置する
     * @param target        対象ビュー
     * @param pos           targetのどの辺に制約をつけるかを指定するビットフラグ（MICUiPosExLEFT|TOP|RIGHT|BOTTOM）を指定
     * @param margin        セーフエリアからのマージン（posで指定されていない部分のマージンは無視される）
     */
    MICAutoLayoutBuilder&
    fitToSafeArea(UIView* target, MICUiPosEx pos = MICUiPosExALL, const UIEdgeInsets& margin=MICEdgeInsets(), int relativity=0);

    /**
     * 親ビューに合わせて配置する
     * @param target        対象ビュー
     * @param pos           targetのどの辺に制約をつけるかを指定するビットフラグ（MICUiPosExLEFT|TOP|RIGHT|BOTTOM）を指定
     * @param margin        親ビューのからのマージン（posで指定されていない部分のマージンは無視される）
     */
    MICAutoLayoutBuilder&
    fitToParent(UIView* target, MICUiPosEx pos, const UIEdgeInsets& margin);

    /**
     * 縦方向に兄弟ビューを並べる
     */
    MICAutoLayoutBuilder& fitVerticallyToSibling(UIView* target, UIView* sibling, bool below, CGFloat spacing, MICUiAlignEx alignToSibling);

    /**
     * 横方向に兄弟ビューを並べる
     */
    MICAutoLayoutBuilder& fitHorizontallyToSibling(UIView* target, UIView* sibling, bool right, CGFloat spacing, MICUiAlignEx alignToSibling);

    /**
     * ビューを兄弟ビューの下に配置する
     * @param target            新たに配置するビュー
     * @param sibling           基準とする兄弟ビュー
     * @param spacing           兄弟ビューと配置するビューの間隔
     * @param alignToSibling    兄弟ビューとの整列方法：TOP(LEFT) | CENTER | BOTTOM(RIGHT) のいずれか。
     */
    MICAutoLayoutBuilder& putBelow(UIView* target, UIView* sibling, CGFloat spacing, MICUiAlignEx alignToSibling) {
        return fitVerticallyToSibling(target, sibling, true, spacing, alignToSibling);
    }
    
    /**
     * ビューを兄弟ビューの上に配置する
     * @param target            新たに配置するビュー
     * @param sibling           基準とする兄弟ビュー
     * @param spacing           兄弟ビューと配置するビューの間隔
     * @param alignToSibling    兄弟ビューとの整列方法：TOP(LEFT) | CENTER | BOTTOM(RIGHT) のいずれか。
     */
    MICAutoLayoutBuilder& putAbove(UIView* target, UIView* sibling, CGFloat spacing, MICUiAlignEx alignToSibling) {
        return fitVerticallyToSibling(target, sibling, false, spacing, alignToSibling);
    }
    
    /**
     * ビューを兄弟ビューの右に配置する
     * @param target            新たに配置するビュー
     * @param sibling           基準とする兄弟ビュー
     * @param spacing           兄弟ビューと配置するビューの間隔
     * @param alignToSibling    兄弟ビューとの整列方法：TOP(LEFT) | CENTER | BOTTOM(RIGHT) のいずれか。
     */
    MICAutoLayoutBuilder& putRight(UIView* target, UIView* sibling, CGFloat spacing, MICUiAlignEx alignToSibling) {
        return fitHorizontallyToSibling(target, sibling, true, spacing, alignToSibling);
    }
    
    /**
     * ビューを兄弟ビューの左に配置する
     * @param target            新たに配置するビュー
     * @param sibling           基準とする兄弟ビュー
     * @param spacing           兄弟ビューと配置するビューの間隔
     * @param alignToSibling    兄弟ビューとの整列方法：TOP(LEFT) | CENTER | BOTTOM(RIGHT) のいずれか。
     */
    MICAutoLayoutBuilder& putLeft(UIView* target, UIView* sibling, CGFloat spacing, MICUiAlignEx alignToSibling) {
        return fitHorizontallyToSibling(target, sibling, false, spacing, alignToSibling);
    }

    /**
     * 作成中の制約を返すとともに、内部情報をリセット。
     * @param activate      true なら、クローズ前にアクティブ化する。
     * @param createNew     true なら、続けて別の制約リストを作成できるよう、内部配列を再初期化する。
     * @return              作成した制約リスト（activateしたりdeactivateしたりするために使う）
     */
    NSMutableArray<NSLayoutConstraint *>* close(bool activate, bool createNew) {
        auto r = _constraints;
        if(activate && _constraints!=nil && _constraints.count>0) {
            [NSLayoutConstraint activateConstraints:_constraints];
        }
        _constraints = nil;
        if(createNew) {
            _constraints = [NSMutableArray array];
        }
        return r;
    }

    /**
     * 作成した制約をアクティブ化してクローズする
     * @param createNew     true なら、続けて別の制約リストを作成できるよう、内部配列を再初期化する。
     */
    NSMutableArray<NSLayoutConstraint *>* activate(bool createNew=false) {
        return close(true, createNew);
    }
};


// Relative Auto-Layouter

/**
 * ビューの各辺の位置を、他のビューの辺に対する相対位置で指定するパラメータークラス
 */
class RALAttach {
public:
    enum Attach {
        FREE,           // 規定しない（デフォルト：他の要素に基づいて決定される）
        FIT,            // 兄弟または親の対応する辺に対して配置　--> 上下左右を揃える
        ADJACENT,       // 兄弟の向かい合う辺に対して配置する --> 上下左右に並べる
        CENTER,         // センタリング（縦方向ならtop/bottom、横方向ならleft/right のいずれかに指定。もう片方の指定は無視される）
        SAFE_AREA,      // セーフエリアにアタッチ
    };
public:
    Attach _attach;
    UIView* _related;
    CGFloat _value;
public:
    RALAttach() {
        _attach = FREE;
        _related = nil;
        _value = 0;
    }
    
    RALAttach(const RALAttach& src) {
        _attach = src._attach;
        _related = src._related;
        _value = src._value;
    }
    
    RALAttach& free() {
        _attach = FREE;
        _related = nil;
        _value = 0;
        return *this;
    }
    
    /**
     * 上下左右を揃える
     * sibling(兄弟View)の対応する辺からの距離で指定
     */
    RALAttach& fit(UIView* sibling, CGFloat distance=0) {
        _attach = FIT;
        _related = sibling;
        _value = distance;
        return *this;
    }
    /**
     * 親にアタッチ：fit(nil) と同義
     */
    RALAttach& parent(CGFloat distance=0) {
        _attach = FIT;
        _related = nil;
        _value = distance;
        return *this;
    }
    
    /**
     * セーフエリアにアタッチ
     */
    RALAttach& safeArea(CGFloat distance=0) {
        _attach = SAFE_AREA;
        _related = nil;
        _value = distance;
        return *this;
    }
    
    /**
     * 上下左右に並べる
     * sibling(兄弟View)の向かい合う辺からの距離で指定
     */
    RALAttach& adjacent(UIView* sibling, CGFloat distance=0) {
        _attach = ADJACENT;
        _related = sibling;
        _value = distance;
        return *this;
    }
    
    /**
     * 中央寄せ
     * @param   sibling     基準ビュー（nilなら親を基準にする）
     */
    RALAttach& center(UIView* sibling=nil) {
        _attach = CENTER;
        _related = sibling;
        _value = 0;
        return *this;
    }
};

/**
 * ビューのサイズを規定するパラメータクラス
 */
class RALScaling {
public:
    enum Scaling {
        FREE,               // 規定しない（他のパラメータから決定される）
        FIXED,              // 固定サイズ（valueで与える）
        NOSIZE,             // サイズ変更しない（viewのサイズのまま配置する）
        RELATIVE,           // relatedビュー（nilなら親ビュー）のサイズを基準に value 倍したサイズにする
    };
    
public:
    Scaling _scaling;
    UIView* _related;            // relative以外の場合は無視 / relativeで target == nil なら親相対
    CGFloat _value;             // fixed の場合は実サイズ、relativeの場合は、比率（１ならequal)、それ以外の場合は無視
    
public:
    RALScaling() {
        _scaling = NOSIZE;
        _related = nil;
        _value = 0;
    }
    RALScaling(const RALScaling& src) {
        _scaling = src._scaling;
        _related = src._related;
        _value = src._value;
    }
    RALScaling& fixed(CGFloat size) {
        _scaling = FIXED;
        _related = nil;
        _value = size;
        return *this;
    }
    RALScaling& free() {
        _scaling = FREE;
        _related = nil;
        _value = 0;
        return *this;
    }
    RALScaling& nosize() {
        _scaling = NOSIZE;
        _related = nil;
        _value = 0;
        return *this;
    }
    RALScaling& relative(UIView* related=nil, CGFloat  size=1.0) {
        _scaling = RELATIVE;
        _related = related;
        _value = size;
        return *this;
    }
};

/**
 * ビューを配置するために必要十分なパラメータをセットして、RALBuilderに渡す。
 */
class RALParams {
private:
    UIView* _target;

    class Attach {
    private:
        RALParams& _owner;
        RALAttach& _ref;
    public:
        Attach(RALParams& owner, RALAttach& ref)
        : _owner(owner)
        , _ref(ref) {}

        Attach(const Attach& src)
        : _owner(src._owner)
        , _ref(src._ref) {}
        
        RALParams& free() {
            _ref.free();
            return _owner;
        }
        
        /**
         * 上下左右を揃える
         * sibling(兄弟View)の対応する辺からの距離で指定
         */
        RALParams& fit(UIView* sibling, CGFloat distance=0) {
            _ref.fit(sibling, distance);
            return _owner;
        }
        
        /**
         * 親にアタッチ：fit(nil) と同義
         */
        RALParams& parent(CGFloat distance=0) {
            _ref.parent(distance);
            return _owner;
        }
        /**
         * 上下左右に並べる
         * sibling(兄弟View)の向かい合う辺からの距離で指定
         */
        RALParams& adjacent(UIView* sibling, CGFloat distance=0) {
            _ref.adjacent(sibling, distance);
            return _owner;
        }
        
        /**
         * 中央寄せ
         * @param   sibling     基準ビュー（nilなら親を基準にする）
         */
        RALParams& center(UIView* sibling) {
            _ref.center(sibling);
            return _owner;
        }
    };
    
    class Scaling {
    private:
        RALParams& _owner;
        RALScaling& _ref;
    public:
        Scaling(RALParams& owner, RALScaling& ref)
        : _owner(owner)
        , _ref(ref) {}
        
        Scaling(const Scaling& src)
        : _owner(src._owner)
        , _ref(src._ref) {}
        
        RALParams& fixed(CGFloat size) {
            _ref.fixed(size);
            return _owner;
        }
        RALParams& free() {
            _ref.free();
            return _owner;
        }
        RALParams& nosize() {
            _ref.nosize();
            return _owner;
        }
        RALParams& relative(UIView* related=nil, CGFloat  size=1.0) {
            _ref.relative(related, size);
            return _owner;
        }
    };
    
public:
    RALAttach _left;
    RALAttach _top;
    RALAttach _right;
    RALAttach _bottom;
    RALScaling _horz;
    RALScaling _vert;
    
    RALParams() {}
    
    RALParams(const RALParams& src)
    :_left(src._left)
    ,_top(src._top)
    ,_right(src._right)
    ,_bottom(src._bottom)
    ,_horz(src._horz)
    ,_vert(src._vert) {}

    Attach
    left() {
        return Attach(*this, _left);
    }
    RALParams&
    left(const RALAttach& attach) {
        _left = attach;
        return *this;
    }
    
    Attach
    top() {
        return Attach(*this, _top);
    }
    RALParams&
    top(const RALAttach& attach) {
        _top = attach;
        return *this;
    }
   
    Attach
    right() {
        return Attach(*this, _right);
    }
    RALParams&
    right(const RALAttach& attach) {
        _right = attach;
        return *this;
    }

    Attach
    bottom() {
        return Attach(*this, _bottom);
    }
    RALParams&
    bottom(const RALAttach& attach) {
        _bottom = attach;
        return *this;
    }
    
    Scaling
    horz() {
        return Scaling(*this, _horz);
    }
    RALParams&
    horz(const RALScaling& scale) {
        _horz = scale;
        return *this;
    }

    Scaling
    vert() {
        return Scaling(*this, _vert);
    }
    RALParams&
    vert(const RALScaling& scale) {
        _vert = scale;
        return *this;
    }

    RALParams&
    top_left(const RALAttach& attach) {
        _top = attach;
        _left = attach;
        return *this;
    }
    RALParams&
    top_right(const RALAttach& attach) {
        _top = attach;
        _right = attach;
        return *this;
    }
    RALParams&
    bottom_left(const RALAttach& attach) {
        _bottom = attach;
        _left = attach;
        return *this;
    }
    RALParams&
    bottom_right(const RALAttach& attach) {
        _bottom = attach;
        _right = attach;
        return *this;
    }
    
    RALParams&
    attach(const RALAttach& attach) {
        return top_left(attach).bottom_right(attach);
    }
    
    RALParams&
    scaling(const RALScaling& scale) {
        _horz = scale;
        _vert = scale;
        return *this;
    }

//    const RALAttach* getCenterAttach(bool vert) const {
//        if(vert) {
//            if(_top._attach == RALAttach::CENTER) {
//                return &_top;
//            } else if(_bottom._attach == RALAttach::CENTER) {
//                return &_bottom;
//            }
//        } else {
//            if(_left._attach == RALAttach::CENTER) {
//                return &_left;
//            } else if(_right._attach == RALAttach::CENTER) {
//                return &_right;
//            }
//        }
//        return NULL;
//    }
};

/**
 * NSLayoutConstraint を使った　AutoLayout の指定を かなり便利にするクラス。
 * MICRelativeLayout と同程度の配置を　AutoLayoutを使って実現。
 * さらに、C++ の呼び出しを利用するので、MICRelativeLayoutよりもかなり簡潔に記述できる。
 */
class RALBuilder : public MICAutoLayoutBuilder {
private:
    bool _autoAddSubview;
    bool _autoCorrect;
public:
    /**
     * @param   parentView  親ビュー
     * @param   autoActivate    true:デストラクタが呼ばれた時にアクティベートする。
     * @param   autoAddSubview  addView()のタイミングでparentViewに対してaddSubviewする。
     */
    RALBuilder(UIView* parentView, bool autoActivate=true, bool autoAddSubview=true, bool autoCorrect=true)
    : MICAutoLayoutBuilder(parentView,autoActivate)
    , _autoAddSubview(autoAddSubview)
    , _autoCorrect(autoCorrect)
    {}

    /**
     * ビューを配置する
     * @param   view    配置するビュー
     * @param   params  レイアウト情報
     */
    RALBuilder& addView(UIView* view, RALParams& params);
    
    /**
     * ビューのセーフエリアに合わせて配置する
     * @param target        対象ビュー
     * @param pos           targetのどの辺に制約をつけるかを指定するビットフラグ（MICUiPosExLEFT|TOP|RIGHT|BOTTOM）を指定
     * @param margin        セーフエリアからのマージン（posで指定されていない部分のマージンは無視される）
     */
    RALBuilder&
    fitToSafeArea(UIView* target, MICUiPosEx pos = MICUiPosExALL, const UIEdgeInsets& margin=MICEdgeInsets(), int relativity=0) {
        if(_autoAddSubview) {
            [_parentView addSubview:target];
        }
        MICAutoLayoutBuilder::fitToSafeArea(target, pos, margin, relativity);
        return *this;
    }

private:
    void attachToRelated(UIView* target, UIView* related, MICUiPos pos, bool adjacent, CGFloat distance);
    void attachCenter(UIView* view, UIView*related, bool vert);
    void attachToRelated(UIView* view, const RALAttach& attach, MICUiPos pos);
    void scaleFor(UIView* view, const RALScaling& scaling, bool vert);
};

#endif

