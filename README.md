# Codex 基础指令覆盖包

用一份改写后的 base instructions 替换 Codex 的默认基础指令，并追加一条 developer 优先级声明。目标是让模型从用户目标与必要条件推导最短实现，把无依据的防御性编程、预防性抽象和例行验证压到最低。

## 前置条件

- Windows，PowerShell 5.1 或 PowerShell 7+
- Codex 已安装并启动过至少一次，存在 `%USERPROFILE%\.codex\config.toml`
- 配置不在默认位置时，设置环境变量 `CODEX_HOME` 指向它

## 安装

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

脚本执行四步：

1. 解析 `CODEX_HOME` 或 `%USERPROFILE%\.codex`，确认 `config.toml` 存在；
2. 备份为 `config.toml.bak-<时间戳>`；
3. 在首个 `[table]` 之前写入两个顶层键——`model_instructions_file` 指向本包 `instructions.md` 的绝对路径（路径在运行时由脚本位置推导，脚本内没有绝对路径），`developer_instructions` 读取 `developer-instructions.txt`；
4. 回读校验两个键各出现一次。

重复运行会替换旧值，不会叠加。

## 验证

完全退出 Codex（包括托盘进程），重新打开，新开会话后询问它系统提示词的第一句。安装成功时回答以 `You are Codex, a coding agent.` 开头。

也可以直接查看配置：

```powershell
Select-String -Path "$env:USERPROFILE\.codex\config.toml" -Pattern 'model_instructions_file|developer_instructions'
```

## 卸载

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

删除两个顶层键并留下备份；Codex 重启后回到默认基础指令。

## 生效范围

| 项 | 是否受本包影响 |
|---|---|
| base instructions | 替换为 `instructions.md`（标准 Responses 模式） |
| developer 段 | 追加 `developer-instructions.txt` 的内容 |
| `approvals` / `permissions` / `auto_review` | 不受影响，由服务端模型配置下发 |
| 服务端 `persistent_instructions` | 仍然存在；其中建议“verifying that a change took effect”的后续工作由 developer 段压制 |
| 已打开的会话 | 不重载，需要新会话 |

## 兼容性

**Responses Lite 下不替换，只追加。** 标准 Responses 模式中，`model_instructions_file` 整段替换模型自带的基础指令；开启 Responses Lite 后，同一份内容会作为一条后置 developer 消息加入，模型同时看到官方 base 身份与自定义指令。需要整段替换时关闭 Responses Lite。参见 [openai/codex#38355](https://github.com/openai/codex/issues/38355)。

**官方配置 schema 对此字段有明确劝阻。** `codex-rs/core/config.schema.json` 原文：

> Optional path to a file containing model instructions that will override the built-in instructions for the selected model. Users are STRONGLY DISCOURAGED from using this field, as deviating from the instructions sanctioned by Codex will likely degrade model performance.

使用前先确认这是你要的取舍。`experimental_instructions_file` 已废弃并更名为 `model_instructions_file`。

## 文件

| 文件 | 用途 |
|---|---|
| `instructions.md` | 改写后的 base instructions |
| `developer-instructions.txt` | developer 优先级声明，可自行修改后重装 |
| `install.ps1` | 安装 |
| `uninstall.ps1` | 卸载 |

## 来源与许可

`instructions.md` 基于 Codex 模型缓存中的 base instructions 改写，原文 21,534 字节，SHA-256 `d12e6dbdfd4a4ddb26a1f6048b69a32b8b32f74e4add9791d1dff7f4cac0b032`。仓库不包含上游原文。本包与 OpenAI 无隶属关系，不含官方安装包、凭据或遥测。脚本以 MIT 许可提供；`instructions.md` 是对上游基础指令的改写，其原始版权归上游作者。
