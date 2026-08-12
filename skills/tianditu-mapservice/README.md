# 天地图瓦片地图服务 Skill

天地图地图服务（OGC WMTS 标准）的 Agent Skill，提供全国矢量、影像、地形底图瓦片。零运行时依赖。

## 功能

- 🗺️ 8 个底图图层：矢量(vec)/注记(cva)/影像(img)/影像注记(cia)/地形(ter)/地形注记(cta)/境界(ibo)，各含 CGCS2000 经纬度(_c)与 Web Mercator(_w) 两种投影
- 📡 GetCapabilities 元数据查询 + GetTile 瓦片获取（LAYER/TILEMATRIXSET/FORMAT/TILEMATRIX/TILEROW/TILECOL）
- 🌐 t0-t7 二级域名轮询
- 🏔️ Cesium 三维扩展（三维地名 GetTiles / 三维地形 swdx / DEM 高程 DataServer）
- 🔌 QGIS XYZ / Leaflet / MapLibre GL 集成配置示例
- 🧮 两种投影的瓦片行列号计算（标准 XYZ vs 经纬度赤道起算）

## 安装

```bash
npx skills add https://github.com/manchan4869/tianditu-skills --skill tianditu-mapservice
```

或手动放入 skills 目录（如 `~/.agents/skills/tianditu-mapservice/`）。

## 配置

在[天地图控制台](https://cloudcenter.tianditu.gov.cn/center/development/myApp)创建应用获取 Key：

```bash
export TIANDITU_KEY="your_key"
```

> ⚠️ Key 类型按调用场景匹配：QGIS/curl 等服务端调用用「服务端」Key；浏览器网页加载用「浏览器端」Key。实测矩阵见 `references/wmts.md`。

## 结构

```
SKILL.md                        # 入口：图层清单/投影/快速开始
references/wmts.md              # WMTS 完整参数/行列号计算/客户端集成/错误排查
```

## 相关

- 本 skill 属于 [manchan4869/tianditu-skills](https://github.com/manchan4869/tianditu-skills) 多 skill 仓库，配套服务 API 见 `tianditu-webapi`
- [地图服务文档](http://lbs.tianditu.gov.cn/server/MapService.html)
- [OGC WMTS 标准](https://www.ogc.org/standard/wmts/)

## License

MIT
