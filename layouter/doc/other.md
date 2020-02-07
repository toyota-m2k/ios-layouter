# その他の小物たち

## MICVar.h

個人的に、
```
HogeHogeFugaFuga t = [HogeHogeFugaFuga new]; // obj-c
HogeHogeFugaFuga t = new HogeHogeFugaFuga(); // Java
```
のようなコードが見苦しくて嫌いです。代入式の右側に型名を書いてあるんだから、
```
var t = new HogeHogeFugaFuga();     // C#
val t = HogeHogeFugaFuga()　        // Kotlin
```
でいいじゃない。Objective-C でも、できるだけ、こういうぐあいに記述できるようにするのが、このヘッダ。
何をしているか、は、一目瞭然。
```
#define var __auto_type
#define let __auto_type const
#ifdef __I_LIKE_KOTLIN__
#define val __auto_type const
#endif
```

基本は、Swift 風に、var, let で変数を宣言するが、__I_LIKE_KOTLIN__をdefineすれば、let の同義語として、Kotlin風の val も使えるようになる！


## MICTargetSelector

イベントハンドラなどを実装したいとき、C# でも、Kotlinでも、デリゲートとかラムダ式のような関数オブジェクトが指定できて、簡単に呼び出せるけど、iOSでは、同様の目的に使う、「ターゲットオブジェクト（id）+ セレクタ－」の呼び出しが、やたらと面倒くさい。このクラスは、そこのあたりをラップして使いやすくする。

```
// Target+Selector=MICTargetSelector
let ts = [MICTargetSelector targetSelector:self @selector(callMe)];
...
// 呼び出す（引数無しの場合）
[ts perform];
```
## MICListeners

MICTargetSelector の配列。
setListenerではなく、addListenr をサポートするためのクラス。
fire メソッドで、すべてのtarget/selectorを呼び出すことが可能。

## MICKeyValueObserver

Key/Value Observer は、任意のオブジェクトのプロパティの変化を監視できる、他のOSでは、あまり見かけない、iOS固有の強力な仕組みだが、これも、使うのが、とても面倒。特に、プロパティが変更されたことを受け取るハンドラを id+selectorとかではなく、
observeValueForKeyPath:ofObject:change:context: という決められたメソッドとして、オブザーバー側に用意しなければならない、という仕様が、どうも気持ち悪い。これを、普通のid+selector でイベントを受け取れるようにするのが、MICKeyValueObserverクラス。最後に、disposeを呼び出して、オブザーバーの登録を解除(removeObserver)するのを忘れずに。

```
// Observerを作成
let observer = [[MICKeyValueObserver alloc] initWithActor:someView];
// viewのサイズ変更を検出するため、frame, boundsを監視する
[observer add:@"frame" listener:self handler:@selector(sizeChanged:target:)];
[observer add:@"bounds" listener:self handler:@selector(sizeChanged:target:)];
...
/// 監視終了（オブザーバーを破棄）
[observer dispose];
```

## MICAutoResetEvent / MICManualResetEvent

それぞれ、.NET の [AutoResetEvent](https://docs.microsoft.com/ja-jp/dotnet/api/system.threading.autoresetevent?view=netframework-4.8), [ManualResetEvent](https://docs.microsoft.com/ja-jp/dotnet/api/system.threading.manualresetevent?view=netframework-4.8) に相当する同期オブジェクト。

次の例では、2つのスレッドを起動して、片方のスレッドが「処理１」を終えてから、もう片方のスレッドで、「処理２」を行う。

```
let event = [[MICManualResetEvent alloc] init];
[MICAsync.executor execute:^{
    ... 処理１
    [event set];
}];

[MICAsync.executor execute:^{
    [event waitOne];
    ... 処理２
}];
```

## MICSortedArray

C#の SortedList のようなもの。addElement していくだけで、自動的にソートされた配列が出来上がる。
NSMutableArray を継承したかったが、思ったより面倒くさそうだったので、NSMutableArrayを内包し、必要に応じて、NSArrayとして取り出せるようにした。

## MICQueue

enque, deque メソッドを持つ、Queue 型コレクション。たぶん、誰もが、１度は作ったことがあると思う。
なら、Stackもあるかというと、なぜか作っていない。。。これまでのObj-Cライフにおいて必要になったことがない、または、素のMutableArrayで簡単に代用できた、ということ？

## MICString (C++)

NSString を MFC の CString的に扱えるようにしたC++クラス。（微妙）

## MICStringBuffer (C++)

NSMutableString を、StringBuffer (or StringBuilder) 風に扱えるようにしたC++クラス。（これも微妙）
