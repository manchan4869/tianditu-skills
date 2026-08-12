# 场景五：静态地图

**触发：** "生成一张地图图片"、"带标注的地图"、"把这些点标在地图上"、"画一条路线图"。

## 步骤

1. 确定底图类型：默认矢量+中文注记（`vec_c,cva_c`）；需要卫星影像用 `img_c,cva_c`；地形用 `ter_c,cta_c`
2. 确定中心点、尺寸（width/height ≤1024）、缩放级别（zoom 3-18）
3. 按需添加覆盖物：markers（标注点）、markerStyles（样式）、paths（折线/面）、pathStyles（样式）
4. `curl -o 图片.png "URL"` 下载图片
5. 将图片路径展示给用户

## 请求

```bash
# 底图 + 标注点 + 折线
curl -o map.png "https://api.tianditu.gov.cn/staticimage?center=116.40,39.93&width=600&height=400&zoom=12&layers=vec_c,cva_c&markers=116.34867,39.94593|116.42626,39.94731&markerStyles=l,1|l,2&paths=116.34867,39.94593;116.42626,39.94731&pathStyles=0xff0000,6,0.8&tk=$TIANDITU_KEY"
```

## 常用参数组合

| 需求 | 参数 |
|------|------|
| 多标注点 | `markers=经度,纬度|经度,纬度...`（最多 26 个） |
| 标注带序号 | `markerStyles=l,1|l,2`（l/m 配 [0-9A-Z] 标签） |
| 自定义图标+中文标签 | `markerStyles=-1,A,标签URI编码`（中文必须 URI 编码） |
| 折线（路线） | `paths=x1,y1;x2,y2;x3,y3`（多条线用 `|` 分隔） |
| 面（区域） | `paths=闭合坐标...&pathStyles=0x0000ff,4,0.5,0x00ff00`（第4参数 fillColor 出现即封闭成面） |
| 卫星影像 | `layers=img_c,cva_c` |

## 中文 URI 编码

中文标签/路径必须 URI 编码。可用 PowerShell 生成：

```powershell
[uri]::EscapeDataString("标注一")   # → %E6%A0%87%E6%B3%A8%E4%B8%80
```

## 返回的 pixLocation 用法

想确认标注点落在图片哪个像素位置时传 `pixLocation`（经纬度，竖线分隔），响应直接返回相对左上角 (0,0) 的像素坐标对 `101,204||327,200`，此时 markers/paths 等覆盖物参数失效。

## 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| 图片显示空白/报错 | URL 超 2048 或标注点超 26 个 | 精简参数 |
| 中文标签乱码 | 未做 URI 编码 | 用 EscapeDataString 编码 |
| 区域未填充 | pathStyles 缺第 4 个参数 | 补 fillColor 才能封闭成面 |
| zoom 超出范围 | 非 3-18 | 修正级别 |
