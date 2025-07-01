function ChatAgent(message: Message[], tone: "happy" | "sad") -> StopTool | ReplyTool {
    client "CustomDeepseek"

    prompt #"
        Be a {{ tone }} bot.

        {{ ctx.output_format }}

        {% for m in message %}
        {{ _.role(m.role) }}
        {{ m.content }}
        {% endfor %}
    "#
}

class Message {
    role string
    content string
}

class ReplyTool {
  response string
}

class StopTool {
  action "stop" @description(#"
    when it might be a good time to end the conversation
  "#)
}