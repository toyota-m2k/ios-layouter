# WPLライブラリ リファレンス

このライブラリは、レイアウト対象の基本要素であるセル（≒ビューのラッパー）と、それを配置するコンテナー、および、監視可能なデータオブジェクトであるオブザーバブルと、セルとオブザーバブルを関連付けるバインディングの各クラスから構成される。

---

## セル

UIView インスタンスを「セル」という単位にラップして扱うことで、UIView毎の身勝手な振る舞いを隠蔽し、統一された方法で、再配置やデータバインディングを実現する。

<details><summary>
IWPLCell プロトコル
</summary>

セルの基本プロトコル。
レイアウト関連の基本プロパティ、メソッド（サイズやアラインメントなど）と、バインディング可能な、visibility, enabledプロパティを定義。

### プロパティ

    @property(nonatomic) NSString* name;                      // 名前（任意）
    @property(nonatomic,readonly) UIView* view;               // セルに配置するビュー
    @property(nonatomic) UIEdgeInsets margin;                 // マージン
    @property(nonatomic) WPLCellAlignment hAlignment;         // 横方向配置指示
    @property(nonatomic) WPLCellAlignment vAlignment;         // 縦方向配置指示
    @property(nonatomic, readonly) CGSize actualViewSize;     // view.frame.size と同じ
    @property(nonatomic) CGSize requestViewSize;              // 要求サイズ
    @property(nonatomic) WPLVisibility visibility;            // 表示・非表示
    @property(nonatomic) bool enabled;                        // 有効/無効

### セルオブジェクトの解放

リスナーや参照関係を確実にクリアするため、不要になったセルオブジェクトは dispose を呼び出して破棄することが望ましい。コンテナーセルのdisposeを呼び出すと、その管理下にあるすべてのセルがdisposeされる。

    - (void) dispose;

</details>

<details><summary>
IWPLCellSupportValue プロトコル
</summary>

value属性と、ビューへの入力を監視するリスナー（バインディングクラスが利用）を定義する。

### プロパティ

IWPLCell プロトコル のプロパティに加えて、以下を定義。

    @property(nonatomic) id value;

### ビューの入力（値の変更）監視用イベントリスナー

    // リスナー登録
    - (id) addInputChangedListener:(id)target selector:(SEL)selector;

    // リスナーの登録を解除
    - (void) removeInputListener:(id)key;


</details>

<details><summary>
IWPLCellSuportReadonly プロトコル
</summary>

readonly属性をサポートするビューをホストするセルを定義する。

### プロパティ

    @property(nonatomic) bool readonly;

</details>


<details><summary>
WPLCell クラス
</summary>

ReadOnly や Value を持たないビュー(UIView,UIButtonなど)を１つ内包することが可能なセルクラス。

### WPLCellの作成

    + (instancetype) newCellWithView:(UIView*)view
                                name:(NSString*) name
                              margin:(UIEdgeInsets) margin
                     requestViewSize:(CGSize) requestViewSize
                          hAlignment:(WPLCellAlignment)hAlignment
                          vAlignment:(WPLCellAlignment)vAlignment
                          visibility:(WPLVisibility)visibility;

    // C++版
    + (instancetype) newCellWithView:(UIView*) view
                                name:(NSString*) name
                              params:(const WPLCellParams&) params;

### WPLCellParams

C++版のイニシャライザで使用するパラメータクラス。
一般的な値はC++のコンストラクタでセットされるので、必要なパラメータだけ変更すればよく、定義を簡素化できる。

    - margin : UIEdgeInsets (left/top/right/bottom)

        ビューのマージン（デフォルト：0）

    - requestViewSize: CGSize

        0: auto ... Viewのサイズに合わせる（デフォルト）
        正値: fixed ... 指定されたサイズに固定
        負値: stretch ... コンテナにfitする

    - align : WPLAlignment (horz/vert)

        コンテナ内での配置位置指定

    - visibility : WPLVisibility

        VISIBLE: 表示
        COLLAPSED: 非表示（サイズゼロとして扱う）
        INVISIBLE: 非表示（ビューのサイズは有効）


### 継承するプロトコル
- IWPLCell
</details>

