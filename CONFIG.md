# 配置说明 / Configuration Guide

## 中文说明

### API 配置
在使用 MemoryLens 之前，您需要配置以下参数：

1. 打开 `MemoryLens/App/Environment.swift` 文件
2. 替换以下占位符为您的实际配置：

```swift
let blockId = "YOUR_BLOCK_ID_HERE"      // 替换为您的 Coze Block ID
let chatId = "YOUR_CHAT_ID_HERE"        // 替换为您的 Coze Chat ID  
let workflowId = "YOUR_WORKFLOW_ID_HERE" // 替换为您的 Coze Workflow ID
let imageServerURL = "YOUR_IMAGE_SERVER_URL_HERE" // 替换为您的图片服务器地址
```

### 图片服务器配置
如果您使用项目中的 WebSocket 图片服务：

1. 进入 `websocket` 目录
2. 安装依赖：`pip install -r requirements.txt`
3. 运行服务：`python main.py`
4. 将 `imageServerURL` 设置为您的服务器地址（例如：`192.168.1.100:7000`）

---

## English Instructions

### API Configuration
Before using MemoryLens, you need to configure the following parameters:

1. Open `MemoryLens/App/Environment.swift` file
2. Replace the following placeholders with your actual configuration:

```swift
let blockId = "YOUR_BLOCK_ID_HERE"      // Replace with your Coze Block ID
let chatId = "YOUR_CHAT_ID_HERE"        // Replace with your Coze Chat ID  
let workflowId = "YOUR_WORKFLOW_ID_HERE" // Replace with your Coze Workflow ID
let imageServerURL = "YOUR_IMAGE_SERVER_URL_HERE" // Replace with your image server URL
```

### Image Server Configuration
If you're using the WebSocket image service included in the project:

1. Navigate to the `websocket` directory
2. Install dependencies: `pip install -r requirements.txt`
3. Run the service: `python main.py`
4. Set `imageServerURL` to your server address (e.g., `192.168.1.100:7000`)

## 安全提醒 / Security Notice

⚠️ **重要**: 请不要将包含真实 API 密钥的配置文件提交到公共代码仓库中。

⚠️ **Important**: Do not commit configuration files containing real API keys to public repositories.
