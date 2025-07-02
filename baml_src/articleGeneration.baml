// 文章生成结果
class ArticleGenerationResult{
    title string
    markdownContent string
    articleType string
}

class RuleSet{
  content string
}

template_string SystemPromptForArticleGeneration(dateString: string) #"
    {{ _.role("system")}}

    <basic_information>
    当前日期是 {{dateString}}
    </basic_information>


<goal>
对于用户传入的文章内容，根据其中的重点内容，将文章改写为不了解文章所涉领域的人也能读懂的新文章，文章的风格偏向科普性质。
控制文章字数在 700 字左右。
最后以不使用标题以及有序列表、无序列表语法的 markdown 格式输出文章。
请注意,你的任务性质是写作，而不是总结，因此需要在写作时存在读者意识，文章是要写给人看的，要考虑阅读体验，而不是枯燥地传达信息。
需要你遵循的其他规则以 `<rule></rule>` 标签包裹，对文章类型的分类以 `<article_type></article_type>` 标签包裹，原文内容以 `<original_content></original_content>` 标签包裹，回复格式以 `<response_format></response_format>` 标签包裹。
全力以赴进行写作，输出内容必须是中文。
最后以JSON格式输出内容，`{
    "title": "文章标题",
    "markdownContent": "文章markdown内容",
    "articleType":"输入文章的类型"
}`
</goal>

<article_type>
文章通常可以归类为以下类型，因此要采取不同的写作策略，下面以 `文章类型(判断依据)` 的方式给出文章类型以及判断依据:
- 新闻类文章(文章围绕某一事件展开，具有明显的时间、地点、事件、人物特征)
- 论文类文章(核心围绕学术论文内容展开)
- 专栏类文章(作者主要阐述个人观点的文章)
- 访谈类文章(文章中存在大量的 QA 内容，围绕人物对话展开)
- 故事类文章(具有明显的讲故事特征)
- 政策发布类文章(和政府相关，通常会发布相关政策法律文件)
- 教程类文章(文章主要内容是想要教会读者什么东西)
</article_type>
"#

// 测试 Prompt 在列出规则上的不同风格的影响
function Style2ArticleGeneration(markdownOriginalString:string,dateString:string) -> ArticleGenerationResult {
  client "CustomDeepseek"
  prompt #"
    {{SystemPromptForArticleGeneration(dateString)}}

    <rule>
    1. 按照指定格式输出文章内容以及文章标题即可，对于文章内的关键词，使用 markdown 的加粗语法，并且确保前后存在空格，以保证部分渲染引擎的正常运作。标点符号遵循中文写作规范。
    2. 写作风格上，优先考虑结合原文所述的实例进行叙述，忠于原文，禁止编造实例，减少发散延伸。
    3. 留意文章讨论内容的客观事件，客观事件指文章所述内容可能涉及到现实中发生的事件，应当从"事件发生的时间""事件发生的地点""事件涉及人物"这三个角度去留意客观事件。如果文章围绕某个客观事件展开，正文中应当出现对应的内容。
    4. 对于不同类型的文章，需要采用不同的写作策略。对于新闻类文章、论文类文章、政策发布类文章结尾不用带上加有个人偏好的总结点评。
    5. 写作应该减少文学性较强的修辞手法，由于核心目标是传达能让人读懂的有价值信息，因此禁止生造无法从字面上理解含义的名词。减少不必要的赘述、车轱辘话。
    6. 如果文章所涉的外文人名在你的知识库内有明确的指向对应，那么可以使用对应的中文名，以括号的形式标注英文名。对于一些行业外文术语，在翻译的时候，同样在后面以括号的形式标注英文名。
    7. 控制文章字数在五段话（700~800字左右）以内，可以考虑减少叙述的维度实现这一点。
    </rule>

    <response_format>
    {{ ctx.output_format(
       prefix="永远以符合下方格式的JSON输出内容"
    )}}
    </response_format>

    <original_content>
    {{markdownOriginalString}}
    </original_content>
  "#
}


// 从传入的 markdown 内容中，尝试生成文章
function GenerateArticle(markdownOriginalString: string,dateString: string) -> ArticleGenerationResult {
  client "CustomDeepseek"
  prompt #"

    {{ SystemPromptForArticleGeneration(dateString)}}


<rule>
<rule_1>
按照指定格式输出文章内容以及文章标题即可，对于文章内的关键词，使用 markdown 的加粗语法，并且确保前后存在空格，以保证部分渲染引擎的正常运作。标点符号遵循中文写作规范。
</rule_1>
<rule_2>
写作风格上，优先考虑结合原文所述的实例进行叙述，忠于原文，禁止编造实例，减少发散延伸。
</rule_2>

<rule_3>
留意文章讨论内容的客观事件，客观事件指文章所述内容可能涉及到现实中发生的事件，应当从“事件发生的时间”“事件发生的地点”“事件涉及人物”这三个角度去留意客观事件。如果文章围绕某个客观事件展开，正文中应当出现对应的内容。
</rule_3>

<rule_4>
对于不同类型的文章，需要采用不同的写作策略。对于新闻类文章、论文类文章、政策发布类文章结尾不用带上加有个人偏好的总结点评。
</rule_4>

<rule_5>
写作应该减少文学性较强的修辞手法，由于核心目标是传达能让人读懂的有价值信息，因此禁止生造无法从字面上理解含义的名词。减少不必要的赘述、车轱辘话
</rule_5>

<rule_6>
如果文章所涉的外文人名在你的知识库内有明确的指向对应，那么可以使用对应的中文名，以括号的形式标注英文名。
对于一些行业外文术语，在翻译的时候，同样在后面以括号的形式标注英文名。
</rule_6>

<rule_7>
控制文章字数在五段话（700~800字左右）以内，可以考虑减少叙述的维度实现这一点。
</rule_7>

</rule>

<response_format>
{{ ctx.output_format(
   prefix="永远以符合下方格式的JSON输出内容"
)}}
</response_format>



    <original_content>
    {{markdownOriginalString}}
    </original_content>
  "#
}

function GenerateArticleWithRuleSets(markdownOriginalString:string,dateString:string,rulesets:RuleSet[]) -> ArticleGenerationResult {
  client "CustomDeepseek"
  prompt #"
    {{SystemPromptForArticleGeneration(dateString)}}

    {% for one_rule in rulesets %}
    <rule_{{loop.index}}>
    {{one_rule.content}}
    </rule_{{loop.index}}>
    {% endfor %}
  "#
}

test EmptyArticleTest {
  functions[GenerateArticle]
  args {
    dateString #"
      2025-07-02
    "#

    markdownOriginalString #"

    "#
  }
}

test GenerationArticleWithRuleSets {
  functions [GenerateArticleWithRuleSets]
  args {
    dateString #"
      2025-07-02
    "#
    markdownOriginalString #"

    "#
    rulesets [
      {
        content "规则"
      }
    ]
  }
}

