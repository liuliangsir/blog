---
title: 使用 gitlab page 预览交互稿以及设计稿
date: "2020-10-12T12:00:03"
---

由于 [avg-product-1](https://g.126.fm/038sB52) 项目本身的体积过于庞大，导致用户在第一次 clone 的过程里面，需要花费大量的时间。不过，这种情况在一定条件下（用户使用内网）会有所缓解。在用户 clone 的操作完成之后，用户需要自己启动本地浏览器来打开对应的交互稿以及设计稿。经常重复这样的操作，这本身也是件很无趣的事情。注意，接下来的这种方式只是简化上面的流程。换句话说，在一些情况下用户仍然需要 clone [avg-product-1](https://g.126.fm/038sB52)。

## 思路

借助 Gitlab 自带的 Pages 服务，实现对 html 文件的访问。之所以会这样考虑，这是因为我们现在的设计稿以及交互稿都是由 html 文件生成。

借助 Gitlab 自带的 CI，实现自动化创建 Gitlab Pages 所需要的 artifacts 以及自动化部署相对应的 artifacts。

另外，由于一个 Pages 服务只提供一个入口。所以，我们需要针对不同的目录，手动创建相对应的额外入口文件（index.html），该入口文件里面包含跳转到子目录的所有超链接。

## 优化

1. 使用 cache 机制
2. 使用 `git show`，减少不必要的 CI 构建
3. 使用系统自带的 bash 脚本，减少不必要的第三方包（库）引入
4. 使用 [`git push -o ci.skip`](https://docs.gitlab.com/ee/user/project/push_options.html#push-options-for-gitlab-cicd) 或者 [commit 信息中包含 `[skip ci]` 、`[ci skip]`](https://devops.stackexchange.com/questions/6809/is-there-a-ci-skip-option-in-gitlab-ci)，跳过不必要的 CI 构建

## TODO

1. 界面不太友好
2. 构建失败的情况可能会频繁出现
3. 在生成 html 文件的过程中，会存在 html 文件冗余
4. 项目的体积可能会超过 Gitlab Pages 所规定的最大体积限制
