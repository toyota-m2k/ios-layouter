# Layouter解説

2015.04.28 M.TOYOTA

----

##### クラス名、プロトコル名の表記について
    
Layouter用に開発した、クラス/プロトコル名には、MICUi というプレフィックスがつくが、読みにくくなるので、これらはすべて省略して表記する。
   
これに対して、iOSの標準ライブラリに含まれるクラス名などは、UIView, UIScrollViewのように、フルネームで表記する。

## 概要

### Layouter の種類

1. StackLayout
    
    子ビューを横、または、縦方向に一列に並べて配置する。
    （WindowsのStackPanel, AndroidのLinearLayoutのイメージ）

2. GridLayout
    
    子ビューを格子状に配置する。
    あらかじめ、GridLayoutに対して、格子サイズ（ユニットサイズ）を定義しておき、
    子ビューのサイズは、このユニットサイズで指定する。これにより、子ビューをWindowsのスタート画面のタイルのように、
    格子のアラインメントにそろえて配置する。
    
3. RelativeLayout
    
    親ビューのBoundsや、兄弟ビューのFrameに対する相対位置、相対サイズによって子ビューを配置する。

### LayouterとLayoutView

Layouter (LayoutProtocol）および、その派生クラス(StackLayout/GridLayout/RelativeLayout)は、
すべてビューは持たず、ロジックだけを定義・実装しており、任意のビューに組み込んで使用することを想定している。

これに対して、LayoutView（StackView, GridView)は、あらかじめ、
それぞれ対応するLayouterとD&Dサポート（後述）を組み込んだUIScrollView派生クラスである。

実装ファイルの中をご覧いただくとわかる通り、ほとんどの実装は、LayouterとD&Dサポーターが持っていて、LayoutViewの実装はごくわずかである。
従って、これらの実装をそのまま使ってもよいが、他のビュークラスに組み込む際のサンプル程度に使ってもらってもよい。
特に、RelativeLayoutに関しては、そのメリットが見いだせなかったため、対応するRelativeViewは実装すらしていない。
    
### AccordionCellViewとAccordionView

AccordionCellViewは、LabelViewと、BodyViewから構成され、折り畳み(fold)と展開(unfold)の状態を持つUIView派生クラスである。
そのLabelViewには、任意のUIViewを、また、BodyViewには、UIViewまたは、他のレイアウターを配置することができる。

AccordionViewはStackView派生クラスであり、AccordionCellViewを縦、または、横に並べて配置し、
AccordionCellViewの折り畳み/展開に合わせて、他のAccordionCellViewを再配置する動作が実装されている。

尚、AccordionCellViewは、AccordionViewの内部に配置するために実装されたビュークラスだが、開閉動作を持つビューとして、単独で使用することも可能である。

### TabBarView

TabBarViewは、任意のビュー（通常はタブボタン）を並べるビュークラス。
バーのサイズに応じて、タブのスクロールなどの動作が追加されている。

### designed ビュークラス

サイズ、配色、アイコンなど、デザイン的要素を持つビューは、すべてdesigned ディレクトリ内にまとめている。
（逆に、このディレクトリ以外のクラスは、デザイン要素を持たず、デザインが変更されても、ソースコードを変更する必要はないように配慮している。）
    
- DsCustomButton
    
    背景(eraseBackground), コンテント描画(drawContent)のカスタマイズ（オーバーライド）が可能なボタンの基底クラス。
    アイコン、テキストの位置（contentRect)だけを調整することも可能。

- DsTabButton

    タブ型（右上に切り欠き）のボタン

- DsTabView

    タブ耳（TabBarView)をラベル領域に持つ、AccordionCellView派生クラス。
    AccordionCellView派生なので、タブ耳上の開閉ボタンタップにより、コンテント領域の折り畳み/展開が可能。
 
- StatefulResource

    ボタンの通常/押下/選択/無効などの状態によって、異なる配色やアイコンを指定するためのクラス。
    DsCustomButtonおよび、その派生クラスのリソースは、すべてこの形式で指定する。
    状態による変更が不要の場合は、StatefulResource派生クラスである、UnstatefulResource（１種類のリソースセットだけを保持）や、
    MonoResource（１つのリソースだけを保持）が利用できる。