// 访谈类文章测试
test GenerationFangtanKindArticleTest {
  functions [GenerateArticle,Style2ArticleGeneration]
  args {
    dateString #"
        2025-07-01
    "#
    markdownOriginalString #"
        "                     \n\n  \n\n!Image\n\n2.5亿估值、硅谷爆火，AI笔记产品Granola如何成为独角兽创始人新宠？\n======================================\n\nFounder Park Founder Park\n\n!Image\n\n笔记工具并不是一个传统意义上的热门投资赛道，在 Google Keep、Apple Notes、OneNote、Evernote 之外，只有 Notion 冲出了重围。\n\n剩下的还有 Obsidian 、Logseq 等新兴的笔记工具在卷双链。\n\n但 AI 笔记产品「Granola」活得很好，2024 年 5 月上线，依靠一些科技圈的创业者和投资人的主动传播，带来了强劲的用户增长，大量知名 VC 合伙人将其用于记录创业者路演。官方统计显示，Granola 用户中有一半以上担任领导职务，诸如 Vercel、Ramp、Roblox 等独角兽企业的创始人和高管每周都在使用 Granola 记录会议。\n\n而且最近又融资了，5 月 14 日，Granola 宣布完成 4300 万美元的 B 轮融资，估值 2.5 亿美元，在笔记赛道，这个估值很厉害了。\n\nGranola 是如何在一众 AI 笔记产品中打出差异化的？创始人 Chris Pedregal 在接受著名科技播客「Colossus」的深度访谈时提到，Granola 不仅仅是一个简单的会议转录工具，其核心关键在于「非常个人化」并赋予用户极致的「控制权」，它是一个超越简单记录、能够深度融入并赋能用户工作流程的「思考空间」。AI 的真正价值在于成为下一代强大的「思维工具」，以前所未有的方式增强和拓展人类的能力。\n\n在此次访谈中，Chris Pedregal 还分享了许多有意思、且值得深思的观点：\n\n* 对于思维工具，一个有趣的观察是：这些工具能帮助人类将需要记住的信息从大脑中「外化」出来。对于 Granola 的定位是：目前它能帮助用户生成质量最高的会议笔记，但在未来，它的目标应该是帮助人类完成几乎所有想做的工作。\n    \n* Granola 的核心是赋予用户控制权。Granola 是让用户变得更好的工具，这意味着由用户来驱动它，用户的每个决策都与此相关。大多数生成笔记的 AI 应用不会让用户编辑笔记，而是给一个 PDF 或邮件形式的「你的笔记」。Granola 的无数个微小的决策都围绕着“让用户掌控”的核心理念。\n    \n* 与 AI 协作的最大障碍之一是界面的设计。我们现在与 ChatGPT 的交互就像早期计算机的终端时代，用户输入命令，计算机返回结果。这种方式虽然不会消失，但会显得过时，用户控制感很弱。Chris Pedregal 认为，我们还没找到与 AI 协作的「方向盘」，现在的控制还很粗糙，是轮流操作——我写点东西，AI 回应，我再调整。未来会更流畅、更具协作性。\n    \n* Granola 在最初设计产品时明确地知道，在开发某个功能时，我们是「开发模式」还是「探索模式」，因为这需要完全不同的方法，是有个明确想法只需快速执行，还是未解的开放问题，需要先探索再找答案？在找到正确方向前，保护产品改方向的能力很重要。\n    \n* 现在信息和灵感来源太分散，我们往往只看一个孤岛里的数据。我想有个工具，能从我的个人生活、上下文，以及人类的集体智慧中，动态提取最相关的信息，实时呈现给我，让我能解读和利用。这个工具是什么样子，还没人知道。\n    \n\n* * *\n\nFounder Park 正在搭建「AI 产品市集」社群，邀请从业者、开发人员和创业者，扫码加群： \n\n!*Image*\n\n进群后，你有机会得到：\n\n* 最新、最值得关注的 AI 新品资讯； \n    \n* 不定期赠送热门新品的邀请码、会员码；\n    \n* 最精准的AI产品曝光渠道\n    \n\n* * *\n\n****01*** \n\n**工具是人脑处理信息的一种「外化」***\n\n****Q：「思维工具」是技术发展赋予人类的宝贵财富。当我们第一次聊天时，你对如何为人们解锁价值的思考方式让我非常着迷，你还提到 x-y 坐标图是一个很好的例子。能否就此展开，分享你对其感兴趣的缘由？****\n\n****Chris：****我认为人类的本质特征之一就是我们是工具制造者，这让我们有别于其他动物。纵观历史，我们发明了一些工具，极大地拓展了人类的能力。有趣的是，其中一部分工具是专门为辅助思考而设计的。书写就是一个典型的例子，各种数学符号系统也是如此。\n\n当我们还在使用罗马数字进行数学计算时，能在大脑中处理的范围非常有限，一旦超出就必须依赖算盘。而如今我们使用的这套数字符号系统，能让我们轻松进行大数字的乘除运算。我特别喜欢的数据可视化就是一个很好的例子。大约 200 年前，William Playfair 首次将数据以图形形式呈现，让人们能够直观地通过视觉来理解数据。\n\n人类在进化过程中形成了快速处理和理解图像的能力。将数字信息转化到视觉层面，使得人们能够凭直觉判断「这个图表是在上升还是下降，或者它的上升速度是否比之前更快」，这在 200 年前是根本无法想象的成就。我想强调的是，从数学符号、书写，到数据可视化，再到计算机，直至现在的 AI，我们正迈入一个全新的阶段。在这个阶段，思维工具的力量和效用将呈指数级增长。虽然我们无法确切预测 10 年、20 年后会是什么样子，但我可以肯定，未来的图景会与今天截然不同。\n\n****Q：对于 ****AI*** **这项新技术可能催生的新工具，你个人是如何思考的？当你最初接触到大语言模型时，最先想到的是什么？\n\n*****Chris：************对于思维工具，我有一个很有趣的观察：****************这些工具往往能帮助你将需要记住的信息从大脑中「外化」出来。目前最常见的思维工具之一就是记事本和笔。********************当你把一些事情写在记事本上，就不必强迫自己记住所有细节，随时都可以查阅这些想法或笔记。\n\n可以打个比方，这就像是扩展了你的记忆力。我们大脑的物理限制决定了它的记忆容量，而这些工具实际上为你提供了额外的存储空间。我认为大语言模型的惊人之处在于，它们能够在你需要的时候，动态地提供与当前情境高度相关的信息，而且这些信息是基于当时的具体需求实时生成的。\n\n如果在会议中通过记笔记来记录想法能够显著提高你的效率和表现，那么试想一下，如果有一台计算机能在当下为你提供所有相关的背景资料，让你在会议中表现得更加出色，那会是怎样的情景？由于大语言模型能够即时重塑和提炼信息，我相信这将极大地增强个人的能力。\n\n********************Q：这是如何实现的？是不是意味着我生活中的一切，比如我读过的书、参与的对话，最终都被存储起来，然后通过某种机制将我的当前情境反馈给系统，它就能提供想法或头脑风暴的建议？****************\n\n************Chris：************在深入讨论 Granola 的具体功能之前，我想先说明一点：在 AI 这个领域，预测未来一两步相对容易，但要想看到十年、二十年后的景象则非常困难。\n\n************可以把 Granola 想象成一个数字化的笔记本。就像你电脑上的 Apple Notes 应用一样，你可以在上面记笔记。但 Granola 最显著的不同在于，它还能「听取」你正在讨论的内容。********\n\n比如在会议中，你可以随时记录任何笔记或闪现的想法，而 Granola 会实时捕捉对话内容并进行转录。会议结束后，它会根据你记录的笔记来进一步完善和丰富转录内容，让最终的笔记更加完整和有价值。这样你就无需事无巨细地记录下会议中的所有内容，而是可以专注于那些关键的洞察点或你独有的思考和判断，把那些繁琐的记录工作交给 AI 来完成。\n\n这样做有什么优势呢？我们目前可能还没有完全理解它将如何彻底改变人们的工作方式，但我可以肯定它正在带来改变，因为我的工作方式已经因此发生了变化，Granola 的许多用户也是如此。********目前我们可能只实现了我们愿景的 5%。************但当你回过头去查看会议笔记时，你能够获得会议的完整背景信息。\n\n你甚至可以直接与 Granola 进行交互，询问会议中讨论了哪些内容，或者提炼出会议的主题。****************我们目前还有一个内部功能尚未正式发布，它可以让你查看与某个特定人物或某个主题相关的所有历史会议记录，并从中整合和提取跨会议的共同主题或信息。********************这些本来很容易丢失或被遗忘的背景信息——也许你曾经记在某个笔记本上，却怎么也找不到了，或者在需要做出相关决策时根本不会去翻找——现在都变得触手可及，可以即时获取。\n\n********************02**************** \n\n************Granola 很高效地利用了上下文窗口********\n\n********Q：Granola 对你自己的工作方式产生了哪些改变吗？作为最深度使用它的人，你的实际行为有哪些变化？********\n\n********Chris：************我认为这种工作方式的转变将会越来越普遍。对于像你我这样的知识工作者，我们总是不断思考「在当前这个时刻，我需要掌握哪些背景信息，才能最有效地发挥我的智力优势？」对于那些使用 ChatGPT 或其他大语言模型的人来说，他们会熟悉「上下文窗口」的概念——你可以输入一定量的信息，相当于告诉模型「这是当前的情况，这些是你需要了解的背景知识」。\n\n其实，这种思维方式同样适用于我们人类，而且我们一直以来就是这样思考的。举个例子，当我需要写一篇博客文章时，以前我会随手拿起一个笔记本，快速记下一些零散的想法，然后尝试将它们组织成文。现在我会先和几位经验丰富的朋友交流，他们给了我很多宝贵的建议。我使用 Granola 记录这些对话，这样我就同时拥有了我的手写笔记和完整的对话转录。\n\n接下来，我会利用 Granola 的录音功能（此处可能指转录内容下的交互功能）进行头脑风暴，然后把相关的材料都整理到一个 Granola 文件夹里，并与 AI 互动，让它帮助我提炼主题或建议文章的整体架构。最终，博客文章还是由我自己来写，但这个过程让我能够以一种非常高效且令人惊喜的方式整合所有收到的建议。我可以肯定地说，如果没有这个工具，我很有可能会遗漏一些重要的内容。这是第一个例子。\n\n另一个例子是我们观察到的 Granola 用户的行为模式变化，****************他们记笔记的方式与以往截然不同****************。那些深度使用 Granola 的用户在会议中只记录非常少的几条笔记，这些笔记通常是他们自己的一些即时想法或判断，而不是对话转录中已经包含的内容。比如他们可能会记下「这个人似乎有点咄咄逼人」、「他们情绪看起来不太高」，或者「我对此领域有些担忧，他们并没有真正回答我的问题」——这些才是最关键、最个人化的判断。其他所有的对话内容都可以放心地交给 AI 去转录。\n\n当他们之后回头查看 Granola 中的笔记时，往往不会一字一句地阅读全文，而是带着特定的问题或想要查找的信息，直接向 AI 提问，从而快速获得高质量的答案，这种方式效率要高得多。\n\n************Q：能否谈谈从 5%到 100%的愿景？你提到大语言模型只能预测几步，但展望两三步后，你认为接下来会走向何方？********\n\n********Chris：************说到底，****************问题的核心在于「在当前这个关键时刻，我需要哪些信息才能做出最明智的决定？」********************设想一下这样的情景：如果你是一位 CEO，在进行一场至关重要且风险极高的谈判之前，你的团队会为你准备一份详尽的背景资料包，其中包含了所有相关的必要信息。我相信，未来每个人在参加每一次会议之前，都能实时获得这样一个定制化的「资料包」。\n\n有意思的问题在于，哪些背景信息才算是真正有用的？是仅限于上次会议的内容？还是你所有的电子邮件？抑或是全世界的信息？同时，用户界面又会是什么样的？************************我对 Granola 的定位是：目前它能帮助你生成质量最高的会议笔记，但在未来，它的目标应该是帮助你完成几乎所有你想做的工作。************************\n\n举个例子，你结束会议走出房间，可能需要立即撰写一封会议的跟进邮件、一份投资备忘录，或者组织一场多方参与的活动。Granola 或类似的工具，在掌握了所有必要的背景信息之后，应该能够帮你完成其中 80%、90%甚至是 95%的工作。我和 Granola 团队都非常强调一个理念：我们认为 AI 的核心价值在于赋能人类，让用户变得更强大。当然，我们也可以用 AI 来替代某个人或某个特定的任务，但我们更倾向于用它来增强人类的能力、提升智力和表现。我们坚信，工具理应是用来帮助人类去做更多、实现更多、思考更多的。\n\n我们所做的一切设计都围绕着这个核心理念展开：Granola 可以帮你处理撰写跟进邮件这类繁琐的事项，但你需要在此基础上加入自己的思考和判断——这才是真正有价值的部分，也是能否说服他人的关键所在。你只需要在 AI 生成的基础上稍加修改和完善，而不是被所有细节所困扰。\n\n********************03**************** \n\n************Granola 的产品哲学：********\n\n********赋予用户控制权********\n\n********Q：你们有没有一套很明确的产品哲学，用来指导平时做决策？********\n\n********Chris：************我的个人方法是，大多数优秀的产品思维和设计可以归结为一个简单问题：****************使用产品时，凝视它时，问自己「这让我感觉如何？」反复问这个问题，认真倾听答案。然后把同样的产品、界面或按钮给另一个人，问他们同样的问题。****************\n\n这样做一百次后，你会发现，在看到产品的最初 500 毫秒内，你会感受到十种情绪。这些情绪转瞬即逝，但往往会告诉你「太复杂了」，「太杂乱了」，「我不知道该做什么」，「这让我不安」。如果有个情感记录器能慢放这些反应，就能告诉你如何让产品变得更好。当然还有其他重要因素，但这个问题是个绝妙的指引。\n\n************Q：刚才说的是你个人的哲学。那对于 Granola 这个产品来说，有没有一套它自己独有的产品哲学？跟你的个人哲学有什么不一样的地方吗？********\n\n********Chris：Granola 的核心是赋予用户控制权。************Granola 是让你变得更好的工具，这意味着你来驱动它，我们的每个决策都与此相关。即便是最基础的设计，它也是一个编辑器。\n\n大多数生成笔记的 AI 应用不会让你编辑笔记，它们给你一个 PDF 或邮件形式的「你的笔记」。我们的无数微小决策都围绕着让用户掌控的核心理念。\n\n************Q：你们的用户群体是怎样的？有没有让你觉得意外的地方？他们的职业类型主要是什么？有没有集中在某个特定的行业？你们从实际的用户数据里学到了什么？********\n\n********Chris：************这很有趣，我们的用户是倾向于使用 AI 的人，他们拥抱新工具和新工作方式。这对应到很多创始人、投资者，以及在 AI 领域跨学科工作的人。****************AI 初创公司里用 Granola 的营销人员比例非常高。********************愿意尝试这些工具的人和不愿尝试的人之间有一条明显的分界线。\n\n********************Q：这听起来很有道理，就像 Geoffrey Moore 在《跨越鸿沟》一书中提到的，总是会有一批「天然的早期采用者」。****************\n\n************Chris：************我记得一个怪事。我们在去年五月发布 Granola，距今八九个月了。我做产品很久了，但这次很「超现实」。产品刚发布时有些人发了推文，我们挺开心，没指望大爆。几周后，一些我们不认识的著名 CEO 开始发推文，然后在 Twitter 上给我发私信提产品反馈。Granola 与某类人群产生了共鸣，而这类人又在社交媒体上很活跃。我的 Twitter 私信基本上成了大科技公司 CEO 的客服渠道，真是很怪的体验。\n\n************Q：我也是通过这种方式联系到你的，确实是个快速认识人的有趣方式。回到产品构建上，有没有哪个重要的节点或决定，当时可能觉得是挑战，但事后看却是个惊喜的转折点？********\n\n********Chris：************至少对 Granola 来说，我们早期决定把它做成 Mac 应用，而不是加入会议的机器人或网页工具。有很多实现方式，这个决定带来了很多麻烦。比如最初，Granola 只能在 macOS 13 上运行，当时只有 15%的 Mac 用户用这个版本。\n\n我们这么做的原因是想让它像笔记本和铅笔一样，无论你在 Zoom、面对面还是 Slack Huddle （Slack 平台上的一款纯音频会议功能）上，都能随时拿起 Granola 使用，不用多想。工具的重要特质是可靠性和一致性，让你知道如何使用。\n\n做 Mac 应用带来了很多意想不到的好处，它就在你电脑上，更即时、更可控、更容易获取。人们使用 Granola 的亲密感很大程度上是因为它是桌面应用，而不是藏在浏览器 50 个标签里的网页。我们可能稍微自夸了一下，但这个决定比我们当时意识到的要好得多。\n\n************Q：在这个过程中，有没有什么重大的问题或者方向，是让你后来改变了原有看法的？********\n\n********Chris：************是的。在我们最初设计 Granola 时，交互模式完全不同。我们实验的第一个版本是，你在会议实时输入一两个关键词，按 Tab 键，Granola 会实时写出完整笔记。演示很酷，用起来有点魔法感。\n\n我们花了六个月试图让这功能完善，但失败了。我们发现，无论笔记写得多好，实时生成都会让人忍不住去看，结果非常分散注意力。\n\n************Granola 的初衷是让你更专注于会议，但这适得其反，人们盯着笔记看，如果不满意就去改，然后发现没听人讲话，这就太糟了。************于是我们彻底改成更平凡的模式：会议中它就是普通文本编辑器，像记事本，「魔法时刻」在结束后发生。\n\n!*******Image*******\n\n这意味着 Granola 的价值要在用完一场会议后才显现，不太理想。构建产品时，你希望「魔法时刻」在前 20 秒出现。但这让产品好太多了。我们花六个月走错路，直到终于接受有更好的办法。\n\n************04********\n\n不保存音频的 AI 会议工具\n\n********Q：我很好奇你在开发过程中遇到的一些具体问题，比如录音这件事。我感觉越来越多的人会请求录制会议，一开始我很不适应，但现在似乎变得正常了。你认为我们会走到一切都被默认录制的地步吗？能否解释一下你们的方法？同时，你认为未来会怎样发展？********\n\n********Chris：************我认为作为一个社会整体，我们确实需要认真权衡其中的利弊。我相信再过几年，如果在开会或进行工作交流时不使用像 Granola 这样的工具，很多人会感到非常不便，因为这些工具的功能将变得极其强大和实用。\n\n然而，正如你所指出的，这确实涉及隐私方面的权衡。我们需要在最大程度地发挥工具的实用价值与最小化对个人隐私的侵犯之间找到一个合理的平衡点。至于这条界线最终会划在哪里，目前我也无法确定。我们在最初开发 Granola 时，是经过深思熟虑后决定不录制或存储任何音频数据的。尽管 Granola 会实时监听音频并进行转录，但原始音频文件本身并不会被保存。\n\n很多人对此感到不解甚至有些嘲讽，问我们为什么不保存音频，难道音频记录不重要、没用吗？当然有用！能够回听某人的原话，了解他们的语气，这确实会损失一部分用户原本可以获得的价值。但这同时也意味着，Granola 在安全性上远远超过那些会加入你会议并进行音视频录制和存储的 AI 机器人。那些机器人会把音视频内容存储下来，谁知道这些数据最终会被保留多久？\n\n在我看来，Granola 在这方面的体验是完全不同的。它能够生成高质量的会议笔记，提供非常有用的转录文本，但它的「侵入感」要低得多。我认为真正的问题在于，当我们将这类工具应用到现实世界，特别是工作场景之外时会是怎样的。在 Zoom 会议这类有明确目的和预期的环境中，大家通常都能理解并接受录音。但在社交生活中，我相信其行为规范会截然不同。我个人也不知道未来的具体走向，但在工作场景下，绝大多数人是希望能够捕捉这些信息的，因为 AI 为用户带来的价值巨大。而在社交场合，这很可能会引发争议。\n\n你还记得当年 Google Glass 刚推出时，因为它可能在不知情的情况下录制他人，引发了公众多么强烈的反弹吗？我完全可以想象，当 AI 穿戴设备或「挂件」变得流行起来时，可能会再次出现类似的情况。如果有人在派对上佩戴这种设备录下现场的一切，很可能会引起在场其他人的反感。\n\n************Q：你觉得要等多长时间，线下开会才能像线上 Zoom 会一样，大家默认对录音有差不多的预期？我已经非常想达到这种状态了。********\n\n********Chris：************我们的 iOS 版本即将上线（已经上线）。我和我的联合创始人Sam Stephenson最初开发这个工具完全是因为我们自己有这样的需求。说实话，我们没有想到它会受到如此广泛的欢迎。一旦人们开始习惯使用 Granola 来记录那些重要的工作交流，你实际上是将一部分个人记忆能力「外包」给了它，你会很自然地期待能够随时方便地回顾任何一场对话中的关键信息。\n\n我们收到过一些用户发来的、措辞非常急切甚至可以说是「愤怒」的邮件，描述的正是你刚才提到的那种情况：「我参加的三分之一的会议都是面对面的，感觉就像是空手去战斗，非常迫切地希望能在现场使用 Granola。」对于我们正在构建的 Granola，我相信这类辅助工具最终将会普及开来，被所有人使用。\n\n至于社会层面的规范会如何演变，我个人并不倾向于那种所有交流都被偷偷录下的未来，尽管我知道这在硅谷的一些人看来是一个潜在的发展方向。\n\n我个人认为，在工作场合，仅仅使用手机作为工具就足够了。当你把手机放在桌上时，与会者之间很容易就能形成一种默契的「社交契约」，大家都清楚正在发生什么。我们在 Granola 内部的工作方式就是这样：每一场会议，大家都很清楚是否有手机在进行笔记记录，以及是谁的手机。我认为这种透明化的社交契约非常重要，个人需要像管理工作中的其他事项一样，自觉地去维护它。如果你能坦诚地将手机放在桌面上，所有人都能从中受益。我觉得在工作场景下，这种行为模式的转变可能会比你预期的来得更快；而在社交场合，情况则会截然不同。\n\n************05********\n\nAI 应用最大的障碍：\n\n没找到与 AI 协作的「 方向盘」\n\n********Q：从你们的经验看，一个关键启示是不是需要更好地构建上下文收集工具？你们正在为「对话」做这个，那其他上下文呢？能不能围绕「上下文收集」这个功能点，畅想一下？********\n\n********Chris：************收集上下文——获取所有数据——其实不难。用不了多久，我们就能把所有邮件、笔记、公司文件、推文都输入到 Anthropic 或 ChatGPT 中。但另一个问题是，这些数据中哪些与我当下要做的事真正相关？这可能是技术问题，也可能是用户界面问题。\n\n我认为，****************与**************** ****************AI**************** ****************协作的最大障碍之一是界面的设计。********************我们现在与 ChatGPT 的交互就像早期计算机的终端时代，你输入命令，计算机返回结果。这种方式虽然不会消失，但会显得过时，用户控制感很弱。\n\n我查过一个类比。最早的汽车没有方向盘，只有一个操纵杆，可以左右转动。如果开得很慢还行，但速度一快，这个杆子就没法用，稍微动多一点就可能冲出路，安全问题很大。后来有人发明了方向盘，这个界面让驾驶者有了更精细的控制。我认为********************我们还没找到与**************** ****************AI**************** ****************协作的「方向盘」****************，现在的控制还很粗糙，是轮流操作——我写点东西，AI 回应，我再调整。未来会更流畅、更具协作性。\n\n************Q：你能不能再具体展开讲下，这种更流畅的交互会是什么样子？它跟我们现在这样，你一句我一句、来回操作的方式有什么不同？********\n\n********Chris：************取决于工具。但现在感觉我和 AI 不在同一个画布上工作，而是并排在两个画布上。一个很基础的事情是，在 ChatGPT 或 Claude 中，你不能直接编辑 AI 的回答。你不能进去说「这个点很蠢，改改语言」。你得命令它「请缩短一点」，然后希望它按你想要的方式重写。不久后这会显得很疯狂。\n\n有个历史类比，这些发明出来后会显得很明显。早期的文本编辑器有「模式」概念，比如插入模式，你进去写字，然后退出，再进入删除模式或复制模式。Larry Tesler 发起了一场变革，让这些操作变得流畅，不用切换模式，在当时是不可想象的。\n\nAI 的未来也一样，很难预测具体模样，但我保证会与现在完全不同。控制的颗粒度和协作速度会大幅提升，体验会更流畅。\n\n注：Larry Tesler，斯坦福人工智能实验室成员，主要研究领域为人机交互 。他因发明并命名现代计算机中广泛使用的「剪切、复制、粘贴」命令以及「查找与替换」（find & replace）功能而闻名。\n\n************Q：有没有一些用户使用 Granola 的方式让你觉得特别意外或者眼前一亮？********\n\n**Chris：********有几件事让我印象深刻。一是使用场景的多样性。我们是为工作会议设计的，但很快就有人说：「我伴侣得了癌症，我们要和医生开很多会，Granola 在这过程中无比宝贵，我不知道以前怎么应付。」这是个意外的用例。\n\n还有人会创造性地给 Granola 输入更多上下文，不是我们设计的功能。比如，有人会开一个 Granola「会议」，自言自语地头脑风暴，或规划一天，说出要做的事，然后让 Granola 帮忙优先级排序。还有人看 YouTube 视频学习时开着 Granola，一边看一边记笔记。这是最大的惊喜。\n\n另一个行为变化是，人们越来越少直接读笔记，而是更多地通过 Granola 的聊天功能询问想找的信息。\n\n*****Q：Granola 具体是怎么评估模型***的？另外，你们会随时切换、使用当下表现最好的模型吗？******\n\n******Chris：******完全正确。评估模型能力不简单，但你描述的就是我们的做法。**********我们不是只用一个模型，而是在 Granola 内部用多个模型，以不同方式组合，我们会随时切换到当天最好的模型。**********\n\n******Q：你怎么看待你们产品跟用户直接使用基础模型的竞争？就像以前问大公司会不会自己做一样，现在大家也问模型公司会不会做你们这样的应用。你在设计产品时，怎么考虑不被模型公司抢「饭碗」的？******\n\n******Chris：******我没有「水晶球」，不能预知未来，但我的看法是，有两个关键轴线：一是使用频率，我是每月用一两次还是每天用 500 次？二是我需要在这件事上表现得多好？\n\n******低频且不需要太出色的任务会被通用系统吃掉。******大多数消费者用例属于这一类，因为低频用例很难养成使用新工具的习惯。如果只需要「还行」的效果，像 Claude 这样的通用助手就够了，而且用得越多，它对你就越好。\n\n******另一端是高频且需要极佳表现的用例，这是「专业工具」领域，总会有人需要顶级工具。******Granola 就属于这里。你可能会问「模型如果变得够聪明，不就能全包了吗？」我的回答是，这不是智能的问题，而是用户界面对这个用例的优化程度。如果一款产品专注于某个用例并做到极致，它的体验会比通用工具更好。限制因素在于产品设计和用户体验的优化，而非底层技术。\n\n******06**\n\n******在找到正确方向前，******\n\n******保护产品「改方向」的能力很重要******\n\n******Q：如果把模型提供商和应用开发者看作是竞争层面，你们如何通过产品架构增强 Granola 的用户粘性和价值？怎么确保用户不会轻易转向性能更好的竞品？当然你们还在早期，主要精力在做好产品，但有没有开始考虑这方面？******\n\n******Chris：**********在这个领域，唯一答案是，你得比别人更快地造出更好的东西。有切换成本，有小的「护城河」，**************但唯一取胜之道是持续比别人更快地产出优于他们的产品。**************\n\n像 Granola 这样的产品有内在切换成本，因为它掌握的上下文越多，对你就越有用。其他产品得比 Granola 强很多，用户才可能放弃。但我觉得如果懈怠三个月，你就麻烦了。\n\n**********Q：你和团队是怎么做到快速迭代的？作为一个****** ******AI****** ******应用公司，你们在这方面的思考和实践是怎样的？有没有特别奏效或失败的方法？******\n\n******Chris：**********我们很明确地知道，在开发某个功能时，我们是「开发模式」还是「探索模式」，因为这需要完全不同的方法。是有个明确想法只需快速执行，还是未解的开放问题，需要先探索再找答案？\n\n如果知道要打造什么，我们的经验是大家常听的建议：尽快建 MVP，给自己截止日期，推给真实用户——不一定是所有人，然后尽量加快迭代速度。\n\n我们以前遇到麻烦，因为没搞清模式，把「尽快发货」的哲学用在开放问题上，结果是仓促推了个烂产品给用户，觉得自己「两周搞定，太棒了」，但其实没解决问题。发布了，但没解决用户需求。\n\n在这个领域尤其重要，因为压力让你必须快节奏，但偶尔多花时间想想怎么做好真的很关键。比如我们花了一年才推出 Granola，已经比 AI 笔记领域晚了七年。如果我们把最初的交互模式公开推出，就没法改了。用户会学会新行为，留下来的会喜欢，但留存率不会高，那就完了。**************在找到正确方向前，保护产品改方向的能力很重要。在快节奏领域中平衡这点，是个挑战。**************\n\n**********Q：你的野心或者说目标，有没有随着产品发展在调整？按 1 到 10 分打，你现在给自己打几分？跟刚开始做比，分数有变高吗？******\n\n******Chris：**********我每天都在问自己，我们做得对吗？Sam Stephenson 在与我研究和测试大语言模型时，发现所有的工作工具都会被重建或重塑。\n\n我们觉得会有个新软件类别，还没名字，你我这样靠人际沟通、项目、会议工作的人会整天用它。这是我们第一天就想建的，现在也是。如果你不是 OpenAI 或 Anthropic，就必须在当下某个用例上特别优秀，不能只建未来的伟大产品。每一步都得对用户超级有用。\n\n你要想清楚：你花多少时间构建接下来五件明显有用的东西，还是大胆一搏？我们想让 Granola 从记笔记工具变成人们做大部分工作的工具。如果你要写文档或备忘录，在 Granola 里应该更容易，因为它知道你工作的所有相关背景。但这是一大步，做好需要大量工作和迭代。\n\n**********Q：设想一下，未来有公司做得比 Granola 好。如果你是他们的****** **VP，会担心哪些重大的市场冲击？**\n\n**Chris：**我觉得你可以担心一堆事，但得挑着担心，因为很多事你控制不了。******我们在 Granola 选择担心的是还没发布产品的竞争者。那种初创公司能看到我们和其他人弄明白的东西，从那个起点开始，比我们更快执行。******\n\n我惊讶于科技巨头的超快反应，ChatGPT 火了后，每家大公司都调整战略，我对他们的领导力印象深刻。但决定做不代表能做好。我们有个投资人说过，列出你每天用的 AI 功能，有多少是大公司做的，有多少是初创公司做的？令人惊讶的是，初创公司占了不少，尽管大公司投入了巨资来打造这些 AI 功能。\n\n这会随时间改变吗？也许吧。初创公司常是大公司的研发部门，一旦东西弄明白，他们能整合到庞大用户群。但属于这个世代的公司会更早弄明白关键，然后借此变得巨大。\n\n**07**\n\n**在** **AI** **应用公司，**\n\n**小团队能干大事**\n\n**Q：我最近对一个现象特别感兴趣，就是现在** **AI** **应用领域里那种「小团队也能做出大产品」。一些非常厉害的 AI 工具，团队规模可能连 25 人都不到，但即使用户和收入都在快速增长，团队人数也没有明显扩张。在这样一个领域做公司，跟你在 AI 出现之前做的那些公司比起来，有什么不一样的体验吗？**\n\n**Chris：******我认为当前 AI 领域有两个非常突出的特点：第一是技术发展的速度快得惊人；第二，**********对于像 Granola 这样构建在大语言模型之上的应用层产品来说，我们能够从底层技术的快速进步中极大地受益。**************我们投入了大量精力去思考如何为用户打造极致的、端到端的优秀体验。如果缺乏底层这些强大的技术基础，我们可能需要一个规模庞大得多的团队才能实现目前的功能和效果。\n\n即便如此，Granola 之所以能够脱颖而出，******************很大程度上得益于我们对技术细节和边缘案例的关注。**********************有些问题可能是你平时不会想到的，比如用户在会议中途摘下了 AirPods 耳机，或者在一个包含多个音频通道的 Zoom 会议中，Granola 需要进行一些特殊处理，才能确保用户体验的流畅和无缝。我们正在尽可能地在内部工作中采用 AI 工具，但不得不说，目前一些相关的开发工具还不够成熟。\n\n我们距离完全实现端到端的自动化还有一定的距离，因此仍然需要投入大量的人力和工作。我个人不太喜欢预测具体的时间点，因为在这个领域，进行长期预测几乎是不可能的。但如果我们将时间快进三年，我认为我们的工作方式以及能够外包给 AI 的任务种类将会发生天翻地覆的变化。\n\n**********************Q：这方面的挑战主要集中在工程层面是吗？你是否设想过未来引入 Cognition、Cursor 或其他工具，团队就能像管理者而不是工程师，只需告诉系统做什么，而不用亲自设计端点？******************\n\n**************Chris：**************没错，确实如此。我们的 CTO 设定的一个目标就是，尽可能减少 Granola 团队每位工程师需要编写的代码行数。我们最近组织了一次很有意思的团队活动，主题就是「在任何你意想不到的场景下使用 AI，挑战我们的固有思维和舒适区」。我有一个很棒的例子可以分享：当时我在西班牙，想给团队烤虾，虽然买来了虾，但我之前从没有烤过。我直接在 ChatGPT 里输入「怎么烤虾」，结果CTO 告诉我：「不对，你必须给它更准确、更丰富的上下文信息。」\n\n他让我把烤架和虾都拍了照片，上传给 AI，结果证明他是对的。我们发现那些虾其实是已经预煮过的，包装袋上的西班牙语我们当时没看懂，所以根本就不用「烤」，只需要稍微加热一下就可以了。如果我只是简单地输入文字提问，是绝对不可能发现这个关键信息的。这个例子很好地说明，******************要想充分利用这些新工具，你需要建立一套全新的直觉和思维模式，**********************就像当年互联网刚出现的时候，上一辈人不会自然而然地想到用 Google 搜索，而年轻一代却习以为常一样。\n\n我相信「AI 原生代」的用户会非常自然地理解应该向 AI 提供什么样的上下文，以及如何更有效地与 AI 进行协作。当他们遇到不确定的时候，可能会本能地提供更多的背景信息，看看 AI 会给出什么样的结果，而不是想当然地直接提出问题。我今年 38 岁了，自认为对这些新技术很敏感，也每天都在思考它们，但即使是我，团队有时候还会提醒我——我使用 AI 的频率和深度还不够。如果连我都这样，那普通大众的情况就可想而知了。\n\n**********************08******************\n\n**************不要把你的思考外包给********** **********AI**********\n\n******Q：抛开现在所有技术的限制，大胆地去畅想一下，你觉得未来五年、十年后，我们使用的「思维工具」会进化成什么样子？**\n\n**Chris：******我想让它们更人性化、成为让人们变得更好的工具。主要是解锁我们的创造力，释放人类独有的惊人能力。打造 AI 工具的人必须有意识地朝这方向努力，因为这里有一个方向：你想外包所有重复、枯燥、无脑的工作，但不想外包判断。\n\n你提到生成想法，让 AI 给 100 个点子，你挑合适的，这很好。但危险的地方在于，大家都这么做，最后变得只会挑选 AI 的想法。比如「写作即思考」，如果 AI 全程代写，有些是无价值的重复劳动，但有些是你思考的部分。如果不小心外包了这些，就有风险。\n\n现在信息和灵感来源太分散，我们往往只看一个孤岛里的数据。我想有个工具，能从我的个人生活、上下文，以及人类的集体智慧中，动态提取最相关的信息，实时呈现给我，让我能解读和利用。这个工具是什么样子，还没人知道。\n\n******Q：我之前见过一个朋友做了一个特别酷的演示：他把麦克风连接到一个类似** **Midjourney** **的工具上，在你说话的时候，它能以每秒五帧或八帧的速度实时生成并投影出和对话内容相关的图像。他用这个来做一些创意性的体验。不过就像你说的，想象一下这应用在工作场景里会怎么样？它一边帮你把思考过程「外化」出来，一边还能给你一些你想不到的信息或灵感点子。但真的要做到既非常有用，同时又完全不让你分心，其实难度是很大的。**\n\n**Chris：******科幻里有很多绝妙点子，实践起来却因琐碎的战术原因行不通，就像实时写笔记会让人分心。**********人类体验定义了「什么行得通」。**********\n\n******Q ：聊聊投资人吧。你从非常优秀的投资人那里融到了资，肯定也跟不少人聊过。现在科技圈和私募市场的投资人基本都把目光聚焦在** **AI** **浪潮上，他们特别想知道怎么才能跟创始人、跟这些新的 AI 应用公司更好地互动，把钱投到最有潜力、最有效率的地方。你有没有什么建议给这些投资人？比如说，可以分享一下你合作过的最好和最差的投资人分别是什么样的，他们做了什么？**\n\n**Chris：******我不是投资人，很难给建议。我可以说什么对我有吸引力。我提到打造新功能时要分「开发」和「探索」模式，AI 整体是个探索问题，没人知道正确答案。\n\n基础模型可能进入开发模式，但应用层完全是探索。这需要特定敏感度，我觉得是以产品为中心，深入思考什么对用户是好的产品，能和我深聊这方面的投资人不是很多。\n\n能让我注意的是，能够在建立联系的邮件中写出对产品行为或空间的具体 insights，哪些地方 Granola 做对了或错了。我想找长期合作的伙伴，共享世界观和解决问题的方式。具体的执行会变，但有没有相似的思维框架？我和我的投资人就有这些，他们是优秀的产品思考者，能在多层次互动。\n\n******Q：你觉得，一个成功的** **AI** **工具，有没有可能不依赖数据优势？比如不像有些公司有独有数据，也不像你们那样积累第一方数据。没有数据壁垒的 AI 应用还能成功吗？数据是不是决定产品可持续性和优势的关键？**\n\n**Chris：******现在数据需求没那么大了，获取一点数据既不贵也不难。趋势是，基础模型能理解世界，做很多事，再加一点数据就能针对用例优化。以前机器学习需要几百万样本，现在 5 万个就行，即便贵点的数据，5 万也不难。\n\n我在想什么数据是拿不到的。我觉得很快人人都能建应用，但对世界的影响还不清楚。我想到摄影的例子。早期，会用相机，你就超过很多人，因为相机很贵，还有很高的学习成本，现在人人兜里有手机，大家都是摄影师，能拍出惊艳的东西。**********但同时，对「品味」的溢价更高。如果你真很出色，能脱颖而出，可能更值钱。**********\n\n******Q：最后一个问题，你为什么选择做 Granola？**\n\n**Chris：******我在打造我相信且觉得重要的东西时最开心，不然就不开心。我就是这样的人。\n\n!****Image****\n\n******* * *\n\n****更多阅读**\n\n<ins>北大校友、OpenAI前安全副总裁Lilian Weng关于模型的新思考：Why We Think</ins>\n\n<ins>独家对话Lovart创始人陈冕：我们没有产品经理，只有设计师</ins>\n\n<ins>付费用户突破 1000 万，All in AI 的多邻国，是怎么用 AI 的？</ins>\n\n<ins>Agent 产品如何定价？一文说清 AI 产品的四种付费模式</ins>\n\n转载原创文章请添加微信：founderparker\n\n继续滑动看下一个\n\n轻触阅读原文\n\n!Image\n\nFounder Park\n\n向上滑动看下一个"
    "#
  }
}