<details><summary>
WPLValueCell クラス
</summary>

値（value属性）を持つセルクラス。これは仮想クラスであり、valueの型、内包するViewのタイプに応じて、サブクラス化して利用する。

### 継承するプロトコル
- IWPLCell
- IWPLCellSupportValue

</details>

<details><summary>
WPLTextCell
</summary>

値（value属性）として、テキストを持つビュー（UILabel, UITextView, UJTextField）を内包するセルクラス。

継承するプロトコル
- IWPLCell
- IWPLCellSupportValue
- IWPLCellSuportReadonly

</details>


<details><summary>
WPLSwitchCell
</summary>

値（value属性）として、bool値を持つビュー（UISwitch）を内包するセルクラス。

継承するプロトコル
- IWPLCell
- IWPLCellSupportValue

</details>

---

## コンテナーセル

複数のセル（IWPLCellプロトコルに準拠したクラス）を保持して、それらの自動的に配置する機能を持つコンテナークラス。各コンテナークラス自身も、IWPLCellプロトコルに準拠しており、コンテナーの内部に他のコンテナーをネストして保持することが可能。

尚、コンテナーセルクラス(WPLGrid/WPLStackPanel/WPLFrame)は、それぞれの内部で、コンテナビューとしてUIViewインスタンスを作成する。

<details><summary>
IWPLContainerCell プロトコル
</summary>

コンテナセルのインターフェース。
addCell, removeCell, findByName, findByView など、サブセルを管理するためのメソッドと、レイアウト用のメソッド/プロパティを定義している。

### メソッド

    // セルを追加
    - (void) addCell:(id<IWPLCell>) cell;

    // セルを削除
    - (void) removeCell:(id<IWPLCell>) cell;

    // セルの名前で検索
    - (id<IWPLCell>) findByName:(NSString*) name;

    // ビューでセルを検索
    - (id<IWPLCell>) findByView:(UIView*) view;

</details>

<details><summary>
WPLContainerCell
</summary>

IWPLContainerCell プロトコルを実装した仮想クラス。
コンテナセル(StackPanel/Grid/Frame)共通実装.

</details>

<details><summary>
WPLGrid
</summary>

WFP/UWP の Grid にインスパイヤされたクラス。
あらかじめ Row/Column を定義し、その中にセルを配置する。HTML の &lt;table&gt; っぽいレイアウトが可能なコンテナ。

### Gridの生成

    + (instancetype) gridWithName:(NSString*) name
                           params:(const WPLGridParams&) params;


### WPLGridParams (extends WPLCellParams)

