# Amazon Review Analysis

这是一个围绕 Amazon 商品评论进行文本分析的早期项目，包含英文报告、LaTeX 源文件、Python 分析脚本与结果图片。涉及词频统计、文本预处理、LDA 主题模型、K-means 聚类、朴素贝叶斯评分预测和敏感性分析。

## 目录说明

- `山东大学徐肇斌.pdf`：已生成的完整报告。
- `nlplatex.tex`、`mcmthesis.cls`：LaTeX 源文件与模板类。
- `code/`：分析脚本；`123.py` 汇总了报告附录中的主要代码。
- `figures/`：报告使用的图表与可视化结果。
- `data/`：脚本预期的数据目录。原始数据未包含在现有归档中。
- `outputs/`：脚本生成的 HTML 或 XLSX 文件目录，运行产物默认不提交。

## Python 环境

```bash
python -m venv .venv
pip install -r requirements.txt
python -m spacy download en_core_web_sm
python -m nltk.downloader stopwords
```

脚本已改为通过自身位置读取 `data/`，不再依赖旧电脑上的绝对路径。由于缺少原始 CSV/XLSX 数据，当前仓库不能完整复现实验结果；所需文件名见 [`data/README.md`](data/README.md)。

## LaTeX

源文件使用 `mcmthesis` 模板并包含 `minted` 代码块。安装相应 TeX 发行版和 Pygments 后，可在本目录尝试：

```bash
xelatex -shell-escape nlplatex.tex
```

已生成的 PDF 是最可靠的历史成品；当前 TeX 环境与原始编译环境可能存在差异。