// 技术类文章
test GenerationTechArticleTest{
  functions [GenerateArticle]
  args {
    dateString #"
      2025-07-01
    "#
    markdownOriginalString #"
Gemini 2.5: Updates to our family of thinking models
JUNE 17, 2025
Shrestha Basu Mallick
Group Product Manager
Logan Kilpatrick
Group Product Manager

Share
Today we are excited to share updates across the board to our Gemini 2.5 model family:

Gemini 2.5 Pro is generally Gvailable and stable (no changes from the 06-05 preview)
Gemini 2.5 Flash is generally available and stable (no changes from the 05-20 preview, see pricing updates below)
Gemini 2.5 Flash-Lite is now available in preview
Gemini 2.5 models are thinking models, capable of reasoning through their thoughts before responding, resulting in enhanced performance and improved accuracy. Each model has control over the thinking budget, giving developers the ability to choose when and how much the model “thinks” before generating a response.

Overview of our family of Gemini 2.5 thinking models
Overview of our family of Gemini 2.5 thinking models
Introducing Gemini 2.5 Flash-Lite
Today, we’re introducing 2.5 Flash-Lite in preview with the lowest latency and cost in the 2.5 model family. It’s designed as a cost-effective upgrade from our previous 1.5 and 2.0 Flash models. It also offers better performance across most evals, and lower time to first token while also achieving higher tokens per second decode. This model is great for high throughput tasks like classification or summarization at scale.

Gemini 2.5 Flash-Lite is a reasoning model, which allows for dynamic control of the thinking budget with an API parameter. Because Flash-Lite is optimized for cost and speed, “thinking” is off by default, unlike our other models. 2.5 Flash-Lite also supports all of our native tools like Grounding with Google Search, Code Execution, and URL Context in addition to function calling.

Benchmarks for Gemini 2.5 Flash-Lite
Benchmarks for Gemini 2.5 Flash-Lite
Updates to Gemini 2.5 Flash and pricing
Over the last year, our research teams have continued to push the pareto frontier with our Flash model series. When 2.5 Flash was initially announced, we had not yet finalized the capabilities for 2.5 Flash-Lite. We also launched with a “thinking” and “non-thinking price”, which led to developer confusion.

With the stable version of Gemini 2.5 Flash rolling out (which is the same 05-20 model preview we made available at Google I/O), and the incredible performance of 2.5 Flash, we are updating the pricing for 2.5 Flash:

$0.30 / 1M input tokens (*up from $0.15 input)
$2.50 / 1M output tokens (*down from $3.50 output)
We removed the thinking vs. non-thinking price difference
We kept a single price tier regardless of input token size
While we strive to maintain consistent pricing between preview and stable releases to minimize disruption, this is a specific adjustment reflecting Flash’s exceptional value, still offering the best cost-per-intelligence available.

And with Gemini 2.5 Flash-Lite, we now have an even lower cost option (with or without thinking) for cost and latency sensitive use cases that require less model intelligence.

Pricing updates for our Gemini Flash family
Pricing updates for our Gemini Flash family
If you are using the Gemini 2.5 Flash Preview 04-17 , the existing preview pricing will remain in effect until its planned deprecation on July 15, 2025, at which point that model endpoint will be turned off. You can transition to the generally available model “gemini-2.5-flash”, or switch to 2.5 Flash-Lite Preview as a lower cost option.


Continued growth of Gemini 2.5 Pro
The growth and demand for Gemini 2.5 Pro continues to be the steepest of any of our models we have ever seen. To allow more customers to build on this model in production, we are making the 06-05 version of the model stable, with the same pareto frontier price point as before.

We expect that cases where you need the highest intelligence and most capabilities are where you will see Pro shine, like coding and agentic tasks. Gemini 2.5 Pro is at the heart of many of the most loved developer tools.

Top developer tools using Gemini 2.5 Pro, featuring Cursor, Bolt, Cline, Cognition, Windsurf, GitHub, Lovable, Replit, and Zed Industries
Top developer tools using Gemini 2.5 Pro
If you are using 2.5 Pro Preview 05-06, the model will remain available until June 19, 2025 and then will be turned off. If you are using 2.5 Pro Preview 06-05, you can simply update your model string to “gemini-2.5-pro”.

We can’t wait to see even more domains benefit from the intelligence of 2.5 Pro and look forward to sharing more about scaling beyond Pro in the near future.
    "#
  }
}