- dimension: WPLGridDefinition

    WPLGridDefinition

        NSArray<NSNumber*>* rowDefs;        // row毎の高さの配列
        NSArray<NSNumber*>* colDefs;        // column毎の幅の配列

        高さ、幅に、正値を指定すると、その固定サイズとなる。
        AUTO を指定すると、中に配置されるCellを収容できるサイズに伸縮する(XAMLの"AUTO"と同じ)。
        STRC を指定すると、残りのサイズいっぱいに広がる(XAMLの"*"と同じ）。
        STRC は複数指定でき、その場合は、残りのサイズが按分される。按分する比率を指定する場合は、STRCx(n) マクロを使用する。例えば、STRC,STRCx(2) と指定すると、1:2 に按分される。
        ※STRCx(1) は STRC と同義。

- cellSpacing: CGSize

    セルとセルの間隔
    当たり前の機能だと思うんだが、WPF/UWP の Gridには、なぜかこれがなくて結構不自由したものだ。

### グリッドへのセル追加

IWPLContainerCell#addCellは、0行0列にセルを追加するメソッドとして動作し、これに加えて、row/column を指定してセルを追加するには、Grid専用のメソッドを利用する。

    // 0行0列にセルを追加
    - (void) addCell:(id<IWPLCell>)cell;
    
    // row/columnにセルを追加
    - (void) addCell:(id<IWPLCell>)cell 
                 row:(NSInteger)row 
              column:(NSInteger)column;
    
    // rowSpan, colSpanを指定してセルを追加
    - (void) addCell:(id<IWPLCell>)cell 
                 row:(NSInteger)row 
              column:(NSInteger)column 
             rowSpan:(NSInteger)rowSpan 
             colSpan:(NSInteger)colSpan;

### グリッド構成の動的な変更

回転や画面分割などによるサイズ変更時に、グリッドの構成を変更したいことがあるが、
グリッドやセルを作り直すのはコストが大きい。そのような場合には、
reformWithParams:updateCell を使用する。

例）landscape / portrait でrow/columnを入れ替える

    - (void) layoutFor:(bool)landscape {
        let cols = (landscape) ? @[AUTO,AUTO,AUTO] : @[AUTO,AUTO];
        let rows = (landscape) ? @[AUTO,AUTO] : @[AUTO,AUTO,AUTO];

        [grid reformWithParams:WPLGridParams(grid.currentParams)
                                .colDefs(@[AUTO,STRC,AUTO])
                                .rowDefs(@[AUTO,AUTO,AUTO])
                updateCell:^WPLCellPosition(id<IWPLCell> cell, WPLCellPosition pos) {
                    let i = pos.row;
                    pos.row = pos.column;
                    pos.column = i;
                    return pos;
                }];
    }

第１引数のparamsを、WPLGridParams(grid.currentParams) をベースして変更している点に注意。
WPLGridParams()をベースにすると、visibilityなど、WPLCellParamsの属性がデフォルト値で初期化されてしまい、意図しない表示になってしまうことがある。

</details>

<details><summary>
WPLStackPanel
</summary>

WFP/UWP の StackPanel にインスパイヤされたクラス。
縦または、横方向にセルを並べて配置する。

### StackPanel の生成

    + (instancetype) stackPanelWithName:(NSString*) name
                                 params:(const WPLStackPanelParams&)params;

### WPLStackPanelParams

- orientation : WPLOrientation
    
    セルの配置方向(horz/vert)

- cellSpacing : NSInteger

    セルとセルの間隔（デフォルト：0）

</details>

<details><summary>
WPLFrame
</summary>

セルを１つだけ配置する一番シンプルなコンテナ。
WPF/UWPでは、しばしば、この用途で、row/columnを定義しない（1x1の）Gridを使うし、このライブラリでも、同じように使えるが、そのような場合には、WPLFrameを使った方がコンパクトでオーバーヘッドも少ない。

</details>

---

## オブザーバブル データオブジェクト

<details><summary>
IWPLObservableData プロトコル
</summary>

すべての監視可能なデータオブジェクトの基底i/f

### プロパティ

    @property (nonatomic,readonly) id value;
    @property (nonatomic,readonly) NSString* stringValue;
    @property (nonatomic,readonly) CGFloat floatValue;
    @property (nonatomic,readonly) bool boolValue;
    @property (nonatomic,readonly) NSInteger intValue;

### 値が変更されたときのイベント

オブザーバブルデータオブジェクトには、値の変更を監視するためのイベントリスナーを登録することが可能。

    // 値変更監視リスナーを追加する
    // @return 登録されたリスナーを識別するキー (登録解除に使う)
    - (id) addValueChangedListener:(id)target selector:(SEL)selector;

    // リスナーを登録解除する
    // @param key   addValueChangedListener の戻り値
    - (void) removeValueChangedListener:(id)key;

    // 値変更イベントの発行
    - (void) valueChanged;

### 依存関係の管理

このデータオブジェクトの値が変更されたとき、それに伴ってデータが変更される関連オブジェクトを定義する。つまり、このデータオブジェクトの変更イベントとともに、addRelation(s)で追加されたオブジェクトについても、変更イベントが発生する。

    - (void) addRelation:(id<IWPLObservableData>)relation;

    - (void) addRelations:(NSArray<id<IWPLObservableData>>*) relations;

    - (void) removeRelation:(id<IWPLObservableData>)relation;

</details>

<details><summary>
IWPLObservableMutableData プロトコル
</summary>

変更可能なデータを保持するデータクラス（WPLObservableMutableData）を表現するためのプロトコル。

### プロパティ

IWPLObservableDataと同じプロパティを持つが、これらがR/W可能になっている点だけ異なる。

    @property (nonatomic) id value;
    @property (nonatomic) NSString* stringValue;
    @property (nonatomic) CGFloat floatValue;
    @property (nonatomic) bool boolValue;
    @property (nonatomic) NSInteger intValue;

</details>

<details><summary>
IWPLDelegatedDataSource プロトコル
</summary>

外部の値にデリゲートする監視可能データオブジェクトのi/f
つまり、このプロトコルをサポートするオブジェクト自身は、データ（value）を持たず、他のオブジェクトの値を参照して動的に値を返す（sourceDelegate を呼び出して得た値を返す）ようにふるまう。

### 値を取得するデリゲート

値を取得するデリゲートとして、ブロック型関数、または、Target/Selectorのどちらかを利用することが可能。
両方設定されている場合は、ブロック型関数版の方を優先し、Target/Selector版は無視する。

    // ブロック型関数版
    // typedef id (^WPLSourceDelegateProc)(id<IWPLDelegatedDataSource>);
    @property (nonatomic) WPLSourceDelegateProc sourceDelegateBlock;

    // Target/Selector 版
    // id someMethod:(id<IWPLDelegateDataSource> me);
    @property (nonatomic) MICTargetSelector* sourceDelegateSelector;

</details>

<details><summary>
WPLObservableData クラス
</summary>

IWPLObservableData プロトコルに準拠した、WPLObservableMutableData, WPLDelegatedObservableData の共通の基底仮想クラス。このクラスを直接利用することはない。
</details>


<details><summary>
WPLObservableMutableData クラス
</summary>

IWPLObservableMutableData プロトコルに準拠した、変更可能な値を保持する「ふつう」のデータクラス。
NSString, NSInteger, bool, CGFloat の各プリミティブ型は専用のプロパティで操作可能。それ以外は、id型プロパティで対応。
valueプロパティが変化すると、自動的にvalueChangeイベントが発行される。
</details>

<details><summary>
WPLDelegatedObservableData クラス
</summary>

IWPLDelegatedObservableData プロトコルに準拠した、外部の値にデリゲートする監視可能データオブジェクト。
dataSource に、値を取得するデリゲートをセットして使用する。
単独で使用する場合は、値が変化するときに、明示的に valueChanged を呼び出す必要があるが、通常は、外部の値として、他のオブザーバブルデータオブジェクトを参照する場合は、その Relation に登録しておくことで、valueChangedイベントの発行を自動化できる。

</details>

<details><summary>
WPLSubject クラス
</summary>

WPLObservableMutableData と、ほとんど同じだが、valueに値をセットしたとき、値が変化していても、変化していなくても、valueChangedイベントを発行する点だけ異なる。つまり、単純なイベント発行/監視（バインド）を 他のObservableDataと同じスタイルで記述できるようにするためのクラスである。

</details>


---

## バインディング

ビュー（Cell)と、データ(ObservableData)を関連付ける（バインド）し、データが変化したときに、ビューが持つ値、表示状態、その他プロパティを自動的に更新したり、逆に、ビューの状態変化をデータとして取り出したりするデータバインディングを実現する。

