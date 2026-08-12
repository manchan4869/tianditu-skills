---
name: tianditu-mapservice
description: 天地图瓦片地图服务（OGC WMTS）综合指南。支持 8 个底图图层（矢量/注记/影像/地形/境界，各含 CGCS2000 经纬度与 Web Mercator 两种投影）、GetCapabilities 元数据查询、GetTile 瓦片获取、t0-t7 二级域名单、Cesium 三维瓦片。使用场景：在 QGIS/Leaflet/MapLibre/Cesium 中加载天地图底图、计算瓦片行列号、搭建 XYZ 瓦片源、需要国内官方底图做叠加分析。
version: 1.0.0
license: MIT
homepage: http://lbs.tianditu.gov.cn/server/MapService.html
---

# 天地图瓦片地图服务 Skill

天地图地图服务采用 **OGC WMTS 标准**（GetCapabilities / GetTile），通过 HTTP/HTTPS 提供全国矢量、影像、地形底图瓦片。**零运行时依赖，用 curl 测试、可配置到任何地图客户端。**

## 服务概览

服务地址模式：`http://t{0-7}.tianditu.gov.cn/{layer}_w/wmts?tk=密钥`

| 图层 | 名称 | 经纬度投影(_c) | 墨卡托投影(_w) |
|------|------|----------------|----------------|
| vec | 矢量底图 | `vec_c/wmts` | `vec_w/wmts` |
| cva | 矢量注记 | `cva_c/wmts` | `cva_w/wmts` |
| img | 影像底图 | `img_c/wmts` | `img_w/wmts` |
| cia | 影像注记 | `cia_c/wmts` | `cia_w/wmts` |
| ter | 地形晕渲 | `ter_c/wmts` | `ter_w/wmts` |
| cta | 地形注记 | `cta_c/wmts` | `cta_w/wmts` |
| ibo | 全球境界 | `ibo_c/wmts` | `ibo_w/wmts` |

- **二级域名 t0-t7 随机选用**，分散请求负载（如 `http://t2.tianditu.gov.cn/vec_c/wmts`）
- 投影后缀：`_c` = CGCS2000 经纬度投影，`_w` = 球面墨卡托（Web Mercator）
- 三维瓦片（Cesium 扩展）：`https://t{t}.tianditu.gov.cn/mapservice/GetTiles`（三维地名）、`https://t{t}.tianditu.gov.cn/mapservice/swdx`（三维地形）、`https://t{t}.tianditu.gov.cn/DEM/DataServer?T=ele_c`（DEM 高程）

## 触发条件

- "把天地图加到 QGIS/Leaflet/MapLibre/Cesium"、"加载天地图底图/影像/地形"
- "天地图瓦片地址是什么"、"怎么申请瓦片服务"
- 需要国内官方底图做底图叠加、或生成地图截图
- 涉及 CGCS2000 与 Web Mercator 投影选择、瓦片行列号计算
- 用户在 QGIS 中要用天地图作为底图（配合 qgis skill 使用）

## 快速开始

### 1. 元数据查询（GetCapabilities）

```bash
curl -s "http://t0.tianditu.gov.cn/img_w/wmts?request=GetCapabilities&service=wmts" \
  -H "Referer: http://lbs.tianditu.gov.cn" | Select-Object -First 5
```

返回 XML：包含所有图层的 TileMatrixSet（缩放级别矩阵）、坐标参考系（EPSG:3857 / EPSG:4490）、瓦片尺寸等。可用 `[xml]` 强转后解析。

### 2. 瓦片获取（GetTile）

```bash
# 影像底图（墨卡托），z=12, 行=3387, 列=1466（北京区域示例）
curl -s -o tile.png "http://t0.tianditu.gov.cn/img_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX=12&TILEROW=3387&TILECOL=1466&tk=$TIANDITU_KEY"
```

参数：`LAYER`=图层名（vec/img/cva/cia/ter/cta/ibo），`TILEMATRIXSET`=投影（c 或 w），`TILEMATRIX`=缩放级 z，`TILEROW`=行 y，`TILECOL`=列 x，`FORMAT=tiles`。

### 3. 行列号计算

```bash
# Web Mercator：x = floor((lon+180)/360 * 2^z)，y = floor((1 - ln(tan(lat)+sec(lat))/π) / 2 * 2^z)
```

详细计算与常用客户端配置见 `references/wmts.md`。

## 参考资料索引

| 文件 | 内容 |
|------|------|
| `references/wmts.md` | WMTS 完整参数、图层对照、QGIS/Leaflet/MapLibre/Cesium 集成、行列号计算、t0-t7 与缓存建议 |
| 配套 skill `tianditu-webapi` | 地名搜索/路线/编码等 Web 服务 API（本仓库 skills/tianditu-webapi/） |

## 注意事项

- **Key 类型与调用场景匹配（实测由 User-Agent 判定）**：curl/QGIS 等服务端调用用**服务端** Key；浏览器网页用**浏览器端** Key。交叉使用报 301012（浏览器端 Key + curl）或 403（服务端 Key + 浏览器 UA）。实测矩阵见 `references/wmts.md`
- 经纬度投影(_c)用 CGCS2000（EPSG:4490，与 WGS-84 基本一致）；墨卡托(_w)是 EPSG:3857。**不要与高德 GCJ-02 混用**
- 部分图层（如影像注记）需与对应底图叠加使用
- 调用量有配额限制，控制台可升级；生产环境注意缓存瓦片
- 实测 http 明文请求易被 WAF 拦截，**建议使用 https**

## 相关链接

- [地图服务文档](http://lbs.tianditu.gov.cn/server/MapService.html)
- [OGC WMTS 标准](https://www.ogc.org/standard/wmts/)
- [天地图控制台](https://cloudcenter.tianditu.gov.cn/center/development/myApp)
