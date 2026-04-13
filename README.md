# Word Town

一个基于 Flutter 开发的文字冒险游戏，玩家通过学习单词来推进剧情，探索一个神秘的平行城市。

## 🎮 游戏特色

- **沉浸式剧情**：在平行城市「灰烬之夜」副本中探索神秘故事
- **单词学习**：通过游戏互动学习英语单词
- **多种结局**：根据你的选择决定故事走向
- **精美音效**：沉浸式的音效和背景音乐体验

## 🚀 快速开始

### 环境要求

- Flutter 3.10+
- Dart 3.0+
- Android SDK / iOS SDK（根据目标平台）

### 安装步骤

```bash
# 克隆项目
git clone https://github.com/your-username/word-town.git
cd word-town

# 安装依赖
flutter pub get

# 运行项目
flutter run
```

### 构建命令

```bash
# 构建 Android APK
flutter build apk

# 构建 Web
flutter build web
```

## 📁 项目结构

```
word_town/
├── lib/                 # Dart 源代码
│   ├── audio/          # 音频管理
│   ├── models/         # 数据模型
│   ├── providers/      # 状态管理
│   ├── scenes/         # 游戏场景
│   │   ├── clinic_scene.dart
│   │   ├── ending_scene.dart
│   │   ├── forge_scene.dart
│   │   ├── letter_scene.dart
│   │   ├── plaza_scene.dart
│   │   └── underground_scene.dart
│   ├── theme/          # 主题配置
│   ├── widgets/        # 自定义组件
│   │   ├── effects/    # 特效组件
│   │   └── ...         # UI 组件
│   └── main.dart       # 入口文件
├── assets/             # 静态资源
│   ├── audio/          # 音效和背景音乐
│   │   ├── bgm_*.mp3   # 场景背景音乐
│   │   └── *.mp3       # 音效文件
│   ├── backgrounds/    # 场景背景图
│   ├── characters/     # NPC 角色立绘
│   ├── decorations/    # 装饰物品
│   ├── endings/        # 结局画面
│   ├── icons/          # 图标资源
│   └── scenes/         # 场景特定资源
├── android/            # Android 平台配置
├── ios/                # iOS 平台配置
├── linux/              # Linux 平台配置
├── macos/              # macOS 平台配置
├── web/                # Web 平台配置
├── windows/            # Windows 平台配置
└── pubspec.yaml        # 项目依赖配置
```

## 🎯 游戏玩法

1. 阅读对话中的高亮单词
2. 点击单词查看释义（未接触的单词显示为 ???）
3. 通过学习单词解锁新剧情
4. 在关键节点做出选择
5. 探索不同的结局

## 📜 故事背景

在平行城市「灰烬之夜」，玩家将扮演一名探索者，通过学习单词来揭开这个神秘世界的秘密。每个单词都是一把钥匙，帮助你理解这个世界的真相。

## 📄 许可证

MIT License

---

*Made with Flutter ❤️*
