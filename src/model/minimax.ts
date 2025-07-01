import OpenAI from "openai";

/**
 * [doc](https://platform.minimaxi.com/document/ChatCompletion%20v2?key=66701d281d57f38758d581d0).
 * MinixMax 只适用于对上下文信息进行提取。
 */
export const minimaxClient = new OpenAI({
    apiKey:"",
    baseURL:"https://api.minimaxi.com/v1"
})

export enum MINIMAX_MODEL {
    /**
     * Minimax-Text-01 ，max_tokens最大输出值为 40000,总 tokens 数为 1000192
     */
    TextV1 = "MiniMax-Text-01"
}