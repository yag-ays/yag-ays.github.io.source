---
title: "fasttextを用いた言語判定"
date: 2019-04-21T03:45:17+09:00
draft: false
---

![https://www.pexels.com/photo/yellow-tassel-159581/](/img/fasttext_language_identification_header.png)


Facebookが提供するfasttextの[公式サイト](https://fasttext.cc)にて、fasttextを用いた言語判定モデルが公開されていたので、実際に利用してみました。

## 概要
fasttextはFacebookが公開している単語埋め込みの学習方法およびそのフレームワークです。word2vecとは違い、サブワードを利用した手法が特徴となっています。

こちらの[公式ブログの記事](https://fasttext.cc/blog/2017/10/02/blog-post.html)によると、fasttextによる言語判定は軽量でかつ高速に言語予測することができると述べられています。言語判定において広く使われる`langid.py`との評価実験では、高い精度でかつ計算時間が1/10程度であることが示されています。またモデルファイルはオリジナルのサイズでは126MB、圧縮されたモデルは917kB (0.9MB)と、既存の単語埋め込みの学習済みモデルと比較してもかなり軽量になっています。

なお「言語判定」(Language Identification)とは、与えられた文章がどの自然言語により書かれているかを判定するタスクを指します。例えば本記事に対して「日本語」(ja)であることを自動で判定するのが、言語判定です。

## 使い方
まずは公開されているモデルを実際に動かしてみましょう。
### 1. モデルのダウンロード
fasttextのモデルをダウンロードします。下記ページにて`lid.176.bin`または`lid.176.ftz`をダウンロードします。

- [Language identification · fastText](https://fasttext.cc/docs/en/language-identification.html)

### 2. fasttextのpythonバインディングをインストール

Pythonからfasttextを利用するためのPythonバインディングをインストールします。いくつかパッケージは存在しますが、[`pyfasttext`](https://github.com/vrasneur/pyfasttext)はすでにメンテナンスされていないため、ここではFacebook公式の[`fastText`](https://github.com/facebookresearch/fastText)をインストールします。

- [fastText/python at master · facebookresearch/fastText](https://github.com/facebookresearch/fastText/tree/master/python)

```sh
$ git clone https://github.com/facebookresearch/fastText.git
$ cd fastText
$ pip install .
```

### 3. モデルを読み込んで利用
さて、ようやく言語判定のモデルをロードして利用してみます。

```py
In []: from fastText import load_model

In []: model = load_model("lid.176.bin") # or lid.176.ftz

In []: model.predict('こんにちは')
Out[]: (('__label__ja',), array([1.00002694]))

In []: model.predict('你好')
Out[]: (('__label__zh',), array([0.98323345]))

In []: model.predict('hello', k=2)
Out[]: (('__label__en', '__label__fr'), array([0.24247202, 0.09511168]))
```

言語判定は上手くいっているようです。ただこのままでは`__label__`が付いていたり、予測する対象が複数の場合には出力が扱いにくいので、下記のような関数を用意してみました。

```py
def predict_language(text, model, k=1):
    label, prob = model.predict(text, k)
    return list(zip([l.replace("__label__", "") for l in label], prob))
```

`predict_language`を使うと、いい感じに出力することができました。

```py
In []: predict_language("こんにちは", model)
Out[]: [('ja', 0.9995893239974976)]

In []: predict_language("hello", model, k=2)
Out[]: [('en', 0.24247202277183533), ('fr', 0.0951116755604744)]
```

## fasttextによるモデルの詳細
さて、fasttextはどのようにモデルを作成しているのでしょうか？[公式ブログの記事](https://fasttext.cc/blog/2017/10/02/blog-post.html)に学習方法の概要が記載されていたので簡単に見てみます。

言語判定自体は、もともとfasttextが持っている教師あり学習の枠組みに沿って学習されています。ここではコマンドラインの`fasttext`を用いて学習されています。ベクトルの次元数は16、サブワードとして文字ngramが2,3,4をすべて利用しています。

学習データについては実験を再現できる形では記載されていませんが「[Wikipedia](https://www.wikipedia.org), [Tatoeba](https://tatoeba.org/eng/) and [SETimes](http://nlp.ffzg.hr/resources/corpora/setimes/)」を利用したと書かれています。合計で176言語を対象にしており、それらは[ISO 639](https://ja.wikipedia.org/wiki/ISO_639-1コード一覧)で定義されたコードが用いられています。ただしサポートされているコードを見ると2文字や3文字が混同していることから、639-1だったり639-2や639-3とバラバラのようです。

モデルを圧縮する際にはWeight quantizationが用いられており、ベクトル圧縮の際には近似最近傍探索で用いられるProduct quantizationが用いられているようです。まあこのあたりはfasttextのコマンドラインの引数から指定することが可能であり、フレームワーク内に実装されている機能です。

## 言語判定の精度
公式ブログではlangid.pyと同精度と記載されいましたが、他の言語判定パッケージと比較したときにはどうでしょうか？こちらのブログ記事では、fasttextとlangid.pyに加えCLDとOpenNLPについて、多言語での言語判定の精度比較を行っています。

[Evaluating fastText's models for language detection \| Alex Ott's blog](http://alexott.blogspot.com/2017/10/evaluating-fasttexts-models-for.html)

その結果を要約すると、

- 日本語や中国語などではどれも同等の性能
- CLDは「レア」な言語に強い
- fasttextは英語やフランス語、ドイツ語などの「メジャー」な言語に強い
- fasttextのモデル間では、圧縮されたモデルでは性能が下がった

となったようです。また、短文においてはCLDよりfasttextの方がより信頼性が高いことが示されています。

## まとめ
本記事ではfasttextが提供する言語判定を実際に使いつつ、そのモデルの詳細や精度について見てきました。既存の言語判定器と比較しても同程度または高精度であることを考えると、やはり分散表現やニューラルネットの強さを感じます。手軽に利用することができますし、言語判定において利用を検討しても良いのではないかと思います。

## 参考

- [Language identification · fastText](https://fasttext.cc/docs/en/language-identification.html)
- [Fast and accurate language identification using fastText](https://fasttext.cc/blog/2017/10/02/blog-post.html)
- [saffsd/langid\.py: Stand\-alone language identification system](https://github.com/saffsd/langid.py)
- [vrasneur/pyfasttext: Yet another Python binding for fastText](https://github.com/vrasneur/pyfasttext)
- [Evaluating fastText's models for language detection \| Alex Ott's blog](https://alexott.blogspot.com/2017/10/evaluating-fasttexts-models-for.html)
- [FastText Users公開グループ \| Facebook](https://www.facebook.com/groups/1174547215919768/permalink/1702123316495486/?comment_id=1704414996266318&reply_comment_id=1705159672858517&notif_id=1507280476710677&notif_t=group_comment)
