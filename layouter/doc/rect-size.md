# CGRect, CGSize, CGPoint, ... を置き換える

iOSの開発を始めて間もないころに、CGRectMake とか、CGPointEqualToPoint とか、いつの時代のコーディング？　と思って作ったクラス。この程度は標準で提供されていてもバチは当たらないと思うし、私にとっては、もしなかったら死ぬレベルで必須。


    /layouter/ut/
        MICUiRectUtil.h


## MICRect
   　
CGRectから派生しており、CGRectの代わりに使える。
コンストラクタで初期化できるだけでもCGRectを置き換える理由としては十分な気がする。移動や座標設定、拡大・縮小などのメソッドが使え、MICEdgeInsetsと組み合わせたマージン計算なども便利。

<details><summary>
コンストラクタ
</summary>
    
    MICRect()
        (0,0)-(0,0)の矩形を作成
    MICRect(const CGRect& src)
        CGRect型からのコピーコンストラクタ
    MICRect(const CGPoint& origin, const CGSize& size) {
        originとsize を指定して矩形を作成
    MICRect(const CGPoint& origin)
        (origin.x, origin.y)-(0,0)の矩形を作成
    MICRect(const CGSize& size)
        (0,0)-(size.width, size.height) の矩形を作成
    MICRect(const CGPoint& lt, const CGPoint& rb)
        左上と右下の座標を与えて矩形を作成
    MICRect(CGFloat w, CGFloat h)
        幅と高さを与えて、origin==(0,0)の矩形を作成
    MICRect(CGFloat l, CGFloat t, CGFloat r, CGFloat b)
        left, top, right, bottom の座標値を与えて矩形を作成（WindowsのRect風）
    MICRect(NSValue* v)
        CGRectValue を持つNSValue から矩形を作成
    static MICRect XYWH(CGFloat x, CGFloat y, CGFloat w, CGFloat h)
        left, top, width, height を与えて矩形を作成
    static CGRect zero()
        CGRectZero
</details>


<details><summary>
再設定
</summary>
    
    MICRect& setRect(const CGRect& src)
    MICRect& setRect(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom)
    MICRect& setRect(const CGPoint& lt, const CGPoint& rb)
    MICRect& setRect(const CGPoint& lt, const CGSize& size)
    MICRect& setRectXYWH(CGFloat x, CGFloat y,CGFloat width, CGFloat height)

</details>

<details><summary>
エイリアス
</summary>

    CGFloat x() const
    void setX(CGFloat x)
        左辺x座標 (==origin.x)
    CGFloat y() const
    void setY(CGFloat y)
        上辺y座標 (==origin.y)

    CGFloat width() const
    void setWidth(CGFloat v)
        幅（== size.width）
    CGFloat height() const
    void setHeight(CGFloat v)
        高さ（== size.height)
</details>

<details><summary>
座標値の取得・設定
</summary>

#### 辺
    CGFloat left() const 
    MICRect& setLeft(CGFloat v)
        左辺のx座標（==origin.x）
    
    CGFloat top() const
    MICRect& setTop(CGFloat v)
        上辺のy座標（==origin.y）
    
    CGFloat right() const
    MICRect& setRight(CGFloat v)
        右辺のx座標
    
    CGFloat bottom() const
    MICRect& setBottom(CGFloat v)
        下辺のy座標
#### 頂点
    CGPoint leftTop() const
    CGPoint LT() const
    MICRect& setLeftTop(CGPoint lt)
        左上の座標 (== origin)
    CGPoint rightBottom() const
    CGPoint RB() const
    MICRect& setRightBottom(CGPoint rb)
        右下の座標
    CGPoint leftBottom() const
    CGPoint LB() const
    MICRect& setLeftBottom(CGPoint lb)
        左下の座標
    CGPoint rightTop() const
    MICRect& setRightTop(CGPoint rt)
    CGPoint RT() const
        右上の座標

#### 中央    
    CGPoint midTop() const
    CGPoint MT() const
        上辺中央の座標
    CGPoint midBottom() const
    CGPoint MB() const
        下辺中央の座標
    CGPoint midLeft() const
    CGPoint ML() const
        左辺中央の座標
    CGPoint midRight() const
    CGPoint MR() const
        右辺中央の座標 
    CGPoint center() const
    CGFloat midX() const
    CGFloat midY() const
        矩形中央の座標
</details>

<details><summary>
Empty/Null/Infinite
</summary>

    MICRect& setEmpty()     //--> CGRectZero
    MICRect& setNull()      //--> CGRectNull
    MICRect& setInfinite()  //--> CGRectInfinite
    bool isEmpty()
    bool isNull()
    bool isInfinite()