### D&Dサポート
    
すべてのLayouter（StackLayout/GridLayout/RelativeLayout）は、DraggableLayoutProtocolを実装し、D&Dサポーターを使用することにより、
D&D動作をサポート可能である。

D&Dサポーターには、次の２種類が用意されている。

- CellDragSupport
    １つのコンテナビュー内でのD&Dをサポート
    
- CellDragSupporEx
    複数の（ネストする）コンテナビューにまたがるD&Dをサポート

特に、コンテナビューとして、UIScrollViewを使用した場合は、ドラッグ中の自動スクロールにも対応可能であり、
StackView, GridView は、デフォルトで、CellDragSupportによるアイテムのD&Dが可能である。

また、AccordionViewでは、CellDragSupporEx を使用し、異なるAccordionCellView間でのアイテムのD&Dと、AccordionCellView自体のD&Dが可能である。

尚、コンテナビューとして、UIScrollView以外を使用する場合、または、UIScrollView派生クラスでも、
スクロールの方法をメタモジックにカスタマイズしているような場合には、独自のD&Dサポーターを実装する必要があるかもしれない。
    
### RelativeLayout 上でのD&Dについて

現状の実装（暫定）では、ドロップされたアイテムは、オリジナルの配置指定を破棄して、
必ず、親ビューのBoundsの左上隅を基準とする相対位置で配置される。

当初の構想としては、親のフレームにアタッチするとか、他の兄弟ビューをよけるとか、いろいろなルールを作ろうと考えていたが、
時間切れで、そこまでは実装できていない。

### SwitchingViewMediator

２つ以上のビューの表示・非表示切り替えに関して、次の３つのルールを定義して登録しておくことにより、
ユーザによるビューの表示切り替え動作による画面の状態遷移を自動化できる。

- ペインAが開いた時は、ペインBを閉じる（排他）
- ペインAを閉じたら、ペインBを開く（反転）
- ペインAが開いたら、ペインBも開く（同調）

表示・非表示切り替えのデフォルトの動作は、UIViewのhidden属性に対する操作であるが、
ViewVisibilityDelegate を実装することにより、例えば、AccordionCellViewの折り畳み動作などに割り当てることができる。
    
    
    
----
    
## 使い方

### ■StackLayout, StackView

StackViewインスタンスを生成

    MICUiStackView* _stackView = [[MICUiStackView alloc] initWithFrame:MICRect(0,0, 300, 300)];
    _stackView.backgroundColor = [UIColor blackColor];      // これがないと、スクロールビューがタップイベントを受け取らないようだ。

D&Dを有効化し、アイテムの長押しで、D&Dを開始するように指定

    [_stackView enableScrollSupport:true];
    [_stackView beginCustomizingWithLongPress:true endWithTap:true];

StackLayout レイアウターを取得して、オプションを設定
   
    MICUiStackLayout* stackLayout = _stackView.stackLayout;
    stackLayout.orientation = MICUiVertical;                // 縦に並べる
    stackLayout.fixedSideSize = 350;                        // 横幅
    stackLayout.margin = MICEdgeInsets(10,5,10,5);          // マージン
    stackLayout.cellSpacing = 20;                           // アイテム間の間隔

StackViewにアイテム（子ビュー）を追加

    UIView* childView = ...;
    [_stackView addChild:childView updateLayout:false withAnimation:false];

StackViewを親ビューに追加
    
    [parentView addSubview:_stackView];

このように、stackViewを親ビューにaddSubviewしたタイミングで、StackViewの子ビュー（アイテム）の再配置が実行されるが、
そのあとに、アイテムの追加、削除などの変更を行った場合は、明示的に再配置を行うよう要求する必要がある。
（つまり、上記の順序で初期化した場合は不要）

    [_stackView updateLayout:false];        // 配置動作でアニメーションを行うなら、trueを渡す。


### ■GridLayout, GridView

StackViewインスタンスを生成

    _gridView = [[MICUiGridView alloc] initWithFrame:MICRect(0,0, 300, 300)];
    _gridView.backgroundColor = [UIColor blackColor];

