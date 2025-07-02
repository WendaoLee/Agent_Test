// 文章生成结果
class ArticleCheckResult{
    title string
    markdownContent string
}


// 给出文章不符合规则的修改指导意见
function CheckContent(generationArticleContent:string) -> ArticleCheckResult {
  client "CustomDeepseek"
  prompt #"
        <goal>
       你的任务是根据下方 `<inspect_rule></inspect_rule>` 标签中的规则，去检查 `<article></article>` 里的JSON的文章内容以及格式是否符合文章的格式要求，
       如果不符合，在不影响文章风格的情况下按照格式要求修正原始文章内容，最后按照JSON格式输出内容 `{
    "title": "文章标题",
    "markdownContent": "文章markdown内容"
}`
    </goal>
    <inspect_rule>
    1.文章内容的 markdown 加粗语法，前后应该存在空格。如果没有为它加上对应空格。这一过程保证原本的markdown语法不变。
    2.强调的内容不应该使用 `「」` 这样的标点符号，而应该使用中文的双引号包裹 `“”` 。
    3.检查文章内容是否缺失了换行。如果文章内容只有一段话，那么在合适的地方添加换行符 `\n\n` 以实现分段。
    4.文章字数应该在700字~800字左右，不超过六段话，如果超过了适当删减原文限制字数。
    </inspect_rule>

    <article>
   {{generationArticleContent}}
    </article>



  "#
}


test CheckContentTest {
  functions [CheckContent]
  args {
    generationArticleContent #"
        在传统产品设计领域，从构思到实现往往需要设计师和开发者反复沟通，一个简单的网页原型可能耗时数周。而 Readdy.ai 的出现，正在彻底改变这一局面。这款由 蓝湖／MasterGo 原班人马打造的 AI 工具，只需用户用自然语言描述需求，就能在数秒内生成商用级别的界面原型和前端代码。 Readdy.ai 的核心突破在于，它不仅解决了“能用”的问题，更实现了“好看且高效”的设计产出。用户无需任何设计或编程基础，只需输入类似“创建一个咖啡馆官网”的简单指令，系统就能自动生成符合现代 UX 原则的完整页面，并支持导出 HTML 、 CSS 、 React 等多种格式。这种能力让它在 Product Hunt 等平台获得高度评价，被认为是目前界面生成表现最强的 AI 工具。这款工具的成功不仅体现在技术上，更反映在商业成果上。上线仅 4 个月， Readdy.ai 就实现了近 500 万美元的 ARR（年度经常性收入） 。这种快速增长得益于三个关键因素：首先是开发效率，将传统需要数天的流程压缩至几分钟；其次是产品质量，生成的代码具备生产级质量；最后是商业模式，通过订阅制在海外市场形成了良性循环。背后的开发团队来自国内知名设计协作工具 蓝湖 和 MasterGo ，他们在过去十年积累了丰富的设计工程化经验。这种背景让 Readdy.ai 不仅是一个生成工具，更是一个完整的设计工程系统。团队对 LLM 模型的使用也与众不同，不是简单的通用模型堆叠，而是构建了从提示词到组件的完整语义映射体系。与多数仅停留在生成层的 AI 工具不同， Readdy.ai 从一开始就瞄准了“从 UI 到代码到部署”的完整交付路径。这种工程导向的基因让它比单纯的图像生成或写作辅助工具更具商业延展性。其定位类似于 Notion AI 和 Framer AI ，既能服务中小客户又可快速规模化，特别是在代码交付这类天然具备付费意愿的场景中。目前， Readdy.ai 正在推动设计工作从传统图形编辑工具向语言驱动范式的转变。这种转变不仅意味着效率提升，更代表着产品设计领域的一个全新起点。随着 AI 技术的持续发展，这类工具很可能会重构整个设计行业的生态格局。
    "#
  }
}