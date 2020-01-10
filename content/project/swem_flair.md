---
title: "Flairを使ってSWEMによる文章埋め込みを計算する"
date: 2019-12-30T14:27:32+09:00
draft: false
---

![https://www.pexels.com/photo/photo-of-man-holding-orange-smoke-1785298/](/img/swem_flair_header.png)


## 概要
[Flair](https://github.com/flairNLP/flair)は、Pytorchで書かれた自然言語処理用のフレームワークです。固有表現抽出や品詞タグ付け、文章分類などの機能を提供しているほか、文章埋め込み (Sentence Embedding) も簡単に計算することができます。以前に本ブログで紹介した[SWEM](https://arxiv.org/abs/1805.09843)も扱うことができたので、ここで使い方を紹介したいと思います。

記事：[SWEM: 単語埋め込みのみを使うシンプルな文章埋め込み \- Out\-of\-the\-box](https://yag-ays.github.io/project/swem/)

---

## 方法
### 単語ベクトルの読み込み
まずFlairで学習済みの単語埋め込みベクトルを読み込みます。あらかじめ学習済み単語ベクトルのファイルを用意しておく必要はなく、以下のコードを初めて動かす際に自動でウェブからダウンロードされます。日本語の場合は、fastTextが提供している[`ja-wiki-fasttext-300d-1M`](https://fasttext.cc/docs/en/pretrained-vectors.html)が選択されます。

```py
from flair.embeddings import WordEmbeddings, DocumentPoolEmbeddings, Sentence
from flair.data import build_japanese_tokenizer
ja_embedding = WordEmbeddings("ja")
```

ここでダウンロードしたファイルは`$HOME/.flair/embeddings/`に保存されます。

### 文章埋め込みの選択
次に、文章埋め込みの手法を選択します。SWEMは各単語ベクトルに対して各種Poolingの操作を行うことで文章埋め込みを計算するため、`DocumentPoolEmbeddings()`を利用します。この引数には、さきほど読み込んだ`WordEmbeddings`のインスタンスを選択します。

```py
document_embeddings = DocumentPoolEmbeddings([ja_embedding])
```


### 文章埋め込みを計算する
最後に文章埋め込みを計算します。まず対象となる文章の`Sentence`オブジェクトを作成し、それを上記で作成した`document_embeddings.embed()`で埋め込みます。

```py
sentence = Sentence("吾輩は猫である。名前はまだ無い。",
                    use_tokenizer=build_japanese_tokenizer("MeCab"))
document_embeddings.embed(sentence)
```

そして、文章埋め込みのベクトルは`sentnece.get_embedding()`から取得することができます。

```py
In []: sentence.get_embedding()
Out[]:
tensor([ 2.1660e+00, -1.9450e+00, -1.9782e+00, -1.0372e+01, -7.4274e-01,
        -1.6262e+00,  2.3832e+00,  1.3668e+00,  4.2834e+00, -3.4007e+00,
[...]        
        3.6956e+00, -4.1554e+00,  4.7224e+00,  4.1686e+00, -4.3685e+00],
        grad_fn=<CatBackward>)
```

---

## カスタマイズ
### 指定した学習済みの単語ベクトルを使う
Flairがデフォルトで指定している学習済みの単語ベクトルではなく、ローカルにあるファイルを指定することもできます。ファイル形式は`gensim`のバイナリフォーマットで用意する必要があります。

```py
own_embedding = WordEmbeddings("path/to/own_vector.bin")
```

[flair/CLASSIC\_WORD\_EMBEDDINGS\.md at master · flairNLP/flair](https://github.com/flairNLP/flair/blob/master/resources/docs/embeddings/CLASSIC_WORD_EMBEDDINGS.md)

### Poolingの方法を変更する
Poolingの方法には、デフォルトのaverage pooling(`pooling="mean"`)の他に、max pooling(`pooling="max"`)とmin pooling(`pooling="min"`)も用意されています。

```py
document_embeddings = DocumentPoolEmbeddings([ja_embedding], pooling="max")
```

### Poolingの方法を組み合わせる
SWEMには、average-poolingとmax poolingを組み合わせた`SWEM-concat`という手法があります。flairでは`StackedEmbeddings()`を使うことで、複数のEmbeddingを組み合わせることができます。


```py
from flair.embeddings import StackedEmbeddings

average_embedding = DocumentPoolEmbeddings([ja_embedding], pooling="mean")
max_embedding = DocumentPoolEmbeddings([ja_embedding], pooling="max")

document_embeddings = StackedEmbeddings([average_embedding,
                                         max_embedding])
document_embeddings.embed(sentence)                                         
```

```py
In []: sentence.get_embedding()
Out[]:
tensor([ 2.1660e+00, -1.9450e+00, -1.9782e+00, -1.0372e+01, -7.4274e-01,
        -1.6262e+00,  2.3832e+00,  1.3668e+00,  4.2834e+00, -3.4007e+00,
[...]
        4.5165e+00, -2.9375e+00,  5.7923e+00,  5.0611e+00, -3.1531e+00],
        grad_fn=<CatBackward>)

In []: sentence.get_embedding().shape
Out[]: torch.Size([600])        
```

## 参考

- [flairNLP/flair: A very simple framework for state\-of\-the\-art Natural Language Processing \(NLP\)](https://github.com/flairNLP/flair)
