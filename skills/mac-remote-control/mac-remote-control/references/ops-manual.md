# Mac 远控系统运维手册

## 系统架构

```
Linux 控制端 (154.40.43.33:8080)
    ↓ WebSocket
Mac Agent (jixiaoyideMac-mini-2)
    ↓ launchd
Watchdog (watchdog-mac.sh)
    ↓ 自动重启
OpenClaw Agent (openclaw-agent)
```

---

## 快速健康检查

### 1. 检查 Mac agent 是否在线

```bash
/usr/local/bin/mac-health
```

**正常输出**：
```
== controller last mac lines ==
💓 Heartbeat from mac
...
== live exec test ==
healthcheck-ok
```

### 2. 检查控制端状态

```bash
curl -s http://154.40.43.33:8080/api/agents | jq
```

**正常输出**：
```json
[
  {"id":"mac","online":true,"lastHeartbeat":1773072456},
  {"id":"linux-agent-1","online":true,"lastHeartbeat":1773072459}
]
```

### 3. 测试远程执行

```bash
/usr/local/bin/mac echo test
```

**正常输出**：
```
test
```

---

## 重启命令

### 重启 Mac agent

**方法 1：通过 launchd（推荐）**
```bash
/usr/local/bin/mac bash -c 'launchctl kickstart -k gui/$(id -u)/com.jixiaoyi.openclaw-agent-watchdog'
```

**方法 2：直接杀进程（watchdog 会自动拉起）**
```bash
/usr/local/bin/mac bash -c 'pkill -f openclaw-agent'
```

### 重启控制端

```bash
pkill -f '/root/openclaw-ws-server/server.js'
# daemon.sh 会在 5 秒内自动拉起
sleep 6
ps aux | grep openclaw-ws-server | grep -v grep
```

### 重启 OpenClaw Gateway（Mac 上的 bot）

```bash
/usr/local/bin/mac bash -c 'launchctl kickstart -k gui/$(id -u)/ai.openclaw.gateway'
```

---

## 日志位置

### Linux 控制端

| 日志文件 | 用途 | 轮转策略 |
|---------|------|---------|
| `/tmp/ws-server.log` | 控制端主日志 | 100MB / 7天 |
| `/tmp/mac-monitor-alerts.log` | 监控告警日志 | 50MB / 7天 |
| `/tmp/rotate-logs.log` | 日志轮转记录 | 无限制 |

**查看控制端日志**：
```bash
tail -100 /tmp/ws-server.log
```

### Mac 端

| 日志文件 | 用途 | 轮转策略 |
|---------|------|---------|
| `~/openclaw-agent/agent-watchdog.log` | Watchdog 运行日志 | 100MB / 7天 |
| `~/openclaw-agent/agent-failure.log` | 连续失败记录 | 50MB / 7天 |
| `~/openclaw-agent/launchd-watchdog.out.log` | launchd 标准输出 | 50MB / 7天 |
| `~/openclaw-agent/launchd-watchdog.err.log` | launchd 错误输出 | 50MB / 7天 |

**查看 Mac 日志**：
```bash
/usr/local/bin/mac tail -100 /Users/jixiaoyi/openclaw-agent/agent-watchdog.log
```

---

## 监控与告警

### 自动监控

- **频率**：每 5 分钟
- **检查项**：
  - Mac agent 是否在线
  - 能否执行命令
  - heartbeat 是否新鲜（< 2 分钟）
- **告警方式**：Telegram 消息到 `8305273339`

### 手动触发监控

```bash
/usr/local/bin/mac-monitor
```

### 查看监控历史

```bash
cat /tmp/mac-monitor-alerts.log
```

---

## 常见问题排查

### 问题 1：`Agent not online`

**症状**：
```bash
/usr/local/bin/mac echo test
❌ 错误: Agent not online
```

**排查步骤**：

1. 检查 Mac agent 是否注册
```bash
curl -s http://154.40.43.33:8080/api/agents | jq
```

2. 如果没有 `mac`，检查 Mac 上的进程
```bash
/usr/local/bin/mac bash -c 'ps aux | grep openclaw-agent | grep -v grep'
```

3. 如果进程不存在，检查 launchd
```bash
/usr/local/bin/mac bash -c 'launchctl list | grep openclaw-agent-watchdog'
```

4. 查看 watchdog 日志
```bash
/usr/local/bin/mac tail -50 /Users/jixiaoyi/openclaw-agent/agent-watchdog.log
```

**解决方案**：
```bash
# 重启 watchdog
/usr/local/bin/mac bash -c 'launchctl kickstart -k gui/$(id -u)/com.jixiaoyi.openclaw-agent-watchdog'
```

---

### 问题 2：Mac agent 频繁重启

**症状**：
```bash
/usr/local/bin/mac tail -20 /Users/jixiaoyi/openclaw-agent/agent-watchdog.log
```
看到大量 `agent exited` 记录

**排查步骤**：

1. 检查是否达到重启上限
```bash
/usr/local/bin/mac cat /Users/jixiaoyi/openclaw-agent/agent-failure.log
```

2. 查看退出码
```bash
/usr/local/bin/mac bash -c 'grep "agent exited" /Users/jixiaoyi/openclaw-agent/agent-watchdog.log | tail -10'
```

**常见原因**：
- `exit_code=1`：配置错误或 token 无效
- `exit_code=137`：被 OOM killer 杀掉
- `exit_code=143`：被 SIGTERM 杀掉

