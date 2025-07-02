import { EventMessage } from "baml_client/types.ts"
import { Effect } from "effect";
import { Terminal } from "@effect/platform"
import { b } from "baml_client/sync_client.ts";
import { show } from "showify";
import { NodeRuntime, NodeTerminal } from "@effect/platform-node";
import dotenv from "dotenv"

dotenv.config()

const formatMessages = (role: string, content: string):EventMessage => {
    return {
        eventName: role,
        dataContent: content
    }
}

const callAgent = (msgs:EventMessage[]) => {
    const result = b.ChatAgent(msgs)
    return result
}

const toolEventRecord = (toolName:string,data:string):EventMessage => {
    return {
        eventName:`tool_${toolName}_result`,
        dataContent:data
    }

}

const AgentLoop = Effect.gen(function* () {
    const messages: EventMessage[] = []
    const memoryState:Record<string,object> = {}
    const terminal = yield* Terminal.Terminal
    console.log("👻 你好，这里是测试 Agent ~ 正在初始化环境中...")
    while (true) {
        const resultEvent = yield* Effect.try(() => callAgent(messages))

        if(resultEvent.event === "stop"){
            console.log("👻 任务结束，再见 ~")
            break
        }

        if(resultEvent.event === "request_human" && resultEvent.data === "isTaskFinished"){
            console.log("😊 真的要结束该任务么？输入 y 确认结束，输入 n 继续任务")
            const input = yield* terminal.readLine
            if(input === "y"){
                console.log("👻 任务完成，再见 ~")
                break
            }
            if(input === "n"){
                messages.push({
                    eventName:"user_continue_task",
                    dataContent:"用户还想继续任务"
                })
            }
        }

        if(resultEvent.event === "request_human" && resultEvent.data === "isSatisfaction?"){
            console.log("😊 请问您满意当前效果么？输入 y 确认满意，输入 n 不满意")
            const input = yield* terminal.readLine
            if(input === "y"){
                messages.push({
                    eventName:"user_confirm_satisfaction",
                    dataContent:"用户满意当前效果生成效果"
                })
            }
            if(input === "n"){
                messages.push({
                    eventName:"user_confirm_satisfaction",
                    dataContent:"用户不满意当前效果生成效果"
                })
            }
        }

        if(resultEvent.event === "tool" && resultEvent.data === "ArticleGenerationTool"){
            console.log("❗ 请黏贴需要写作的文章内容：")
            const input = yield* terminal.readLine
            memoryState["originalMarkdownContent"] = {markdownOriginalString:input}
            messages.push({
                eventName:"user_enter_article",
                dataContent:`用户传入了文章，记忆 id 为 originalMarkdownContent`
            })
            console.log("👻 正在生成文章...")
            const result = b.GenerateArticle(input,new Date().toLocaleDateString())
            console.log(`👻 文章生成成功，结果为：《${result.title}》 \n 文章内容为：${result.markdownContent}`)
            memoryState["articleGenerationTool"] = result
            messages.push(toolEventRecord("ArticleGenerationTool",`已经生成文章内容，记忆Id为 articleGenerationTool 。由于记忆过长不放在上下文中。可调用记忆提取Id获取`))
        }
        continue
    }
})

NodeRuntime.runMain(AgentLoop.pipe(
    Effect.provide(NodeTerminal.layer)
))