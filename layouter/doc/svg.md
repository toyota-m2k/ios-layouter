# SVG Path

iOS + Objective-Cでは、SVG Path の描画ができないっぽい。Android も Windowsも、アイコンに SVG を使ってリソースを共通化しているのに、iOSだけ別にPNGやPDF(?!)で用意するとか、ちょっとあり得ないので、SVG　Pathを描画できるようにしてみた。

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
        例えば、

        <svg style="width:24px;height:24px" viewBox="0 0 24 24">
            <path fill="#000000" 
            d="M20,14H4V10H20" />
        </svg>        

        というSVGからMICSvgPathを生成する場合は、
        [MICSvgPath pathWithViewboxSize:MICSize(24) pathString: @"M20,14H4V10H20"];
        となる。

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

#### (1) グローバルインスタンス
アプリ起動中、ずっと生息しているので、releasePath されなかったパスは、いつまでもメモリ上に保持していることになるので注意。繰り返し、頻繁に使うアイコンに限定して使うことを想定。

    + (MICPathRepository*) instance
        シングルトンインスタンスを取得
#### (2) ローカルインスタンス
ダイアログ内など、限定的なスコープで利用する場合のリポジトリ。個々のリポジトリは独立しており、リソースの生存期間が、リポジトリインスタンスの生存期間と一致するので、取得したリポジトリインスタンスが適切に解放される限り、releasePathを呼び出す必要はない。

    + (MICPathRepository*) localInstance

### リソースの取得と解放
    - (MICSvgPath*) getPath:(NSString*)pathString viewboxSize:(CGSize)size
        SVGパス文字列と、viewboxサイズを渡してSvgPathインスタンスを取得。
        キャッシュに存在しなければ、新たに作成し、キャッシュに登録して返す。

    - (void) releasePath:(MICSvgPath*)path;
        getPath:: で取得したSvgPathを解放する。個々のSvgPathは参照カウンタを持っており、
        参照されなくなると、自動的に解放される。

## 使い方

### MICSvgPathインスタンスの生成と描画

~~~
#import "MICSvgPath.h"
#import "MICRectUtil.h"     // for MICSize
#import "MICCGContext.h"    // for MICCGContext

// SVG Path
#define SVG_PATH_ARROW = @"M8.59,16.58L13.17,12L8.59,7.41L10,6L16,12L10,18L8.59,16.58Z"

// SvgPathインスタンスを作成
MICSvgPath* svgPath = [MICSvgPath pathWithViewboxSize:MICSize(24) pathString:SVG_PATH_ARROW];

// MICSvgPathの描画　(UIView#drawRect などで)
- (void)drawRect:(CGRect)rect {
    MICCGContext ctx;
    // 塗りつぶし
    [svgPath fill:rctx dstRect:rect fillColor:self.currentIconColor];
}
~~~

### MICPathRepositoryの利用

直接MICSvgPathを生成する代わりに、MICPathRepository#getPath:viewboxSize: を使用する。
通常、SvgPathを利用する複数のビューを含む親ビューのイニシャライザなどで、getPathして、deallocなどのタイミングで、releasePathする。

~~~
#import "MICPathRepository.h"

// SVG Path
#define SVG_PATH_ARROW = @"M8.59,16.58L13.17,12L8.59,7.41L10,6L16,12L10,18L8.59,16.58Z"

// リポジトリからPathインスタンスを取得（なければ自動的に生成される）
MICSvgPath* svgPath = [MICPathRepository.instance getPath:SVG_PATH_ARROW viewboxSize:MICSize(24)];

// 解放
[MICPathRepository.instance releasePath:svgPath];
~~~
