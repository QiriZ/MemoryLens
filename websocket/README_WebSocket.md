# 📹 WebSocket摄像头服务

基于WebSocket的实时摄像头图像传输服务，支持多客户端同时连接。

## 🚀 功能特性

- **实时传输**: 通过WebSocket实时传输摄像头图像
- **多客户端**: 支持多个客户端同时连接
- **低延迟**: 优化的图像编码和传输
- **跨平台**: 支持各种编程语言的WebSocket客户端
- **局域网访问**: 支持局域网内其他设备访问

## 📋 系统要求

- Python 3.7+
- 摄像头设备（内置或外接）
- macOS/Linux/Windows

## 🛠️ 安装步骤

1. **安装依赖包**
   ```bash
   pip install -r requirements.txt
   ```

2. **运行WebSocket服务器**
   ```bash
   python websocket_camera.py
   ```

## 🌐 访问地址

启动服务器后，可以通过以下地址连接：

### 本地访问
- `ws://localhost:8765`
- `ws://127.0.0.1:8765`

### 局域网访问
- `ws://[本机IP]:8765`

例如：`ws://192.168.1.100:8765`

## 📡 数据格式

服务器发送的JSON消息格式：

```json
{
    "type": "image",
    "data": "base64编码的JPEG图像",
    "timestamp": 1234567890.123
}
```

错误消息格式：
```json
{
    "type": "error",
    "message": "错误描述"
}
```

## 🧪 测试客户端

### 1. Python客户端
```bash
# 本地测试
python websocket_client.py

# 局域网测试
python websocket_client.py ws://192.168.1.100:8765
```

### 2. Web浏览器客户端
1. 打开 `websocket_client.html` 文件
2. 输入WebSocket服务器地址
3. 点击"连接"按钮

### 3. 自定义客户端
可以使用任何支持WebSocket的编程语言：

**JavaScript示例：**
```javascript
const ws = new WebSocket('ws://localhost:8765');
ws.onmessage = function(event) {
    const data = JSON.parse(event.data);
    if (data.type === 'image') {
        const img = document.createElement('img');
        img.src = 'data:image/jpeg;base64,' + data.data;
        document.body.appendChild(img);
    }
};
```

**Python示例：**
```python
import asyncio
import websockets
import json

async def client():
    async with websockets.connect('ws://localhost:8765') as websocket:
        async for message in websocket:
            data = json.loads(message)
            if data['type'] == 'image':
                print(f"收到图像，时间戳: {data['timestamp']}")

asyncio.run(client())
```

## 🔧 配置选项

### 摄像头索引
默认使用摄像头索引0。如需使用其他摄像头：

```python
camera_stream = CameraStream(camera_index=1)  # 使用第二个摄像头
```

### 端口配置
默认端口为8765，可修改：

```python
server = await websockets.serve(camera_handler, "0.0.0.0", 8765)
```

### 图像质量
可调整JPEG压缩质量：

```python
img_base64 = frame_to_base64(frame, quality=90)  # 0-100
```

### 传输频率
可调整图像传输频率：

```python
await asyncio.sleep(0.1)  # 10 FPS
```

## 📱 使用场景

1. **实时监控**: 多客户端同时查看摄像头画面
2. **远程控制**: 通过WebSocket控制摄像头
3. **图像处理**: 客户端接收图像进行AI分析
4. **移动应用**: 手机APP实时查看摄像头
5. **Web应用**: 网页中嵌入实时摄像头

## 🛡️ 安全注意事项

- 程序绑定到 `0.0.0.0`，支持局域网访问
- 生产环境中建议配置防火墙规则
- 不要将程序暴露到公网环境
- 考虑添加身份验证机制

## 🔍 故障排除

### 连接失败
- 检查服务器是否正在运行
- 确认端口8765未被占用
- 检查防火墙设置

### 图像延迟高
- 降低图像质量（quality参数）
- 减少传输频率
- 检查网络连接质量

### 多客户端性能问题
- 服务器会自动处理多连接
- 考虑增加服务器资源
- 优化图像编码参数

## 📝 文件说明

- `websocket_camera.py` - WebSocket服务器
- `websocket_client.py` - Python测试客户端
- `websocket_client.html` - Web浏览器测试客户端
- `requirements.txt` - Python依赖包

## 🆚 与HTTP版本对比

| 特性 | HTTP版本 | WebSocket版本 |
|------|----------|---------------|
| 实时性 | 需要轮询 | 实时推送 |
| 延迟 | 较高 | 较低 |
| 多客户端 | 支持 | 支持 |
| 资源消耗 | 较高 | 较低 |
| 实现复杂度 | 简单 | 中等 |
| 浏览器兼容性 | 很好 | 好 |

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目！ 