D&Dを有効化し、アイテムの長押しで、D&Dを開始するように指定
    
    [_gridView enableScrollSupport:true];
    [_gridView beginCustomizingWithLongPress:true endWithTap:true];
    
GridLayout レイアウターを取得して、オプションを設定

    MICUiGridLayout* gridLayout = _gridView.gridLayout;
    gridLayout.growingOrientation = MICUiVertical;              // 伸長方向を指定（縦方向に伸び、横方向のセル数を固定）
    gridLayout.fixedSideCount = 4;                              // 固定方向のセル数
    gridLayout.margin = MICEdgeInsets(10,5,10,5);               // マージン
    gridLayout.cellSize = CGSizeMake(50,50);                    // セルサイズ（＝ユニットサイズ）
    gridLayout.cellSpacingVert = 5;                             // 縦方向のセル間隔
    gridLayout.cellSpacingHorz = 5;                             // 横方向のセル間隔

GridViewにアイテム（子ビュー）を追加。このとき、セルのサイズをユニット数で指定する。

    UIView* childView1 = ...;
    [_gridView addChild:childView1 unitX:1 unitY:1];             // 1x1 のセル

    UIView* childView2 = ...;
    [_gridView addChild:childView2 unitX:2 unitY:1];             // 2x1 のセル

    UIView* childView3 = ...;
    [_gridView addChild:childView3 unitX:4 unitY:4];             // 4x4 のセル

GridViewを親ビューに追加

    [parentView addSubview:_gridView];

このように、gridViewを親ビューにaddSubviewしたタイミングで、GridViewの子ビュー（アイテム）の再配置が実行されるが、
そのあとに、アイテムの追加、削除などの変更を行った場合は、明示的に再配置を行うよう要求する必要がある。
（つまり、上記の順序で初期化した場合は不要）

    [_gridView updateLayout:false];        // 配置動作でアニメーションを行うなら、trueを渡す。

### ■AccordionCellView

AccordionCellViewインスタンスを作成

    MICUiAccordionCellView* ac = [[MICUiAccordionCellView alloc] initWithFrame:MICRect(0,0,250,250)];
    ac.backgroundColor = [UIColor blueColor];

AccordionCellViewのオプションを設定

    ac.labelAlignment = MICUiAlignExFILL;               // ラベルビューを領域いっぱいに拡大/縮小
    ac.labelMargin = MICEdgeInsets(5);                  // ラベル領域の周囲に5pxのマージンを確保
    ac.orientation = MICUiVertical;                     // 開閉の方向：縦
    ac.labelPos = MICUiPosTOP|MICUiPosLEFT;             // ラベルは、セルの上（縦開閉の場合）または左（横開閉の場合）に配置
    ac.movableLabel = true;                             // 開閉動作で、ラベルが移動する
    ac.bodyMargin = MICEdgeInsets(5,0,5,5);             // ボディ（コンテント）領域のマージン


ラベルビューを設定

    UIView* labelView = ...
    ac.labelView = labelView;

ボディビューを設定。

    UIView* bodyView = ...      // 通常はGridViewや、StackViewなどのインスタンス
    ac.bodyView = bodyView;

また、セル内でのスクロールなどの必要がなければ、ボディビューの代わりに、GridLayoutや、StackLayoutなどのレイアウターを指定することもできる。

    MICUiGridLayout* gridLayout = ...;
    [ac setBodyLayouter: gridLayout];
    gridLayout.parentView = ac;                 // gridLayoutにaddChildしたとき、acにもaddSubviewする。

AccordionCellViewを親ビューに追加する（AccordionViewの子ビューとする場合は、次項を参照）

    [parentView addSubview:ac];

StackView/GridViewと同様、、親ビューにaddSubviewしたタイミングで再配置が実行されるが、
そのあとに、アイテムの追加、削除などの変更を行った場合は、明示的に再配置を行うよう要求する必要がある。
（つまり、上記の順序で初期化した場合は不要）

    [ac updateLayout:false];        // 配置動作でアニメーションを行うなら、trueを渡す。


### ■AccordionView

AccordionViewインスタンスを作成

    MICUiAccordionView* accordion = [[MICUiAccordionView alloc] init];
    accordion.backgroundColor = [UIColor blueColor];

