# NSLayoutConstraint を使いやすくする

NSLayoutConstraintをプログラムから操作するのは、かなり面倒だし、一度書いたものを読み解くのも一苦労です。そこで、MICAutoLayoutBuilderや、RALBuilder (どちらもC++クラス)を使うと、かなり簡潔にレイアウトを定義できます。

## __MICAutoLayoutBuilder__

ビルダー形式のAPIでNSLayoutConstraint の配列を構築し、activateする動作を提供します。

### ■コンストラクタ

```
MICAutoLayoutBuilder(
    UIView* parentView, 
    bool autoActivate=true)
```


|パラメータ|説明|
|:--|:--|
|parentView|親ビュー（このビューにサブビューを配置し、NSLayoutConstraintでレイアウトする）|
|autoActivate|（ビルダーのデストラクタで）NSLayoutConstraintをactivateする。|
    

### ■親ビューのセーフエリアに合わせて配置する

```
MICAutoLayoutBuilder&
fitToSafeArea(
    UIView* target, 
    MICUiPosEx pos = MICUiPosExALL, 
    const UIEdgeInsets& margin=MICEdgeInsets(), 
    int relativity=0
)
```

|パラメータ|説明|
|:--|:--|
|target|対象ビュー|
|pos|targetのどの辺に制約をつけるかを指定するビットフラグ<br> MICUiPosExLEFT\|TOP\|RIGHT\|BOTTOM を指定
|margin|セーフエリアからのマージン<br>posで指定されていない部分のマージンは無視される|
|relativity|=0  NSLayoutAnchor#constraintEqualToAnchor<br>>0 NSLayoutAnchor#constraintGreaterThanOrEqualToAnchor<br><0 NSLayoutAnchor#constraintLessThanOrEqualToAnchor<br>|



### ■親ビューに対する相対位置を指定

```
MICAutoLayoutBuilder&
fitToParent(
    UIView* target, 
    MICUiPosEx pos = MICUiPosExALL, 
    const UIEdgeInsets& margin=MICEdgeInsets())
```

|パラメータ|説明|
|:--|:--|
|target|対象ビュー|
|pos|targetのどの辺に制約をつけるかを指定するビットフラグ<br> MICUiPosExLEFT\|TOP\|RIGHT\|BOTTOM を指定
|margin|親ビューのからのマージン<br>posで指定されていない部分のマージンは無視される|

### ■縦方向に兄弟ビューを並べる

```
MICAutoLayoutBuilder& 
fitVerticallyToSibling(
    UIView* target, 
    UIView* sibling, 
    bool below, 
    CGFloat spacing, 
    MICUiAlignEx alignToSibling);
```

|パラメータ|説明|
|:--|:--|
|target|対象ビュー|
|sibling|基準とする兄弟ビュー|
|below|true: siblingの下に配置<br>false: siblingの上に配置
|spacing|siblingとtargetとの間隔(px)
|alignToSibling| MICUiAlignExTOP: 左揃え<br>MICUiAlignExBOTTOM: 右揃え<br>MICUiAlignExCENTER:中央揃え<br>MICUiAlignExFILL:幅（左右）を揃える

### ■横方向に兄弟ビューを並べる

```
MICAutoLayoutBuilder& 
fitHorizontallyToSibling(
    UIView* target, 
    UIView* sibling, 
    bool right, 
    CGFloat spacing, 
    MICUiAlignEx alignToSibling);
```

|パラメータ|説明|
|:--|:--|
|target|対象ビュー|
|sibling|基準とする兄弟ビュー|
|right|true: siblingの右に配置<br>false: siblingの左に配置
|spacing|siblingとtargetとの間隔(px)
|alignToSibling| MICUiAlignExTOP: 上揃え<br>MICUiAlignExBOTTOM: 下揃え<br>MICUiAlignExCENTER:中央揃え<br>MICUiAlignExFILL:高さ（上下）を揃える

### ■兄弟ビューの下に配置

```
MICAutoLayoutBuilder& 
putBelow(
    UIView* target, 
    UIView* sibling, 
    CGFloat spacing, 
    MICUiAlignEx alignToSibling);
```

fitVerticallyToSibling(target, sibling, true, spacing, alignToSibling)　と等価。

### ■兄弟ビューの上に配置

```
MICAutoLayoutBuilder& 
putAbove(
    UIView* target, 
    UIView* sibling, 
    CGFloat spacing, 
    MICUiAlignEx alignToSibling);
```

fitVerticallyToSibling(target, sibling, false, spacing, alignToSibling)　と等価。

### ■兄弟ビューの右に配置

```
MICAutoLayoutBuilder& 
putRight(
    UIView* target, 
    UIView* sibling, 
    CGFloat spacing, 
    MICUiAlignEx alignToSibling);
```

