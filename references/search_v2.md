# 地名搜索 V2.0 参考

地址：`https://api.tianditu.gov.cn/v2/search`

统一请求方式（GET + URL 编码的 JSON）：

```bash
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"医院","level":12,"mapBound":"116.02524,39.83833,116.65592,39.99185","queryType":1,"start":0,"count":10}' \
  --data-urlencode "type=query" \
  --data-urlencode "tk=$TIANDITU_KEY"
```

**关键：postStr 必须是合法 JSON 且 URL 编码**（`--data-urlencode` 自动处理）。参数名一律小写。

## 查询类型（queryType）

| queryType | 服务 | 必填参数 | 可选参数 |
|-----------|------|---------|---------|
| 1 | 普通搜索（含地铁公交） | keyWord（mapBound、level 官方标必填） | specify, dataTypes, show |
| 7 | 地名搜索 | keyWord（mapBound、level 官方标必填） | specify, dataTypes, show |
| 2 | 视野内搜索 | keyWord, mapBound, level | dataTypes, show |
| 3 | 周边搜索 | keyWord, queryRadius, pointLonlat | dataTypes, show |
| 10 | 多边形搜索 | keyWord, polygon（首尾坐标相同） | dataTypes, show |
| 12 | 行政区划区域搜索 | keyWord, specify | dataTypes, show |
| 13 | 数据分类搜索 | specify, dataTypes（mapBound 官方示例未传） | show |
| 14 | 统计搜索 | keyWord, specify | dataTypes, show |

## 通用参数

| 参数 | 必选 | 说明 |
|------|------|------|
| keyWord | 视类型 | 搜索关键字 |
| specify | 视类型 | 行政区国标码（9 位）或名称，如北京 `156110000`；指定省以上级别普通搜索时返回统计数据 |
| mapBound | 视类型 | 地图范围 `"minx,miny,maxx,maxy"`，经纬度限 -180,-90 至 180,90 |
| level | 视类型 | 查询级别 1-18 |
| pointLonlat | 周边 | 中心点坐标 `"经度,纬度"` |
| queryRadius | 周边 | 查询半径（米），**最大 10 公里** |
| polygon | 多边形 | 坐标对序列，经纬度用 `,` 分割，首尾坐标必须相同：`x1,y1,x2,y2,...,x1,y1` |
| dataTypes | 否 | 数据分类（分类名称或分类编码，多个用英文逗号分隔），编码表见 error_codes.md |
| show | 否 | 1=基本 POI 信息，2=详细 POI 信息 |
| start | 必填 | 起始位（分页），0-300（统计搜索 14 可省略） |
| count | 必填 | 返回条数，1-300（统计搜索 14 可省略） |

## 请求示例

```bash
# 普通搜索（queryType=1）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"北京大学","level":12,"mapBound":"116.02524,39.83833,116.65592,39.99185","queryType":1,"start":0,"count":10}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"

# 周边搜索（queryType=3，半径 5000 米）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"公园","queryRadius":5000,"pointLonlat":"116.48016,39.93136","queryType":3,"start":0,"count":10}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"

# 行政区划区域搜索（queryType=12，在海淀区搜"商厦"）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"商厦","queryType":12,"start":0,"count":10,"specify":"156110108"}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"

# 数据分类搜索（queryType=13）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"queryType":13,"start":0,"count":5,"specify":"156110000","dataTypes":"法院,公园"}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"

# 统计搜索（queryType=14，统计海淀区"学校"数量）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"学校","queryType":14,"specify":"156110108"}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"

# 多边形搜索（queryType=10，polygon 首尾坐标相同）
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"学校","polygon":"118.9323,27.4233,118.9315,27.3097,118.8036,27.3118,118.9323,27.4233","queryType":10,"start":0,"count":10}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"
```

## 返回结构

```json
{
  "resultType": 1,          // 1=普通POI 2=统计 3=行政区 4=建议词搜索 5=线路结果
  "count": 10,              // 返回总条数
  "keyword": "医院",
  "pois": [                 // resultType=1 时返回
    {
      "name": "北京协和医院",
      "phone": "010-...",
      "address": "...",
      "lonlat": "116.42127,39.91264",   // 坐标 x,y（经度,纬度）
      "poiType": 101,                   // 101=POI 102=公交站 103=线路
      "hotPointID": "...",
      "province": "北京市", "provinceCode": "156110000",
      "city": "北京市", "cityCode": "156110100",
      "county": "东城区", "countyCode": "156110101",
      "source": "...",
      "typeCode": "...", "typeName": "综合医院",
      "distance": "1.5km",              // 仅周边搜索返回；<1km 为米，≥1km 为 km
      "stationData": [...]              // poiType=102 时返回车站信息
    }
  ],
  "statistics": {...},                  // resultType=2 时返回
  "area": [...],                        // resultType=3 时返回（行政区）
  "lineData": [...],                    // resultType=5 时返回（线路）
  "prompt": {...},                      // 需要提示时返回（如"是否在XXX搜索XXX"）
  "status": { "infocode": 1000, "cndesc": "服务正常" }
}
```

**status.infocode 错误码**见 `error_codes.md`。`prompt` 用于处理搜索词需要行政区跳转的场景（type 1=是否在where搜what，2=where无结果，3=多行政区可跳转，4=城市）。
