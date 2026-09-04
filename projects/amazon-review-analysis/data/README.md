# Data files

原始 Amazon 评论数据没有包含在现有归档中。现有脚本会在本目录查找以下文件：

- `app3.csv`
- `app4.csv`
- `app4gai3.csv`
- `app4444.csv`
- `app6.csv`
- `app6yu4.xlsx`
- `app666.xlsx`

CSV 至少会用到 `reviewText`、`summary`、`overall` 字段；部分脚本还需要 `asin`。两个 XLSX 文件作为写入预测结果的模板使用。

请仅放置你有权使用的数据，并在提交前确认其中不含个人信息或受限制内容。

