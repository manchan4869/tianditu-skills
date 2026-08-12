---
name: tianditu-webapi
description: 天地图 Web 服务 API 综合指南（零依赖 curl）。支持地名搜索 V2.0（普通/地名/视野内/周边/多边形/行政区划区域/分类/统计八种查询）、驾车规划、公交规划、地理编码、逆地理编码、行政区划 V2.0、静态地图。使用场景：搜索 POI 地点（医院/学校/公园/美食等）、查"某点附近有什么"、"规划驾车/公交路线"、地址与经纬度互转、查行政区划边界与编码、生成带标注的静态地图图片。
version: 1.0.0
license: MIT
homepage: https://lbs.tianditu.gov.cn
---

# 天地图 Web 服务 API 综合 Skill

天地图（国家地理信息公共服务平台）Web 服务 API 提供 HTTP/HTTPS 接口，**零运行时依赖，仅用 curl 调用 REST API**。所有接口需要先在[天地图控制台](https://cloudcenter.tianditu.gov.cn/center/development/myApp)申请服务 Key（参数名为 `tk`）。

## 功能特性

- 🔍 地名搜索 V2.0 八种查询：普通搜索(1)、地名搜索(7)、视野内(2)、周边(3)、多边形(10)、行政区划区域(12)、数据分类(13)、统计(14)
- 🛣️ 驾车规划（最快/最短/避开高速/步行，支持途经点）
- 🚌 公交规划（较快捷/少换乘/少步行/不坐地铁）+ 公交站/线路详情 + 返程线路查询
- 📍 地理编码（地址→坐标）与逆地理编码（坐标→地址）
- 🏛️ 行政区划 V2.0（名称/国标码查层级、中心点、轮廓边界）
- 🗺️ 静态地图图片（标注/折线/面/自定义图标/底图叠加）
- 🌐 采用 CGCS2000/WGS-84 坐标（与 GPS 一致，**无需纠偏**，区别于高德 GCJ-02）

## 首次配置

1. 访问 [天地图控制台](https://cloudcenter.tianditu.gov.cn/center/development/myApp) → 注册用户 → 申请成为开发者 → 创建应用，**应用类型选择「服务端」**（本 skill 调用的是 Web 服务 API，必须服务端类型 Key）→ 获取 Key
2. 设置环境变量：`export TIANDITU_KEY=your_key`
3. 或手动编辑 `config.json`（模板见 `config.example.json`）

发起请求时优先使用环境变量，其次读取 `config.json`。

## 触发条件

用户表达了以下意图之一：
- 搜索某类地点或某个确定地点（"找医院"、"学校在哪"、"搜公园"）
- 在某个位置附近/范围内搜索（"天安门附近酒店"、"北京市海淀区医院"）
- 规划驾车或公交路线（"从天安门到故宫怎么走"、"查公交线路"）
- 地址与经纬度互转（"这个地址的坐标是多少"、"这个坐标是哪里"）
- 查行政区划（"北京的区划编码"、"朝阳区的边界"）
- 生成地图图片（"生成一张带标注的地图"）
- 含"搜"、"找"、"查"、"附近"、"周边"、"路线"、"规划"、"编码"、"边界"等关键词
- 用户未指定地图服务商时的中国境内地图查询（天地图是国家官方底图数据源）

## 场景判断

收到用户请求后，先判断属于哪个场景，再执行对应 recipe：

| 场景 | 判断依据 | 执行流程 |
|------|---------|---------|
| **场景一** 关键词搜索 | 明确类别或地点，无位置限定 | `recipes/keyword_search.md` |
| **场景二** 周边搜索 | 同时含「位置」和「搜索类别」（半径≤10km） | `recipes/nearby_search.md` |
| **场景三** 区域搜索 | 视野范围/多边形/行政区/分类/统计 | `recipes/region_search.md` |
| **场景四** 路线规划 | 规划驾车/公交路线 | `recipes/route_planning.md` |
| **场景五** 静态地图 | 生成带标注的地图图片 | `recipes/static_map.md` |
| **场景六** 地址坐标 | 地理/逆地理编码、行政区划查询 | `recipes/geocode_admin.md` |

**通用规则：**
- 所有请求必须携带 `tk` 参数（环境变量 `TIANDITU_KEY` 或 `config.json`），禁止省略
- **postStr/ds 参数是 JSON 字符串，必须用 curl 的 `--data-urlencode` 编码**，不能直接拼接在 URL 中（否则引号/中文会破坏请求）
- 所有坐标均为 `经度,纬度`（lon,lat）顺序，WGS-84 坐标，纬度范围 -90~90，经度 -180~180
- 接口返回 `status.infocode` 或 `status` 非正常值时对照 `references/error_codes.md` 排查
- 天地图坐标系统为 CGCS2000（与 WGS-84 基本一致），与高德/百度坐标不同，不要混用

---

## 参考资料索引

**recipes/（场景流程）：**

| 文件 | 场景 |
|------|------|
| `recipes/keyword_search.md` | 场景一 关键词搜索（普通/地名搜索） |
| `recipes/nearby_search.md` | 场景二 周边搜索 |
| `recipes/region_search.md` | 场景三 视野内/多边形/行政区划区域/分类/统计搜索 |
| `recipes/route_planning.md` | 场景四 驾车规划 + 公交规划 |
| `recipes/static_map.md` | 场景五 静态地图 |
| `recipes/geocode_admin.md` | 场景六 地理编码/逆地理编码/行政区划 |

**references/（API 参考）：**

| 文件 | 内容 |
|------|------|
| `references/search_v2.md` | 地名搜索 V2.0 全部八种查询的完整参数与返回结构 |
| `references/geocoding.md` | 地理编码（地址→坐标）与逆地理编码（坐标→地址） |
| `references/administrative.md` | 行政区划 V2.0（层级/中心点/轮廓/编码） |
| `references/transit.md` | 公交规划（线路规划/ID查询/返程查询） |
| `references/drive.md` | 驾车规划（途经点/路线风格/XML 返回结构） |
| `references/static_map.md` | 静态地图 API（标注/折线/面/样式） |
| `references/error_codes.md` | 错误码对照表 + 分类编码说明 |
| `scripts/xml2json.ps1` | /drive XML 响应转 JSON 的零依赖脚本（用法见 drive.md） |

## 注意事项

- **postStr 必须 URL 编码**：构造 JSON 后使用 `curl --data-urlencode "postStr={...}"`，这是最易出错的地方
- 周边搜索半径最大 10 公里（queryRadius 单位米）
- 搜索分页参数 start 范围 0-300，count 范围 1-300
- 静态地图 URL 总长度限制 2048，标注点最多 26 个，图片尺寸 1-1024 像素，zoom 3-18
- 多边形搜索的 polygon 参数首尾坐标必须相同
- 行政区划 V1.0（`/administrative`）已于 2024-06-30 下线，统一使用 V2.0（`/v2/administrative`）
- 天地图对调用量有配额限制，个人/企业开发者需在控制台升级；请勿压力测试
- 请妥善保管 Key，不要分享；Key 可设置域名/IP 白名单
- **Key 类型必须与调用场景匹配（实测由 User-Agent 判定）**：本 skill 的 curl 调用（服务端场景）必须用**服务端**类型 Key；浏览器场景（网页 JS，带浏览器 UA）用**浏览器端** Key。交叉使用报 `301012 权限类型错误`（浏览器端 Key + curl）或 403（服务端 Key + 浏览器 UA）
- 天地图为官方权威数据源，适合需要准确行政边界、国家底图的场景

## 相关链接

- [天地图服务指南](http://lbs.tianditu.gov.cn/server/guide.html)
- [地名搜索 V2.0](http://lbs.tianditu.gov.cn/server/search2.html)
- [地理编码](http://lbs.tianditu.gov.cn/server/geocodinginterface.html) / [逆地理编码](http://lbs.tianditu.gov.cn/server/geocoding.html)
- [行政区划 V2.0](http://lbs.tianditu.gov.cn/server/administrative2.html)
- [公交规划](http://lbs.tianditu.gov.cn/server/bus.html) / [驾车规划](http://lbs.tianditu.gov.cn/server/drive.html)
- [静态地图 API](http://lbs.tianditu.gov.cn/staticapi/static.html)
