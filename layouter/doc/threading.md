# 非同期API・マルチスレッド

iOSの非同期APIは、メソッド呼び出し＋完了コールバックという、原始的な仕掛けで動くので、所謂、コールバック地獄に陥ると、可読性が著しく低下します。C#の　async/await や、Kotlinの coroutineのような仕掛けが欲しいです。そこまでは無理としても、JavaScriptのPromiseライクにコードが書けたら、ずいぶん、綺麗なコードが書けそうです。


## Promise --> Acom --> Aiful　：背景と経緯

まず最初に、Promiseっぽい記述ができる、非常に簡単なMICPromise というクラスを作りました。
このMICPromisteは、タスクチェーンを定義するだけで、実行するスレッドの管理は、タスクに委ねるという、とてもいい加減な作りだったため、慎重にコーディングしないと、メインスレッドをブロックしてしまい、具合が悪く、そのあたりをちゃんとするために、
改良版の　MICAcom クラスを作りました。しばらくは、MICPromiseとMICAcomが共存していましたが、現在は、MICAcomに一本化しています。（MICPromiseは、id<IMICAcom>のエイリアスとして、メソッドの戻り値の型として痕跡が残っています。）
ちなみに、MICAcomは、Objective-C だけで、なんとか、Promise風の記述ができるように工夫した実装ですが、C++を使えば、もう少し、綺麗に書けるよね、というのが　MICAiful クラスです。

### 主要なクラス

- MICAcom

    タスクチェーンを構築し、それをサブスレッドで逐次実行するエンジン。

- MICAiful

    MICAcomをラップする、C++クラス。MICAcomを直接操作するより、少しだけ楽。

- MICPromise

    MICAcomが扱う「実行可能なタスク」を表現するインターフェースで、executeメソッドだけを持っている。
    id<IMICAcom> のエイリアス(typedef)。
    
- MICAwaiter

    サブスレッドの待ち合わせを行うためのインターフェース。
    id<IMICAwaiter> のエイリアス(typedef)。

- MICExecutor

    iOSでスレッドを起こしたいと思ったとき、NSOperationQueue　とか、dispatch_queue_t　とか、NSThread　とか、いったい、どれを使えばいいの？？？ってなりました。これらの中から、使いたい方法を簡単に選択し、且つ統一的な方法で扱えるようにしました。デフォルトは、GCD (dispatch_queue_create) です。
  

### 使い方

#### Promistic な API

- MICPromise then(MICPromise (^action)(id chainedResult))

    action を実行するPromiseノードを生成してタスクチェーンに追加する。
    JSのthenと同様、このノードは、一つ前のPromiseノードが成功した(MICAcom.resolveを返した)ときに実行される。

- MICPromise then_(void ^(action)(id chainedResult, MICAcomix acomix))

    前述の then()と同様だが、このactionは、MICPromiseを返す代わりに、acomix引数に対して、resolve または、reject メソッドを呼び出すことで、このノードの処理を終了して、次のノードに処理を移す。
    MICAcomix は、.NET の、TaskCompletionSource、Kotlinの、suspendCoroutineで使う、Continuation のような役割と考えればよいかと。「コールバック型APIをMICAcomタスクチェーンに取り込む」参照。

- MICPromise ignore(MICPromise (^action)(id chainedResult))

    actionが返すMICPromiseの成功/失敗に関わらず、必ず、Resolved するノードを作成する。
    処理が失敗しても、Promiseチェーンの実行を継続する必要がある場合に使用する。
    後述の anyway に似ているが、こちらは、chainedResult を引き渡して、続きのPromiseチェーンに処理を渡していく点が異なる。

- MICPromise failed(void (^action)(id error))

    actionが失敗したときに実行されるPromiseノードを生成してタスクチェーンに追加する。
    JSのPromiseでは、catch だが、catchは予約後のため、定義できないので、failedという名前にしている。

- MICPromise anyway(void (^action)(id param))

    actionの成功、失敗に関わらず実行されるPromiseノードを生成してタスクチェーンに追加する。
    JSのPromiseでは、finally に相当。これも予約語のため、anyway という名前で定義。

- MICPromise all((NSArray&lt;MICPromise>* tasks)

    tasks で与えられた １つ以上のPromiseチェーンをパラレルに実行するPromiseノードを作成しする。
    このノードに着火すると、すべてのPromiseチェーンを同時に実行し、すべてのチェーンの実行が完了するまで待機する。
    そして、すべてが成功した場合には成功(Resolved)、１つでも失敗したらエラー(Rejected)として扱う。
    次のthenノードのchainedResult には、個々のPromiseチェーンの結果（chainedResult)の配列、
    failedノードには、chainedResultまたはerrorの配列が渡される。

    注意
    Promiseチェーン毎にスレッドを起こすので、大量にぶっこむとマズいかもしれない。後述の seq で代用できるなら、その方がよいケースが多いと思われる。

