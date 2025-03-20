# 节点同步脚本

> 本项目目前仍在开发中，后续内容将在有时间时继续完善...（指睡醒了（（（（目前仅在ubuntu上测试通过

## 一、客户端部署

### 支持的协议
目前支持：
- Hysteria2 (hy2)

### 部署方式

#### 1. hy2 完整部署
> 基于 [hysteria2](https://github.com/seagullz4/hysteria2) 修改，如有侵权请联系我删除，谢谢>_<

```bash
curl -s -O https://raw.githubusercontent.com/kilockok/clash-sync/refs/heads/main/hy2_install.sh && chmod +x hy2_install.sh && ./hy2_install.sh
```

#### 2. 仅部署同步脚本
```bash
curl -s -O https://raw.githubusercontent.com/kilockok/clash-sync/refs/heads/main/hy2_sync.sh && chmod +x hy2_sync.sh && ./hy2_sync.sh
```

## 二、服务器端部署

### 前置配置
1. 目前一键脚本还在开发（指创建文件），如需使用，请自行修改 `api.py` 配置文件路径：
   ```python
   CONFIG_FILE = "/www/wwwroot/example.com/clash.yaml"  # 替换为您的配置文件路径
   ```

2. 确保端口 54321 已开放（可在 api.py 末尾修改）

3. 可在客户端安装时添加 API 参数：
   ```bash
   -a http://您的服务器地址:54321/config
   ```

### 环境安装

1. 安装基础环境：
```bash
# 更新软件包
sudo apt update

# 安装 Python 环境
sudo apt install python3 python3-pip

# 安装依赖库
pip3 install flask ruamel.yaml
```

2. 下载服务端脚本：
```bash
wget -O api.py https://raw.githubusercontent.com/kilockok/clash-sync/refs/heads/main/api.py
```
---
## 配置 `api.py` 为服务并自启动

### 编辑 Systemd 服务文件

```sh
sudo nano /etc/systemd/system/clashapi.service
```

> **注意：** 若使用 `vim` 编辑，可执行：
> ```sh
> sudo vim /etc/systemd/system/clashapi.service
> ```
> 在 `vim` 中，按 `i` 进入编辑模式，完成后按 `Esc`，输入 `:wq` 保存并退出。

### 添加以下内容至 `clashapi.service`注意缩进 nano粘贴不会换行，建议使用vim

```ini
[Unit]
Description=Clash API Service
After=network.target

[Service]
User=root
WorkingDirectory=/root
ExecStart=/usr/bin/python3 /root/api.py
Restart=always
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
```

---


### 服务管理

```bash
# 重载服务配置
sudo systemctl daemon-reload
sudo systemctl enable clashapi.service

# 启动服务
sudo systemctl start clashapi.service

# 查看服务状态
sudo systemctl status clashapi.service
```
