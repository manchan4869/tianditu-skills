# 天地图 Agent Skills

[![skills.sh](https://skills.sh/b/manchan4869/tianditu-skills)](https://skills.sh/manchan4869/tianditu-skills)

天地图（国家地理信息公共服务平台）Agent Skills 集合。零运行时依赖，仅使用 `curl` 调用 REST API。

## Skills

| Skill | 功能 | 安装 |
|-------|------|------|
| [**tianditu-webapi**](skills/tianditu-webapi/) | 地名搜索 V2.0（八种查询）、驾车/公交规划、地理/逆地理编码、行政区划 V2.0、静态地图 | `npx skills add https://github.com/manchan4869/tianditu-skills --skill tianditu-webapi` |
| [**tianditu-mapservice**](skills/tianditu-mapservice/) | 瓦片地图服务（OGC WMTS）：8 图层 × 2 投影、GetCapabilities/GetTile、QGIS/Leaflet/MapLibre/Cesium 集成、Cesium 三维瓦片 | `npx skills add https://github.com/manchan4869/tianditu-skills --skill tianditu-mapservice` |

## 配置

在[天地图控制台](https://cloudcenter.tianditu.gov.cn/center/development/myApp)注册并创建应用获取 Key：

```bash
export TIANDITU_KEY="your_key"
```

> ⚠️ Key 类型区分：**服务端 API**（webapi）需「服务端」类型 Key；**瓦片/静态图服务**（mapservice）需「浏览器端」类型 Key。用错返回 `301012 权限类型错误`。

## 文档

- [天地图服务指南](http://lbs.tianditu.gov.cn/server/guide.html)
- [地图服务（瓦片）](http://lbs.tianditu.gov.cn/server/MapService.html)
- 坐标系统：CGCS2000/WGS-84（与 GPS 一致，区别于高德 GCJ-02）

## License

MIT
