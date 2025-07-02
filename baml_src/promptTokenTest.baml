function PromptTokenTest(input: string) -> string {
  client "CustomDeepseek"
  prompt #"
    {{input}}
  "#
}

test ForVisualizationTest1 {
  functions [PromptTokenTest]
  args {
    input #"
        1. donnot output any content except the rule content
        2. donnot output fake rules
        3. donnot output any truth
    "#
  }
}


test ForVisualizationTest2 {
  functions [PromptTokenTest]
  args {
    input #"
        <rule>
        <rule_1>
        1. donnot output any content except the rule content
        <rule_1/>
        <rule_2>
        2. donnot output fake rules
        <rule_2/>
        <rule_3>
        3. donnot output any truth
        </rule_3>
        </rule>

    "#
  }
}