</details>

<details><summary>
移動
</summary>

    MICRect& moveTop(CGFloat y)
    MICRect& moveBottom(CGFloat y)
    MICRect& moveLeft(CGFloat x)
    MICRect& moveRight(CGFloat x)
        上下左右の座標を指定して平行移動

    MICRect& moveLeftTop(const CGPoint& toPos)
    MICRect& moveLeftBottom(const CGPoint& toPos)
    MICRect& moveRightTop(const CGPoint& toPos)
    MICRect& moveRightBottom(const CGPoint& toPos)
        左上、左下、右江、右下 の座標を指定して平行移動

    MICRect& move(const CGVector& v)
    MICRect& move(CGFloat dx, CGFloat dy)
        ベクトルを指定して移動

    MICRect& moveCenter(const CGPoint& toPos)
        中央の座標を指定して平行移動

    MICRect& moveToCenterOfOuterRect(const MICRect& outer) 
    MICRect& moveToHCenterOfOuterRect(const MICRect& outer)  // 水平方向
    MICRect& moveToVCenterOfOuterRect(const MICRect& outer)  // 垂直方向
        矩形の中心をouter矩形の中心に一致させるように移動
</details>

<details><summary>
正規化    
</summary>

    MICRect& norimalize()
        サイズが正値になるよう、origin/size を調整する。（矩形自体は変化しない）
</details>

<details><summary>
    連結・重なり・ヒットテスト
</summary>

    static CGRect unionRect(const CGRect& r1, const CGRect& r2)
    MICRect& unionRect(const CGRect& r)
        ２つの矩形を含む矩形を作成
    static CGRect intersectRect(const CGRect& r1, const CGRect& r2)
    MICRect& intersectRect(const CGRect& r)
        二つの矩形の重なる部分の矩形を作成

    static bool containsPoint(const CGRect& rc, const CGPoint& p)
    bool containsPoint(const CGPoint& p) const
    bool ptInRect(const CGPoint& p) const // Win風エイリアス
        矩形は、点を含むか？
</details>

<details><summary>
    拡大・縮小