<details><summary>
IWPLBinding プロトコル
</summary>

１つのバインディング、すなわち、１つのセルと、１つのデータソースのペアを保持して、それぞれの間でのデータの更新を管理するオブジェクトのi/fを規定する。

### プロパティ
    
    // セル
    @property (nonatomic,readonly) id<IWPLCell> cell;

    // データソース
    @property (nonatomic,readonly) id<IWPLObservableData> source;

    // バインドモード
    @property (nonatomic,readonly) WPLBindingMode bindingMode;

        WPLBindingModeTWO_WAY,                   // TwoWay
        WPLBindingModeVIEW_TO_SOURCE_WITH_INIT,  // OneWayToSource   初期化時だけSOURCE->View に反映する
        WPLBindingModeSOURCE_TO_VIEW,            // OneWay
        WPLBindingModeVIEW_TO_SOURCE,            // OneWayToSource

    // 値変更時のカスタムアクション
    @property (nonatomic,readonly) WPLBindingCustomAction customAction;

        typedef void (^WPLBindingCustomAction)(id<IWPLBinding> sender, bool fromView);
        値が変化したタイミングで、セルとデータソースの標準的なバインディング以外の処理が必要な場合に利用可能。


### オブジェクト解放
参照・依存関係をクリアするために、不要になれば、dispose を呼ぶことが望ましい。    
※WPLBinder クラスを利用することにより、dispose の呼び出しなどを自動化できる。

    - (void) dispose;

