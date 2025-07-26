# MemoryLens 🔍

<div align="center">
  <img src="poster/poster.png" alt="MemoryLens Poster" width="600"/>
  
  **一个基于 Apple Vision Pro 的智能物体识别与记忆助手**
  
  **An intelligent object recognition and memory assistant for Apple Vision Pro**

  [![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
  [![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)](https://developer.apple.com/xcode/)
  [![visionOS](https://img.shields.io/badge/visionOS-1.0+-purple.svg)](https://developer.apple.com/visionos/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📖 项目简介 / Project Overview

### 中文简介
MemoryLens 是一款专为 Apple Vision Pro 设计的智能应用，结合了机器学习、语音识别和实时图像处理技术。它能够帮助用户识别和记忆日常物品的位置，通过自然语言交互提供智能的物品查找服务。

### English Overview
MemoryLens is an intelligent application designed specifically for Apple Vision Pro, combining machine learning, speech recognition, and real-time image processing technologies. It helps users identify and remember the locations of everyday objects, providing intelligent object-finding services through natural language interaction.

## ✨ 功能特性 / Features

### 🎯 核心功能 / Core Features
- **🔍 智能物体识别**: 使用 Core ML 模型进行实时物体检测
- **🗣️ 语音交互**: 支持中文语音识别和自然语言处理
- **📱 混合现实界面**: 原生 visionOS 界面，支持空间计算
- **🌐 实时通信**: WebSocket 连接支持实时数据传输
- **🎵 音频反馈**: 智能语音播放和音频提示

### 🛠️ 技术特性 / Technical Features
- **Real-time Object Detection**: Core ML model for live object recognition
- **Speech Recognition**: Chinese speech recognition and natural language processing
- **Mixed Reality UI**: Native visionOS interface with spatial computing support
- **Real-time Communication**: WebSocket connection for live data transmission
- **Audio Feedback**: Intelligent voice playback and audio prompts

## 🏗️ 技术架构 / Technical Architecture

### 系统架构 / System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vision Pro    │    │  Image Server   │    │   AI Service    │
│   MemoryLens    │◄──►│   (WebSocket)   │◄──►│     (Coze)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 核心组件 / Core Components

#### 📱 Vision Pro 应用 / Vision Pro App
- **SwiftUI + RealityKit**: 混合现实用户界面
- **Core ML**: 本地机器学习推理
- **Speech Framework**: 语音识别
- **AVFoundation**: 音频处理

#### 🖼️ 图像服务 / Image Service
- **Flask**: Web 服务器框架
- **OpenCV**: 图像处理
- **WebSocket**: 实时通信

#### 🤖 AI 服务 / AI Service
- **Coze API**: 智能对话和工作流
- **自然语言处理**: 语义理解和响应生成

## 🚀 快速开始 / Quick Start

### 系统要求 / System Requirements
- **Apple Vision Pro** with visionOS 1.0+
- **Xcode 15.0+** 
- **Swift 5.9+**
- **Python 3.7+** (for image server)

### 安装步骤 / Installation Steps

#### 1. 克隆项目 / Clone Repository
```bash
git clone https://github.com/yourusername/MemoryLens.git
cd MemoryLens
```

#### 2. 配置环境 / Configure Environment
参考 [CONFIG.md](CONFIG.md) 文件配置 API 密钥和服务器地址。

Refer to [CONFIG.md](CONFIG.md) for API keys and server configuration.

#### 3. 启动图像服务 / Start Image Service
```bash
cd websocket
pip install -r requirements.txt
python main.py
```

#### 4. 构建应用 / Build App
1. 在 Xcode 中打开 `MemoryLens.xcodeproj`
2. 选择 Vision Pro 模拟器或设备
3. 点击运行按钮

## 📱 使用说明 / Usage Guide

### 基本操作 / Basic Operations
1. **启动应用**: 在 Vision Pro 上打开 MemoryLens
2. **语音交互**: 说出您要查找的物品名称
3. **视觉反馈**: 应用会在检测到的物品周围显示边框
4. **获取帮助**: 应用会提供物品位置的语音提示

### 支持的语音命令 / Supported Voice Commands
- "我的钥匙在哪里？" / "Where are my keys?"
- "帮我找找手机" / "Help me find my phone"
- "这是什么东西？" / "What is this?"

## 📁 项目结构 / Project Structure

```
MemoryLens/
├── MemoryLens/                 # 主应用代码
│   ├── App/                    # 应用配置
│   │   ├── MemoryLensApp.swift # 应用入口
│   │   └── Environment.swift   # 环境配置
│   ├── View/                   # 用户界面
│   │   ├── ImmersiveView.swift # 沉浸式视图
│   │   └── CanvasView.swift    # 画布视图
│   ├── Module/                 # 功能模块
│   │   ├── SpeechRecognizer.swift # 语音识别
│   │   ├── AudioPlayer.swift   # 音频播放
│   │   ├── BoxManager.swift    # 边框管理
│   │   └── Socket.swift        # WebSocket 通信
│   ├── MLModel/                # 机器学习模型
│   │   ├── KeyDetection.mlmodel # Core ML 模型
│   │   └── KeyFinder.swift     # 模型接口
│   └── Model/                  # 数据模型
│       └── BoundingBox.swift   # 边框数据结构
├── websocket/                  # 图像服务器
│   ├── main.py                 # 服务器主程序
│   ├── websocket_camera.py     # 摄像头处理
│   └── requirements.txt        # Python 依赖
├── poster/                     # 项目图片资源
└── Packages/                   # Swift 包依赖
```

## 🔧 依赖项 / Dependencies

### Swift 包依赖 / Swift Package Dependencies
- **[Alamofire](https://github.com/Alamofire/Alamofire)**: HTTP 网络请求库
- **[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)**: JSON 解析库
- **[Starscream](https://github.com/daltoniam/Starscream)**: WebSocket 客户端库

### Python 依赖 / Python Dependencies
- **Flask**: Web 服务器框架
- **OpenCV**: 图像处理库
- **WebSocket**: 实时通信支持

## 📸 应用截图 / Screenshots

<div align="center">
  <img src="poster/app-icon.jpg" alt="App Icon" width="200"/>
  <p><em>应用图标 / App Icon</em></p>
</div>

## 🤝 贡献指南 / Contributing

我们欢迎所有形式的贡献！/ We welcome all forms of contributions!

### 如何贡献 / How to Contribute
1. Fork 本项目 / Fork the project
2. 创建功能分支 / Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. 提交更改 / Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 / Push to the branch (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request / Open a Pull Request

### 开发规范 / Development Guidelines
- 遵循 Swift 编码规范
- 添加适当的注释和文档
- 确保代码通过所有测试
- Follow Swift coding conventions
- Add appropriate comments and documentation
- Ensure code passes all tests

## 🐛 问题反馈 / Issue Reporting

如果您遇到任何问题或有功能建议，请通过以下方式联系我们：

If you encounter any issues or have feature suggestions, please contact us through:

- **GitHub Issues**: [提交问题 / Submit Issue](https://github.com/yourusername/MemoryLens/issues)
- **邮箱 / Email**: your.email@example.com

## 📄 开源协议 / License

本项目采用 MIT 协议开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 致谢 / Acknowledgments

- 感谢 Apple 提供的 Vision Pro 开发平台
- 感谢开源社区的各种优秀库和工具
- Thanks to Apple for the Vision Pro development platform
- Thanks to the open source community for various excellent libraries and tools

## 📞 联系方式 / Contact

- **项目维护者 / Project Maintainer**: [Your Name]
- **邮箱 / Email**: your.email@example.com
- **GitHub**: [@yourusername](https://github.com/yourusername)

## 🔄 项目开发总结与反思 / Project Development Summary & Reflection

### 📈 项目完成情况 / Project Completion Status

本项目已完成 GitHub 发布的所有准备工作：

✅ **已完成的工作 / Completed Work**:
1. **项目文件整理**: 移除了测试项目 `ui_visionpro`，处理了敏感信息
2. **文档完善**: 创建了完整的中英文双语 README.md
3. **开源协议**: 添加了 MIT License
4. **配置管理**: 创建了 .gitignore 和配置说明文件
5. **图片优化**: 优化了图片大小（从17MB减少到654KB）
6. **元数据完善**: 更新了 Info.plist 和版本信息

### 🛠️ 技术架构优化建议 / Technical Architecture Optimization Suggestions

#### 安全性改进 / Security Improvements
- ✅ 已将硬编码的 API 密钥和服务器地址移至配置文件
- 🔄 建议：实现环境变量配置系统
- 🔄 建议：添加 API 密钥验证机制

#### 代码质量提升 / Code Quality Enhancement
- 🔄 建议：添加单元测试覆盖
- 🔄 建议：实现错误日志系统
- 🔄 建议：添加代码文档注释

#### 用户体验优化 / User Experience Optimization
- 🔄 建议：添加多语言支持（英文、日文等）
- 🔄 建议：实现离线模式功能
- 🔄 建议：优化语音识别准确度

### 🚀 未来发展方向 / Future Development Directions

#### 短期目标 (1-3个月) / Short-term Goals
1. **功能完善**: 添加更多物体识别类型
2. **性能优化**: 提升 Core ML 模型推理速度
3. **用户反馈**: 收集并处理用户使用反馈

#### 中期目标 (3-6个月) / Medium-term Goals
1. **平台扩展**: 考虑支持其他 AR 平台
2. **AI 增强**: 集成更先进的 AI 模型
3. **社区建设**: 建立开发者社区

#### 长期目标 (6个月+) / Long-term Goals
1. **商业化**: 探索商业应用场景
2. **生态系统**: 构建完整的 AR 应用生态
3. **技术创新**: 推动 Vision Pro 开发技术发展

### 📝 开发经验总结 / Development Experience Summary

#### 成功经验 / Success Factors
- **模块化设计**: 清晰的代码结构便于维护
- **文档先行**: 完善的文档提高了项目可用性
- **安全意识**: 及时处理敏感信息避免安全风险

#### 改进空间 / Areas for Improvement
- **测试覆盖**: 需要增加自动化测试
- **CI/CD**: 建议建立持续集成流程
- **监控系统**: 需要添加应用性能监控

### 🤝 贡献指南补充 / Additional Contributing Guidelines

对于未来的贡献者，建议关注以下方面：
1. **Vision Pro 最佳实践**: 遵循 Apple 的 visionOS 开发指南
2. **性能优化**: 注意 AR 应用的性能要求
3. **用户体验**: 重视空间计算的用户交互设计

---

<div align="center">
  <p>如果这个项目对您有帮助，请给我们一个 ⭐️</p>
  <p>If this project helps you, please give us a ⭐️</p>
</div>
