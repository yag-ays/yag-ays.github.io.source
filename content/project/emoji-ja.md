---
title: "📙Unicode絵文字の日本語読み/キーワード/分類辞書📙"
date: 2018-08-23T07:41:44+09:00
draft: false
---
![emoji_ja](/img/emoji_ja.png)

`emoji_ja`は、Unicodeに登録されている絵文字に対して、日本語の読みやキーワード、分類を付与したデータセットです。Unicodeで定められている名称やアノテーションを元に構築しています。


TwitterやInstagramなどのSNSを通じた絵文字の普及により、[emoji2vec](https://arxiv.org/abs/1609.08359)や[deepmoji](https://deepmoji.mit.edu/)などの絵文字を使った自然言語処理の研究が行われるようになりました。絵文字を含む分析においては、絵文字の持つ豊富な情報や多彩な利用方法により、従来の形態素分析などのテキスト処理では対応できない場合があります。例えば、「今日は楽しかった😀」という文章では感情表現として絵文字が使われていますが、「今日は🍣を食べて🍺を飲んだ」ではそれぞれの対象を表す単語として用いられることもあります。[[佐藤,2015]]((https://www.slideshare.net/overlast/mecab-ipadicneologdpydatatokyo05pub-48560060))では絵文字の品詞を名詞/サ変名詞/動詞/副詞/記号/感動詞の6種類に分類しており、形態素解析に用いる[NEologd](https://github.com/neologd/mecab-ipadic-neologd)辞書にも絵文字が登録されています。

このように、絵文字を機械的な処理や研究対象として扱うには、絵文字の読み方であったり意味を表す単語、または意味的な種類で分類したカテゴリが必要になります。こうした辞書は、英語においては[emojilib](https://github.com/muan/emojilib)がありますが、絵文字は文化的に異なった意味として用いられる場合があるため、それらの対訳をそのまま利用できないことがあります。

そのため、日本語で容易に使えるリソースとして`emoji_ja`を作成しました。

---

## 💻 ダウンロード
以下のGitHubレポジトリからjson形式のファイルをダウンロードできます。`data/`配下にある各種jsonファイルが、データセットの本体です。

[yagays/emoji\-ja: 📙UNICODE絵文字の日本語読み/キーワード/分類辞書📙](https://github.com/yagays/emoji-ja)

---

## 📁 データセット
emoji-jaには下記の3種類のデータが含まれています。

- [`emoji_ja.json`](https://github.com/yagays/emoji-ja/blob/master/data/emoji_ja.json): 絵文字に対応するキーワードやメタ情報
- [`group2emoji_ja.json`](https://github.com/yagays/emoji-ja/blob/master/data/group2emoji_ja.json): 絵文字のグループ/サブグループに対応した絵文字のリスト
- [`keyword2emoji_ja.json`](https://github.com/yagays/emoji-ja/blob/master/data/keyword2emoji_ja.json): 絵文字のキーワードに対応した絵文字のリスト

### 1️⃣ `emoji_ja.json`データ
`emoji_ja.json`には、絵文字に対応する以下のメタデータが含まれています。

| カラム          | 概要                    | 取得元                                                                                  |
| :----------- | :-------------------- | :----------------------------------------------------------------------------------- |
| `keywords`   | 絵文字に関連したキーワード         | [CJK Annotations](https://unicode.org/cldr/charts/latest/annotations/cjk.html) <br>(CLDR Version 33)       |
| `short_name` | 絵文字を表す短い名前            | [CJK Annotations](https://unicode.org/cldr/charts/latest/annotations/cjk.html) <br>(CLDR Version 33)       |
| `group`      | 絵文字を意味的に分類したときのグループ   | [Emoji List, v11.0](http://www.unicode.org/emoji/charts-11.0/emoji-list.html)を元に翻訳 |
| `subgroup`   | 絵文字を意味的に分類したときのサブグループ | [Emoji List, v11.0](http://www.unicode.org/emoji/charts-11.0/emoji-list.html)を元に翻訳 |

```
{
    "♟": {
        "keywords": [
            "チェス",
            "チェスの駒",
            "捨て駒",
            "駒"
        ],
        "short_name": "チェスの駒",
        "group": "活動",
        "subgroup": "ゲーム"
    },
    "♾": {
        "keywords": [
            "万物",
            "永遠",
            "無限",
            "無限大"
        ],
        "short_name": "無限大",
        "group": "記号",
        "subgroup": "その他 シンボル"
    },
...    
```

### 2️⃣ `group2emoji_ja.json`データ

`group2emoji_ja.json`には、`group`と`subgroup`が含まれており、それらのグループ/サブグループに対応する絵文字がリスト形式で列挙されています。これらの分類は[Emoji List, v11\.0](http://www.unicode.org/emoji/charts-11.0/emoji-list.html)に準拠します。

```
{
    "group": {
        "スマイリーと人々": [
            "😀",
            "😁",
            "😂",
...

    "subgroup": {
        "顔 ポジティブ": [
            "😀",
            "😁",
            "😂",            
...
```

### 3️⃣ `keyword2emoji_ja.json`データ
`keyword2emoji_ja.json`には、キーワードに対応する絵文字のリストがリスト形式で列挙されています。`emoji_ja.json`から自動的に作成しているので、キーワードは[CJK Annotations](https://unicode.org/cldr/charts/latest/annotations/cjk.html)に登録されている日本語アノテーションに準拠します。

```
{
...
    "驚き": [
        "🤨",
        "😯",
        "😲",
        "🤯"
    ],
    "ポーカーフェイス": [
        "😐"
    ],
    "無表情": [
        "😐",
        "😑"
    ],
...
}
```

---

## 💬 翻訳について
本データセットは基本的にUnicodeにて定められた名前やキーワードを改変せず利用していますが、以下の項目は本辞書の作者が対訳を作成しております。

- グループ/サブグループ
- 国旗の名称

これらの翻訳に際しては、独自に下記ガイドラインを基準として作成しています。誤りやニュアンスが異なる翻訳がある場合は[yagays/emoji\-ja](https://github.com/yagays/emoji-ja)のissueより登録下さい。

[Translation Guideline · yagays/emoji\-ja Wiki](https://github.com/yagays/emoji-ja/wiki/Translation-Guideline)

また、これらの翻訳された文字列は、上記の理由またはUnicodeによる公式のCJK Annotationが付与された場合には更新されることがあります。

---

## ⚖️ ライセンス

[MITライセンス （MIT）](https://github.com/yagays/emoji-ja/blob/master/LICENSE.md)

---

## 📝 参考
### コーパス

- 佐藤,2015 : [🍻\(Beer Mug\)の読み方を考える\(mecab\-ipadic\-NEologdのUnicode 絵文字対応\)](https://www.slideshare.net/overlast/mecab-ipadicneologdpydatatokyo05pub-48560060)
- [日絵翻訳😍 with emojilib \- Qiita](https://qiita.com/risacan/items/7d80f7d53e3fb954a8fa)
  - 英語の`emojilib`に登録されている絵文字と単語の辞書を用いて、日本語の文字列を機械翻訳することで対応付けた事例
- [muan/emojilib: Emoji keyword library\.](https://github.com/muan/emojilib)
- [📙 Emojipedia — 😃 Home of Emoji Meanings 💁👌🎍😍](https://emojipedia.org/)
- [Full Emoji List, v11\.0](http://unicode.org/emoji/charts/full-emoji-list.html)
- [Miscellaneous Symbols and Pictographs \- Wikipedia](https://en.wikipedia.org/wiki/Miscellaneous_Symbols_and_Pictographs#Emoji_modifiers)

### 対訳

- [Unicodeの絵文字 \[SUNPILLAR情報舘\]](http://sunpillar.jf.land.to/bekkan/data/character/utf-8-emoji.html)
- [Let's EMOJI｜絵文字一覧と絵文字検索🎉](https://lets-emoji.com/)
