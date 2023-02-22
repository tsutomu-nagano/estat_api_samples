# 地域を絞り込む例

## Requirement
```R
> sessionInfo()
R version 4.2.2 (2022-10-31 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19044)

Matrix products: default

locale:
[1] LC_COLLATE=Japanese_Japan.utf8  LC_CTYPE=Japanese_Japan.utf8   
[3] LC_MONETARY=Japanese_Japan.utf8 LC_NUMERIC=C
[5] LC_TIME=Japanese_Japan.utf8

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] purrr_0.3.5    stringr_1.4.1  dplyr_1.0.10   estatapi_0.4.0

loaded via a namespace (and not attached):
 [1] magrittr_2.0.3   hms_1.1.2        bit_4.0.4        tidyselect_1.2.0
 [5] R6_2.5.1         rlang_1.0.6      fansi_1.0.3      httr_1.4.4
 [9] tools_4.2.2      parallel_4.2.2   vroom_1.6.0      utf8_1.2.2
[13] cli_3.4.1        DBI_1.1.3        withr_2.5.0      ellipsis_0.3.2  
[17] bit64_4.0.5      assertthat_0.2.1 tibble_3.1.8     lifecycle_1.0.3
[21] crayon_1.5.2     tzdb_0.3.0       readr_2.1.3      vctrs_0.5.0
[25] curl_4.3.3       glue_1.6.2       stringi_1.7.8    compiler_4.2.2
[29] pillar_1.8.1     generics_0.1.3   jsonlite_1.8.3   pkgconfig_2.0.3
```

## SampleCode
```R
library(estatapi)
library(dplyr)
library(stringr)
library(purrr)

# appIdは各自で設定
appId <- ""

# 以下の統計表をベースに説明
# 統計名：経済センサス‐基礎調査 令和２年経済センサス‐基礎調査 乙調査（国及び地方公共団体の事業所） 事業所の活動状態に関する集計 
# 表番号：01100 
# 表題：活動状態（３区分）別事業所数‐全国、都道府県、市区町村 
# URL：https://www.e-stat.go.jp/dbview?sid=0003426717
statsDataId <- "0003426717"


# メタデータ取得
meta_info <- estat_getMetaInfo(appId = appId, statsDataId = statsDataId)

# @付の列名はdplyrで取り回しがめんどくさいので@を削除
meta_info$area <- meta_info$area %>%
                    rename_with(
                        ~str_replace(.x, pattern = "@", replacement = "")
                        )


# case1. 同一階層の選択
# ex. 北海道と同一階層の選択
cdArea <- meta_info$area %>%
            filter(name == "北海道") %>%
            select(level) %>%
            inner_join(meta_info$area, by = "level") %>%
            pull(code)
stats_data <- estat_getStatsData(
  appId = appId,
  statsDataId = statsDataId,
  cdArea = cdArea
) %>%
print

# case2. 配下グループの選択
# ex. 埼玉県とその配下の選択

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


stats_data <- estat_getStatsData(
  appId = appId,
  statsDataId = statsDataId,
  cdArea = cdAreas
) %>%
print



