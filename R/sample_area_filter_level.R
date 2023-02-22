
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


# 北海道と同一階層の選択
lvArea <- meta_info$area %>%
            filter(name == "北海道") %>%
            pull(level)

stats_data <- estat_getStatsData(
  appId = appId,
  statsDataId = statsDataId,
  lvArea = lvArea
)
print(stats_data)


