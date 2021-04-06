---
title: "万病辞書を形態素解析器Sudachiで利用する"
date: 2021-04-05T20:45:14+09:00
draft: false
---

![https://www.pexels.com/ja-jp/photo/6997/](/img/manbyo-sudachi_header.png)


## 概要
[万病辞書](http://sociocom.jp/~data/2018-manbyo/index.html)とは、NAISTソーシャル・コンピューティング研究室から公開されている病名辞書です。様々な病名に対してICD10と呼ばれる疾患の標準規格が対応付いているほか、医療従事者による作業や計算機による自動抽出で得られた病名が列挙されています。また、形態素解析器で利用するための辞書データとして、MeCabに対応したものが配布されています。

今回は、この万病辞書を形態素解析器[Sudachi](https://github.com/WorksApplications/Sudachi)で利用できるようにするために、万病辞書からSudachiのユーザ辞書を作成しました。ダウンロードして利用できるように辞書データも配布します。

## レポジトリと辞書ファイル

レポジトリ：
- [yagays/manbyo\-sudachi](https://github.com/yagays/manbyo-sudachi)

ユーザ辞書ファイル：
- [manbyo20190704_all_dic.txt](https://github.com/yagays/manbyo-sudachi/blob/master/manbyo20190704_all_dic.txt)
- [manbyo20190704_sabc_dic.txt](https://github.com/yagays/manbyo-sudachi/blob/master/manbyo20190704_sabc_dic.txt)

配布している辞書ファイルのライセンスは元のライセンスを継承してCC-BYです。また、この辞書ファイルにはSudachidictのシステム辞書の情報は含まれていません。

## 作成方法
ここでは、万病辞書からSudachiのユーザ辞書を作成する方法を解説します。もし上記の作成済みユーザ辞書ファイルを利用する場合は3.以降をお試しください。

### 1. 万病辞書の準備
万病辞書は`MANBYO_201907`を利用します。各病名には信頼度LEVELというものが設定されており、ICDとの対応やアノテーションの作業度合いによってS,A,B,C,D,E,Fと降順で割り振られています。今回は元となる万病辞書から、信頼度でフィルタして2種類の辞書を作成します。

- 信頼度がS,A,B,Cの、ある程度信頼できる病名 (`*_sabc`と表記)
- すべての病名 (`*_all`と表記)

なお、登録されている病名や読みがななどは基本的にはそのまま利用しますが、見出し語に全角カンマ`，`が含まれていると正規化時に`,`となりcsvを破壊するため、日本語の句読点`、`に変換しています。

### 2. Sudachiのユーザ辞書の作成
Sudachiのドキュメントに従って、以下のようにユーザ辞書を作成します。

- 見出し語は、万病辞書の「出現形」にSudachiの文字正規化を行った文字列を使用
- 左連接ID,右連接ID,品詞1および品詞2は、`4786,名詞,固有名詞`を利用
- 読みは、万病辞書の複合文字列ラベルの`しゅつげんけい`がある場合に登録し、なければ空白
- 正規化表記は、万病辞書に登録されている表記を利用

### 3. ユーザ辞書のビルド
作成したユーザ辞書をビルドして、バイナリ辞書ファイルを作成します。今回はsudachidictのシステム辞書を利用するため、自身の環境に合わせて`system.dic`の場所を指定してください。

```sh
BASE_PATH=/path/to/sudachidict/resources/

sudachipy ubuild -s $BASE_PATH/system.dic manbyo20190704_sabc_dic.txt -o user_manbyo_sabc.dic
sudachipy ubuild -s $BASE_PATH/system.dic manbyo20190704_all_dic.txt -o user_manbyo_all.dic
```

### 4. 設定ファイルに記述する
Sudachiで指定するバイナリ辞書ファイルを利用するには、設定ファイル`sudachi.json`の`userDict`に指定する必要があります。インストールしているsudachipyの`sudachi.json`を直接変更する方法もありますが、今回は自分で`sudachi.json`を作成してSudachi利用時に指定してみます。

以下のように、`userDict`に先ほど作成したバイナリ辞書ファイルを指定します。なお、設定ファイル内には他にも`char.def`や`unk.def`のパスも指定されているため、そちらはインストールされているsudachipyの`resources/`以下のファイルを見に行くように修正します。

```
    "userDict": ["/Users/yag_ays/dev/nlp/manbyo-sudachi/user_manbyo_sabc.dic"],
```


### 実行

それでは実行してみましょう。まずはコマンドラインから病名をsudachiに渡して実行してみます。

```sh
$ echo "間質性腎炎所見" | sudachipy -a -r config/sudachi_sabc.json | tr "\t" "\n" | nl -b a
     1  間質性腎炎所見
     2  名詞,固有名詞,一般,*,*,*
     3  間質性腎炎所見
     4  間質性腎炎所見
     5  かんしつせいじんえんしょけん
     6  1
     7  EOS
```

ちゃんと1つの名詞として分かち書きされていますね。品詞や読みもユーザ辞書に登録した通りに表示されています。

また、sudachipyから実行するには、以下のように`config_path`に設定ファイルのパスを渡してtokenizerを作成します。

```python
from sudachipy import dictionary, tokenizer

tokenizer_obj = dictionary.Dictionary(config_path="config/sudachi_all.json").create()
tokens = tokenizer_obj.tokenize("線維筋痛症になった",  tokenizer.Tokenizer.SplitMode.B)
for token in tokens:
    print(token.surface(), token.part_of_speech())

# 線維筋痛症 ['名詞', '固有名詞', '一般', '*', '*', '*']
# に ['助詞', '格助詞', '*', '*', '*', '*']
# なっ ['動詞', '非自立可能', '*', '*', '五段-ラ行', '連用形-促音便']
# た ['助動詞', '*', '*', '*', '助動詞-タ', '終止形-一般']
```

## まとめと今後
この記事では、万病辞書をSudachiのユーザ辞書に変換して利用する方法を解説しました。これで医療ドメインの形態素解析において万病辞書のリソースを利用することができます。

今回のSudachi対応の理由としては[spaCy](https://spacy.io/)や[GiNZA](https://megagonlabs.github.io/ginza/)といったNLPライブラリで利用する目的だったので、それ自体は達成することができました。一方で、Sudachi固有の機能として、複数の分割単位で形態素解析を利用できるという大きな特徴があります。万病辞書に登録されている病名においても、「発熱」といった最小単位のものから「アトピー性皮膚炎」といった分割が可能なものなど粒度が様々で、複数の分割単位に対応することで恩恵が得られそうなものもあります。ユーザが作成する辞書においても複数の分割単位に対応することができるため、そうした情報を辞書から自動で付与することができれば、より活用できそうです。

## 参考

- [Sudachi/user\_dict\.md at develop · WorksApplications/Sudachi](https://github.com/WorksApplications/Sudachi/blob/develop/docs/user_dict.md)
- [Elasticsearchのための新しい形態素解析器 「Sudachi」 \- Qiita](https://qiita.com/sorami/items/99604ef105f13d2d472b)
- [形態素解析器Sudachiのユーザー辞書には文字正規化が必要](https://zenn.dev/sorami/articles/6bdb4bf6c7f207)