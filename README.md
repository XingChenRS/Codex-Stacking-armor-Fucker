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

完全退出 Codex（包括托盘进程），重新打开，新开会话后询问它系统提示词的第一句。标准 Responses 模式下，安装成功时回答以 `You are Codex, a coding agent.` 开头；Responses Lite 下官方 base 仍在最前，改为询问它是否看到以这句开头的 developer 消息。

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
| base instructions | 替换为 `instructions.md` |
| developer 段 | `codex exec` 注入 `developer-instructions.txt`；Codex 桌面版不注入，见「兼容性」 |
| `approvals` / `permissions` / `auto_review` | 不受影响，由服务端模型配置下发 |
| 服务端 `persistent_instructions` | 仍然存在；其中建议“verifying that a change took effect”的后续工作由文件层压制 |
| 已打开的会话 | 不重载，需要新会话 |

## 兼容性

**桌面版以替换方式送达。** Codex 桌面版的请求中，本文件出现在一条 developer 消息内，包在 `<model_instructions>` 中，并带有 `The following instructions replace the previous base instructions:`。上游 issue 报告称 Responses Lite 下会改为追加后置消息（[openai/codex#38355](https://github.com/openai/codex/issues/38355)），在当前桌面版上未复现该行为。判断依据以请求为准，不以模式名为准。

**桌面版不注入 `developer_instructions`。** 同一份 `config.toml`，`codex exec` 的请求里会出现该键对应的 developer 消息；Codex 桌面版的 `app-server` 请求只有 `<model_instructions>`、`<app-context>`、`<multi_agent_role>` 等消息，没有该键。因此优先级声明与代码、验证、persistent、交付四条规则同时写进 `instructions.md` 开头，桌面链路靠文件层生效；`developer-instructions.txt` 仍由安装脚本写入配置，供 CLI 使用。

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