- MICPromise race((NSArray&lt;MICPromise>* tasks)

    tasks で与えられた １つ以上のPromiseチェーンをパラレルに実行するPromiseノードを作成しする。
    このノードに着火すると、すべてのPromiseチェーンを同時に実行し、１つでも成功したら、その時点で、そのchainedResultを次のthenブロックに渡す。
    すべて失敗すると、最後のerror を、次の failedノードに渡す。

    注意
    最初の１つのPromiseチェーンが成功しても、残りのタスクが中止されるわけではない。つまり、結果が捨てられるのに、処理が続く。JSのPromiseにraceというのがあったから真似したが、（少なくともクライアントのプログラムで）これが必要になるケースを思いつかないし、使ったことがない。

- MICPromise seq((NSArray&lt;MICPromise>* tasks)

    tasks で与えられた １つ以上のPromiseチェーンをシーケンシャルに実行するPromiseノードを作成しする。
    普通に、then()でノードを足していくのと結果は同じだが、動的に複数のPromiseチェーンが生成される場合に対応するために、このメソッドを用意した。
    all() ではスレッドが走りすぎて問題を起こしそうな場合の代用としても利用。



#### 終了を待たない呼び出し（やりっぱなし型呼び出し）

MICAiful でタスクチェーンを作り、BEGIN_AIFUL_LAUNCH/END_AIFUL マクロで囲みます。このタスクチェーンは、サブスレッドで実行され、その完了を待たずに処理を返します。ちなみに、*_LAUNCH は、kotlin の coroutine の launch をリスペクトして命名。

```
    BEGIN_AIFUL_LAUNCH
        MICAiful()
        .then(^MICPromise (id chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            return MICAcomRESOLVE(@(1));
        }).then(^MICPromise (id chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            let v = MPSV_INT(chainedResult);
            return MICAcomRESOLVE(@(v+1));
        }).then(^MICPromise (id chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            let v = MPSV_INT(chainedResult);
            return MICAcomRESOLVE(@(v+2));
        }).failed(^(id error) {
            // thenブロックで例外が発生したとき、
            // または、MICAcomREJECT(error)をリターンしたときに、このブロックに入ります。
        }).anyway(^(id param) {
            // resolve/rejectにかかわらず、必ず実行されます。
        })
    END_AIFUL
```
ちなみに、BEGIN_AIFUL_LAUNCHマクロは、MICAiful::launch() を呼び出すだけ、MICAiful::launchは、MICAcom#launchを呼び出すだけです。直接、MICAifulやMICAcomのlaunchメソッドを呼び出しても良いのですが、非同期処理の実行範囲を明示するため、このマクロを使ってアピールすることにしています。

#### 終了の待ち合わせが可能な非同期呼び出し

MICAiful でタスクチェーンを作り、BEGIN_AIFUL_ASYNC/END_AIFUL マクロで囲みます。これにより、このタスクチェーンをサブスレッドで実行するとともに、その完了を待ち合わせるための、MICAwaiter インスタンスを返します。このMICAwaiterに対して、await メソッドを呼び出すことで、結果が取得できるまで待機しますが、この待ち合わせは、スレッドをブロックするので、必ず、サブスレッドで実行します。もちろん、この *_ASYNC も、kotlin の async から。

```
    let awaiter = BEGIN_AIFUL_ASYNC
        MICAiful()
        .then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            return MICAcomRESOLVE(@(1));
        }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            let v = MPSV_INT(chainedResult);
            return MICAcomRESOLVE(@(v+1));
        }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            let v = MPSV_INT(chainedResult);
            return MICAcomRESOLVE(@(v+2));
        }).then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            [NSThread sleepForTimeInterval:0.2];
            return MICAcomRESOLVE(chainedResult);
        })
    END_AIFUL
    
    // 待ち合わせ（必ずサブスレッドで実行
    __block int value = -1;    
    [MICAsync.executor execute:^{
        let r = awaiter.await;
        if(r.error==nil) {
            value = MPSV_INT(r.result);
        } else {
            value = 0;
        }
    }];
```

### コールバック型APIをMICAcomタスクチェーンに取り込む

タスクチェーン構築時に、.then()の代わりに._then()を使用します。この _thenブロックは、引数として渡される　MICAcomix 型引数に対して、resolveまたは、rejectメソッドを呼び出すまで待機します。

```
/**
 * サブスレッドで重い処理を実行し、完了したら、completedコールバックを呼び出す、よくある形のメソッド
 */
- (void) someFunc:(void(^)(NSInteger result)) completed {
    [MICAsync.executor execute:^{
        // 時間がかかる処理
        [NSThread sleepForTimeInterval:0.2];
        completed(1);
    }];
}

/**
 * MICAcomで使用可能な MICPromiseを返すメソッドに変換する
 */
- (MICPromise) promisticSomeFunc {
    return MICAiful()
    .then_(^(id  chainedResult, MICAcomix promix) {
        [self someFunc:^(NSInteger result) {
            promix.resolve(@(result));
        }];
    });
}

```



