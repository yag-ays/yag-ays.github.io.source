---
title: "絵文字の日本語読み辞書をUnicode 12.0対応に更新しました"
date: 2019-07-26T11:45:37+09:00
draft: false
---

![emoji_ja_update_header](/img/emoji_ja_update_header.png)

以前に公開した[「Unicode絵文字の日本語読み/キーワード/分類辞書」](https://github.com/yagays/emoji-ja/)ですが、Unicode 12.0が公開され絵文字も追加されたので、辞書を更新しました。

前回の記事：[📙Unicode絵文字の日本語読み/キーワード/分類辞書📙 \- Out\-of\-the\-box](https://yag-ays.github.io/project/emoji-ja/)

---

## 🔖 リリース
Githubレポジトリの`20190726`リリースからダウンロードするか、現在masterブランチに含まれている各種ファイルを利用ください。

- [Release 20190726 · yagays/emoji\-ja](https://github.com/yagays/emoji-ja/releases/tag/20190726)

前回からの変更点は以下の通りです。

```
- [update] Unicode 12.0の新しい絵文字を追加
- [update] Unicode 12.0で変更されたグループ名/サブグループ名の翻訳を更新
- [fix] サブグループ名において、スペース区切りをハイフンに変更 (e.g.動物 鳥類→動物-鳥類)
```

絵文字の追加がメインですが、サブグループ名でこれまでスペース区切りで表していたものをハイフン区切りに変更しておりますので、以前のバージョンを利用していた方はご注意下さい🙏

---

## 👀 追加された絵文字
せっかくなので、追加された絵文字を少し見てみましょう。

### カワウソ
各種メディアでも取り上げられていた**カワウソ**（otter）ですが、日本語のキーワードを見ると**ラッコ**（Sea otter）も付与されているようです（[参考](https://github.com/unicode-org/cldr/blob/master/common/annotations/ja.xml#L984)）。Emojipediaの[🦦 Otter Emoji](https://emojipedia.org/otter/)を見てみると、カワウソかラッコかイマイチ区別が付かないですが、Microsoftのotterは貝を持っているのでラッコを意識してそうな雰囲気があります。

```
    "🦦": {
        "keywords": [
            "カワウソ",
            "ラッコ",
            "動物",
            "遊び好き",
            "魚を食べる"
        ],
        "short_name": "カワウソ",
        "group": "動物と自然",
        "subgroup": "動物-哺乳類"
      }
```

### 玉ねぎとにんにく
玉ねぎとにんにくも今回から追加されました。どちらも似たような外見ですが、Emojipediaの[🧅 Onion Emoji](https://emojipedia.org/onion/)と[🧄 Garlic Emoji](https://emojipedia.org/garlic/)を見比べてみると、丸みや色で区別しているようですね。Googleは唯一玉ねぎの絵文字に輪切りの状態のものを載せていて、頑張って区別しました感があります。


```
"🧄": {
    "keywords": [
        "におい",
        "ニンニク",
        "薬味",
        "野菜",
        "香り"
    ],
    "short_name": "ニンニク",
    "group": "飲み物と食べ物",
    "subgroup": "食べ物-野菜"
},
"🧅": {
    "keywords": [
        "タマネギ",
        "ねぎ",
        "玉ねぎ",
        "薬味",
        "野菜"
    ],
    "short_name": "タマネギ",
    "group": "飲み物と食べ物",
    "subgroup": "食べ物-野菜"
}
```


## 📝 参考

- [Emoji Recently Added, v12\.0](https://unicode.org/emoji/charts-12.0/emoji-released.html)
- [Unicode 12\.0 Emoji List](https://emojipedia.org/unicode-12.0/)