</details>

<details><summary>
IWPLBoolStateBinding プロトコル
</summary>

bool型データソースとViewの状態（＝セルの visibility, enabled, readonly 属性)のBindingを実現するための i/f

### プロパティ

    // bool値を、セル（ビュー）のどの属性に関連付けるか
    @property (nonatomic, readonly) WPLBoolStateActionType actionType;

        WPLBoolStateActionTypeVISIBLE_COLLAPSED,  // bool --> ビューの表示・非表示（サイズゼロ扱い）
        WPLBoolStateActionTypeVISIBLE_INVISIBLE,  // bool --> ビューの表示・非表示（サイズは維持）  
        WPLBoolStateActionTypeENABLED,            // bool --> ビューの有効・無効
        WPLBoolStateActionTypeREADONLY,         　// bool --> RW・RO

    // bool 値の意味を反転する場合は true にする
    @property (nonatomic, readonly) bool negation;

</details>

<details><summary>
WPLGenericBinding クラス
</summary>

IWPLBindingに準拠するバインディングの基底クラス。通常は、サブクラスの WPLValueBinding, WPLBoolStateBinding を使用するが、ViewのbackgroundColor や alpha など、（Cellのプロパティではなく）Viewのプロパティにバインドするようなケースには、このクラスを直接使用して、customActionに処理を記述するか、あるいは、サブクラスを作成して、onSourceChanged: をオーバーライドする。

### 初期化

    - (instancetype) initWithCell:(id<IWPLCell>)cell
                           source:(id<IWPLObservableData>)source
                      bindingMode:(WPLBindingMode)bindingMode
                     customAction:(WPLBindingCustomAction) customAction;

</details>

<details><summary>
WPLBoolStateBinding クラス
</summary>

IWPLBoolStateBinding プロトコルに準拠し、Cellの bool型属性（visibility, enabled, readonly）にデータをバインドすることを目的としたバインディングクラス。

### 初期化

    - (instancetype) initWithCell:(id<IWPLCell>) cell
                           source:(id<IWPLObservableData>) source
                     customAction:(WPLBindingCustomAction)customAction
                       actionType:(WPLBoolStateActionType) actionType
                         negation:(bool)negation;
                        
</details>

<details><summary>
WPLValueBinding クラス
</summary>

IWPLCellSupportValue プロトコルに準拠したセルクラス（WPLValueCellなど）の value属性と、データソースをバインドすることを目的としたバインディングクラス。

### 初期化

    - (instancetype) initWithCell:(id<IWPLCell>) cell
                           source:(id<IWPLObservableData>) source
                      bindingMode:(WPLBindingMode)bindingMode
                     customAction:(WPLBindingCustomAction)customAction;


</details>

<details><summary>
WPLBinder クラス
</summary>

Cell と　ObservableData のバインドを管理するクラス。

このクラスを使わなくても、それぞれのインスタンスをBindingクラスを使って関連づけていけばよいのだが、
Viewごとにそれらの構築用のコードを書いて、どこか（Viewクラスのメンバーなど）に保持しなければならず、コード量も少なくなく、保守性、可読性が悪くなる。そこで、柔軟性を多少犠牲にして（例えばプロパティはすべて文字列の名前をつけてアクセスする、とか）、できるだけ簡潔に利用できるようにすることを目指したクラス。

尚、このクラス内では、バインドされるデータソースのことを、バインド可能なプロパティ(bindable property)または、単にプロパティ、と呼んでいる。ObjC的な意味のプロパティと混同しないように。

WPLBinderは、以下の手順で使う。
1. WPLBinder インスタンスを作成（ViewControllerのフィールドなどとして保持）
2. WPLBinder インスタンスに、バインド可能なプロパティを登録
3. バインド可能なプロパティに対して、Cellを関連づけて登録

