# 场景三：区域搜索（视野内/多边形/行政区划区域/分类/统计）

**触发：** 搜索限定在某个视野、多边形、行政区、分类，或需要统计数量的查询。

## 子场景判断

| 子场景 | 用户说法 | queryType | 必填参数 |
|--------|---------|-----------|---------|
| 行政区划区域搜索 | "海淀区的商厦"、"在北京的学校" | 12 | keyWord, specify |
| 视野内搜索 | "这个地图范围里的医院" | 2 | keyWord, mapBound, level |
| 多边形搜索 | "这片区域里的学校" | 10 | keyWord, polygon |
| 数据分类搜索 | "按分类找海淀区的设施" | 13 | specify, dataTypes |
| 统计搜索 | "北京有多少公园" | 14 | keyWord, specify |

## 请求

```bash
# 行政区划区域搜索（海淀区 = 156110108，查"商厦"）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"商厦","queryType":12,"start":0,"count":10,"specify":"156110108"}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"

# 视野内搜索（mapBound = minx,miny,maxx,maxy）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"医院","level":12,"mapBound":"116.02524,39.83833,116.65592,39.99185","queryType":2,"start":0,"count":10}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"

# 多边形搜索（polygon 首尾坐标必须相同，最多约 20 个点）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"学校","polygon":"116.35,39.90,116.36,39.90,116.36,39.91,116.35,39.91,116.35,39.90","queryType":10,"start":0,"count":10}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"

# 数据分类搜索（海淀区内的法院和公园）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"queryType":13,"start":0,"count":20,"specify":"156110108","dataTypes":"法院,公园"}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"

# 统计搜索（海淀区"学校"数量）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"学校","queryType":14,"specify":"156110108"}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"
```

## 关键点

- **specify 编码获取**：行政区划 9 位国标码，用行政区划 V2.0 接口查（`recipes/geocode_admin.md`），如北京 `156110000`、朝阳区 `156110105`
- **polygon 格式**：`x1,y1,x2,y2,...,x1,y1`（首尾相同闭合），坐标数量过多会报 2006（超过 20 点）
- **统计搜索返回** `statistics`：`count`（POI 总数）、`adminCount`（行政区数量）、`priorityCitys[]`（推荐行政区及数量）、`allAdmins[]`（各省数量）

## 结果解析

统计搜索响应示例：

```json
{
  "resultType": 2,
  "statistics": {
    "count": 320,
    "adminCount": 1,
    "priorityCitys": [ { "name": "北京市", "count": 320, "adminCode": 156110100 } ],
    "allAdmins": [ { "name": "北京市", "count": 320, "lonlat": "116.40,39.90", "adminCode": "156110000", "isleaf": true } ]
  },
  "status": { "infocode": 1000, "cndesc": "服务正常" }
}
```

## 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| 2006 经纬度越界 | polygon 超过 20 个点 | 精简坐标点 |
| 2005 经纬度错误 | specify 编码错误 | 从行政区划接口取准确编码 |
| 2004 枚举值错误 | queryType 与参数不匹配 | 按子场景表核对必填参数 |
