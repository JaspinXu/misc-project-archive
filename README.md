# Misc Project Archive

这是一个个人旧项目归档仓库，集中保存早期课程、竞赛、写作与求职准备材料。内容以“保留现场、方便回看”为主，不再持续维护，也不代表当前的代码风格或技术水平。

## 内容索引

| 目录 | 主题 | 主要内容 | 技术/格式 |
| --- | --- | --- | --- |
| [`projects/2023-cumcm-problem-a`](projects/2023-cumcm-problem-a/) | 2023 全国大学生数学建模竞赛 A 题 | 定日镜场光学效率建模、蒙特卡洛模拟、粒子群优化、论文与支撑材料 | MATLAB、MAT、XLSX、DOCX、PDF |
| [`projects/amazon-review-analysis`](projects/amazon-review-analysis/) | Amazon 评论分析 | 词频与文本预处理、LDA、K-means、朴素贝叶斯、敏感性分析、LaTeX 报告 | Python、LaTeX、PDF、PNG |
| [`projects/metaverse-cultural-heritage`](projects/metaverse-cultural-heritage/) | 元宇宙与文化传承 | 早期商业计划书归档 | PDF |
| [`references`](references/) | 编程资料 | ACM 常见输入输出模板与练习 | PDF |
| [`notes`](notes/) | 零散笔记 | 牛客在线笔试常见知识点截图 | PNG |

## 仓库结构

```text
.
├── projects/
│   ├── 2023-cumcm-problem-a/
│   ├── amazon-review-analysis/
│   └── metaverse-cultural-heritage/
├── references/
└── notes/
```

各项目目录中的 README 记录了文件用途、依赖和已知限制。原有项目内部结构基本保留，仅清理了构建缓存，并将 NLP 脚本中的本机绝对路径改为仓库内的相对路径。

## 使用说明

- 报告与成品优先直接查看 PDF/DOCX；源代码主要用于回顾当时的思路。
- 部分原始数据集没有随旧文件一起保存，因此相关脚本不能开箱即用。缺失文件和预期位置已在项目 README 中标明。
- MATLAB、Python 与 LaTeX 的原始版本均未记录；重新运行时可能需要按当前环境调整依赖或语法。
- 仓库按历史快照归档，不接受功能性维护承诺。

## 版权与许可

仓库中包含竞赛通知、论文、模板等第三方参考资料，其版权归原作者或原发布机构所有，仅作为当时项目背景材料保留。仓库未附开源许可证；除非文件自身另有声明，不应默认获得复制、分发或再授权的权利。

