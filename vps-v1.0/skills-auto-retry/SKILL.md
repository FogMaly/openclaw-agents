# Auto-Retry Skill

## 描述

当子 agent 执行超时或失败时，自动重试的逻辑处理 skill。

## 功能

- 自动检测子 agent 执行错误
- 根据错误类型决定是否重试
- 支持可配置的重试次数和延迟
- 记录重试历史和状态
- 超过最大重试次数后向用户报告

## 支持的错误类型

- `timeout` - 执行超时
- `Request was aborted` - 请求被中止
- `No response generated` - 未生成响应
- `All models failed` - 所有模型失败

## 配置

参见 `config.json` 文件进行配置调整。

## 使用方法

```bash
# 手动触发重试检查
./scripts/auto_retry.sh <subagent_id> <error_type>

# 或通过 agent 系统自动调用
```

## 配置参数

- `max_retries`: 最大重试次数（默认：3）
- `retry_delays`: 每次重试前的延迟秒数数组（默认：[0, 2, 5]）
- `retry_on_errors`: 触发重试的错误类型列表

## 日志

重试记录保存在 `/tmp/auto-retry-<subagent_id>.log`
