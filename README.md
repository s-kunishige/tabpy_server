# tabpy & jupyter notebook

### dockerコンテナの立ち上げとjupyterの使用
このプロジェクトのローカルにクローンする  
プロンプト(ターミナル)でこのプロジェクトのディレクトリに移動して`docker compose up`を実行する  
プロンプトの出力の`http://127.0.0.1:8888/?token=<tokenの文字列>`をブラウザで開くとjupyter notebookを使用できる

### tableauからtabpy serverへの接続
Tableau Desktopからダッシュボードを開いて 
ヘルプ>設定とパフォーマンス>分析の拡張機能接続の管理  
から  
ホスト名:localhost  
port:9004  
を入力

### tabpy clientからtabpy serverに関数をデプロイ
jupyter notebookからnotebookを作成して  
```
import tabpy_client

client = tabpy_client.Client("http://localhost:9004/")
```
を実行してtabpy serverへ接続

```
def 実行したい関数():
    # 実行処理
    return something # returnの型はlist
```
のように関数を定義して
```
client.deploy('tableauから呼び出す名称',
                実行したい関数,
                '説明をここに記入', override=True)
```
override=Trueにするとclient.deployのたびに関数の中身が上書きできる  

**例**

```
def kmeans(_arg1, _arg2):
    import pandas as pd
    from sklearn.cluster import KMeans

    x = pd.DataFrame(_arg1)
    y = pd.DataFrame(_arg2)
    d = pd.concat([x,y] , axis=1)

    model = KMeans(n_clusters = 2)
    db = model.fit(d)

    return db.labels_.tolist()

client.deploy('kmeans',
                kmeans,
                'Returns cluster Ids for each data point specified by the pairs in x and y', override=True)
```

### tableauからtabpy serverの実行
[サンプルのダッシュボード](https://drive.google.com/file/d/1MFTelvdyohEJd-T41TpjRVv8Y0iOWcLk/view)  
tableauから直接pythonを実行する場合はtableauの計算フィールドで
```
SCRIPT_INT(
'
import pandas as pd
from sklearn.cluster import KMeans

x = pd.DataFrame(_arg1)
y = pd.DataFrame(_arg2)
d = pd.concat([x,y] , axis=1)

model = KMeans(n_clusters = 2)
db = model.fit(d)

return db.labels_.tolist()
'

,SUM([x]), SUM([y]))
```

tabpy serverにデプロイ済みの関数を実行する場合は
```
SCRIPT_INT(
"
return tabpy.query('kmeans',_arg1,_arg2)['response']
"
,
SUM([x]), SUM([y])
)
```
