# SVG Path

iOS + Objective-Cでは、SVG Path の描画ができないっぽい。Android も Windowsも、アイコンに SVG を使ってリソースを共通化しているのに、iOSだけ別にPNGやPDF(?!)で用意するとか、ちょっとあり得ないので、SVGを描画できるようにしてみた。

    layouter/ut/
        MICSvgPath
        MICPathRepository

## MICSvgPath

&lt;svg&gt; タグの d 属性（xamlでいうと&lt;Path&gt;タグの data属性、Androidのdrawableでいうと、vector内の &lt;path&gt; タグのpathData属性）文字列から　CGPathを生成し、CGContextに描画するクラス。

### プロパティ

    CGPathRef cgpath;
        このオブジェクトが保持しているCGPathを取得。
        管理主体はMICSvgPathなので、CGPathRelease()してはいけない。

    NSString* pathString;
        パスの構築に使用したパス命令文字列　（SVGの d 属性）

### 構築
    + (MICSvgPath) pathWithViewboxSize:(CGSize)size
                            pathString:(NSString*)pathString;
        
        パス文字列とviewboxサイズから、MICSvgPathオブジェクトを生成する。

### 描画

    - (void)   draw:(CGContextRef) rctx 
            dstRect:(CGRect) dstRect 
          fillColor:(UIColor*)fillColor 
             stroke:(UIColor*)strokeColor 
        strokeWidth:(CGFloat)strokeWidth;

        色を指定して、CGContext上の dstRectに描画する。
    
    - (void) fill:(CGContextRef) rctx 
          dstRect:(CGRect) dstRect 
        fillColor:(UIColor*)fillColor;
        
        色を指定して、CGContext上の dstRectに塗る。

    - (void)     stroke:(CGContextRef) rctx 
                dstRect:(CGRect) dstRect 
            strokeColor:(UIColor*)strokeColor 
            strokeWidth:(CGFloat)strokeWidth;
        
        色,線幅を指定して、CGContext上の dstRectに線を描く。

### リソース切り離し

    - (CGPathRef) detachCGPath;
        
        このオブジェクトが保持しているCGPathをオブジェクトから切り離して取得する。
        管理主体は呼び出し元に移るので、不要になれば、CGPathRelease()すること。

## MICPathRepository

リスト内のチェックマークなど、同じアイコンを繰り返して使う場合、一つずつ SVGPath インスタンスを作成するのはもったいない。このような場合に、SVGPathをキャッシュしておく仕掛けが、これ。

### インスタンス取得

    + (MICPathRepository) instance
        シングルトンインスタンスを取得

### リソースの取得と解放
    - (MICSvgPath*) getPath:(NSString*)pathString viewboxSize:(CGSize)size
        SVGパス文字列と、viewboxサイズを渡してSvgPathインスタンスを取得。
        キャッシュに存在しなければ、新たに作成し、キャッシュに登録して返す。

    - (void) releasePath:(MICSvgPath*)path;
        getPath:: で取得したSvgPathを解放する。個々のSvgPathは参照カウンタを持っており、
        参照されなくなると、自動的に解放される。
