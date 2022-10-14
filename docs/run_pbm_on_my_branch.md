# forkしたリポジトリのPBMを動かす方法

forkしたリポジトリのPBMを動かす場合には、`app.rb` にある `gem 'procon_bypass_man'` を次のように変更する必要があります。  

```diff
-    gem 'procon_bypass_man', '0.3.2'
+    gem 'procon_bypass_man', github: 'splaplapla/procon_bypass_man', branch: "dev"
```

`github: xxx/procon_bypass_man', branch: "xxx"` の部分にあなたのリポジトリとブランチ名を入力してください。  
変更する行はここだけです。  
  
あとは通常通りに起動してください。