// 综合类文章测试
test GenerationForGeneralArticleTest2{
  functions [GenerateArticle]
  args {
    dateString #"
      2025-07-01
    "#
    markdownOriginalString #"
      特朗普或推出以其名字命名的手机品牌；百度启动最大规模 AI 人才招聘；《鱿鱼游戏》第三季预告发布｜极客早知道
图片
图片
特朗普公司或进军手机市场，名字或成手机「招牌」
6 月 14 日，据媒体报道，代表美国总统特朗普管理商标的实体 DTTM Operations已申请使用他的名字以及「T1」一词来提供电信服务。

公开数据库显示，这些商标申请在周四提交给了美国专利商标局，涵盖了手机、手机壳、电池充电器和无线电话服务，甚至还可能包括零售店。

对此，美国一位资深专业律师公开发文表示「虽然商标申请并不意味着一定会推出相关产品，但申请材料的详尽程度表明它已经过了慎重考虑。」

同时他还指出，这些商标申请表明，特朗普可能正在筹划推出特朗普品牌的手机或通信服务，与 Verizon 通信 、AT&T 和 T-Mobile 美国展开竞争。

图片
上述人士认为「这将标志着特朗普私人商业版图的一次重大扩张，他的生意历来集中于房地产、酒店业和品牌商品领域。」 

值得注意的是，在今年 3 月初，根据一份商标申请显示，特朗普家族商业帝国还准备搞 VR 元宇宙了，也曾引起广泛关注。

特朗普家族在申请中描述的潜在用途包括：

1、用于在线世界的虚拟物品，如服装、鞋类、手袋、珠宝、食品和饮料；

2、用户可以在游戏中将数字代币兑换成加密货币和收藏品；

3、模拟豪华轿车出行和餐厅服务；

4、酒店和房地产管理领域的虚拟培训服务。（来源：快科技）

图片
苹果 App Store 大动作：2025 年末全面开放应用内购买兑换码
6 月 14 日，苹果公司在其开发者官网上宣布了一项即将在 2025 年末实施的新政策，这一变动将深刻影响应用内购买的体验方式。据悉，苹果计划为所有类型的应用内购买引入兑换码功能，这一举措不仅限于订阅服务，还将覆盖游戏内的消耗品，如虚拟货币等。

值得注意的是，苹果早在 2020 年就已推出了兑换码功能，但当时仅限于自动续订订阅的折扣或免费获取。据苹果介绍，这些一次性兑换码的分发方式将非常灵活。开发者可以选择通过电子邮件等数字化手段发送代码，也可以在实体活动中线下发放。这种灵活性，不仅为开发者提供了更多的选择，也为用户带来了更加丰富多样的获取兑换码的途径。（来源：ITBear）



百度启动最大规模顶尖 AI 人才招聘，岗位招聘同比扩大 60%
百度方面在 6 月 14 日表示，今年的 AIDU 计划，是百度最大规模的顶尖 AI 人才招聘。

相比去年，今年 AIDU 计划的岗位招聘扩增了超 60%，覆盖了 23 个核心业务和 11 类研究方向，主要聚焦于人工智能最前沿，包括大模型算法、大模型基础架构、机器学习、语音技术、智能体等众多领域。为了招纳到顶尖的校园人才，AIDU 计划 offer 的薪资上不封顶。（来源：华尔街见闻）



据报美国司法部审查谷歌收购 Wiz 交易
6 月 14 日，据彭博引述消息人士称，美国司法部反垄断执法部门正检视谷歌收购网络保安公司 Wiz 的交易，以判断交易有否违规。有关交易金额约 320 亿美元，是谷歌母公司 Alphabet 历来最大宗收购计划。Alphabet 计划把 Wiz 与谷歌自身的云服务部门合并，从而加强本身的网络保安能力。（来源：格隆汇）



英伟达 CEO 黄仁勋回应任正非最新讲话：华为能覆盖中国市场的需求
6 月 14 日，据媒体报道，英伟达 CEO 黄仁勋对任正非的讲话表达了他的观点。

黄仁勋表示「（虽然）我们的技术比他们领先一代，但重要的是要记住，技术层面的人工智能是一个并行问题。如果每台计算机的性能不够强，那就用更多的计算机。他所说的是，中国有充足的能源，他们会使用更多的芯片。所以在很多方面，他是在说中国的技术对中国来说已经足够好了。如果美国不想参与中国（的市场），华为能覆盖中国市场的需求，也能覆盖其他所有地区。」

6 月 10 日，华为创始人任正非表示，芯片问题其实没必要担心，用叠加和集群等方法，计算结果上与最先进水平是相当的。（来源：第一财经）

图片
挑战英伟达主导地位，AMD 联手多家 AI 初创公司改进芯片及软件设计
6 月 14 日，据路透社报道，AMD 正在与多家 AI 初创公司密切合作，意在增强自身的软件能力并设计出更先进的芯片。随着越来越多的 AI 企业寻求英伟达芯片的替代方案，AMD 开始扩大布局，计划打造竞争力更强的硬件，并收购了服务器制造商 ZT Systems。

但成功推出芯片产品的前提是具备强大的软件生态，以更高效地运行 AI 开发者的程序。AMD 近几周已收购了数家小型软件公司，以增强技术人才队伍，并加速优化名为 ROCm 的软件平台。AMD AI 高级副总裁瓦姆西・博帕纳说，「这是我们精心策划、长期布局的一项跨世代计划。」

AMD 承诺持续优化 ROCm 等软件，这对 AI 初创企业 Cohere 等客户尤其有益，他们能更快获得软件更新及新功能。

Cohere 专注于为大型企业打造定制化的 AI 模型，而非类似 OpenAI 所专注的基础模型。该公司 CEO 艾丹・戈麦斯接受采访时表示，AMD 的软件改进极大地提升了效率。以往 Cohere 将软件迁移到 AMD 芯片上需要数周，如今只需数天即可完成。（来源：IT之家）



外媒：谷歌计划与 Scale AI 分道扬镳，引发行业连锁反应
6 月 14 日，据路透社报道称，消息人士透露，谷歌本周已与 Scale AI 的多家竞争对手接洽，意图转移大部分业务。Scale AI 失去了大量业务，而 Meta 的入股使其估值达到 290 亿美元，高于交易前的 140 亿美元。

图片
然而，由于其核心业务依赖少数关键客户，若失去谷歌等客户，可能遭受重大损失。Scale AI 发言人表示公司业务稳健，与多家企业和政府合作，并致力于保护客户数据，但未具体评论与谷歌的合作事宜。

消息人士称，Scale AI 2024 年收入达 8.7 亿美元，谷歌去年在 Scale AI 的服务上花费约 1.5 亿美元。除谷歌外，微软、埃隆・马斯克的 xAI 也计划退出 Scale AI。

OpenAI 数月前决定退出，尽管其支出远低于谷歌，然而 6 月 14 日，OpenAI 首席财务官表示，公司将继续把 Scale AI 作为众多数据供应商之一。

多家公司担忧与 Scale AI 合作可能使研究重点和路线图暴露给竞争对手 Meta。客户通常会共享专有数据及原型产品，鉴于 Meta 持有 49% 股份，竞争对手担心其商业战略和技术蓝图可能被知晓。（来源：新浪科技）



美国白宫着手审查 SpaceX 联邦合同
6 月 14 日，据央视新闻报道，知情人士发布消息称，本月早些时候，美国白宫指示国防部和国家航空航天局（NASA）搜集 SpaceX 数十亿美元合同的详细信息，此举是在美国总统特朗普与马斯克公开爆发矛盾后采取的举措。

知情人士表示，作为可能对马斯克及其公司采取报复措施的准备，政府已下令相关机构仔细审查其合同，进而引发了一项持续审查。目前尚不清楚白宫是否计划取消 SpaceX 现有的，总额约为 220 亿美元的联邦合同。但这一审查显示，特朗普政府正在兑现他上周与马斯克争执时发出的威胁言论，即可能终止与马斯克企业的商业往来与补贴支持。白宫发言人在发给路透社的邮件中未正面回应有关马斯克企业的问题，仅表示：「特朗普政府致力于对所有投标和合同进行严格审查。」（来源：央视新闻）



特朗普年度财务披露报告：通过持有加密货币平台股份获得超 5700 万美元收益
当地时间 6 月 13 日晚，美国总统特朗普提交了其任内首份公开财务披露报告。根据美国政府道德办公室发布的文件，特朗普仍持续从数十处豪华地产和商业项目中获得收入，其中许多项目价值高达数千万美元。

这份 2025 年度财务披露报告共计 234 页，其中 145 页为股票和债券投资记录。报告显示，特朗普的主要收入来源之一，是他通过持有 World Liberty Financial 股份所获得的约 5736 万美元收益。这家加密货币平台于去年启动，数字代币的销售为特朗普及其家族带来了可观利润。（来源：界面）

图片
百度地图全球首发「司机智能体」，支持自由指路、路线记忆等
6 月 14 日，百度地图官方发文宣布全球首发「司机智能体」，号称「上路即⾃由」。

据介绍，百度地图「司机智能体」支持自由指路、路名定制、偏好路线、多点规划、路线记忆、路线查询、百科问答等功能。

另外，百度地图「司机智能体」还支持随时下达左转、右转或掉头指令，改变路线规划；支持灵活调整行程计划，按需变更行驶路段方案；支持用户自由规划想行驶的地点和线路，并按照路名规划行程。

图片
从百度地图官方获悉，手机用户升级百度地图 V21 最新版后可免费使用该功能，V21 车机版暂未发布，用户需继续等待。（来源：IT之家）



小米汽车固态电池专利公布，新能源行业竞赛加速
6 月 14 日，小米汽车科技有限公司申请的一项电池专利于 6 月 13 日正式公布，主要涉及「一种固态电池复合电极与制备方法及包含其复合电极的固态电池」，申请号为 CN202311707711.8，申请公布号为 CN120149317A。

从专利信息来看，该固态电池复合电极包含集流体与电极材料层，电极材料层沿集流体厚度方向层叠设置，其由基质（含电极活性物质、导电剂、粘结剂）和固态电解质（含聚合物、金属盐）构成，且固态电解质沿集流体厚度方向贯通电极材料层。如此设计，可有效缩短金属离子在厚电极里的传输路径，加快传输速率，让电极载量和倍率性能更出色。

今年 2 月，中国电动汽车百人会相关负责人透露，在新能源汽车领域，预计到 2027 年全固态电池开始装车，预计到 2030 年可以实现量产化应用。（来源：IT之家）

图片
Netflix《鱿鱼游戏》第三季终极预告发布，6 月 27 日上线
6 月 14 日，Netflix 热门剧《鱿鱼游戏》第三季终极预告现正式发布，本季为该剧最后一季，6 月 27 日上线。

图片
《鱿鱼游戏》第三季由黄东赫执导并担任编剧，李政宰、李炳宪、魏化儁等人主演，主角将再次参与游戏，为终结组织的恶行而迎接各种挑战。（来源：IT之家）



    "#
  }
}