**解决方案**：
- 检查 `config.json` 配置
- 检查控制端是否正常
- 重启控制端强制重新注册

---

### 问题 3：OpenClaw bot 不回复消息

**症状**：给 @fogmacbot 发消息，没有回复或回复 `[blank text]`

**排查步骤**：

1. 检查 Gateway 是否在运行
```bash
/usr/local/bin/mac bash -c 'ps aux | grep openclaw-gateway | grep -v grep'
```

2. 查看 Gateway 状态
```bash
/usr/local/bin/mac bash -c '/opt/homebrew/bin/openclaw status | grep -A 5 Sessions'
```

3. 查看最近的错误
```bash
/usr/local/bin/mac bash -c '/opt/homebrew/bin/openclaw logs | grep -i error | tail -20'
```

**常见错误**：
- `401 TokenStatusExhausted`：API Key 额度用尽
- `500 auth_unavailable`：认证失败
- `502 unknown provider`：模型 ID 不匹配
- `Context window is full`：上下文爆满

**解决方案**：
```bash
# 重启 Gateway
/usr/local/bin/mac bash -c 'launchctl kickstart -k gui/$(id -u)/ai.openclaw.gateway'

# 清空会话历史
/usr/local/bin/mac bash -c 'rm -f ~/.openclaw/agents/main/sessions/*.jsonl && echo "{}" > ~/.openclaw/agents/main/sessions/sessions.json'
```

---

### 问题 4：控制端日志显示 heartbeat 但无法执行命令

**症状**：
```bash
tail /tmp/ws-server.log
💓 Heartbeat from mac
💓 Heartbeat from mac
```
但执行命令返回 `Agent not online`

**原因**：Mac agent 重连时没有重新发送 `hello` 消息

**解决方案**：
```bash
# 重启控制端，强制所有 agent 重新注册
pkill -f '/root/openclaw-ws-server/server.js'
sleep 6
curl -s http://154.40.43.33:8080/api/agents | jq
```

---

## 配置文件位置

### Linux 控制端

- 控制端代码：`/root/openclaw-ws-server/server.js`
- 守护脚本：`/root/openclaw-ws-server/daemon.sh`
- 统一入口：`/usr/local/bin/mac`
- 健康检查：`/usr/local/bin/mac-health`
- 监控脚本：`/usr/local/bin/mac-monitor`
- 日志轮转：`/usr/local/bin/rotate-logs`

### Mac 端

- Agent 配置：`~/openclaw-agent/config.json`
- Watchdog 脚本：`~/openclaw-agent/watchdog-mac.sh`
- 启动脚本：`~/openclaw-agent/start-mac.sh`
- launchd plist：`~/Library/LaunchAgents/com.jixiaoyi.openclaw-agent-watchdog.plist`
- OpenClaw 配置：`~/.openclaw/openclaw.json`
- OpenClaw Gateway plist：`~/Library/LaunchAgents/ai.openclaw.gateway.plist`

---

## 定时任务

### Linux 控制端 cron

```bash
crontab -l
```

**当前配置**：
```
*/5 * * * * /usr/local/bin/mac-monitor
0 3 * * * /usr/local/bin/rotate-logs >> /tmp/rotate-logs.log 2>&1
```

---

## 关键指标

### 正常运行指标

- Mac agent heartbeat 间隔：< 30 秒
- 远程命令响应时间：< 2 秒
- Watchdog 重启次数：< 10 次 / 10 分钟
- 监控检查成功率：> 95%

### 告警阈值

- Heartbeat 超过 2 分钟：立即告警
- 连续 3 次监控失败：立即告警
- Watchdog 达到重启上限：立即告警并停止

---

## 紧急联系

- **Telegram 告警接收人**：`8305273339` (fog maly)
- **控制端地址**：`154.40.43.33:8080`
- **Mac 地址**：`10.32.136.26` (jixiaoyideMac-mini-2)

---

## 版本信息

- **控制端**：openclaw-ws-server (custom)
- **Mac Agent**：openclaw-agent (binary)
- **OpenClaw**：2026.3.7
- **部署日期**：2026-03-09
- **最后更新**：2026-03-09 16:21 GMT

---

## 备份与恢复

### 备份关键配置

```bash
# Linux 端
tar czf /tmp/openclaw-backup-$(date +%Y%m%d).tar.gz \
  /root/openclaw-ws-server/ \
  /usr/local/bin/mac* \
  /usr/local/bin/rotate-logs

# Mac 端
/usr/local/bin/mac bash -c 'tar czf /tmp/openclaw-mac-backup-$(date +%Y%m%d).tar.gz \
  ~/openclaw-agent/ \
  ~/.openclaw/openclaw.json \
  ~/Library/LaunchAgents/com.jixiaoyi.openclaw-agent-watchdog.plist \
  ~/Library/LaunchAgents/ai.openclaw.gateway.plist'
```

### 恢复

1. 解压备份文件
2. 恢复配置文件到对应位置
3. 重启服务
4. 验证健康检查

---

## 维护建议

### 每周

- 检查日志大小
- 查看监控告警历史
- 验证远程执行

### 每月

- 备份配置文件
- 检查 API Key 额度
- 更新 OpenClaw 版本（如有）

### 每季度

- 审查 command whitelist
- 审查 file_path whitelist
- 更新 token（如需要）

---

**最后更新**：2026-03-09 by OpenClaw Assistant
