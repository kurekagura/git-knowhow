# GitHubで複数アカウントを使う

HTTPSで複数のアカウントでcloneする場合は特別な方法が必要。

トークンを「Settings」-> 「Developer Settings」-> 「Personal Access Tokens」 からGenerate New Token する。Tokens(classic)でも良い。パーミッションの設定は普通のリポジトリ操作だけなら「repo」にチェックで良い。

cloneするURLを次のように変更する

```cmd
git clone https://{ユーザ名}:{トークン}@github.com/{ユーザ名}/reponame.git
```

この設定は.git/configに保存される。

## 参考・謝辞

- [githubの複数アカウントの使い分け](https://qiita.com/hbjpn/items/fe1be4a57b5868c1a86e)