test ArticleGenerationForFinanceArticle {
  functions [GenerateArticle]
  args {
    markdownOriginalString #"
      Senate passes Trump’s tax bill, sending it to House for final vote
The bill would extend tax cuts from Trump’s first term and slash roughly $1 trillion from Medicaid and other health care programs.
Updated
July 1, 2025 at 5:00 p.m. EDTtoday at 5:00 p.m. EDT
9 min
Summary3888
Senate Majority Leader John Thune (R-South Dakota) speaks with the media after the passage of the tax bill on Capitol Hill on Tuesday. (Demetrius Freeman/The Washington Post)
By Jacob Bogage
, 
Theodoric Meyer
, 
Liz Goodwin
 and 
Marianna Sotomayor
The Senate on Tuesday narrowly approved massive tax and immigration legislation that Republicans hope will become the centerpiece of President Donald Trump’s second term, cutting taxes while axing funding for social safety net programs and undoing much of President Joe Biden’s climate law.
Vice President JD Vance cast the tiebreaking vote for the measure, which would extend trillions of dollars in tax cuts from Trump’s first term and implement new campaign promises — such as eliminating income taxes on tips and overtime wages — while spending hundreds of billions of dollars on immigration enforcement and defense.
To offset the cost, the legislation would cut about $1 trillion from Medicaid, the federal health insurance program for low-income individuals and people with disabilities, and other health care programs. It would also make reductions to SNAP, the anti-hunger Supplemental Nutrition Assistance Program, formerly known as food stamps. Nearly 12 million people will lose health care coverage if the bill becomes law, according to the nonpartisan Congressional Budget Office.
To reach the Oval Office, the bill must clear one more hurdle: the House, where many members have balked at the Senate’s changes, raising questions about whether the legislation will make it to Trump’s desk by Independence Day.

Follow Trump’s second term

Follow
House Speaker Mike Johnson (R-Louisiana) said Tuesday that the Senate “went a little further than many of us would have preferred,” but he vowed to “get that bill over the line.”
“A lot of people didn’t get what they wanted,” Johnson said. But, he continued, “the president said it’s his bill. It’s not a House bill, it’s not a Senate bill. It’s the American people’s bill.”
Fiscal hawks in the House may take some convincing. “What’s happened is our bill has been completely changed,” said Rep. Ralph Norman (R-South Carolina), a member of the influential Rules Committee and the archconservative House Freedom Caucus. “It’s a nonstarter. This bill doesn’t do what the president wants it to do.”
The bruising battle to pass the bill split Senate Republicans, as some pressed for deeper spending reductions and others balked at the cuts to Medicaid and other programs. Lawmakers spent nearly 48 consecutive hours reading, debating and amending the legislation on the Senate floor. And in the end, three Republicans voted against the measure: Sens. Rand Paul (Kentucky), Thom Tillis (North Carolina) and Susan Collins (Maine).
“There will be a day that conservatives will rue the fact that some of them actually voted for this,” Paul said after the vote.
Tillis abruptly announced Sunday that he would not seek another term next year after voting against beginning debate on the measure — and drawing Trump’s ire online. His decision will force Republicans to defend an open seat in a swing state that Democrats are determined to pick up in the midterms.
Collins, a moderate up for reelection next year in a blue state, joined Tillis in opposing the bill, citing her concerns about Medicaid cuts. Paul, a deficit hawk, opposed it on different grounds: that it didn’t cut spending enough.
Sen. Lisa Murkowski (R-Alaska), who expressed concerns about the legislation’s Medicaid cuts, ultimately voted for it. The bill was loaded with benefits for Alaska, including a special tax break for whaling captains.
She said her decision to back the legislation was “agonizing” and described the Senate’s process as “rushed” — to the detriment of “the deliberative approach to good legislating” — to meet Trump’s “artificial timeline.”
She added that she hopes the House amends the measure to reduce the cuts to social safety net programs.
“This is probably the most difficult and agonizing legislative 24-hour period that I have encountered, and I’ve been here quite awhile, and you all know that I have a few battle scars underneath me,” Murkowski said. “But I held my head up and made sure the people of Alaska are not forgotten in this. But I think there is more that needs to be done, and I’m not done.”
To win her support, Republican leaders made last-minute concessions. The GOP doubled the value of a rural hospital bailout fund meant to ease the institutions’ adjustment to the Medicaid cuts. The agriculture portion of the bill delayed implementation of cuts to SNAP in high-poverty states. And tax writers removed a provision that would have imposed a new duty on renewable-energy systems.
“Good things are important,” Murkowski said, “but it also is important in terms of how they are paid for, and I struggled mightily with the impact on the most vulnerable in this country when you look to the Medicaid and the SNAP provisions.”
Senate holds marathon overnight vote on Trump’s tax cuts bill


+12
Republicans declared that their legislation would help the working-class voters who swept Trump to the White House and the GOP to unified control of Congress in November’s elections.
The bill would increase the child tax credit and add a bonus to the standard deduction for seniors, a provision inspired by Trump’s campaign pledge to stop taxing Social Security benefits. It would also create savings accounts for newborns, seeded with $1,000 of taxpayer money, and it would allow buyers of American-made cars to deduct up to $10,000 in car loan interest.
“This is delivering on President Trump’s promises. That’s the key,” said Sen. Eric Schmitt (R-Missouri).
But beyond those populist flourishes, the measure is starkly regressive. The 10 percent of households with the lowest incomes would stand to be worse off by an average of $1,600 per year because of benefits cuts, according to the Congressional Budget Office’s analysis of the House version of the bill. The 10 percent of households with the highest incomes would be better off by $12,000 on average.
The legislation would make permanent a trio of corporate tax deductions that make it easier for companies to invest in research and purchase new equipment.
Adding in the impact of Trump’s tariffs — which the White House has argued will help pay for the bill’s tax cuts and new spending — the bottom 80 percent of households would see their take-home incomes fall, according to the Yale Budget Lab.
“The right way to understand this bill is it is the largest wealth transfer from the poorest Americans to the richest Americans in modern history,” said Natasha Sarin, the Budget Lab’s president.
The nearly $170 billion in the bill to fund the Trump administration’s border and immigration crackdown would be one of the largest sums ever spent on homeland security, and an additional $160 billion would flow to the Defense Department, partially for Trump’s proposed “Golden Dome” continental missile defense system.
The new spending and lost tax revenue would force the federal government to borrow nearly $4 trillion more over the next decade, according to the congressional bookkeepers. To shove the measure through the cumbersome budget reconciliation process, the GOP weakened the Senate’s filibuster in a way that will make addressing the nation’s poor financial health more difficult.
Republicans began their tax-writing process shortly after November electoral victories with pledges to dramatically reduce government spending and annual deficits, wary of adding to a national debt that already totals more than $36 trillion.
Budget reconciliation, the process Republicans used to bypass a Democratic Senate filibuster, requires both chambers to approve a budget resolution with broad policy outlines for the bill, then to pass the legislation itself.
Would-be GOP rebels voiced debt concerns when the House took up a budget resolution in February, then again in April on an amended budget and finally in May on the tax legislation itself. Each time, they ultimately voted for the measure.
The bill also would raise the debt ceiling — a cap on how much the country can borrow to pay for spending already required by law — by $5 trillion, which Republicans hope will be enough to keep Trump from having to deal with the issue again during his presidency.
“If the economy continues to climb the way it is and our deficit reduction continues to go into effect, it could get there, but the math is going to be tough. There’s a lot of factors,” said Sen. Markwayne Mullin (R-Oklahoma), a key interlocutor between Senate leadership and House skeptics.
Paul vowed to vote against the bill because it included such a large debt limit increase, arguing that Congress should raise the limit in smaller increments to keep up the pressure to cut spending.
Senate Majority Leader John Thune (R-South Dakota) insisted that his conference had a larger appetite for deficit reduction than his House colleagues did.
Sen. Ron Johnson (R-Wisconsin) repeatedly vowed that the bill would not pass without deeper spending cuts. Instead, the Senate Finance Committee wrote a bill hundreds of billions of dollars more expensive than the House’s, and more punitive toward Medicaid.
That sent Tillis to the floor outraged with his party over he what he described as a betrayal of constituents on the federal health insurance program.
“The effect of this bill is to break a promise,” Tillis bellowed Sunday on the Senate floor.
“What do I tell 663,000 people in two years or three years,” he added, “when President Trump breaks his promise by pushing them off of Medicaid because the funding’s not there anymore?”
Emily Davies, Mariana Alfaro, Paul Kane and Dylan Wells contributed to this report.
    "#
    dateString #"
      2025-07-02
    "#
  }
}