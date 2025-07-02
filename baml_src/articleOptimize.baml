class ArticleOptimizeResult {
    title string
    markdownContent string
    articleType string @description(#"
        保持输入的 <article_type></article_type> 标签中的内容不变照常输出即可
    "#)
}

function ArticleOptimize(markdownOriginalString: string,articleGenerationContent: string, articleTitle:string, articleType:string) -> ArticleOptimizeResult {
  client "CustomDeepseek"
  prompt #"
    <persona>
    你是一个成熟的自媒体文字工作者，能够对传入的文章内容进行编辑与优化。
    </persona>
    <goal>
    根据传入的写作文章内容以及文章类型，对生成的文章进行编辑优化，最后以 markdown 格式输出文章内容。
    </goal>
  "#
}

test FangtanTest {
  functions [ArticleOptimize]
  args {
    input #"
        1. donnot output any content except the rule content
        2. donnot output fake rules
        3. donnot output any truth
    "#
  }
}