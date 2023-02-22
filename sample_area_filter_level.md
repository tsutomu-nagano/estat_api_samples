
# 同一階層の選択

## 使用する統計表
以下の統計表をベースに説明  
URL：https://www.e-stat.go.jp/dbview?sid=0003426717


## e-Statで想定される操作
![](/assets/sample_area_filter_level.png)


## SampleCode
### 1. 必要なライブラリを呼び出し
```R
library(estatapi)
library(dplyr)
library(stringr)
```

### 2. appIdの設定（各自で取得したアプリケーションIDを設定してください）
```R
appId <- ""
```

### 3. 統計表IDの設定
```R
statsDataId <- "0003426717"
```

### 4. メタデータの取得
@つきの列名（@codeなど）はdplyrで取り回しがめんどくさいので@を削除
```R
meta_info <- estat_getMetaInfo(appId = appId, statsDataId = statsDataId)

meta_info$area <- meta_info$area %>%
                    rename_with(
                        ~str_replace(.x, pattern = "@", replacement = "")
                        )
```

### 5. 選択したメタの階層レベルを取得
「北海道」のlevelを取得して同一のlevelのデータをinner_joinで絞りこみ  
estatapiライブラリのestat_getStatsDataメソッド用にcodeのベクトルを作成
```R
lvArea <- meta_info$area %>%
            filter(name == "北海道") %>%
            pull(level)
```

### 6. 階層レベルを指定してデータを取得
```R
stats_data <- estat_getStatsData(
  appId = appId,
  statsDataId = statsDataId,
  lvArea = lvArea
)


### 7. 取得した結果を表示
```R
> print(stats_data)
# A tibble: 192 × 11
   tab_code 表章項目 cat01_c…¹ 活動…² area_c…³ 地域  time_…⁴ 時間軸 unit   value
   <chr>    <chr>    <chr>     <chr>  <chr>    <chr> <chr>   <chr>  <chr>  <dbl>
 1 1-2019   事業所数 0         総数(… 00000    全国  202000… 2020年 NA    137102
 2 1-2019   事業所数 0         総数(… 01000    北海… 202000… 2020年 NA      8862
 3 1-2019   事業所数 0         総数(… 02000    青森… 202000… 2020年 NA      1959
 4 1-2019   事業所数 0         総数(… 03000    岩手… 202000… 2020年 NA      2280
 5 1-2019   事業所数 0         総数(… 04000    宮城… 202000… 2020年 NA      2797
 6 1-2019   事業所数 0         総数(… 05000    秋田… 202000… 2020年 NA      2063
 7 1-2019   事業所数 0         総数(… 06000    山形… 202000… 2020年 NA      1617
 8 1-2019   事業所数 0         総数(… 07000    福島… 202000… 2020年 NA      3075
 9 1-2019   事業所数 0         総数(… 08000    茨城… 202000… 2020年 NA      3411
10 1-2019   事業所数 0         総数(… 09000    栃木… 202000… 2020年 NA      2148
```

