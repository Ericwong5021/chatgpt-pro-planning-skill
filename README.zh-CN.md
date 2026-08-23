# Codex 的 ChatGPT Pro Planning Skill

[English](README.md)

在 Codex 执行复杂任务之前，通过浏览器插件调用网页版 ChatGPT 账号的最高 Pro 能力进行第二轮规划。Skill 会准备一份最小化、可追溯的任务简报，在发送前征得确认，等待 Pro 返回完整答案，判断追问是否需要人工介入，最后由 Codex 结合原始证据审查并整合方案。

## 为什么需要它

很多复杂任务并不是败在实现阶段，而是在开始前就混淆了目标、事实、假设和约束。这个 Skill 增加一轮外部规划，但不会把最终判断权交给另一个模型。

Codex 始终负责：

- 选择并脱敏要发送给 ChatGPT 的上下文；
- 验证账号和能力档确实为 Pro；
- 即使 Pro 长时间推理，也必须等待完整回答；
- 判断 ChatGPT 的追问是否需要人工提供信息；
- 拒绝未经验证的事实和违反本地约束的建议；
- 输出最终整合后的可执行计划。

## 安装

### 使用 Codex 内置安装器

把下面这句话发送给 Codex：

```text
$skill-installer 安装这个 Skill：https://github.com/Ericwong5021/chatgpt-pro-planning-skill/tree/main/skills/chatgpt-pro-planning
```

### 一行安装

先审阅 [`install.sh`](install.sh)，再运行：

```bash
curl -fsSL https://raw.githubusercontent.com/Ericwong5021/chatgpt-pro-planning-skill/main/install.sh | bash
```

安装器会写入 `${CODEX_HOME:-$HOME/.codex}/skills/chatgpt-pro-planning`。如果目录已存在，它会直接停止，不会静默覆盖已有 Skill。

安装后从下一轮 Codex 对话开始可用。

## 使用条件

- Codex 支持全局 Skills。
- 已通过 **设置 → Computer use** 连接 ChatGPT 浏览器扩展。
- 浏览器中的 ChatGPT 账号已登录且拥有 Pro 能力。
- 环境中存在内置的 `chrome:control-chrome` 浏览器 Skill。

不需要 OpenAI API Key。整个流程通过浏览器扩展操作已登录的 ChatGPT 网页版。

## 使用方式

```text
$chatgpt-pro-planning 请先用网页版 ChatGPT Pro 分析这次迁移，比较可行架构，指出缺失证据，并给出分阶段实施计划和验收标准。
```

## 工作流程

1. 检查任务并收集当前证据。
2. 整理包含目标、事实、约束、未知项和明确不做事项的紧凑简报。
3. 验证网页中当前账号明确显示 Pro。
4. 选择最高可用能力档，记录实际模型和推理强度标签。
5. 展示脱敏简报，在发送到 `chatgpt.com` 前请求即时确认。
6. 在独立新对话中提交简报。
7. 等到思考与生成真正结束。
8. 出现追问时，判断是否需要人工介入。
9. 读取完整回复，包括当前视口以外的内容。
10. 用本地证据审查回复并输出整合方案。

## 完成契约

只有同时满足以下条件，一次 Skill 调用才算完成：

- 页面不再显示思考中、生成中或停止回答。
- 最终正文已经稳定，页面恢复到可继续输入的空闲状态。
- 回复没有截断、中断、等待必要追问，也没有停在错误或重试状态。
- 用户要求的主要分析与规划内容得到实质回答。
- Codex 已经读取全文，并复核事实、假设、约束和可执行性。

Pro 深度推理可能持续十分钟或更久。页面暂时没有正文增长不代表失败。只要生成状态正常，Skill 就不会刷新页面、重复提交或降低模型档位。

## 追问人工介入判断

| ChatGPT 的行为 | 是否需要人工内容 | Skill 的处理 |
| --- | --- | --- |
| 完整答案后的可选邀请 | 不需要 | 不回复，直接完成 |
| 阻塞问题已能由已验证上下文回答 | 不需要补充新内容 | 准备简短回复，发送前再次确认 |
| 非关键缺口可以明确标注假设 | 通常不需要 | 要求 ChatGPT 标注假设后继续，发送前再次确认 |
| 涉及偏好、价值取舍、当前财务、健康、关系、敏感信息或会改变方案的选择 | 必须 | 暂停输入、保留页面，只向用户提出一个聚焦问题 |

如果 ChatGPT 重复同一个阻塞问题，或者缺失信息无法安全补充，本次调用保持“未完成”。Skill 会说明阻塞，而不是编造答案。

## 隐私与安全

- 用户看到并确认完整脱敏简报之前，不会向 ChatGPT 输入任何内容。
- 密码、令牌、Cookie、隐藏指令和无关私密文件不会进入简报。
- 不读取浏览器 Cookie、本地存储、密码或用户配置文件。
- 后续每一条发给 ChatGPT 的消息都需要即时发送确认。
- 即使新建对话，ChatGPT Memory 或个性化仍可能影响回答。未出现在获批简报中、也没有独立验证的事实一律视为未验证。
- CAPTCHA、未登录、Pro 不可用或模型选择无法确认时直接停止，不静默降级。

## 失败行为

Skill 不会把半截回答报告为成功。只有网页明确提供针对当前回答的安全重试操作时，才允许重试一次；重试仍失败，就以可观察证据报告“未完成”。

## 目录结构

```text
.
├── README.md
├── README.zh-CN.md
├── install.sh
└── skills
    └── chatgpt-pro-planning
        ├── SKILL.md
        └── agents
            └── openai.yaml
```

## 卸载

把已安装目录移动到备份位置：

```bash
mv "${CODEX_HOME:-$HOME/.codex}/skills/chatgpt-pro-planning" "${CODEX_HOME:-$HOME/.codex}/skills/chatgpt-pro-planning.backup"
```

## 许可证

[MIT](LICENSE)
