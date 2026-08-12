# 静态地图 API 参考

地址：`https://api.tianditu.gov.cn/staticimage`，返回 PNG 图片。

**限制：** URL 总长度 2048，标注点最多 26 个，图片尺寸 1-1024 像素，zoom 3-18，请求频率无限制。

## 参数

| 参数 | 必选 | 默认 | 说明 |
|------|------|------|------|
| width | 否 | 400 | 图片宽度 [1, 1024] |
| height | 否 | 300 | 图片高度 [1, 1024] |
| center | 否 | 116.39127,39.90712 | 中心点 `经度,纬度` |
| zoom | 否 | 10 | 地图级别 [3, 18] |
| layers | 否 | vec_c,cva_c | 叠加层组合：`img_c`=影像图，`vec_c`=矢量底图，`ter_c`=地形图，`cva_c`=中文注记，`eva_c`=英文注记，`cta_c`=地形注记 |
| markers | 否 | null | 标注点，竖线 `|` 分隔：`lng1,lat1\|lng2,lat2` |
| markerStyles | 否 | null | 标注样式，与 markers 对应，竖线分隔：`size,label,url[,sLabel,fontColor,fontSize]` |
| paths | 否 | null | 折线：线间竖线 `|`，点间分号 `;`，坐标逗号：`x1,y1;x2,y2\|x3,y3;x4,y4` |
| pathStyles | 否 | null | 折线样式：`color,weight,opacity[,fillColor]`；带 fillColor 时自动封闭为面并填充 |
| pixLocation | 否 | null | 经纬度坐标 → 静态图左上角(0,0)起算的屏幕像素坐标，竖线分隔；存在时优先处理，其他覆盖物参数失效 |

## markerStyles 详解

`size,label,url[,sLabel,fontColor,fontSize]`（同点参数逗号分隔，不同点竖线分隔）：

- `size`：`l`=大图标，`m`=中图标，`s`=小图标，`-1`=自定义图标
- `label`：size 为 l/m 时是图标标签，取值 [0-9] 或 [A-Z]
- `url`：仅当 size=`-1` 时生效，自定义图标资源地址
- `sLabel`：自定义图标标签，**中文必须 URI 编码**
- `fontColor`：16 进制色码如 `0xff0000`
- `fontSize`：字号

## 示例

```bash
# 基础底图（矢量+中文注记）
curl -o map.png "https://api.tianditu.gov.cn/staticimage?center=116.40,39.93&width=400&height=300&zoom=10&tk=$TIANDITU_KEY"

# 影像图叠加中文注记
curl -o map.png "https://api.tianditu.gov.cn/staticimage?center=116.40,39.93&width=500&height=500&zoom=13&layers=img_c,cva_c&tk=$TIANDITU_KEY"

# 默认图标标注（6 个点）
curl -o map.png "https://api.tianditu.gov.cn/staticimage?center=116.40,39.93&width=500&height=500&zoom=12&markers=116.34867,39.94593|116.42626,39.94731|116.4551,39.90267|116.43381,39.86766|116.34249,39.87178|116.32807,39.90748&tk=$TIANDITU_KEY"

# 大图标+数字标签
curl -o map.png "https://api.tianditu.gov.cn/staticimage?center=116.40,39.93&width=500&height=500&zoom=12&markers=116.34867,39.94593|116.42626,39.94731&markerStyles=l,1|l,2&tk=$TIANDITU_KEY"

# 自定义图标+中文标签（中文需 URI 编码，"标注一"= %E6%A0%87%E6%B3%A8%E4%B8%80）
curl -o map.png "https://api.tianditu.gov.cn/staticimage?center=116.40,39.93&width=500&height=500&zoom=12&markers=116.34867,39.94593|116.42626,39.94731&markerStyles=-1,A,%E6%A0%87%E6%B3%A8%E4%B8%80|-1,B,%E6%A0%87%E6%B3%A8%E4%BA%8C&tk=$TIANDITU_KEY"

# 折线 + 面（pathStyles 带 fillColor 时封闭成面）
curl -o map.png "https://api.tianditu.gov.cn/staticimage?center=116.40,39.93&width=500&height=500&zoom=12&paths=116.34867,39.94593;116.42626,39.94731;116.4551,39.90267&pathStyles=0xff0000,8,0.7&tk=$TIANDITU_KEY"

# 坐标 → 屏幕像素坐标（不渲染地图外的标注）
curl "https://api.tianditu.gov.cn/staticimage?center=116.40,39.93&width=500&height=500&zoom=12&pixLocation=116.34867,39.94593|116.42626,39.94731&tk=$TIANDITU_KEY"
# 返回：101,204||327,200  （相对左上角(0,0)的像素坐标对）
```

## 注意事项

- 中文标签、中文路径等非 ASCII 内容必须 URI 编码
- 多个标注、多条折线的分隔符是竖线 `|`，点的分隔符是分号 `;`，坐标分隔符是逗号 `,`
- 静态图不需要 postStr，全部为普通 GET 查询参数
- 下载图片建议 `curl -o 文件名.png "URL"`；也可直接在浏览器/`<img>` 标签中使用
