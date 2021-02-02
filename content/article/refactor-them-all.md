---
title: "精度向上のために機械学習プロダクト全体をフルスクラッチで書き直した話"
date: 2021-01-24T14:58:15+09:00
draft: false
---

![](/img/refactoring-them-all_2.png)

2020年7月から医療スタートアップの[Ubie](https://ubie.life/)で機械学習エンジニアをしています。ようやく入社から半年くらいが経ちましたので、ここ最近やっていた仕事として、**機械学習プロダクトの精度向上のためにシステム全体をフルスクラッチでかつ一人で実装し直した話**をしたいと思います。

機械学習は既に様々な会社でプロダクトに組み込まれ始めていると思いますが、サービスとしてのリリースや長期運用、そして今回お話する継続的な精度向上とリファクタリングについては、公開されている知見はまだまだ少ないと思います。もし同じような境遇の機械学習エンジニアの方への参考になれば幸いです。

## tl;dr

- **精度向上のために、機械学習プロダクト全体をフルスクラッチで書き直した**
- **開発スピードを上げるためには、既存のコードを流用するより新規で書き直すほうが良いような特殊な状況だった**
- **機械学習タスクの実装は、可視化やテストなどを活用しつつ小さく積み上げていくことが大事**

---

## はじまり
私が取り組んでいた機械学習プロダクトは、**ドキュメントの画像をOCRしてテキスト中から情報を抽出する**というサービスでした。画像処理と自然言語処理の領域が入り混じった、なかなかに複雑なタスクです。サービス全体はWebAPIとして実装されており、クラウド上の画像のURLがリクエストとして来ると、画像を読み込んで前処理、OCRに投げて文字を抽出、文字列とその座標位置からいい感じに情報抽出をして、最後に構造化した情報をレスポンスとして返すという構造でした。

今回お話するロジックとは、この中の情報抽出の部分を指します。機械学習プロダクトとしての精度は悪くありませんでしたが、まだまだ精度向上や機能開発の可能性がありました。

## 精度向上への課題
さて、そのようなプロダクトの精度向上を任されのですが、じゃあKaggleみたいに様々な機械学習モデルを駆使してテストセットの精度を上げていくぜ！となるかというと、そういう話ではありませんでした。よくある機械学習タスクに持ち込めない理由として、具体的には以下のようなものがありました。

- **複数の機械学習タスクが存在し、それらに依存関係がある**
  - 前段のOCRによる文字検出の結果が、後段の自然言語処理による情報抽出に強く影響する
  - OCRで大きく間違えると、そもそも情報抽出の方ではどうしようもできない
- **一部のタスクはブラックボックスになっている**
  - OCRは自作しているわけではないため、ブラックボックスとして扱わざるを得ない
  - システム全体で単一のロス関数を設定してそれを下げるみたいなEnd-to-Endなアプローチが難しい
- **教師データがそもそも少ない**
  - ドメインの性質上、学習データを大量に作ることが容易ではないため、使えるデータが少ない&増やせない
  - 情報抽出の固有表現はバリエーションが非常に多く、全部を網羅するようなデータ集合を作ることは不可能 (分類タスク的に解こうとするとExtreme Multi-label Classificationみたいな設定)

そのため、実際のシステムはディープラーニングでEnd-to-Endに推論するわけではなく、かなり泥臭い方法でロジックを組み立てていき、細かな微調整を繰り返しながら地道に精度を上げていくという感じでした。ディープラーニングが流行る前の、古き良き特徴量エンジニアリング時代の機械学習という感じですね。私が入社した時点ではそういった作業はある程度進んでいる状態でしたので、既存のロジック自体はかなり複雑かつ大きなものになっていました。短期的に精度向上する余地は、未知のパターンに対応したり、辞書を拡充したりといったことくらいでした。

この時点では、**見えていた課題に対してこうアプローチすれば精度が改善する！という見立ては立てられていたものの、その手法は既存ロジックを拡張する形では実現できず、わりと根本からのロジックの修正が必要**でした。実装の見通しも立っていなかったため、それに手を付けられないまま、細かな修正で少しずつ精度を上げることしかできていませんでした。いわゆる局所最適の谷に嵌っていた感じです。ちなみに他の精度向上施策として一時期はOCR自作も考えましたが、あまりにもRoIのInvestmentが大きいという理由で却下しています。

## フルスクラッチで書き換える決意

大きな精度向上のために残された道としては既存ロジックを新しく置き換えるくらいでしたので、ある程度やり尽くした時点でやると決断します。この時に今回の記事の主題である、**既存のコードベースはほぼ使わずにシステム全体をフルスクラッチで作ろう**と判断しました。

ではなぜ既存のコードベースを活かしつつ該当する箇所だけ置き換えなかったのか？ですが、その理由としては

**「開発スピードを上げるため」**

これに尽きます。

精度向上を山登りに例えるならば、今登っている登山道を登り続けるよりも、一旦下山して別のルートから頂上にアタックするほうが最終的に頂上に着くのが早いと判断しました。

この時期にちょうど[「レガシーコードからの脱却」](https://www.oreilly.co.jp/books/9784873118864/)[「リファクタリング」](https://www.ohmsha.co.jp/book/9784274224546/)といった本を読んでいたのですが、そこに書かれているアドバイスとしては「レガシーコードのフルスクラッチでの書き換えはやめろ」でした。先人がそうした警鐘を鳴らすなかで、この決定は自分でもかなり葛藤がありました。今でも多くのケースでは、フルスクラッチでの書き換えは悪手だと私は思っています。今回のケースではデメリットを上回るメリットがあると思い、このように決意しました。

![](/img/refactoring-them-all_3.png)

## 開発スピードが落ちる理由
フルスクラッチで書き換える理由は開発スピードを上げるためと書きましたが、その理由としては大きく2つあります。

1. 画像処理 × 自然言語処理というタスクの難しさ
2. 既存システムの問題

### 1. 画像処理 × 自然言語処理という難しさ
まず何より今回のシステムが、通常のシステム開発や機械学習タスクと比較して特殊だったということがあります。画像をOCRしてテキストから情報抽出するタスクですが、処理の途中でどういう値を扱うかというと、雰囲気はこんな感じです。

```python
# 画像
array([[[243, 245, 244],
        [242, 244, 243],
        [241, 243, 242],
...
        [255, 255, 255],
        [255, 255, 255],
        [255, 255, 255]]], dtype=uint8)

```

```python
# テキスト
[
    Symbol(
        text="y",
        bbox=Bbox(
            top_left=Vertices(x=128, y=20),
            bottom_right=Vertices(x=142, y=20),
        ),
    ),
    Symbol(
        text="a",
        bbox=Bbox(
            top_left=Vertices(x=143, y=20),
            bottom_right=Vertices(x=158, y=20),
        ),
    ),
    Symbol(
        text="g",
        bbox=Bbox(
            top_left=Vertices(x=159, y=21),
            bottom_right=Vertices(x=175, y=21),
        ),
    ),
]
```

デバッグコンソールで変数の中身にこれが出てきたとして、頭の中で文字が描画された画像としてイメージできるかというと、到底無理ですよね。画像の情報も活用しつテキストを扱うことは、すなわち座標と文字を行き来するということです。そのためには何かしら人間が解釈できる形での可視化が必須です。

既存のシステムが作られた初期は、おそらくiterativeに可視化をしながら作っていたので問題なかったのかもしれませんが、現在のコードベースには残念ながらそうした機能は残っておらず、動いているものに手を付けるの際に大きな障害となりました。処理の一部分を改良しようと思ったとき、どのような型かはPythonのコードから分かっても、それが画像としてどういうものだったり、他のデータと相対的にどういう関係にあるかが、即座に理解できないのです。これをいちいち手動で確認したり可視化するのは、かなりの手間と苦痛を要しました。

ちなみに、このシステムを触っていた同僚から引き継ぎがてら最初に教わったのはデバック方法で、ブレークポイントを設定した上でコンソール上でPILをimportしてnp.arrayから画像を保存するスニペットでした。この方法で処理途中の画像をファイルに保存してPreview.appで確認するのに、かなりの手間がかかります。これに座標情報が乗っかったテキストや矩形情報を描写するとなると、コードスニペットでどうこうなる話ではありません。

### 2. 既存システムの問題
開発スピードを上げられないもう一つの理由として、既存システムが抱える負債がありました。これはもう機械学習とは全く関係ないエンジニアリングの側面で、レガシーコードの話でよくあるパターンだと思います。大まかには以下のような問題がありました。

- **テストやドキュメントがほぼ書かれていない**
	- 肝心の抽出ロジックまわりに関しては皆無だった
	- ドキュメントが少なく、動いているコードやコメントから何とか振る舞いを把握する必要があった
- **システム全体が密に結合していた**
	- ロジックの動作に必須な辞書データはWebAPI起動時に読み込まれていたが、それがグローバル変数的に各所で使われており、それに依存したクラスを単体で動かすことが難しかった
	- 状態の依存が多く、特定の機能を切り出して簡単にテストが書ける状態ではなかった

こういう状態で何が起きるかというと、動いてはいるが正しい振る舞いがわからない、何か書き換えた時の挙動の変化が追えなくバグに気付けない、ロジックの微修正のたびにWebAPIをまるっと再起動しないといけない、というものでした。一部の修正でも全体を最初から最後まで動かす必要があり、最終的に出てくる結果を見ながら途中の状況を把握していく必要がありました。実際に私はこうした開発環境でバグをプロダクションにデプロイしてしまったことがあり、心が折れかけたことがあります。

ただし、私自身も大規模開発に慣れていなかったことも原因の一つとしてあります。きっとコードを書くのが上手い人なら良い感じにリファクタリングして問題を切り崩していくんだろうなと今でも思っていますし、これがもっと大きなプロダクトだったら書き直しなんて到底無理で、自分の手に負えないタスクできっと詰んでいたでしょう。

既存システムのコードに対しては色々と思うところもありましたが、責めるつもりは全くありません。何よりまずプロダクションで動き続けて顧客に対して価値を創出していたというのが、既存のコードが最も偉大でかつ尊重されるべきです。また、時間や工数などのリソースに制約がある中での開発だったことも聞いていますし、何より0→1が一番難しく大変な部分なので、その時の最善を尽くした結果だと受け止めています。このあたりは、ベンチャーあるあるかもしれないですね。


## フルスクラッチで実装していくために何をしたか
こうして開発スピードを上げるためにフルスクラッチで実装し直すことを判断したわけですが、具体的にどのように作っていったかを紹介します。

1. 小さく動くものを作る
2. サポートツールを作る
3. テストを書き、コードの質を保つ

### 1. 小さく動くものを作る
既存システムの内部で何をやってるかは理解していたので、それを細かく分割して小さく動くものを作っていきました。例えば、画像を読み込む部分、画像に特定の処理を加えるだけの部分、テキストを読み込んで何かしらの結果を返す部分といったように、それ単体で動いてテストできる状態を維持し、それを積み上げていくようにしました。

精度向上のロジック以外のコードもすべて自作することになりましたが、中間データをキャッシュして処理を高速化したり、既存のコードよりも良い処理を考えつくこともありました。また、精度に関連する部分以外のコンポーネントを色々と作ることができたのも良かったと思います。例えば、開発途中でデータのアノテーションツールを自作する必要があったのですが、すでにデータ構造や汎用的な関数などを作っていたので、高速に実装することができました。

### 2. サポートツールを作る
先ほども説明したように、画像処理と自然言語処理を行き来するには可視化ツールが不可欠です。私の場合は、[streamlit](https://www.streamlit.io/)というパッケージで可視化ツールを作成し、今どういう状態なのかを都度確認できるようにしました。

![](/img/refactoring-them-all_1.png)

(Visualizationの部分は、後ろの画像を白く塗りつぶしています)

こうした可視化ツールで、開発の見通しが立てやすくなりました。画像処理は特に高さや幅などの座標操作でバグを生みやすいので、デバッグを意識しなくともそうした間違いにすぐ気づくことができる点も、可視化ツールの良いところです。


### 3. テストを書き、コードの質を保つ
今回はとにかく初期からテストをきちんと書くように心がけました。データ処理がメインだとTDDのようなアプローチは難しい場面もありますが、なるべくテスト可能な単位に切り分けてそれぞれテストしていきました。テストにデータが必要な場面では、疑似画像や機械学習の推論結果をレポジトリに入れておいて、テスト時に読み込んで使っています。

また、テストで意図した挙動かをチェックし続けるとともに、コードの質を保つような仕組みも整備しました。pytest, black, isort, mypyといったテストツールや各種フォーマッタ、型チェックでコード全体をチェックするようにしています。

## フルスクラッチ実装のメリット/デメリット
この経験を踏まえて、フルスクラッチ実装の良かった面と悪かった面を振り返ってみます。

### メリット: 強くてニューゲームできる
実装の仕様や方針は明らかなので、とにかくゴリゴリ開発を進められます。目の前には実装すべき機能リストが山積みなので、それを一つずつ切り崩すことだけに注力すれば良いのです。また、既存システムでの欠点や負債も知っているので、それを踏まえて設計することもできました。

具体的な話としては、例えば画像処理で扱う座標関連の各オブジェクトの表記を統一しました。例えばxy座標の任意の1点を表すときに、`(10,20)`とかではなく`Vertices(x=10, y=20)`とすることで、x座標を取得するときには`point[0]`ではなく`point.x`と書けます。文字の位置座標や領域を表す矩形の各点は、すべて`Vertices`クラスで表現しています。

```
@dataclass
class Vertices:
    x: int
    y: int
```

こういうことがとにかく大事なのは、座標としての点というのは、文字の中心を表す点、文字の領域を4つの頂点で表す矩形、文字の集合を表すときの頂点の集合など、様々なクラスや関数で登場するからです。

普通のエンジニアから見るとバカバカしいくらい当たり前のような話ですが、これがOpenCVやPILのような画像処理ライブラリなどを駆使すると、返ってくる値やフォーマットが多種多様で崩れがちになるのです。これらを使ったことがない人は想像できないと思いますが、ライブラリによって画像の幅と高さの順番が違っていたり、RGBの色の順番が違っていたり、矩形の表し方が異なっていたりと、画像処理には闇が広がっています。深淵を覗きたい人はぜひ検索してみてください。こうしたI/Fの統一を矩形だったり文字にきちんと適用していくことで、例えば矩形の集合を囲む外接矩形を求めたり、特定の領域の文字をマージして一つの単語を作ったり、複雑な処理にも耐えうるコードになりました。

### デメリット: 時間が溶ける
いくら強くてニューゲームなったとして、全部書き直すのにはそれ相応の時間がかかります。再実装といえども、写経とは違ってアーキテクチャの設計やリファクタリングも同時に行っていくので、考えたり試行錯誤する時間も必要です。時間がかかるだけならまだいいのですが、 **「いまから数ヶ月はシステムの再実装をするので、精度向上の進捗は出ません」** と言ってPO (Product Owner) やチームを説得し工数を確保するのは一筋縄ではいきません。しかも精度向上というタスクの性質上、再実装したからといって精度が必ずあがるわけではなく、もしかしたら自分が思い描いているやり方では既存手法を超えられないこともありえます。必ずしも良い結果が出るわけではないというのが、機械学習プロジェクトの難しいところです。

でもフルスクラッチで再実装したい……！となると、やれることは一つ。**裏でこっそり進めるしかありません** 。20%ルールや仕事の細切れの時間だったり、場合によってはプライベートの時間を使ってある程度形になるところまで進めておき、行けるとわかった時点でそれを公開して周囲の同意を得るという方法です。不確実性を取り除くには、モノを作って示す以外にありません。

私の場合は、精度向上できそうとわかるまで1ヶ月半ほどサブタスクとして進めました。車輪の再発明は勉強にもなるし良いかと開き直りながらやっていましたが、メインの仕事があるなかで先が見えないままコードを書くのは、なかなか大変でした。それでもやり切ったのは、リファクタリングに対する苦手意識や理想のコードを作り上げたいという思いだったり、自分でもこの規模のプロダクトを1から作れるということを自分で証明したかったからかもしれません。自分で書き直してそれでも駄目ならコードはお蔵入りと割り切っていたものの、きちんと結果に繋がってよかったと思います。

ただし、そうして時間をつぎ込んで再実装したコードも、数ヶ月、数年経った時には、新しい技術的負債になっていることでしょう。現時点でも実装したコードの[バス係数](https://en.wikipedia.org/wiki/Bus_factor)はほぼ1ですし、いかに長期的かつ多人数で開発が継続できるかが直近の問題でもあります。

---

## まとめ
この記事では、機械学習システムの精度向上のために、あえて一からフルスクラッチで書き直した経験を紹介しました。あまり参考にならないケースかもしれないですが、今回の教訓として、機械学習プロダクトの保守や改善には以下のような視点を持つと良いと思います。

- フルスクラッチでの再実装は、最後の手段として取っておこう
- 開発スピードを上げるためにやれることをやろう
- 長期的に考えて意味のあることを、継続できる形でやり続けよう

機械学習プロダクト、頑張って保守しながらより良いものにしていきましょう！


## 最後に   
[Ubie](https://ubie.life/)では、ウェブ開発や機械学習のエンジニアを募集しています。やることがたくさんありすぎて全然手が足りていないので、医療ドメインやスタートアップのプロダクト開発などに興味がある方はぜひお声がけください。カジュアル面談も実施しておりますので、話を聞いてみたいという方でも構いません。下記の採用サイトもしくはTwitterで[@yag_ays](https://twitter.com/yag_ays)にDMしていただければと思います。お待ちしております🙌

- [Ubie Dev 組織 採用サイト | トップ](https://recruit.ubie.life/)

<iframe class="note-embed" src="https://note.com/embed/notes/n454a0d04a1eb" style="border: 0; display: block; max-width: 99%; width: 494px; padding: 0px; margin: 10px 0px; position: static; visibility: visible;" height="400"></iframe><script async src="https://note.com/scripts/embed.js" charset="utf-8"></script>