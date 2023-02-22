
library(estatapi)
library(dplyr)
library(stringr)

# appIdは各自で設定
appId <- ""

# 以下の統計表をベースに説明
# URL：https://www.e-stat.go.jp/dbview?sid=0003426717
statsDataId <- "0003426717"


# メタデータ取得
meta_info <- estat_getMetaInfo(appId = appId, statsDataId = statsDataId)

# @付の列名はdplyrで取り回しがめんどくさいので@を削除
meta_info$area <- meta_info$area %>%
                    rename_with(
                        ~str_replace(.x, pattern = "@", replacement = "")
                        )

# 埼玉県とその配下の選択
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
)
print(stats_data)



