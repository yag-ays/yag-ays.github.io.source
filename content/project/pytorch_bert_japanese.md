---
title: "pytorchでBERTの日本語学習済みモデルを利用する - 文章埋め込み編"
date: 2019-06-05T20:11:43+09:00
draft: false
---

![https://www.pexels.com/photo/red-and-white-umbrella-during-night-time-39079/](/img/pytorch_bert_japanese_header.png)

## 概要
BERT (Bidirectional Encoder Representations from Transformers) は、NAACL2019で論文が発表される前から大きな注目を浴びていた強力な言語モデルです。これまで提案されてきたELMoやOpenAI-GPTと比較して、双方向コンテキストを同時に学習するモデルを提案し、大規模コーパスを用いた事前学習とタスク固有のfine-tuningを組み合わせることで、各種タスクでSOTAを達成しました。

そのように事前学習によって強力な言語モデルを獲得しているBERTですが、今回は日本語の学習済みBERTモデルを利用して、文章埋め込み (Sentence Embedding) を計算してみようと思います。

---

## 環境
今回は京都大学の黒橋・河原研究室が公開している「BERT日本語Pretrainedモデル」を利用します。

- [BERT日本語Pretrainedモデル - KUROHASHI-KAWAHARA LAB](http://nlp.ist.i.kyoto-u.ac.jp/index.php?BERT%E6%97%A5%E6%9C%AC%E8%AA%9EPretrained%E3%83%A2%E3%83%87%E3%83%AB)

BERTの実装は、pytorchで書かれた[`pytorch-pretrained-BERT`](https://github.com/huggingface/pytorch-pretrained-BERT)がベースになります。また形態素解析器は、学習済みモデルに合わせるため[JUMAN++](http://nlp.ist.i.kyoto-u.ac.jp/index.php?JUMAN++)を利用します。

## 方法
今回は`BertWithJumanModel`というトークナイズとBERTによる推論を行うクラスを自作しています。ソースコード自体は下記レポジトリにあり、また各ステップでの計算方法を本記事の後半で解説しています。

- [yagays/pytorch\_bert\_japanese](https://github.com/yagays/pytorch_bert_japanese)

```py
In []: from bert_juman import BertWithJumanModel

In []: bert = BertWithJumanModel("/path/to/Japanese_L-12_H-768_A-12_E-30_BPE")

In []: bert.get_sentence_embedding("吾輩は猫である。")
Out[]:
array([ 2.22642735e-01, -2.40221739e-01,  1.09303640e-02, -1.02307117e+00,
        1.78834641e+00, -2.73566216e-01, -1.57942638e-01, -7.98571169e-01,
       -2.77438164e-02, -8.05811465e-01,  3.46736580e-01, -7.20409870e-01,
        1.03382647e-01, -5.33944130e-01, -3.25344890e-01, -1.02880754e-01,
        2.26500735e-01, -8.97880018e-01,  2.52314955e-01, -7.09809303e-01,
[...]        
```

これでBERTによる文章埋め込みのベクトルが得られました。あとは、後続のタスクに利用したり、文章ベクトルとして類似度計算などに利用できます。

また、BERTの隠れ層の位置や、プーリングの計算方法も選択できるようにしています。このあたりの設計は[hanxiao/bert-as-service](https://github.com/hanxiao/bert-as-service) を参考にしています。

```py
In []: bert.get_sentence_embedding("吾輩は猫である。",
   ...:                             pooling_layer=-1,
   ...:                             pooling_strategy="REDUCE_MAX")
   ...:
Out[]:
array([ 1.2089624 ,  0.6267309 ,  0.7243419 , -0.12712255,  1.8050476 ,
        0.43929055,  0.605848  ,  0.5058241 ,  0.8335829 , -0.26000524,
[...]        
```

---

## 解説
上記の`BertWithJumanModel`クラスの内部を順に解説していきます。そのまま上から実行しても動作するように記載しているので、途中の動作が気になる方は試してみて下さい。

### 1. 学習済みモデルを`pytorch-pretrained-bert`で読み込む

まず始めに配布されている学習済みモデルなどを`pytorch-pretrained-BERT`から読み込みます。

```py
import torch
from pytorch_pretrained_bert import BertTokenizer, BertModel

model = BertModel.from_pretrained("/path/to/Japanese_L-12_H-768_A-12_E-30_BPE/")
bert_tokenizer = BertTokenizer("/path/to/Japanese_L-12_H-768_A-12_E-30_BPE/vocab.txt",
                               do_lower_case=False, do_basic_tokenize=False)
```

モデルは[黒橋・河原研究室の配布サイト](http://nlp.ist.i.kyoto-u.ac.jp/index.php?BERT%E6%97%A5%E6%9C%AC%E8%AA%9EPretrained%E3%83%A2%E3%83%87%E3%83%AB)からダウンロードし解凍します。`BertModel`の`from_pretrained()`で解凍先のパスを指定することで、モデルをロードすることができます。必要なファイルは`pytorch_model.bin`と`vocab.txt`のみです。

なお、モデル配布ページでは`pytorch-pretrained-BERT`内の`tokenization.py`の特定行をコメントアウトするように指示されていますが、`BertTokenizer()`で引数を`do_basic_tokenize=False`とすれば対応は不要です。 

### 2. テキストを分かち書きして対応するid列に変換する
次に、与えられたテキストを分かち書きしてトークンに分割したのちに、対応するidに変換します。`pytorch-pretrained-BERT`は日本語の分かち書きに対応していないため、前者はJuman++によるトークナイザを自作し、後者は`BertTokenizer()`を利用します。

```py
# Jumanによるトークナイザ
class JumanTokenizer():
    def __init__(self):
        self.juman = Juman()

    def tokenize(self, text):
        result = self.juman.analysis(text)
        return [mrph.midasi for mrph in result.mrph_list()]
```

分かち書きしたトークン列には、テキストの冒頭に`[CLS]`トークンを付与します。得られたトークン列は、英語のトークナイズに対応できるようにスペース区切りで結合し、最後に`BertTokenizer()`でid列に変換します。この際には、学習済みモデルの`max_seq_length`が128に設定されているため、トークン列を前方から128個目までにしています。

```py
juman_tokenizer = JumanTokenizer()

tokens = ["[CLS]"] + juman_tokenizer.tokenize(text)
bert_tokens = bert_tokenizer.tokenize(" ".join(tokens[:128]))  # max_seq_len
ids = bert_tokenizer.convert_tokens_to_ids(bert_tokens)
tokens_tensor = torch.tensor(ids).reshape(1, -1)
```

例えば「`我輩は猫である。`」という文章は、以下のようにトークン化されid列に変換されます。ちなみに`我輩`という単語は辞書中に存在せずかつサブワードとしても分割できないことから、未知語として`id:1`(`[UNK]`)に変換されています。

```
# text
  吾輩は猫である
# tokens
  ['[CLS]', '吾輩', 'は', '猫', 'である']
# tokens_tensor
  tensor([[   2,    1,    9, 4817,   32]])
```

### 3. BERTのモデルに入力し、特徴ベクトルを得る
id列に変換したベクトルをBERTのモデルに入力し、それぞれの隠れ層から出力される特徴ベクトルを得ます。

```py
model.eval()
with torch.no_grad():
    all_encoder_layers, _ = model(tokens_tensor)
```

`all_encoder_layers`には全12層から出力される特徴ベクトルが格納されています。

### 4. 特徴ベクトルから文章埋め込みを得る
最後に、BERTの隠れ層から得られた特徴ベクトルから文章埋め込みを計算します。BERTでは各入力のトークンに対応する`hidden_size`次元 (本モデルでは768次元) のベクトルが得られるため、それを文章埋め込みとしての固定次元のベクトルで表現する必要があります。

ここでは[hanxiao/bert-as-service](https://github.com/hanxiao/bert-as-service)での計算方法を参考に、SWEMと同じ方法でベクトルを時間方向にaverage-poolingしています。また利用するBERTの隠れ層は、最終層ではなくその一つ前の層を選択しています。

```py
pooling_layer = -2
embedding = all_encoder_layers[pooling_layer].numpy()[0]
np.mean(embedding, axis=0)
```

hanxiao/bert-as-serviceでは、この計算方法はいくつか選択できるようになっており、本家に習って`BertWithJumanModel`のコード内でも`REDUCE_MEAN`や`REDUCE_MAX`などの方法を指定できるようにしています。これらの手法は基本的にSWEMの概念と同じですので、詳細は「[SWEM: 単語埋め込みのみを使うシンプルな文章埋め込み](https://yag-ays.github.io/project/swem/)」の記事を参考ください。


## 参考

- [huggingface/pytorch-pretrained-BERT: 📖The Big-&-Extending-Repository-of-Transformers: Pretrained PyTorch models for Google’s BERT, OpenAI GPT & GPT-2, Google/CMU Transformer-XL.](https://github.com/huggingface/pytorch-pretrained-BERT)
- [hanxiao/bert-as-service: Mapping a variable-length sentence to a fixed-length vector using BERT model](https://github.com/hanxiao/bert-as-service)
- [BERT日本語Pretrainedモデル - KUROHASHI-KAWAHARA LAB](http://nlp.ist.i.kyoto-u.ac.jp/index.php?BERT%E6%97%A5%E6%9C%AC%E8%AA%9EPretrained%E3%83%A2%E3%83%87%E3%83%AB)
- [[1810.04805] BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding](https://arxiv.org/abs/1810.04805)
- [BERTの日本語事前学習済みモデルでテキスト埋め込みをやってみる ｜ DevelopersIO](https://dev.classmethod.jp/machine-learning/bert-text-embedding/)
