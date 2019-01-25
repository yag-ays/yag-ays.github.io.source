---
title: "日本語Wikipediaで学習したdoc2vevモデル"
date: 2019-01-22T15:55:40+09:00
draft: false
---

![https://www.pexels.com/photo/woman-in-black-long-sleeved-looking-for-books-in-library-926680/](/img/doc2vec_header.png)

日本語Wikipediaを対象にdoc2vec学習させたモデルを作成したので、学習済みモデルとして公開します。

## 概要

doc2vecは2014年に[Quoc LeとTomas Mikolov](https://arxiv.org/abs/1405.4053)によって発表された文章の埋め込みの手法です。今更doc2vecかという感じではありますが、日本語のdoc2vecの学習済みモデルは探した限り容易に利用できるものがなかったこともあり、せっかくなので作成したモデルを配布します。

word2vecのような単語の分散表現においては学習済みモデルとして配布されたものを利用することが多いですが、文章の埋め込みに関しては対象とするドキュメント集合やそのドメインに特化した学習モデルを作成することが多い印象です。なので、学習済みモデルファイルの配布自体にそれほど意味があるわけではなさそうですが、既存手法との比較に利用したり、とりあえず何かしらの手法で単語列から文章ベクトルにしたいといった場合には便利かと思います。まあ何も無いよりかはマシかなという雰囲気です。今回の作成の経緯として、別の手法を実装する際にdoc2vecが内部で使われていたということで副次的に必要になったからだったのですが、ふと利用したいときに気軽に利用できるというのは結構良いのではないかと思います。

## モデル
ここでは2つの学習アルゴリズムでdoc2vecを学習しました。`dbow300d`はdistributed bag of words (PV-DBOW)を、`dmpv300d`はdistributed memory (PV-DM)を用いています。なお、モデルファイルはサイズが大きいため、Googleドライブに配置してあります。下記リンク先からダウンロードしてください。

- `dbow300d`
  - [https://www.dropbox.com/s/j75s0eq4eeuyt5n/jawiki.doc2vec.dbow300d.tar.bz2?dl=0](https://www.dropbox.com/s/j75s0eq4eeuyt5n/jawiki.doc2vec.dbow300d.tar.bz2?dl=0)
  - 圧縮ファイルのサイズ：5.48GB
- `dmpv300d`
  - [https://www.dropbox.com/s/njez3f1pjv9i9xj/jawiki.doc2vec.dmpv300d.tar.bz2?dl=0](https://www.dropbox.com/s/njez3f1pjv9i9xj/jawiki.doc2vec.dmpv300d.tar.bz2?dl=0)
  - 圧縮ファイルのサイズ：8.86GB

## モデルの学習パラメータ

| param         | dbow300d | dmpv300d |
| :------------ | :------- | :------- |
| `dm`          | 0        | 1        |
| `vector_size` | 300      | 300      |
| `window`      | 15       | 10       |
| `alpha`       | 0.025    | 0.05     |
| `min_count`   | 5        | 2        |
| `sample`      | 1e-5     | 0        |
| `epochs`      | 20       | 20       |
| `dbow_words`  | 1        | 0        |

`dbow300d`のパラメータは、[An Empirical Evaluation of doc2vec with Practical Insights into Document Embedding Generation](https://arxiv.org/abs/1607.05368)におけるEnglish Wikipeiaの学習時のパラメータを利用しました。`dmpv300d`のパラメータは、[Gensim Doc2Vec Tutorial on the IMDB Sentiment Dataset](https://github.com/RaRe-Technologies/gensim/blob/develop/docs/notebooks/doc2vec-IMDB.ipynb)の設定を参考にしました。

## 実験設定
学習元のコーパスには、2019/01/14時点でのWikipediaの[CirrusSearch](https://www.mediawiki.org/wiki/Help:CirrusSearch/ja)のダンプデータを用いました。形態素解析には[MeCab](http://taku910.github.io/mecab/)を使用し、辞書には[NEologd](https://github.com/neologd/mecab-ipadic-neologd)を用いています。また、doc2vecの計算には[gensim](https://radimrehurek.com/gensim/)を使用しました。利用したパッケージや辞書のバージョンは以下の通りです。

- コーパス
  - [`jawiki-20190114-cirrussearch-content.json.gz`](https://dumps.wikimedia.org/other/cirrussearch/20190114/)
- 形態素解析
  - MeCab: 0.996
  - NEologd: Periodic data update on 2019-01-17(Thu)
- ライブラリ
  - Gensim: 3.7.0
  - Numpy: 1.16

もしモデルが読み込めない場合には、各種ライブラリを最新のバージョンにするなど試してください。

## ソースコード
学習時のソースコードは、以下のリポジトリにあります。

- [yagays/pretrained\_doc2vec\_ja](https://github.com/yagays/pretrained_doc2vec_ja)

## 使い方
### モデルファイルの読み込み

```py
from gensim.models.doc2vec import Doc2Vec
model = Doc2Vec.load("jawiki.doc2vec.dbow300d.model")
```

### 類似するドキュメントを表示する

```py
In []: model.docvecs.most_similar("アリストテレス")
Out[]:
[('オルガノン', 0.5950535535812378),
 ('善のイデア', 0.5811843872070312),
 ('スペウシッポス', 0.5756123065948486),
 ('プラトン', 0.5733123421669006),
 ('ジークムント・フロイト', 0.5668295621871948),
 ('カルキディウス', 0.5634585618972778),
 ('アンモニオス・サッカス', 0.5591270923614502),
 ('メリッソス、クセノパネス、ゴルギアスについて', 0.5568180084228516),
 ('ピレボス', 0.5543898940086365),
 ('睡眠と覚醒について', 0.5480767488479614)]
```

### 未知の入力文に対して類似するドキュメントを表示する
`model.infer_vector()`には形態素解析済みのリストを入力する必要があります。そのため、ここではMeCabを用いた`tokenize()`を定義しています。

```py
import MeCab

def tokenize(text):
    wakati = MeCab.Tagger("-O wakati")
    wakati.parse("")
    return wakati.parse(text).strip().split()
```

```py
In []: text = """バーレーンの首都マナマ(マナーマとも)で現在開催されている
ユネスコ(国際連合教育科学文化機関)の第42回世界遺産委員会は日本の推薦していた
「長崎と天草地方の潜伏キリシタン関連遺産」 (長崎県、熊本県)を30日、
世界遺産に登録することを決定した。文化庁が同日発表した。
日本国内の文化財の世界遺産登録は昨年に登録された福岡県の
「『神宿る島』宗像・沖ノ島と関連遺産群」に次いで18件目。
2013年の「富士山-信仰の対象と芸術の源泉」の文化遺産登録から6年連続となった。"""

In []: model.docvecs.most_similar([model.infer_vector(tokenize(text))])
Out[]:
[('イタリアの世界遺産', 0.599028468132019),
 ('海の道むなかた館', 0.5562682151794434),
 ('タジキスタンの世界遺産', 0.5554744005203247),
 ('ウクライナの世界遺産', 0.5542891621589661),
 ('バーレーンの世界遺産', 0.552284836769104),
 ('世界遺産センター (曖昧さ回避)', 0.540568470954895),
 ('アラブ首長国連邦の世界遺産', 0.5372575521469116),
 ('アイスランドの世界遺産', 0.5366297960281372),
 ('マレーシアの世界遺産', 0.5362405776977539),
 ('ラトビアの世界遺産', 0.5351229906082153)]
```

（出典：[潜伏キリシタン関連遺産、世界遺産登録 \- ウィキニュース](https://ja.wikinews.org/wiki/%E6%BD%9C%E4%BC%8F%E3%82%AD%E3%83%AA%E3%82%B7%E3%82%BF%E3%83%B3%E9%96%A2%E9%80%A3%E9%81%BA%E7%94%A3%E3%80%81%E4%B8%96%E7%95%8C%E9%81%BA%E7%94%A3%E7%99%BB%E9%8C%B2)）

### 類似する単語を表示する

なお、doc2vecでもword2vecと同様に、任意の単語に対して類似する単語を表示することもできますが、単語間の類似度を知りたいだけならword2vecの学習済みモデルである[日本語 Wikipedia エンティティベクトル](http://www.cl.ecei.tohoku.ac.jp/~m-suzuki/jawiki_vector/)を使った方が良いでしょう。

```py
In []: model.wv.most_similar("一揆", topn=3)
Out[]:
[('百姓一揆', 0.717296302318573),
 ('国人衆', 0.7110892534255981),
 ('国人一揆', 0.7016592025756836)]
```

## ライセンス
CC-BY-SA: [Creative Commons Attribution-ShareAlike License](https://creativecommons.org/licenses/by-sa/3.0/)

## 参考

-  [\[1607\.05368\] An Empirical Evaluation of doc2vec with Practical Insights into Document Embedding Generation](https://arxiv.org/abs/1607.05368)
- [gensim/doc2vec\-IMDB\.ipynb at develop · RaRe\-Technologies/gensim](https://github.com/RaRe-Technologies/gensim/blob/develop/docs/notebooks/doc2vec-IMDB.ipynb)
- [gensim: models\.doc2vec – Doc2vec paragraph embeddings](https://radimrehurek.com/gensim/models/doc2vec.html)
