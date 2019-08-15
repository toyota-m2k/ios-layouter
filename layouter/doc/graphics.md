# グラフィックス・描画

CGContextRef とか、CGImageRelease()とか、これまた、前時代の香りがする仕掛けだな。特に、解放が必要なリソースの扱いは、C++の得意分野。

    layouter/ut/
        MICCGContext.h

## MICCGResource

解放が必要なグラフィックリソース（CGContextRef, CGImageRef, CGPathRef, CGFontRef, CGColorRef）をラップする、テンプレートクラス。
デストラクタでリソースを確実に解放。各リソース型（CGXxxxRef）への変換オペレータを実装するので、それらの型を要求するメソッドなどに、そのまま渡せる。

<details><summary>
メソッド
</summary>

    MICCGResource()
        デフォルトコンストラクタ
        setResource()でリソースをセットする。
    MICCGResource(T res, bool retained)
        リソースを与えて初期化するコンストラクタ
    void setResource(T res, bool retained)
        リソースを設定する。
    void release()
        リソースを解放する。
        通常は、デストラクタから呼ばれる。
    T detach()
        リソースを管理対象から切り離す。
    operator T&()
        リソース型(CGXxxxRef)への変換オペレータ

</details>

## MICCGImage

CGImageRef のラッパクラス （MICCGResource派生）。

## MICCGFont

CGFontRef のラッパクラス（MICCGResource派生）。

## MICCGColor

CGColorRef のラッパクラス（MICCGResource派生）。

<details><summary>
メソッド
</summary>

    MICCGColor(UIColor* uicolor)
        UIColor から、CGColorRefへの変換コンストラクタ

    MICCGColor(UIColor* uicolor, CGFloat alpha)
        UIColor＋alpha値から、CGColorRefへの変換コンストラクタ
    
    MICCGColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a) 
        ARGB値から、CGColorRefを作成するコンストラクタ
    
    UIColor* asUIColor()
        CGColor --> UIColor変換
</details>

## MICCGPath

CGPathRef のラッパクラス（MICCGResource派生）。

## MICCGMutablePath

CGMutablePath のラッパクラス（MICCGResource派生）。

