


# 地域を絞り込む例

sessionInfo()

library(estatapi)
library(dplyr)
library(stringr)

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

print(meta_info$area)


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



