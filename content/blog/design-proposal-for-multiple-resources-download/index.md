---
title: 素材批量下载
date: "2020-04-11T14:16:25"
---

总体来说，针对素材批量下载的这个需求一共有两个方案，分别为素材逐一下载以及素材打包下载。

## 方案一：素材逐一下载

### 思路

- 使用前端 `js` 脚本，动态创建一个带 `download` 属性的 `a` 标签，该 `a` 标签的 `href` 属性值为素材的下载地址

- 使用前端 `js` 脚本，主动调用 `a` 标签的 click 方法，从而触发浏览器的下载功能（浏览器默认会在下载操作被执行之前，询问每个文件的保存位置，默认行为可以被修改）

- 遍历所有需要被下载的素材，重复执行上述一、二步操作

### 流程图

![逐个下载.png](https://ww1.sinaimg.cn/large/d58e2729gy1gdps76orp5j206f0j63yu.jpg)

### 优点

- 实现简单

### 缺点

- 体验不太友好
- 效率不高

## 方案二：素材打包下载

### 思路

- 在前端使用 [fetch](https://fetch.spec.whatwg.org/) 或者 [axios](https://github.com/axios/axios) 工具，将所需下载的素材先预请求下来

- 使用 [JSZip](https://stuk.github.io/jszip/) 工具将所有资源给打包成一个名为 **素材.zip** 的压缩文件

- 使用前端 `js` 脚本，动态创建一个带 `download` 属性的 `a` 标签，该 `a` 标签的 `href` 以及 `download` 的值分别为 **素材.zip** 以及 **素材.zip** 转成 blob 之后的数据

### 流程图

![打包下载.png](https://ww1.sinaimg.cn/large/d58e2729gy1gdps76owasj20c90m9t9b.jpg)

### 优点

- 体验友好
- 异步转换

### 缺点

- 耗时比较长
- 实现较为复杂

### 耗时

png(2.82M * 36) | jpg(3.42M * 36) | gif(3.65M * 36) | mp3(9.73M * 36)
:-:|:-:|:-:|:-:
33173 ms | 47124 ms | 131480 ms | 242303 ms

### 兼容性

| [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/edge/edge_48x48.png" alt="IE / Edge" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>IE / Edge | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/firefox/firefox_48x48.png" alt="Firefox" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Firefox | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/chrome/chrome_48x48.png" alt="Chrome" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chrome | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/safari/safari_48x48.png" alt="Safari" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Safari |
| :---------: | :---------: | :---------: | :---------: |
| Edge| last 2 versions| last 2 versions| last 2 versions

### 例子

真实数据可以通过[这个例子](https://github.com/liuliangsir/image-downloader-example)来获取