</summary>

    MICRect& inflate(CGFloat l, CGFloat t, CGFloat r, CGFloat b)
    MICRect& inflate(CGFloat width)
    MICRect& inflate(CGFloat width, CGFloat height)
    MICRect& inflate(const CGSize& size) {
    MICRect& inflate(const UIEdgeInsets& insets)
        矩形を拡大する

    MICRect& deflate(CGFloat l, CGFloat t, CGFloat r, CGFloat b)
    MICRect& deflate(CGFloat width)
    MICRect& deflate(CGFloat width, CGFloat height)
    MICRect& deflate(const CGSize& size)
    MICRect& deflate(const UIEdgeInsets& insets)
        矩形を縮小する
</details>

<details><summary>
変形
</summary>

    MICRect& transpose()
    static CGRect transpose(const CGRect& r)
        縦、横を入れ替える

    MICRect& transform(const CGAffineTransform& tr)
        アフィン変換する
</details>

<details><summary>
部分矩形
</summary>

    MICRect partialLeftRect(CGFloat width) const
        矩形の左側を指定幅分切り出す
    MICRect partialRightRect(CGFloat width) const
        矩形の右側を指定幅分切り出す
    MICRect partialHorzCenterRect(CGFloat width) const
        矩形の中央を指定幅分切り出す
    MICRect partialTopRect(CGFloat height) const
        矩形の上側を指定高さ分切り出す
    MICRect partialBottomRect(CGFloat height) const
        矩形の下側を指定高さ分切り出す
    MICRect partialVertCenterRect(CGFloat height) const {
        矩形の中央を指定高さ分切り出す
</details>

<details><summary>
オペレーター
</summary>
    
    bool operator == (const CGRect& rc) const
    bool operator != (const CGRect& rc) const 
        等価比較

    MICRect& operator += (const UIEdgeInsets& margin)
    CGRect operator +(const CGRect& rc, const UIEdgeInsets& margin)
        拡大

    MICRect& operator -= (const UIEdgeInsets& margin)
    CGRect operator -(const CGRect& rc, const UIEdgeInsets& margin)
        縮小

    MICRect& operator -= (const CGVector& v)
    MICRect& operator += (const CGVector& v)
    CGRect operator -(const CGRect& rc, const CGVector& v)
    CGRect operator +(const CGRect& rc, const CGVector& v)
        移動
</details>

<details><summary>
NSValue(CGRectValue)変換
</summary>

    static CGRect fromValue(NSValue* value)
    NSValue* asValue()
</details>

----    

## MICSize

CGSizeから派生しており、CGSizeの代わりに使える。

<details><summary>
コンストラクタ
</summary>

    MICSize()
    MICSize(const CGSize& src)
    MICSize(const CGVector& v)
    MICSize(CGFloat s)
    MICSize(CGFloat w, CGFloat h) 
    MICSize(NSValue* value)
    static CGSize zero()
</details>

<details><summary>
再設定
</summary>

    MICSize& set(CGFloat w, CGFloat h)
    MICSize& set(const CGSize& size) {
</details>

<details><summary>
エイリアス</summary>

    CGFloat x() const   // width
    CGFloat y() const   // height
</details>

<details><summary>
Empty
</summary>

    bool isEmpty()
    static bool isEmpty(const CGSize& size)
    MICSize& setEmpty()
</details>

<details><summary>
変形
</summary>   

    MICSize& transpose()
    static CGSize transpose(const CGSize& size)
        縦・横を入れ替える
    MICSize& transform(const CGAffineTransform& tr)
        アフィン変換する
</details>

<details><summary>
拡大・縮小
</summary>

    MICSize& inflate(CGFloat dw, CGFloat dh)
    MICSize& inflate(const CGSize& s)
    MICSize& inflate(CGFloat d)
    MICSize& inflate(const UIEdgeInsets& insets)
        拡大する
    
    MICSize& deflate(CGFloat dw, CGFloat dh)
    MICSize& deflate(const CGSize& s)
    MICSize& deflate(const UIEdgeInsets& insets) 
    MICSize& deflate(CGFloat d)
        縮小する

</details>

<details><summary>
NSValue (CGSizeValue) 変換
</summary>

    static CGSize fromValue(NSValue* value)
    NSValue* asValue()

</details>

<details><summary>
最大・最小
</summary>

    static CGSize max(const CGSize& s1, const CGSize& s2)
    static CGSize min(const CGSize& s1, const CGSize& s2);
        ２つのサイズのwidth, height の最大・最小値をもつサイズを取得
</details>

<details><summary>
オペレーター
</summary>

    bool operator == (const CGSize& s) const
    bool operator != (const CGSize& s) const
        等価比較
    
    operator CGVector()
        CGSize --> CGVevtor

    CGSize operator +(const CGSize& size, const UIEdgeInsets& margin)
    CGSize operator -(const CGSize& size, const UIEdgeInsets& margin)
    CGSize operator +(const CGSize& size, const CGSize& s)
    CGSize operator -(const CGSize& size, const CGSize& s)
        拡大・縮小
</details>

----    

## MICPoint

CGPointを継承していており、CGPointの代わりに使える。また、+/- オペレータで、MICVectorを介した演算ができ、それを、CGRectの移動操作に適用するのが、とても便利。

<details><summary>
コンストラクタ
</summary>
 

    MICPoint()
    MICPoint(CGFloat sx, CGFloat sy)
    MICPoint(const CGPoint& p)
    MICPoint(NSValue* value)

</details>

<details><summary>
再設定
</summary>

    MICPoint& set(const CGPoint& src)
    MICPoint& set(CGFloat sx, CGFloat sy)

</details>

<details><summary>
変換・変形
</summary>

    MICPoint& transpose()
    static CGPoint transpose(CGPoint p)
        転置（縦・横を入れ替える）
    
    transform(const CGAffineTransform& tr)
        アフィン変換する
</details>

<details><summary>
NSValue(CGPointValue)変換
</summary>

    static CGPoint fromValue(NSValue* value)
    NSValue* asValue()

</details>

<details><summary>
ヒットテスト
</summary>

    bool isContained(const CGRect& rc)
        矩形に含まれるか

</details>

<details><summary>
オペレータ
</summary>

    bool operator == (const CGPoint& s) const
    bool operator != (const CGPoint& s) const
        等価比較
      
    MICPoint& operator += (const CGVector& v)
    MICPoint& operator -= (const CGVector& v)
    CGPoint operator +(const CGPoint& p, const CGVector& v)
    CGPoint operator -(const CGPoint& p, const CGVector& v)
        移動

    CGVector operator -(const CGPoint& to, const CGPoint& from)
        ２点間のベクトル
</details>



----    

## MICVector

CGVector を継承しており、CGVectorを置き換え可能。+/- オペレータを使って、ベクトルを合成したり、MICPoint, MICRectを移動したりできる。

<details><summary>
コンストラクタ
</summary>

    MICVector()
    MICVector(CGFloat x, CGFloat y)
    MICVector(CGPoint pos)
    MICVector(const CGVector& p)
    MICVector(NSValue* value)
    static CGVector zero()

</details>

<details><summary>
再設定    
</summary>

    MICVector& set(CGFloat x, CGFloat y)
    MICVector& set(const CGVector& src)

</details>

<details><summary>
変形
</summary>

    MICVector& transpose()
    static CGVector transpose(const CGVector p)
        転置（縦・横を入れ替える）

</details>

<details><summary>
NSValue (CGVectorValue) 相互変換
</summary>

    static CGVector fromValue(NSValue* value)
    NSValue* asValue()

</details>

<details><summary>
距離
</summary>

    CGFloat magnitude() const

</details>

<details><summary>
オペレーター    
</summary>

    bool operator == (const CGVector& s) const
    bool operator != (const CGVector& s) const
        等価比較
    
    MICVector& operator+=(const CGVector& s)
    MICVector& operator-=(const CGVector& s) 
    CGVector operator+(const CGVector& d, const CGVector& s)
    CGVector operator-(const CGVector& d, const CGVector& s)
        ベクトルの合成

</details>

----    

## MICEdgeInsets

UIEdgeInsets から派生しており、UIEdgeInsetsを置き換えて使用可能。
MICRect や MICSize の +/- オペレータと組み合わせると、矩形の拡大/縮小ができる。また、コンストラクタによる初期化が便利すぎて手放せない。「上下左右すべてに5pxのマージン」というような場合に、MICEdgeInset(5) と記述するだけでよく、可視性が大幅向上。

<details><summary>
コンストラクタ
</summary>

    MICEdgeInsets()
    MICEdgeInsets(const UIEdgeInsets& src)
    MICEdgeInsets(CGFloat w)
    MICEdgeInsets(CGFloat h, CGFloat v)
    MICEdgeInsets(CGFloat l, CGFloat t, CGFloat r, CGFloat b)
    MICEdgeInsets(const CGSize& lt, const CGSize& rb)
    MICEdgeInsets(const CGRect& outer, const CGRect& inner)
    MICEdgeInsets(NSValue* value)
    static UIEdgeInsets zero()
</details>

<details><summary>
再設定
</summary>

    MICEdgeInsets& set(const UIEdgeInsets& src)
    MICEdgeInsets& set(CGFloat w)
    MICEdgeInsets& set(CGFloat h, CGFloat v)
    MICEdgeInsets& set(CGFloat l, CGFloat t, CGFloat r, CGFloat b)
    MICEdgeInsets& set(const CGSize& lt, const CGSize& rb)
    MICEdgeInsets& set(const CGRect& outer, const CGRect& inner)
</details>

<details><summary>
変形
</summary>

    MICEdgeInsets& transpose()
    static UIEdgeInsets transpose(const UIEdgeInsets& e)

</details>

<details><summary>
マージン量
</summary>

    CGFloat dh() const
    static CGFloat dh(const UIEdgeInsets& v)
        高さのマージン合計(top+bottom)
    
    CGFloat dw() const
    static CGFloat dw(const UIEdgeInsets& v)
        幅のマージン合計（left+right)

</details>

<details><summary>
NSValue (UIEdgeInsetsValue) 相互変換    
</summary>

    static UIEdgeInsets fromValue(NSValue* value)
    NSValue* asValue()

</details>

<details><summary>
Empty  
</summary>
    bool isEmpty()
    static bool isEmpty(const UIEdgeInsets& v)
</details>

<details><summary>
オペレータ    
</summary>

    bool operator==(const UIEdgeInsets& s) const
    bool operator!=(const UIEdgeInsets& s) const
        等価比較
    
    MICEdgeInsets& operator+=(const UIEdgeInsets& s)
    MICEdgeInsets& operator-=(const UIEdgeInsets& s)
    UIEdgeInsets operator +(const UIEdgeInsets& s)
    UIEdgeInsets operator -(const UIEdgeInsets& s)
    UIEdgeInsets operator+(const UIEdgeInsets& d, const UIEdgeInsets& s)
    UIEdgeInsets operator-(const UIEdgeInsets& d, const UIEdgeInsets& s)
        マージンの合成

    UIEdgeInsets operator -(const CGRect& outer, const CGRect& inner)
        ２つの矩形の差分
</details>
