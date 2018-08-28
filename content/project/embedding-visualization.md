---
title: "学習済み分散表現をTensorBoardで可視化する (gensim/PyTorch/tensorboardX)"
date: 2018-08-28T21:37:26+09:00
draft: false
---

<video autoplay loop width="680">
　　<source src="/img/embedding-visualization_02.webm">
</video>


word2vecや系列モデル等で学習した分散表現の埋め込みベクトル（word embeddings）は、単語の意味をベクトル空間上で表現することが可能です。最も有名な例では「King - Man + Woman = Queen」のように意味としての加算や減算がベクトル計算で類推可能なこともあり、ベクトル空間の解釈として低次元へ写像する形で分散表現の可視化が行われています。

可視化の際に用いられるツールとしては、[TensorFlow](https://www.tensorflow.org/)のツールの一つである[TensorBoard](https://www.tensorflow.org/guide/summaries_and_tensorboard)が、豊富な機能とインタラクティブな操作性を備えていて一番使い勝手が良いと思います。ただ、TensorFlowと組み合わせた可視化は容易なのですが、他のツールやパッケージで作成したコードをそのまま読み込めないなど、かゆいところに手が届かないと感じる部分もあります。

そこで今回は、すでに学習された単語の分散表現を可視化するために、

1.  [gensim](https://radimrehurek.com/gensim/)を用いてベクトルを読み込み、
2. [PyTorch](https://pytorch.org/)のTensor形式に変換したうえで、
3. [tensorboardX](https://github.com/lanpa/tensorboardX)を用いてTensorBoardが読み込めるログ形式に出力する

ことで、TensorBoard上で分散表現を可視化します。いろいろなステップがあって一見して遠回りに思えますが、コード自体は10行に満たないほどで完結します。個人的には、Tensorflowで学習済み分散表現を読み込むよりも、これらを組み合わせたやり方のほうが簡潔に書くことができて好きです。

---

## 方法
### 準備
必要な外部パッケージは、`gensim`/`pytorch`/`tensorboardX`/`tensorflow`の4つです。インストールされていない場合は`pip`などであらかじめインストールしておきます。

```sh
$ pip isntall gensim torch tensorboardX tensorflow
```

### 分散表現の読み込みからtensorboard形式のログ出力まで
TensorBoardで可視化するまでに必要な本体のコードです。これだけ！

```py
import gensim
import torch
from tensorboardX import SummaryWriter

vec_path = "entity_vector.model.bin"

writer = SummaryWriter()
model = gensim.models.KeyedVectors.load_word2vec_format(vec_path, binary=True)
weights = model.vectors
labels = model.index2word

# DEBUG: visualize vectors up to 1000
weights = weights[:1000]
labels = labels[:1000]

writer.add_embedding(torch.FloatTensor(weights), metadata=labels)
```

コード内の`vec_path`は、任意の学習済みベクトルのファイルに置き換えてください。

また、途中で差し込まれている`DEBUG`の部分では、TensorBoardの読み込みスピード等を考慮して対象単語数を1000に絞っています。本来ならばこのような操作は不要ですが、かといってすべてのベクトルをTensorBoardで読み込んだとしても、デフォルトではランダムに10万件しか表示されません。学習済み分散表現の単語数があまりにも多い場合は、自分の可視化したい単語等に限定するなど少し工夫が必要です。

[Embedding projector only loads first 100,000 vectors · Issue \#773 · tensorflow/tensorboard](https://github.com/tensorflow/tensorboard/issues/773)

### TensorBoardで可視化
上記スクリプトを実行すると、実行されたディレクトリに`runs/`が作成されます。TensorBoardの起動時に`runs`ディレクトリを指定することで、変換した単語の分散表現が可視化できます。

```
$ tensorboard --logdir=runs
```

上記コマンドを実行した状態で http://localhost:6006/ にアクセスすると、PROJECTORのページにてグラフが確認できます。

---

## 可視化の事例
### 日本語 Wikipedia エンティティベクトル
可視化の具体例として、[日本語 Wikipedia エンティティベクトル](http://www.cl.ecei.tohoku.ac.jp/~m-suzuki/jawiki_vector/)を可視化してみます。

![embedding-visualization_01](/img/embedding-visualization_01.png)

これはPCAでの可視化の事例です。3次元上の点をクリックすると、その単語の情報とともに、類似した点のラベル情報も同時に確認することができます。ここでは「路線」という点をクリックしており、それに対応する類似単語が中央の3次元グラフ上でも右側のリストでも表示されています。

3次元グラフ上ではまとまりがあまり無いように見えますが、これはPCAで3次元に圧縮したものを可視化しているためです。TensorBoardに用意されているもう一つの次元圧縮の手法であるT-SNEを使うことで、より類似した単語が3次元空間上で近い位置に配置されるように可視化されます。

### 文字の図形的な埋め込み表現
また、画像を含めた可視化も可能です。本サイトで公開している[文字の図形的な埋め込み表現](https://yag-ays.github.io/project/char-embedding/)でも同様に可視化をしてみます。画面上で黒い四角の文字が表示されていますが、これはあらかじめ用意してあった画像を読み込んでいるためです。

![embedding-visualization_02](/img/embedding-visualization_02.png)


ここで使用しているTensorBoardの変換のためのコードは、以下から取得可能です。

[glyph\-aware\-character\-embedding/make\_tbx\_visualize\.py at master · yagays/glyph\-aware\-character\-embedding](https://github.com/yagays/glyph-aware-character-embedding/blob/master/src/make_tbx_visualize.py)

---

## 参考

- [lanpa/tensorboardX: tensorboard for pytorch \(and chainer, mxnet, numpy, \.\.\.\)](https://github.com/lanpa/tensorboardX)
- [PyTorch から tensorboardX で画像データの Embedding をとってみたら結構楽だなと感じたお話 \- Qiita](https://qiita.com/ciela/items/ae1737bf6cb357cda900)