### 初期化

    - (instancetype) init;

### 自動解放の制御

    // dispose 時に、登録されている　binding に対して dispose を呼ぶか？
    // default:true
    @property (nonatomic) bool autoDisposeBindings;
    
    // dispose 時に、登録されている　データソース (ObservableData) に対して dispose を呼ぶか？
    // default:true
    @property (nonatomic) bool autoDisposeProperties;

### バインド可能なプロパティ（データソース）の登録・取得・登録解除

    /**
     * 通常の値型（ObservableMutableData型）プロパティを作成して登録
     * @param initialValue 初期値
     * @param key プロパティを識別するキー(nilなら、内部で生成して戻り値に返す）。
     * @return プロパティを識別するキー
     */
    - (id) createPropertyWithValue:(id)initialValue withKey:(id) key;

    /**
     * 依存型(DelegatedObservableData型）プロパティを生成して登録
     * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
     * @param sourceProc 値を解決するための関数ブロック
     * @param relations このプロパティが依存するプロパティ（のキー）
     *                  このメソッドが呼び出される時点で解決できなければ、指定は無効となるので、定義順序に注意。
     */
    - (id) createDependentPropertyWithKey:(id)key 
                               sourceProc:(WPLSourceDelegateProc)sourceProc 
                                dependsOn:(id)relations, ... NS_REQUIRES_NIL_TERMINATION;

    /**
     * 上のメソッドの可変長引数部分をva_list型引数で渡せるようにしたメソッド
     */
    - (id) createDependentPropertyWithKey:(id)key 
                               sourceProc:(WPLSourceDelegateProc)sourceProc 
                                dependsOn:(NSString*) firstRelation 
                        dependsOnArgument:(va_list) args;

    /**
     * 外部で作成したObservableData型のインスタンスをプロパティとしてバインダーに登録する。
     * @param prop ObservableData型インスタンス
     * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
     */
    - (id) addProperty:(id<IWPLObservableData>) prop forKey:(id) key;

    /**
     * 登録済みのプロパティを取得
     * @param key   createProperty/createDependentProperty の戻り値
     * @return IWPLObservableData型インスタンス（未登録ならnil）
     */
    - (id<IWPLObservableData>) propertyForKey:(id)key;

    /**
     * Observablega*MutableData型のプロパティを取得
     * @param key   createProperty/createDependentProperty の戻り値
     * @return IWPLObservableMutableData型インスタンス
     *         未登録、または、指定されたプロパティがMutableでなければnil
     */
    - (id<IWPLObservableMutableData>) mutablePropertyForKey:(id)key;

    /**
     * プロパティをバインダーから削除する。
     * @param key   addProperty, createProperty / createDependentProperty などが返した値。
     */
    - (void) removeProperty:(id)key;

### Cellとプロパティの関連づけ

    /**
    　* セルの値とプロパティのバインディングを作成して登録
    　* @param propKey   バインドするプロパティを識別するキー（必ず登録済みのものを指定）
    　* @param cell      バインドするセル
    　* @param bindingMode   VIEW_TO_SOURCE_WITH_INIT | VIEW_TO_SOURCE | SOURCE_TO_VIEW | TWOWAY
    　* @param customAction  プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
    　* @return 作成された binding インスタンス
    　*/
    - (id<IWPLBinding>) bindProperty:(id)propKey
                    withValueOfCell:(id<IWPLCell>)cell
                        bindingMode:(WPLBindingMode)bindingMode
                        customActin:(WPLBindingCustomAction)customAction;

    /**
    　* セルの状態(Bool型）とプロパティのバインディングを作成して登録
    　* @param propKey       バインドするプロパティを識別するキー（必ず登録済みのものを指定）
    　* @param cell          バインドするセル
    　* @param actionType    Cellの何とバインドするか？
    　* @param negation      trueにすると、bool値を反転する
    　* @param customAction  プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
    　* @return 作成された binding インスタンス
    　*/
    - (id<IWPLBinding>) bindProperty:(id)propKey
                withBoolStateOfCell:(id<IWPLCell>)cell
                        actionType:(WPLBoolStateActionType) actionType
                            negation:(bool) negation
                        customActin:(WPLBindingCustomAction)customAction;

    /**
    　* 特殊なバインドを作成　（SOURCE to VIEWのみ）
    　* バインドの内容は、customAction に記述する。
    　* （ソースが変更されると、customAction が呼び出されるので、そこでなんでも好きなことをするのだ）
    　*/
    - (id<IWPLBinding>) bindProperty:(id)propKey
                            withCell:(id<IWPLCell>)cell
                        customAction:(WPLBindingCustomAction) customAction;

    /**
    　* 外部で作成したバインディングインスタンスを登録する。
    　* @param binding   バインディングインスタンス
    　*/
    - (void) addBinding:(id<IWPLBinding>) binding;


    /**
    　* バインドを解除する
    　* @param binding   バインディングインスタンス
    　*/
    - (void) unbind:(id<IWPLBinding>) binding;

