import OpenAI from "openai";

export const deepseekClient = new OpenAI({
    apiKey:"sk-dev-",
    baseURL:"https://bi.ganjiuwanshi.com/v1/"
})

export enum DEEPSEEK_MODEL {
    /**
     * 
     */
    Volcano = "deepseek-v3-250324"
}