fitHorizontallyToSibling(target, sibling, true, spacing, alignToSibling)　と等価。

### ■兄弟ビューの左に配置

```
MICAutoLayoutBuilder& 
putLeft(
    UIView* target, 
    UIView* sibling, 
    CGFloat spacing, 
    MICUiAlignEx alignToSibling);
```

fitHorizontallyToSibling(target, sibling, false, spacing, alignToSibling)　と等価。

### ■レイアウトのアクティブ化

[NSLayoutConstraint activeConstraints:] を呼び出して、作成したレイアウトをアクティブ化する。コンストラクタで、autoActivate=falseにしていない場合は、デストラクタで自動的にアクティブ化されるので、これを明示的に呼ぶ必要はない。

```
NSMutableArray<NSLayoutConstraint *>* activate(bool createNew=false) {
```
|パラメータ|説明|
|:--|:--|
|createNew|true:続けて別の制約リストを作成<br>false:これで終了|

## __RALBuilder__

MICAutoLayoutBuilder よりも複雑な相対レイアウトを行う。レイアウトの機能性は、[MICRelativeLayout](original-layouter.md) とほぼ同じ。

### ■コンストラクタ

```
RALBuilder(
    UIView* parentView, 
    bool autoActivate=true, 
    bool autoAddSubview=true, 
    bool autoCorrect=true)
```

|パラメータ|説明|
|:--|:--|
|parentView|親ビュー（このビューにサブビューを配置し、NSLayoutConstraintでレイアウトする）|
|autoActivate|true:（ビルダーのデストラクタで）NSLayoutConstraintをactivateする。|
|autoAddSubview|true:addView()のタイミングでparentViewに対してaddSubviewする。|
|autoCorrect|レイアウト情報に矛盾・不備があった場合、<br>true:できるだけ補正<br>false:そのまま実行|

### ■レイアウト情報(RALParam)とともにビューを追加する

```
RALBuilder& 
addView(
    UIView* view, 
    RALParams& params)
```

|パラメータ|説明|
|:--|:--|
|view|追加するサブビュー|
|params|レイアウト情報|

### ■レイアウト情報　(RALParam)

RALBuilderに addViewするとき、View毎に、RALParam オブジェクトを渡すことで、レイアウトが構成される。
RALParamは、Viewの上(top)下(bottom)左(left)右(right)を何に合せるか（RALAttach）、および、Viewサイズ(horz/vert)を何に合せるか（RALScaling）、を保持したC++クラスである。

例えば、Viewの左上を親ビューにぴったり合せ、サイズは変更しない（ビューの元のサイズのまま貼り付ける）場合は、
```
RALParam().left().parent(0)     // 左を親にピッタリ合せる
          .top().parent(0)      // 上を親にピッタリ合せる
          .right().free()       // 右は指定しない（left+horzで決まる）
          .bottom().free()      // 下は指定しない(top+vertで決まる)
          .horz().nosize()      // 元のサイズのまま変更しない
          .vert().nosize()      // 元のサイズのまま変更しない
```
のように指定する。このとき、RALAttachは、デフォルトでfree, RALScalingは、デフォルトでnosize なので、これらの指定は省略可能で、以下のように書くことができる。
```
RALParam().left().parent(0)     // 左を親にピッタリ合せる
          .top().parent(0)      // 上を親にピッタリ合せる
```

#### RALAttach

Attach(RALParam#left/top/right/bottom) には、次の指定が可能。

- Attach.free()   

    無指定の場合のデフォルト。
    反対側の辺の位置とサイズによって、この辺の位置は自動的に決まる。

- Attach.parent(CGFloat distance=0)

    親ビューの対応する辺との距離（マージン）で指定。

- Attach.adjacent(UIView* sibling, CGFloat distance=0)

    兄弟ビュー(sibling)の対応する辺からの距離で指定。

- Attach.fit(UIView* sibling, CGFloat distance=0)

    兄弟ビュー(sibling)の向かい合う辺からの距離で指定。

- Attach.center(UIView* sibling)

    兄弟ビューに対してセンタリングする。siblingにnilを渡すと、親ビューに対してセンタリングする。

#### RALScaling

Scaling(RALParam#horz/vert) には、次の指定が可能。

- Scaling.nosize()

    無指定の場合のデフォルト。
    レイアウターは、サブビューのサイズを元のまま変更しない。

- Scaling.free()

    両側の辺の位置によって、サイズは自動的に決まる。

- Scaling.fixed(CGFloat size)

    明示的にサイズを指定。

- Scaling.relative(UIView* related=null, CGFloat size=1.0)

    兄弟ビュー(related)に対する比率(size)で指定する。
    related==nil の場合は、親ビューに対する相対サイズとなる。