### バインディングの破棄

    - (void) dispose;

</details>
---

<details><summary>
WPLBinderBuilder (C++クラス)
</summary>

WPLBinderを使ったバインディングの構築を、C++の書式でエレガントにやってみよう、という試み。

例えば、

    _binder = [[WPLBinder alloc] init];
    // bool型のプロパティをhogeという名前で登録 (初期値はtrue)
    id propKey = [_binder createPropertyWithValue:@true @"hoge"];
    // hogeにcellのvisibilityを関連づける
    [_binder bindProperty:propKey
      withBoolStateOfCell:cell
               actionType:WPLBoolStateActionTypeVISIBILITY_COLLAPLSED
                 negation:false
              customActin:nil];

というコードは、C++で次のように書ける。シンプルだろ？

    _binder = WPLBinderBuilder()
                .property(@"hoge", true)
                .bindState(@"hoge, cell, WPLBoolStateActionTypeVISIBILITY_COLLAPLSED)
                .build();



</details>

---

##  セル・ホスティング・ビュー

コンテナーセルは、そのサイズやマージンなどの属性が変化したときに、内部のセルやコンテナーセルを自動的に再配置するが、普通のUIViewの世界と、WPLの世界との境界、すなわち、ルートのコンテナーセルだけは、UIViewのサイズ変更などに対して、適切な処理を行うためのコードを書く必要がある。

これらの、ちょっと面倒な、お決まりの仕事を引き受けるビュークラスが、これ。
ちなみに、WPLCellHosting

<details><summary>
WPLCellHostingView / WPLCellHostingScrollView 
</summary>

汎用的な、セル・ホスティング・ビュークラス。
あらかじめ用意した containerCell をプロパティとして与えることで、セル・ホスティング・ビューのサイズ変更などに合わせて、containerCellが適切に再配置される。

WPLCellHostingViewはUIViewから派生しているのに対して、WPLCellHostingScrollViewは、UIScrollView から派生しており、親ビュー上での frame を指定しておくと、そのサイズがコンテントのサイズより小さくなると、自動的にスクロールが有効になる。

また、セルホスティングビューは、親となるビュー(UIViewContainer#viewなど)に配置することになるが、その配置には、NSLayoutConstraint などが使え、さらに、NSLayoutConstraint を使うなら、[AutoLayoutBuilder](/layouter/auto-layout.md)が便利。

尚、通常は、特定のレイアウターをあらかじめ保持している、サブクラスの、WPLGridView/WPLGridScrollView, WPLStackView/WPLStackPanelScrollView, WPLFrameView/WPLFrameScrollView など使用する。
</details>

<details><summary>
WPLGridView / WPLGridScrollView
</summary>

WPLCellHostingView / WPLCellHostingScrollView の containerCellプロパティに、WPLGrid インスタンスがセットされたもの。
WPLCellHostingViewとWPLGridを別々に作ってセットすることすら面倒なもので。
</details>

<details><summary>
WPLStackPanelView / WPLStackPanelScrollView
</summary>
WPLCellHostingView の containerCellプロパティに、WPLStackPanel インスタンスがセットされたもの。
</details>

<details><summary>
WPLFrameView / WPLFrameScrollView
</summary>
WPLCellHostingView の containerCellプロパティに、WPLFrame インスタンスがセットされたもの。
</details>