<details><summary>
メソッド
</summary>

    const MICCGMutablePath& closePath()
        閉じられていないパスを閉じる。

    CGPoint getCurrentPoint() const
        パスのカレントポイントを取得

    const MICCGMutablePath& moveTo(CGFloat x,CGFloat y,CGAffineTransform* m = NULL const
    const MICCGMutablePath& moveTo(const CGPoint p, CGAffineTransform* m = NULL) const
        パスのカレントポイントを移動

    const MICCGMutablePath& lineTo(CGFloat x, CGFloat y, CGAffineTransform* m = NULL) const
    const MICCGMutablePath& lineTo(const CGPoint& p, CGAffineTransform* m = NULL) const
        直線を描画

    const MICCGMutablePath& addCurveToPoint(CGFloat cp1x, CGFloat cp1y, CGFloat cp2x, CGFloat cp2y, CGFloat x, CGFloat y, CGAffineTransform* m = NULL) const
    const MICCGMutablePath& addCurveToPoint(CGPoint cp1, CGPoint cp2, CGPoint p, CGAffineTransform* m = NULL) const
        ２次元ベジェ曲線を描画

    const MICCGMutablePath& addQuadCurveToPoint(CGFloat cp1x, CGFloat cp1y, CGFloat x, CGFloat y, CGAffineTransform* m = NULL) const
    const MICCGMutablePath& addQuadCurveToPoint(CGPoint cp1, CGPoint p, CGAffineTransform* m = NULL) const
        ３次元ベジェ曲線を描画

    const MICCGMutablePath& addArc (CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat delta,CGAffineTransform* m = NULL) const
        CGPathAddRelativeArc
    const MICCGMutablePath& addArc (CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat endAngle, bool clockwise, CGAffineTransform* m = NULL) const
        CGPathAddArc
    const MICCGMutablePath& addArcToPoint(const CGPoint& p1, const CGPoint& p2, CGFloat radius, CGAffineTransform* m = NULL) const
        CGPathAddArcToPoint
        円弧を描画

</details>

## MICCGContext

CGContextRef のラッパークラス (MICCGResource派生)

<details><summary>
コンストラクタ・初期化
</summary>

    MICCGContext()
        UIGraphicsGetCurrentContext()で取得したコンテキストで初期化
    MICCGContext(bool getContext)
        getContext==false なら、空のリソースで初期化
    MICCGContext(const CGContextRef& ctx,bool retained)
        コンテキストを与えて初期化
    
</details>

<details><summary>
Path操作
</summary>

    Path createPath()
        コンテキストに関連付けられたPath（インナークラス）オブジェクトを取得
        このPathオブジェクトに対して描画操作を行う。
    
    CGPathRef copyPath()
    bool copyPath(MICCGPath& pathR)
        コンテキスト内のPath（Pathインナークラスに対して描画したもの）をCGPathRef として取り出す。
    
</details>

<details><summary>
Path inner class
</summary>

できることは、MICCGMutablePathと ほぼ同じ。CGContext に直接書き込むか、CGMutablePathに書き込んでから、CGContext に書き込む（CGContextAddPath）するかの違い。

    const Path& closePath() const
        閉じられていないパスを閉じる
    
    CGPoint getCurrentPoint() const
    const Path& moveTo(CGFloat x,CGFloat y) const
    const Path& moveTo(const CGPoint p) const
        カレントポイント
    
    const Path& lineTo(CGFloat x,CGFloat y) const 
    const Path& lineTo( const CGPoint& p) const
        直線を描画
    
    const Path& addCurveToPoint(CGFloat cp1x,CGFloat cp1y,CGFloat cp2x,CGFloat cp2y,CGFloat x,CGFloat y) const
    const Path& addCurveToPoint(CGPoint cp1,CGPoint cp2,CGPoint p) const 
    const Path& addQuadCurveToPoint(CGFloat cp1x,CGFloat cp1y,CGFloat x,CGFloat y) const
    const Path& addQuadCurveToPoint(CGPoint cp1,CGPoint p) const
        ベジェ曲線を描画
    
    const Path& addArc (CGFloat x,CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle,bool clockwise) const
    const Path& addArcToPoint(CGFloat x1,CGFloat y1,CGFloat x2,CGFloat y2,CGFloat radius) const
    const Path& addArcToPoint(const CGPoint& p1,const CGPoint& p2,CGFloat radius) const
        円弧を描画
    
    const Path& addLine(CGFloat x,CGFloat y) const
    const Path& addRect(const CGRect& rect) const
    const Path& addPath(const CGPathRef& path) const
        図形を描画
    
    CGPathRef copyPath() const
    void copyPath(MICCGPath& r) const
        CGPathRef のコピーを取得    
</details>

<details><summary>
Image    
</summary>

    CGImageRef createImage()
    bool createImage(MICCGImage& imageR)
        CGContextの内容からビットマップ(CGImageRef)を作成する
    
</details>

<details><summary>
Color
</summary>

    void setAlpha(CGFloat alpha)

    void setFillColor(CGColorRef color)
    void setFillColor(UIColor* color)
    void setFillColor(CGFloat red,CGFloat green,CGFloat blue,CGFloat alpha)
    void setFillColorCMYK(CGFloat cyan,CGFloat magenta,CGFloat yellow,CGFloat black,CGFloat alpha)

    void setStrokeColor(CGColorRef color)
    void setStrokeColor(UIColor* color)
    void setStrokeColor(CGFloat red,CGFloat green,CGFloat blue,CGFloat alpha)
    void setStrokeColorCMYK(CGFloat cyan,CGFloat magenta,CGFloat yellow,CGFloat black,CGFloat alpha)

</details>

<details><summary>
Drop-shadow
</summary>
    
    void setShadow(CGSize offset, CGFloat blur)
    void setShadow(CGSize offset, CGFloat blur, CGColorRef color)
    void disableShadow()
    
</details>

<details><summary>
Getting and Setting Graphics State Parameters
</summary>

    CGInterpolationQuality getInterpolationQuality()
    void setInterpolationQuality(CGInterpolationQuality v)
    void setFlatness(CGFloat flatness)
    void setLineCap(CGLineCap linecap)
    void setLineDash(CGFloat phase, const CGFloat lengths[], size_t count)
    void setLineJoin( CGLineJoin join)
    void setLineWidth(CGFloat width)
    void setMiterLimit(CGFloat limit)
    void setPatternPhase(CGSize phase)
    void setFillPattern(CGPatternRef pattern, const CGFloat components[])
    void setRenderingIntent(CGColorRenderingIntent intent)
    void setStrokePattern(CGPatternRef pattern, const CGFloat components[])
    void setBlendMode(CGBlendMode mode)
    void setShouldAntialias(bool shouldAntialias)
    void setAllowsAntialiasing(bool allowsAntialiasing)
    void setShouldSmoothFonts(bool shouldSmoothFonts)
    void setAllowFontSmoothing(bool allowsFontSmoothing)
    void setAllowsFontSubpixelPositioning(bool allowsFontSubpixelPositioning)
    void setAllowsFontSubpixelQuantization(bool allowsFontSubpixelQuantization)
    void setShouldSubpixelQuantizeFonts(bool shouldSubpixelQuantizeFonts)
    
</details>

<details><summary>
Painting Paths
</summary>

    void clearRect(CGRect rc)
        矩形をクリア （=透明の矩形を描画）   
    void drawPath(CGPathDrawingMode mode)
        現在のパスを与えられたモードで描画する。
        このメソッドを実行すると、現在のパスはクリアされる。
    void eofFillPath()
        drawPath(kCGPathEOFill) と等価
    void fillPath() {
        drawPath(kCGPathFill) と等価
    void strokePath() {
        drawPath(kCGPathStroke) と等価    
    void fillRect(CGRect rc)
        矩形を fill color で塗りつぶす
    void fillRects(const CGRect rects[], size_t count)
        複数の矩形を塗りつぶす
    void fillEllipseInRect(CGRect rc)
        矩形に内接する楕円を塗りつぶす
    void strokeRect(CGRect rc)
        現在のline-width/stroke-colorで矩形を描画
    void strokeRect(CGRect rc, CGFloat width)
        指定された線幅と、現在のstroke-colorで矩形を描画（line-widthは無視）
    void strokeEllipseInRect(CGRect rc)
        現在のline-width/stroke-colorで楕円を描画
    void strokeLineSegments(const CGPoint points[], size_t count)
        polyline 描画

</details>

<details><summary>
Drawing Text
</summary>

Core Text によるテキスト描画は、まじめに扱ったことがありません。

    CGPoint getTextPosition()
    void setTextPosition(CGPoint pos)
        テキスト描画位置

    void setFont(CGFontRef font)
    void setFontSize(CGFloat size)
        フォント    
    
    void setCharacterSpacing(CGFloat spacing)
        字間

    void setTextDrawingMode(CGTextDrawingMode mode)
        テキスト描画モード

</details>

<details><summary>
Affine transformation
</summary>
    
    void rotate(CGFloat angle)
    void rotate(CGFloat angle, CGPoint origin) 
        回転
    
    void translate(CGFloat x, CGFloat y)
        平行移動

    void scale(CGFloat sx, CGFloat sy)
        拡大・縮小

</details>

## MICCGImageContext

UIGraphicsBeginImageContext() または、UIGraphicsBeginImageContextWithOptions()で取得されるコンテキストを保持するクラス。(MICCGContextから派生)

<details><summary>
メソッド
</summary>

    MICCGImageContext(const CGSize& size) : MICCGContext(false)
    MICCGImageContext(const CGSize& size, BOOL opaque, CGFloat scale) : MICCGContext(false)
        CGImageContextを開始（デストラクタで終了）

    UIImage* getCurrentImage()
        コンテキストからUIImageを取り出す。

</details>

## MICCGBitmapContext

CGBitmapContextCreate() で作成されるコンテキストを保持するクラス。(MICCGContextから派生)
デストラクタで release される。

## MICCGGStateStack

CGContext に対する CGContextSaveGState / CGContextRestoreGState をスタック風に操作できるようにして、スコープを抜けるときに、忘れずRestoreされるようにするヘルパークラス。

<details><summary>
メソッド
</summary>

    MICCGGStateStack(const CGContextRef& ctx, bool initialPush=true)
        initialPush==true なら、コンストラクタ実行時に、push()する。
    ~MICCGGStateStack()
        popAll()する
    void push()
        CGContextSaveGState()を呼び出す
    void pop()
        CGContextRestoreGState（）を呼び出す
    void popAll() 

</details>

## MICCGAffinTransform

CGAffinTransformの構築をサポートするビルダークラス

<details><summary>
メソッド
</summary>

    MICCGAffinTransform()
    MICCGAffinTransform(const CGAffineTransform& src)
        コンストラクタ
    
    void copyFrom(const CGAffineTransform& src)
        CGAffineTransformをコピー

    MICCGAffinTransform& scale(CGFloat scaleX, CGFloat scaleY)
    MICCGAffinTransform& rotate(CGFloat rotate)
    MICCGAffinTransform& transrate(CGFloat x, CGFloat y)
    MICCGAffinTransform& invert()
    MICCGAffinTransform& concat(const CGAffineTransform& src)
        アフィン変換操作

    operator CGAffineTransform()
    operator CGAffineTransform*()
        変換オペレータ
    
    bool operator == (const CGAffineTransform& src)
    bool operator != (const CGAffineTransform& src)
        等価比較

</details>
