

# 配下グループの選択

## 使用する統計表
以下の統計表をベースに説明  
URL：https://www.e-stat.go.jp/dbview?sid=0003426717


## e-Statで想定される操作
![](/assets/sample_area_filter_child.png)


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

### 5. 選択したメタを親に持つメタデータを繰返し取得
```R
cdArea <- meta_info$area %>%
           filter(name == "埼玉県")

cdAreas <- c()
while(nrow(cdArea) != 0) {
    cdAreas <- c(cdAreas,cdArea %>% pull(code))
    cdArea <- cdArea %>%
                select(code) %>%
                rename(parentCode = code) %>%
                inner_join(meta_info$area, by = "parentCode")
}
```


### 6. 取得したコードのベクトルを指定してデータを取得
```R
stats_data <- estat_getStatsData(
  appId = appId,
  statsDataId = statsDataId,
  cdArea = cdAreas
)
```

### 7. 取得した結果を表示
```R
> print(stats_data)
# A tibble: 328 × 11
   tab_code 表章項目 cat01_code 活動…¹ area_c…² 地域  time_…³ 時間軸 unit  value
   <chr>    <chr>    <chr>      <chr>  <chr>    <chr> <chr>   <chr>  <chr> <dbl>
 1 1-2019   事業所数 0          総数(… 11000    埼玉… 202000… 2020年 NA     4962
 2 1-2019   事業所数 0          総数(… 11100    さい… 202000… 2020年 NA      643
 3 1-2019   事業所数 0          総数(… 11101    さい… 202000… 2020年 NA       46
 4 1-2019   事業所数 0          総数(… 11102    さい… 202000… 2020年 NA       62
 5 1-2019   事業所数 0          総数(… 11103    さい… 202000… 2020年 NA       70
 6 1-2019   事業所数 0          総数(… 11104    さい… 202000… 2020年 NA       54
 7 1-2019   事業所数 0          総数(… 11105    さい… 202000… 2020年 NA       77
 8 1-2019   事業所数 0          総数(… 11106    さい… 202000… 2020年 NA       45
 9 1-2019   事業所数 0          総数(… 11107    さい… 202000… 2020年 NA      125
10 1-2019   事業所数 0          総数(… 11108    さい… 202000… 2020年 NA       56
```