D&Dを有効化し、アイテムの長押しで、D&Dを開始するように指定。
これにより、アコーディオンセルとアコーディオンセル内のアイテムの両方がドラッグ可能になる。

    [accordion enableScrollSupport:true];
    [accordion beginCustomizingWithLongPress:true endWithTap:true];

必要なら、AccordionViewのレイアウターを取得して、オプションを指定

    MICUiStackLayout* stackLayout = accordion.stackLayout;
    stackLayout.orientation = MICUiHorizontal;              // 横に並べる

AccordionCellViewを作成して、AccordionViewに追加

    MICUiAccordionCellView* ac = ...                        // 初期化手順は、前項参照
    ac.frame = MICRect([ac calcMinSizeOfContents]);         // セルの初期サイズをコンテンツのサイズに合わせる
    [accordion addChild:ac];

AccordionViewの位置、サイズを決めて親ビューに追加

    CGSize contentSize = [accordion.layouter getSize];          // レイアウターからコンテントのサイズを取得
    accordion.frame = MICRect(MICSize(contentSize.width, 400)); // AccordionViewの位置
    accordion.contentSize = contentSize;                        // スクロール領域のサイズ（accordion.contentSizeは、UIScrollViewのプロパティ）
    [parentView addSubview:accordion]; 

必要なら、再配置を要求

        [accordion updateLayout:false];

### ■RelativeLayout

RelativeLayoutオブジェクトを作成する。

    _layout = [[MICUiRelativeLayout alloc] init];
    
必要に応じて、オプションを設定

    _layout.overallSize = parentView.frame.size;            // 必須：RelativeLayout
    _layout.margin = MICEdgeInsets(10, 100, 0, 0);          // 親ビューに対する管理領域のマージン

レイアウターの親ビューを設定する。この処理は必須ではないが、これをやっておくことで、_layoutにaddChildと同時に、parentViewへのaddSubviewされるようになる。

    _layout.parentView = parentView;                        // 親ビュー

配置ルール（MICUiRelativeLayoutInfo）を指定して、レイアウターに子ビューを追加する。

    [_layout addChild:label1
              andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingFree]
                                                               left:[MICUiRelativeLayoutAttachInfo newAttachParent:15]
                                                              right:[MICUiRelativeLayoutAttachInfo newAttachParent:15]
                                                               vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                top:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                             bottom:[MICUiRelativeLayoutAttachInfo newAttachFree]]];

配置ルール（MICUiRelativeLayoutInfo）は、上下左右の位置決定方法（MICUiRelativeLayoutAttachInfo）とサイズ決定方法（MICUiRelativeLayoutScalingInfo）を指定するデータクラスであり、
以下のような指定ができる。

##### 位置決定方法の指定

- AttachPARENT

    RelativeLayoutの管理領域（親ビューのBoundsに、RelativeLayoutのマージンを加味した領域）と配置されるアイテムの対応する辺の間隔を指定する。
    例えば、bottomに、この属性を使用する場合は、管理領域のbottomとアイテムのbottomとの間隔を指定する。

- AttachADJACENT

    基準とする兄弟アイテムと、配置されるアイテムの向かい合う辺の間隔を指定する。
    例えば、View-A を基準アイテムとし、View-B の right について、この属性を使用する場合は、View-A の left と View-Bの right の間隔を指定する。
    複数のビューを一定間隔で並べるようなレイアウトに使用する。
    
- AttachFITTO

    基準とする兄弟アイテムと、配置されるアイテムの対応する辺との間隔を指定する。
    例えば、View-A を基準アイテムとし、View-B の right について、この属性を使用する場合は、View-A の right と View-Bの right の間隔を指定する。
    複数のビューの端をそろえるようなレイアウトに使用する。
    
- AttachCENTEROF
    
    基準とする兄弟アイテムに対して、中央ぞろえで配置する。基準とするアイテムがnilなら、 RelativeLayoutの管理領域の中央に配置する。
    leftにこの属性を指定した場合には、rightにも同じ属性を指定する。top/bottomも同様。
    
