# 驾车规划参考

地址：`https://api.tianditu.gov.cn/drive`，请求参数 `type=search`。

请求：

```bash
# 基本：起点 → 终点
curl -G "https://api.tianditu.gov.cn/drive" \
  --data-urlencode 'postStr={"orig":"116.35506,39.92277","dest":"116.39751,39.90854","style":"0"}' \
  --data-urlencode "type=search" \
  --data-urlencode "tk=$TIANDITU_KEY"

# 带途经点（mid：多个坐标用英文分号分隔）
curl -G "https://api.tianditu.gov.cn/drive" \
  --data-urlencode 'postStr={"orig":"116.35506,39.92277","dest":"116.39751,39.90854","mid":"116.36506,39.91277;116.37506,39.92077","style":"0"}' \
  --data-urlencode "type=search" \
  --data-urlencode "tk=$TIANDITU_KEY"
```

## 参数（postStr 内）

| 参数 | 必选 | 说明 |
|------|------|------|
| orig | 是 | 起点经纬度 `"经度,纬度"`，范围 -180,-90 至 180,90 |
| dest | 是 | 终点经纬度 `"经度,纬度"` |
| mid | 否 | 途经点：`"116.35506,39.92277;116.36506,39.91277"`（坐标 x,y 逗号分隔，点之间分号分隔） |
| style | 否 | 0=最快路线，1=最短路线，2=避开高速，3=步行。默认 0 |

## 返回结构（XML，实测与官方示例一致）

> ⚠️ **/drive 接口返回 XML 格式**，不是 JSON。解析时按 XML 处理（PowerShell 用 `[xml]` 强转），不要用 JSON 解析器。

官方返回结构（实测一致）：

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<result orig='116.35506,39.92277' dest='116.39751,39.90854'>
    <parameters>            <!-- 请求参数回显：orig/dest/mid/style/width/height/version/sort -->
        <orig>116.35506,39.92277</orig>
        <style>0</style>
    </parameters>
    <routes count='11'>     <!-- count = 分段总数；item 为每段导航 -->
        <item id='0'>
            <strguide>从阜成门内大街向西出发,沿阜成门内大街走400米...</strguide>  <!-- 每段文字描述 -->
            <signage>"路牌"引导提示/高速出口信息</signage>
            <streetName>阜成门内大街</streetName>   <!-- 当前路段名称 -->
            <nextStreetName>阜成门桥</nextStreetName>  <!-- 下一段道路名称 -->
            <tollStatus>0</tollStatus>   <!-- 0=免费 1=收费 2=部分收费 -->
            <turnlatlon>116.35506,39.92249</turnlatlon>  <!-- 转折点经纬度 -->
        </item>
    </routes>
    <simple>                <!-- 合并后的段（简版），结构同 item：strguide/streetNames/lastStreetName/tollStatus/turnlatlon/streetLatLon/streetDistance(米)/segmentNumber -->
    </simple>
    <distance>7.5</distance>   <!-- 全长（公里） -->
    <duration>542</duration>   <!-- 行驶总时间（秒） -->
    <routelatlon>116.35506,39.92277;...;116.39751,39.90854</routelatlon>  <!-- 线路经纬度字符串 -->
    <mapinfo>                  <!-- 全部结果同时显示的适宜中心与缩放 -->
        <center>116.37627,39.91566</center>
        <scale>13</scale>
    </mapinfo>
</result>
```

> 核心字段：`routes/item/strguide`（导航文字）、`distance`（公里）、`duration`（秒）、`routelatlon`（坐标串）、`turnlatlon`（转折点）。

## XML → JSON 转换（推荐）

/drive 是唯一返回 XML 的接口。**PowerShell 内置 `[xml]` + `ConvertTo-Json` 不可用**（会把 XmlDocument 序列化成空数组嵌套），请用本 skill 的零依赖转换脚本：

```bash
# 先保存响应到文件（避免管道编码问题）
curl.exe -s -o drive.xml -G "https://api.tianditu.gov.cn/drive" \
  --data-urlencode 'postStr={"orig":"116.35506,39.92277","dest":"116.39751,39.90854","style":"0"}' \
  --data-urlencode "type=search" --data-urlencode "tk=$TIANDITU_KEY"

# 再转换（也支持 -Text 参数或管道输入；管道需保证 UTF-8 字节流）
pwsh -NoProfile -File "scripts/xml2json.ps1" -Path drive.xml
```

转换后结构示例：

```json
{
  "orig": "116.35506,39.92277",
  "dest": "116.39751,39.90854",
  "parameters": { "style": "0", "width": "600", "height": "400" },
  "routes": { "count": "11", "item": [ { "strguide": "...", "signage": "...", "streetName": "...", "nextStreetName": "...", "tollStatus": "0", "turnlatlon": "..." } ] },
  "simple": { "item": [ { "strguide": "...", "streetNames": "...", "streetDistance": "353.0", "segmentNumber": "0" } ] },
  "distance": "7.5",
  "duration": "542.0",
  "routelatlon": "116.35506,39.92277;116.35506,39.92249;...",
  "mapinfo": { "center": "116.375,39.91463", "scale": "10" }
}
```

> 转换约定：纯文本元素输出字符串，重复同名子元素输出数组，元素属性并入对象键（如 `routes.count`）。

## 注意事项

- **返回是 XML**（见上），不是 JSON
- 所有坐标 `经度,纬度` 顺序，WGS-84
- `style=3`（步行）也可用于简单步行路线查询；专门的步行规划场景可考虑 style=3
- 途经点 mid 最多支持的数量有限，过多途经点可能被截断
- 驾车规划不返回公交方案，公交请用 transit 接口
