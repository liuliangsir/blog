---
title: PostCSS 8 插件迁移的二三事
date: "2020-09-20T12:44:03"
---
本文已获得原作者（Andrey Sitnik）和 Evil Martians 授权许可进行翻译。原文介绍了如何把 PostCSS 插件给迁移到 PostCSS 8.0。

- 原文链接：[postcss 8 plugin migration](https://evilmartians.com/chronicles/postcss-8-plugin-migration)
- 作者：[Andrey Sitnik](https://twitter.com/sitnikcode)
- 站点：Evil Martians ——位于纽约和俄罗斯的 Ruby on Rails 开发人员博客。 它发布了许多优秀的文章，并且是不少 gem 的赞助商

随着 8.0 版本的发布，PostCSS 也迎来了一次大版本的更新，该版本的代号被命名为“欧赛魔神”（President Ose）。经过这次更新之后，PostCSS 插件的作者可以有选择性地使用一新 API，该 API 能够提升构建速度以及减少插件用户安装依赖的体积。该指南旨在描述一些内容：作为一个插件开发者，为了能够“掏空”（make the most out of） 新 PostCSS，你所需要采取的一些步骤。

> PostCSS，一个使用 JavaScript 来处理 CSS 的框架。在经历[周下载量](https://www.npmtrends.com/postcss)超过 `25_000_000` 之后，已经成为当代 web 开发领域里面最流行的前端工具之一。

至于为什么会有那么多代码库依赖 PostCSS，一是因为 PostCSS 有 [webpack](https://webpack.js.org/) 或者 [Rails](https://rubyonrails.org/) 等类似大项目背书，二是 [PostCSS 插件](https://www.postcss.parts/)生态的加持。不得不说，[PostCSS 插件](https://www.postcss.parts/)的出现改变前端开发者撸 CSS 的方式。

在 PostCSS 里面配置简单的 JavaScript 规则，就可以实现任务自动化，比如 CSS 语法检查以及给 CSS 属性名加浏览器前缀，或者支持新的 CSS 写法，该 CSS 写法还未被当前的 web 标准所直接接纳。

如果你有开发或者维护 PostCSS 插件的经历，那这篇博文就非常适合你阅读。因为它在这里面罗列出插件开发者为了让插件适配 PostCSS 新版本所应该做的二三事。

可以去 github 上看一下有关于此次最新发布的完整[描述](https://github.com/postcss/postcss/releases/tag/8.0.0)，了解一下 PostCSS 8.0 还有哪些新特性，包括更好的 source map 支持以及极具弹性（resilient）的 CSS 解析。

## 为什么插件开发者需要更新自己的插件

先前的 PostCSS 版本对于插件来说，可谓是限制重重：

- **速度**，即使你的插件只改了少量的样式属性，PostCSS 也还是会遍历 CSS bundle 文件的整个抽象语法树（Abstract Syntax Tree）。既然存在不同的插件经常会被放到一起使用的情况，所以任何一个属性的变更，都会导致所有插件都需要去遍历整个抽象语法树，这极大降低插件用户构建 CSS 速度。
- **node_modules 的体积**，插件能够列出 `dependencies` 下不同版本的 PostCSS。如果 npm 执行删除重复数据的操作失败，这会导致最终的 `node_modules` 文件夹臃肿不堪。
- **兼容性**，针对老版本的 PostCSS，插件可以使用废弃的方式来构建节点（比如，`postcss.decl()`）。混用不同版本的 PostCSS 所创建的抽象语法树节点，会导致 bug 难以定位。

## 第一步：把 `postcss` 移到 `peerDependencies` 里面

第一步很简单，只需要把 PostCSS 7.x 从 `dependencies` 里面移除，然后把 PostCSS 8.x 加到 `devDependencies` 里面。

```bash
npm uninstall postcss
npm install postcss --save-dev
```

接着，通过编辑 `package.json` 文件，把 PostCSS 8.x 加到 `peerDependencies` 里面：

```bash
  "dependencies": {
-   "postcss": "^7.0.10"
  },
  "devDependencies": {
+   "postcss": "^8.0.0"
  },
+ "peerDependencies": {
+   "postcss": "^8.0.0"
+ }
}
```

这样会控制插件用户的 `node_modules` 体积：现在，所有插件都会使用相同版本的 `postcss` 作为依赖。

如果你的 `dependencies` 里面没有任何内容，可以随意删除 `dependencies`：

```bash
- "dependencies": {
- }
  "devDependencies": {
```

不要忘记在自己的插件文档里面更新[安装指引](https://github.com/postcss/postcss-focus#usage)相关内容：

```bash
- npm install --save-dev postcss-focus
+ npm install --save-dev postcss postcss-focus
```

## 第二步：使用新的 API

1. 用 `module.exports = creator` 代替 `module.exports = postcss.plugin(name, creator)`。

2. 返回一个对象，该对象里面包含 `postcssPlugin` 属性以及 `Root` 方法，`postcssPlugin` 属性值为插件名。

3. 把之前的插件代码移到 `Root` 方法里面。

4. 在文件的最后加上 `module.exports.postcss = true`。

之前：

```bash
- module.exports = postcss.plugin('postcss-dark-theme-class', (opts = {}) => {
-   checkOpts(opts)
-   return (root, result) => {
      root.walkAtRules(atrule => { … })
-   }
- })
```

之后：

```bash
+ module.exports = (opts = {}) => {
+   checkOpts(opts)
+   return {
+     postcssPlugin: 'postcss-dark-theme-class',
+     Root (root, { result }) => {
        root.walkAtRules(atrule => { … })
+     }
+   }
+ }
+ module.exports.postcss = true
```

不要忘记 `module.exports.postcss = true`。它可以让 PostCSS 区分出插件用户调用插件的方式：`require('plugin')` 以及 `require('plugin')(opts)`。

## 第三步：“掏空”新的 API

PostCSS 8.x 会对 CSS 树进行一次扫描。多个插件可以借用这次扫描结果来获取更好的性能。

为了使用这次扫描结果，你需要移除 `root.walk*` 函数的调用代码，然后把代码移到插件对象里面的 `Declaration()`、`Rule()`、 `AtRule()` 或者 `Comment()` 方法里面：

```bash
  module.exports = {
    postcssPlugin: 'postcss-dark-theme-class',
-   Root (root) {
-     root.walkAtRules(atRule => {
-       // Slow
-     })
-   }
+   AtRule (atRule) {
+     // Faster
+   }
  }
  module.exports.postcss = true
```

对于声明以及 @ 规则（at-rules），你可以通过订阅特定的声明属性或者 @ 规则（at-rules） 名字来获取更快的代码执行速度：

```bash
  module.exports = {
    postcssPlugin: 'postcss-example',
-   AtRule (atRule) {
-     if (atRule.name === 'media') {
-       // Faster
-     }
-   }
+   AtRule: {
+     media: atRule => {
+       // The fastest
+     }
+   }
  }
  module.exports.postcss = true
```

注意，插件将会再次遍历那些所有变更过或者新增的节点。所以你应该主动去检查插件执行转换的这个流程是否已经被执行过，以及判断该种情况是否需要忽略这些节点。记住只有 `Root` 以及 `RootExit` 监听器（listener）才只会被真正调用一次。

```bash
const plugin = () => {
  return {
    Declaration(decl) {
      console.log(decl.toString());
      decl.value = "red";
    },
  };
};
plugin.postcss = true;

await postcss([plugin]).process("a { color: black }", { from });
// => color: black
// => color: red
```

如果你的插件大到难以被重写，继续在 `Root` 监听器（listener）里面使用 `walk` 方法也不失为一种方法。

新版的 PostCSS 包含两种不同类型的监听器（listener）：“enter” 以及 “exit”。`Root`、`AtRule`、或者 `Rule` 方法会在该节点下的所有子元素被处理之前调用。`RootExit`、`AtRuleExit` 以及 `RuleExit` 会在该节点下的所有子元素被处理之后调用。

如果你需要在两个监听器之间共享数据，你可以使用 `prepare()`：

```bash
module.exports = (opts = {}) => {
  return {
    postcssPlugin: "PLUGIN NAME",
    prepare(result) {
      const variables = {};
      return {
        Declaration(node) {
          if (node.variable) {
            variables[node.prop] = node.value;
          }
        },
        RootExit() {
          console.log(variables);
        },
      };
    },
  };
};
```

## 第四步：移除 import `postcss` 代码

在 PostCSS 插件新 API 的加持下，你也就没有必要引入 `postcss`。因为你可以从 `Root` 函数的第二个参数里面拿到所有样式以及方法：

```bash
- const { list, Declaration } = require('postcss')

  module.exports = {
    postcssPlugin: 'postcss-example',
-   Root (root) {
+   Root (root, { list, Declaration }) {
      …
    }
  }
  module.exports.postcss = true
```

如果你不想马上做，你也可以暂时保持原样，什么都不改。

## 第五步：减少 npm 包的体积

这一步不做强制规定，不过我们想给 [clean-publish](https://github.com/shashkovdanil/clean-publish) 工具打个广告，该工具能够在你发布 npm 包之前，清理 `package.json` 里面有关于开发配置的配置项。如果 PostCSS 生态开始准备用它，我们可以把 `node_modules` 甚至弄的更小。

把下面这行代码加到你的项目里面：

```bash
npm install --save-dev clean-publish
```

现在可以用 `npx clean-publish` 来替代 `npm publish`。

你可以使用官方提供的[插件脚手架](https://github.com/postcss/postcss-plugin-boilerplate)以及插件，来作为自己学习使用新 API 的范例：

- [`postcss-dark-theme-class`](https://github.com/postcss/postcss-dark-theme-class)

- [`postcss-mixins`](https://github.com/postcss/postcss-mixins)

我们推荐使用 [Sharec](https://lamartire.github.io/sharec/) 来管理自己的开发配置，并且它可以实现多个项目共享一个开发配置。去[这里](https://github.com/postcss/postcss-sharec-config)，你可以发现 PostCSS 的共享配置。

为了解决大家的问题，我们这边开通 [Gitter chat](https://gitter.im/postcss/postcss) 账号！不要犹豫，快来跟我们分享你们迁移的心路历程或者你插件的语法和架构。我们非常乐于帮助大家排忧解难。
