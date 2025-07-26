# MemoryLens - 智能物体识别与记忆助手

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![visionOS](https://img.shields.io/badge/visionOS-1.0+-blue.svg)](https://developer.apple.com/visionos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

🎉 **AdventureX版本：MemoryLens v1.1.0**

一个基于 Apple Vision Pro 的智能物体识别与记忆助手，专为老年人和记忆力减退的用户设计。

## 🌟 新版本特性 (v1.1.0)

### ✨ 新增功能
- **情感交互**: 新增"我想你了"关键词识别，提供温暖的情感回应
- **智能语音响应**: 为不同物品提供个性化的语音提示
- **记忆卡系统**: 详细的物品位置记录和环境信息
- **实时语音识别**: 支持中文语音交互
- **沉浸式界面**: 优化的 Vision Pro 空间计算体验

### 🔧 技术改进
- 修复图片资源路径问题
- 优化音频播放和语音识别流程
- 增强用户界面响应性
- 改进错误处理机制

## 📱 功能特色

### 🎯 核心功能
- **智能物体识别**: 基于 Core ML 的实时物体检测
- **语音交互**: 自然语言查询物品位置
- **记忆管理**: 记录和回忆常用物品位置
- **情感陪伴**: 温暖的人性化交互体验

### 🗣️ 语音命令支持
- "我的钥匙在哪里？"
- "帮我找找手机"
- "我想你了" (情感回应)
- "这是什么东西？"

### 🎨 用户界面
- **沉浸式体验**: 专为 Vision Pro 优化的空间界面
- **直观操作**: 语音和手势双重交互方式
- **个性化设置**: 可调节的语音交互和实时记录功能

## 🚀 快速开始

### 系统要求
- **Apple Vision Pro** with visionOS 1.0+
- **Xcode 15.0+**
- **Swift 5.9+**

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/QiriZ/MemoryLens.git
   cd MemoryLens
   ```

2. **打开项目**
   - 在 Xcode 中打开 `MemoryLens.xcodeproj`
   - 选择 Vision Pro 模拟器或设备

3. **构建运行**
   - 点击运行按钮或使用 `Cmd+R`
   - 在 Vision Pro 上体验应用

## 📁 项目结构

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
├── Packages/                   # Swift 包依赖
└── MemoryLensTests/           # 测试文件
```

## 🔧 技术架构

### 核心技术栈
- **SwiftUI**: 现代化用户界面框架
- **RealityKit**: 3D 渲染和空间计算
- **Core ML**: 机器学习模型推理
- **Speech Framework**: 语音识别
- **AVFoundation**: 音频处理
- **WebSocket**: 实时通信

### 依赖库
- **Alamofire**: HTTP 网络请求
- **SwiftyJSON**: JSON 解析
- **Starscream**: WebSocket 客户端

## 🎮 使用指南

### 基本操作
1. **启动应用**: 在 Vision Pro 上打开 MemoryLens
2. **语音交互**: 说出您要查找的物品名称
3. **视觉反馈**: 应用会在检测到的物品周围显示边框
4. **获取帮助**: 应用会提供物品位置的语音提示

### 高级功能
- **回忆簿**: 查看已记录的物品历史
- **设置面板**: 个性化配置语音交互和实时记录
- **记忆卡**: 详细的物品位置和环境信息

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献
1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 开发规范
- 遵循 Swift 编码规范
- 添加适当的注释和文档
- 确保代码通过所有测试

## 📄 开源协议

本项目采用 MIT 协议开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- 感谢 Apple 提供的 Vision Pro 开发平台
- 感谢开源社区的各种优秀库和工具
- 感谢所有贡献者的支持

## 📞 联系方式

- **项目维护者**: [QiriZ](https://github.com/QiriZ)
- **GitHub**: [@QiriZ](https://github.com/QiriZ)

## 🔄 版本历史

### v1.1.0 (AdventureX版本) - 2025年1月
- ✨ 新增"我想你了"情感交互功能
- 🎯 优化语音识别和响应系统
- 🎨 改进用户界面和交互体验
- 🔧 修复图片资源和音频播放问题
- 📚 完善项目文档和代码注释

### v1.0.0 - 2024年12月
- 🎉 初始版本发布
- 📱 基础物体识别功能
- 🗣️ 语音交互系统
- 🎨 Vision Pro 原生界面

---

如果这个项目对您有帮助，请给我们一个 ⭐️

---

*MemoryLens - 让记忆更智能，让生活更温暖* 