- AttachFREE

    位置が他のルールで決まるため、明示的に指定しない場合に使用。
    例えば、left を AttachPARENTで指定し、幅を ScaleFIXED（固定サイズ）で指定すると、rightの位置は自動的に決まるため、AttachFREEを指定する。
    
##### サイズ定方法の指定

- ScaleFIXED

    サイズを数値（ピクセル数）で指定する。
    指定されたアイテム（ビュー）のサイズを、このサイズに変更する。
    
- ScaleNOSIZE

    Viewがもともと持っていたサイズを変更しない。

- ScaleRELATIVE

    基準とする兄弟アイテムのサイズに対する比率(0～1)でサイズを指定する。
    基準とする兄弟アイテムがnilの場合は、 RelativeLayoutの管理領域に対する比率となる。

- ScaleFREE

    サイズが他のルールで決まるため、明示的に指定しない場合に使用。
    例えば、leftとrightをAttachParentで指定すると、widthは自動的に決まるため、ScaleFREEを指定する。
    
##### 具体例

横方向：親枠からの距離(左右１５ｐｘ）サイズ自由　/　縦方向：親枠上端にアタッチ、サイズ不変

    [_layout addChild:item1
        andInfo:[[MICUiRelativeLayoutInfo alloc] 
            initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingFree]        // 幅は可変
            left:[MICUiRelativeLayoutAttachInfo newAttachParent:15]             // 左は親枠の左端からの距離で15pxに設定
            right:[MICUiRelativeLayoutAttachInfo newAttachParent:15]            // 右は親枠の右端からの距離で15pxに設定
            vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]              // 高さは元のサイズから変更しない。
            top:[MICUiRelativeLayoutAttachInfo newAttachParent:0]               // 上は親枠の上端に未着
            bottom:[MICUiRelativeLayoutAttachInfo newAttachFree]]];             // 下は成行き


横方向：親の30%幅でセンタリング　/ 縦方向：兄弟(item1)の下に配置、高さ不変
  
    [_layout addChild:item2
        andInfo:[[MICUiRelativeLayoutInfo alloc] 
            initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingRelative:0.3]    // 幅は親の30%
            left:[MICUiRelativeLayoutAttachInfo newAttachCenter]                    // 左右位置はセンタリング
            right:[MICUiRelativeLayoutAttachInfo newAttachCenter]                   // 同上
            vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]                  // 高さは不変
            top:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:label1 inDistance:5]   // label1の下に、5pxあけて配置
            bottom:[MICUiRelativeLayoutAttachInfo newAttachFree]]];                 // 下は成行き

横方向：item1の50%幅でitem2の左側に配置 / 縦方向：item2と下ぞろえ、高さ不変

    [_layout addChild:item3
        andInfo:[[MICUiRelativeLayoutInfo alloc] 
            initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingRelativeToView:item1 inRatio:0.5]    // 幅は item1の50%
            left:[MICUiRelativeLayoutAttachInfo newAttachFree]                                          // 左は成行き
            right:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:item2 inDistance:5]                 // 右は item2の左辺から5pxの位置
            vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]                                      // 高さは不変
            top:[MICUiRelativeLayoutAttachInfo newAttachFree]                                           // 上は成行き
            bottom:[MICUiRelativeLayoutAttachInfo newAttachFitTo:item2 inDistance:0]]];                // label2と下揃え

### ■DsTabView

TabViewインスタンスを生成

    MICUiDsTabView* _tab = [[MICUiDsTabView alloc] initWithFrame:rcTab];

オプションを設定

    _tab.labelAlignment = MICUiAlignExFILL;
    _tab.orientation = MICUiVertical;
    _tab.labelPos = MICUiPosTOP|MICUiPosLEFT;
    _tab.movableLabel = false;
    _tab.attachBottom = false;
    _tab.tabHeight = 20;
    _tab.tabWidth = 0;
    _tab.contentMargin = MICEdgeInsets(10,0,10,0);
    _tab.backgroundColor = MICCOLOR_PANEL_FACE;     

タブボタンを追加
    
    NSString *tabname = ...    // タブの名前
    [_tab addTab:tabname label:tabname color:nil icon:nil updateView:false];

TabViewを親ビューに追加

    [parentView addSubview:_tab];