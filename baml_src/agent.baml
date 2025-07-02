
class EventMessage {
    eventName string
    dataContent string
}


/// 对于比较长的上下文记忆，需要通过 MemoryStateToolData 工具去获取相应的记忆
class MemoryStateToolData {
    toolName string @description(#"
        工具名称
    "#)
    dataContent string @description(#"
        工具数据
    "#)
}


/// 文章初步生成工具
class ArticleGenerationTool {
    event "tool"
    data "ArticleGenerationTool" @description(#"
        用于调用初步文章生成工具，该工具将提示用户输入一篇文章，它适用于用户还未传入原始文章内容或者用户想尝试写作不同类型的文章的情形。
    "#)
}

class MemoryRetrivalTool {
    event "tool"
}

/// 让用户确认任务是否完成
class RequestHumanForConfirmation {
    event "request_human"
    data "isTaskFinished" @description(#"
        向用户确认当前任务是否已经完成。用户可以选择继续或结束当前任务。
    "#)
}

/// 让用户确认当前生成的内容是否满足需求
class RequestHumanForSatisfaction {
    event "request_human" @description(#"
        当用户已经生成了一篇文章，提示用户是否满意该文章的内容效果
    "#)
    data "isSatisfaction?" @description(#"
        向用户确认当前生成的内容是否满足需求。用户可以选择继续优化或接受当前结果。
    "#)
}

class ArticleMemorySaveEvent {
    event "memory_saved" @description(#"
        该事件用于标明
    "#)
    data "memory_data" @description(#"
        需要保存的记忆数据，以 JSON 格式输出。
    "#)
}

class StopEvent {
  event "stop" @description(#"
    当你觉得任务已经完成时，输出 stop 事件
  "#)
  data null
}


// class ArticleGenerationTool {
//     tool
// }


function ChatAgent(eventMessage: EventMessage[]) -> StopEvent | RequestHumanForConfirmation | RequestHumanForSatisfaction | ArticleGenerationTool {
    client "CustomDeepseek"

    prompt #"
        {{ _.role("system")}}

        你是用于帮助用户根据一篇文章内容写作出新的文章的文章助手。你的核心目标是帮助用户书写出具有人类写作风格的文章。为了完成这项任务,你需要根据用户和你对话的过程中的历史事件，不断给出下一步的行动回应。
        对于你可以调用的工具以及下一步的行动回应，都存放在 `<event_action_available_list></event_action_available_list>` 标签中。
        对于过去发生的事件，都存放在用户输入内容的 `<event_history></event_history>` 标签中；

        <event_action_available_list>
        {{ ctx.output_format(
            prefix="永远严格按照按照下方的 JSON 格式输出调用的工具或下一步行动的回应："
        )}}
        </event_action_available_list>

        除此之外还存在的 event 有：
        <additional_event_list>
        {{ ArticleMemorySaveEvent }}
        </additional_event_list>

        {{ _.role("user") }}

        以下是过去发生过的事件，以 `<事件名>{事件数据}</事件名>` 的格式输出，最新发生的内容次序往后靠。
        <event_history>
        {% for m in eventMessage %}
        <{{loop.index}}{{ m.eventName }}>
         {{ m.dataContent }}
        </{{ loop.index }}{{ m.eventName}}>
        {% endfor %}
        </event_history>

        现在，下一步应该怎么做？
    "#
}


test ChatAgentTest {
    functions [ChatAgent]
    args {
        eventMessage [
            {
                eventName: request_human,
                dataContent: 你好
            }
        ]
    }
}