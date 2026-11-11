# hindsight-offline-kit（分卷存储）

Hindsight 离线安装包（目标机 H2413485，内网）。**内容 ~2.4GB，超出 Gitee 单文件限制，已切成 40MB 分卷放在 `parts/` 下。**

组件版本：uv 0.13.7 / hindsight-embed · hindsight-api-slim · hindsight CLI 全部 **1.2.1**（`embedVersion: "1.2.1"`）/ CPython 3.14.7 / BAAI-bge-small-en-v1.5 + hs-rerank-1 模型。已在联网机上以 `UV_OFFLINE=1 + HF_HUB_OFFLINE=1` 完成真离线启动验证。

## 还原（Windows 自带 PowerShell + tar，无需装任何东西）

```powershell
git clone https://gitee.com/jiuadaihui/hindsight-offline-kit.git
cd hindsight-offline-kit
powershell -ExecutionPolicy Bypass -File .\restore.ps1
```

Git Bash 一行版：`cat parts/hindsight-kit.tar.gz.part-* > bundle.tar.gz && mkdir restored && tar xzf bundle.tar.gz -C restored`

还原出的 `restored/` 即完整 `hindsight-offline-kit`，部署位置表见 `restored/README-拷贝说明.md`（逐条 robocopy 命令）。

## 卷清单与校验

- `parts/hindsight-kit.tar.gz.part-00 .. NN`（每卷 ≤40MB，绕开单文件限制）
- `parts/SHA256SUMS.txt`：合并后整包的 sha256（Git Bash 校验：`cat parts/* > bundle.tar.gz && sha256sum -c`）

## 重要提醒（给内网机的 agent）

1. daemon **硬性要求 LLM key**：不配置则引擎初始化抛 `ValueError: LLM API key is required` 拒绝启动 —— 内网 LLM 的 base_url / api_key / 模型名必须先准备好。
2. `%APPDATA%\uv\uv.toml`（阿里云默认源）必须与缓存配套拷贝，否则按源 URL 键控的缓存全部未命中。
3. `UV_OFFLINE=1`（用户级）必设；首次启动建议再加 `HINDSIGHT_EMBED_DAEMON_STARTUP_TIMEOUT=1800`。
4. `hindsight-embed profile create` 的 profile 名**不要用 `default`**（保留字，会误报 "Profile name cannot be empty"）。
5. 本分卷包相对原始包的裁剪：只带 CPython 3.14.7（daemon 与 tool env 实际使用的解释器），未带 3.11.16；其余内容与已验证版本一致。
