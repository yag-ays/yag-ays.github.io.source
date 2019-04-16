---
title: "MeCabの形態素解析の結果から正規表現を使って品詞列を抜き出すmecabpr"
date: 2019-04-15T21:44:12+09:00
draft: false
---

![https://www.pexels.com/photo/red-and-green-christmas-stocking-hanging-inside-room-1679769/](/img/mecabpr_header.png)


MeCabの形態素解析の結果から、正規表現を使って品詞列を抜き出すためのパッケージ[`mecabpr`](https://github.com/yagays/mecabpr)(mecab-pos-regexp)を作成しました。

## 概要
キーフレーズ抽出などのタスクにおいて、MeCabの形態素解析した文字列の中から「形容詞に続く名詞」や「任意の長さを持つ名詞の系列」といった特定のパターンを持つ品詞列を取り出したいことがあります。そのようなパターンを正規表現の記法を用いて表現し、一致する品詞列を抜き出すためのパッケージを作成しました。

![](/img/mecabpr_01.png)

---

## ソースコード

- [https://github.com/yagays/mecabpr](https://github.com/yagays/mecabpr)


## 使い方
### インストール
[`mecabpr`](https://pypi.org/project/mecabpr/)はpipを使ってインストールできます。

```sh
$ pip install mecabpr
```

### 準備
`mecabpr`を読み込みます。

```py
import mecabpr
mpr = mecabpr.MeCabPosRegex()
sentence = "あらゆる現実をすべて自分のほうへねじ曲げたのだ。"
```

- `MeCabPosRegex()`にはMeCabに渡すオプションを指定できます
  - `MeCabPosRegex("-d /path/to/mecab-ipadic-neologd")`で[NEologd](https://github.com/neologd/mecab-ipadic-neologd)の辞書を使うことができます
- `mpr.findall()`の引数には、対象とする文字列と、正規表現で表した品詞列を指定します
  - 品詞には任意の階層を指定することができ、階層間を`-`で区切って入力します (e.g. `名詞-固有名詞-人名-一般`)

あとは、以下のように品詞のパターンを指定すると、目的の品詞列を取得できます。

---

### 例）「名詞」を抽出する

```py
In []: mpr.findall(sentence, "名詞")
Out[]: [['現実'], ['すべて'], ['自分'], ['ほう'], ['の']]
```

### 例）「名詞に続く助詞」を抽出する

```py
In []: mpr.findall(sentence, "名詞助詞")
Out[]: [['現実', 'を'], ['自分', 'の'], ['ほう', 'へ']]
```

ちなみに、`"名詞助詞"`のように一続きに表現しても問題ないですが、可読性のために`"(名詞)(助詞)"`のように品詞を括弧で括っても同様の結果が得られます。

---

### 例）「名詞に続く助詞が2回続くパターン」を抽出する
通常の正規表現と同様の記法を使うことができます。ここでは`{2}`を指定することで、2回の繰り返しを表現しています。

```py
In [42]: mpr.findall(sentence, "(名詞助詞){2}")
Out[42]: [['自分', 'の', 'ほう', 'へ']]
```

### 例）「名詞または動詞」を抽出する
ここでは、正規表現に`|`を使って和集合を表現しています。

```py
In []: mpr.findall(sentence, "(名詞|動詞)")
Out[]: [['現実'], ['すべて'], ['自分'], ['ほう'], ['ねじ曲げ'], ['の']]
```

---

### 例）「名詞-一般」を抽出する
正規表現で表した品詞列には、階層を表す分類も用いることができます。以下の例では、`名詞`の中でも`一般`であるものに限定して列挙しています。

```py
In []: mpr.findall(sentence, "名詞-一般")
Out[]: [['現実'], ['自分']]
```

### 例）「名詞-一般に続く助詞」を抽出する
パターンを指定するときの品詞には、階層を表す分類を複数組み合わせることも可能です。その際に品詞の階層を合わせる必要はありません。以下の例では`名詞-一般`と`助詞`を組み合わせて正規表現を構成しています。

```py
In []: mpr.findall(sentence, "名詞-一般助詞")
Out[]: [['現実', 'を'], ['自分', 'の']]
```

---

### MeCabの出力をそのまま利用する
`mpr.findall(raw=True)`とすることで、出力を単語ではなくMeCabが出力した形態素解析結果の文字列に変更することができます。

```py
In []: mpr.findall(sentence, "名詞助詞", raw=True)
Out[]:
[['現実\t名詞,一般,*,*,*,*,現実,ゲンジツ,ゲンジツ', 'を\t助詞,格助詞,一般,*,*,*,を,ヲ,ヲ'],
 ['自分\t名詞,一般,*,*,*,*,自分,ジブン,ジブン', 'の\t助詞,連体化,*,*,*,*,の,ノ,ノ'],
 ['ほう\t名詞,非自立,一般,*,*,*,ほう,ホウ,ホー', 'へ\t助詞,格助詞,一般,*,*,*,へ,ヘ,エ']]
```


## 参考

- [MeCab: Yet Another Part\-of\-Speech and Morphological Analyzer](http://taku910.github.io/mecab/)
- [posregex: POSタグ正規表現による抽出器 \- ナード戦隊データマン](http://datanerd.hateblo.jp/entry/2018/12/15/071646)
- [mecab を便利に利用するためのtips \- 高度なKWICをスクリプト無しで実現する \- \- Qiita](https://qiita.com/tkngue/items/640c5b84c16252833a8d)
