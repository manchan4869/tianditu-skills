# 天地图 WMTS 瓦片服务参考

## 1. 服务地址与图层

基础 URL：`http://t{0-7}.tianditu.gov.cn/{layer}_{proj}/wmts?tk=密钥`

| 图层 | 说明 | 常用组合 |
|------|------|---------|
| vec | 矢量底图（线划图） | 配 cva 注记 |
| cva | 矢量注记（地名/路名） | 叠加在 vec 上 |
| img | 影像底图（卫星影像） | 配 cia 注记 |
| cia | 影像注记 | 叠加在 img 上 |
| ter | 地形晕渲（DEM 渲染） | 配 cta 注记 |
| cta | 地形注记 | 叠加在 ter 上 |
| ibo | 全球境界（国界/省界线） | 单独或叠加 |

投影后缀：`_c` = CGCS2000 经纬度投影（约 EPSG:4490），`_w` = 球面墨卡托（EPSG:3857）。

## 2. 请求参数

### GetCapabilities（元数据）

```
http://t0.tianditu.gov.cn/img_w/wmts?request=GetCapabilities&service=wmts
```

无需 tk 也可访问（示例未带）。返回 XML 含：
- `Layer/Identifier`：图层标识（vec/img/cva/...）
- `TileMatrixSet`：每个缩放级（0-18）的 `ScaleDenominator`、`TopLeftCorner`、`TileWidth/TileHeight`（256）
- `SupportedCRS`：EPSG:3857 或 EPSG:4490
- 读取方法（PowerShell）：`$x = [xml](curl.exe -s "..."); $x.Capabilities.Contents.Layer`

### GetTile（瓦片）

```
http://t0.tianditu.gov.cn/img_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=密钥
```

| 参数 | 值 | 说明 |
|------|-----|------|
| SERVICE | WMTS | 固定 |
| REQUEST | GetTile | 固定 |
| VERSION | 1.0.0 | 固定 |
| LAYER | vec/img/cva/cia/ter/cta/ibo | 图层名（不带投影后缀） |
| STYLE | default | 固定 |
| TILEMATRIXSET | c 或 w | 与 URL 中投影后缀对应 |
| FORMAT | tiles | 固定（PNG 瓦片） |
| TILEMATRIX | z | 缩放级别 0-18 |
| TILEROW | y | 行号（墨卡托：北纬0起向下递增） |
| TILECOL | x | 列号 |
| tk | 密钥 | 必填 |

## 3. 瓦片行列号计算

### Web Mercator（_w，EPSG:3857）——标准 XYZ 切片规则

```
n = 2^z
x = floor((lon + 180) / 360 * n)
y = floor((1 - asinh(tan(lat)) / π) / 2 * n)      # 等价 (1 - ln(tan+sec)/π)/2 * n
```

### CGCS2000 经纬度（_c，EPSG:4490）——天地图自定义规则

天地图经纬度投影瓦片**不是**标准 XYZ：经度-180°起算、行号从**赤道**起：

```
n = 2^z
x = floor((lon + 180) / 360 * n)
y = floor((90 - lat) / 180 * n)      # 纬度从 90 向下，0 级为全球 2×1 张
```

> 简单记忆：`_w` 用标准 XYZ（QGIS/Leaflet 直接支持）；`_c` 的行号计算特殊，非标准客户端需按上式换算。

## 4. 客户端集成

### QGIS（XYZ Tiles）

```
矢量底图+注记：http://t0.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=密钥
影像+注记：把 LAYER 换 img/cia（两个图层叠加）
```

### Leaflet（L.tileLayer）

```javascript
L.tileLayer('https://t0.tianditu.gov.cn/img_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=KEY', {
  maxZoom: 18, attribution: '天地图'
}).addTo(map);
```

### MapLibre GL（raster 图层）

```json
{
  "type": "raster",
  "tiles": ["https://t0.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=KEY"],
  "tileSize": 256
}
```

### Cesium（三维扩展）

```
三维地名：https://t0.tianditu.gov.cn/mapservice/GetTiles?tk=KEY
三维地形：https://t0.tianditu.gov.cn/mapservice/swdx?tk=KEY
DEM 高程：https://t0.tianditu.gov.cn/DEM/DataServer?T=ele_c&tk=KEY
```

配合 Cesium 的 `CesiumTerrainProvider` / 影像图层使用。

## 5. 性能与稳定性建议

- **域名轮询**：t0-t7 随机分配（浏览器多域名并发下载限制），QGIS/前端可配置多域名模板
- **缓存**：瓦片响应建议长期缓存（TileJSON/磁盘缓存）；本地测试用 `curl -o` 落盘
- **Referer 白名单**：控制台可给 Key 配置域名白名单；服务端批量抓瓦片注意配额
- **URL 长度**：GetTile 请求全部为查询参数，无 postStr，直接拼 URL 即可

## 6. 常见错误

| 现象 | 原因 | 解决 |
|------|------|------|
| 返回 301012 权限类型错误 | Key 是浏览器端类型（实测浏览器端 Key 拉瓦片返回 403 + 301012） | 控制台创建「服务端」应用获取 Key（与 Web 服务 API 同一 Key 通用） |
| 瓦片 404/空白 | LAYER 或 TILEMATRIXSET 与 URL 后缀不一致 | 如 `img_w/wmts` 必须 `LAYER=img&TILEMATRIXSET=w` |
| 瓦片偏移 | 把 CGCS2000/3857 瓦片当 GCJ-02 用（高德坐标） | 确认客户端坐标系一致 |
| _c 投影瓦片错位 | 行号规则用错（赤道起算） | 按 3.2 公式计算，或改用 _w 标准 XYZ |
| http 请求失败/被拦截 | WAF 对明文 http 拦截（实测） | 改用 https 协议 |
