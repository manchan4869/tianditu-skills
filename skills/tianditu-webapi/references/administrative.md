# 行政区划 V2.0 参考

地址：`https://api.tianditu.gov.cn/v2/administrative`

> ⚠️ 行政区划 V1.0（`/administrative` + postStr）已于 2024-06-30 下线，统一使用 V2.0。

请求：

```bash
curl -G "https://api.tianditu.gov.cn/v2/administrative" \
  --data-urlencode "keyword=北京" \
  --data-urlencode "childLevel=1" \
  --data-urlencode "extensions=true" \
  --data-urlencode "tk=$TIANDITU_KEY"
```

## 参数

| 参数 | 必选 | 说明 |
|------|------|------|
| keyword | 是 | 行政区划名称或编码（支持模糊查询），如 `北京` 或 `156110000`；**只支持单个关键词**；名称支持模糊，编码需精确 |
| childLevel | 否 | 返回下级行政区级数：0=不返回下级，1=下一级，2=下两级，3=下三级。默认 0 |
| extensions | 否 | `true`=返回轮廓数据（boundary），`false`=不返回。默认 false |

注意：keyword 只有一个字符时只返回 suggestion（建议词），不返回 district。

## 返回结构

```json
{
  "message": "查询成功",
  "status": 200,              // 200=正常，其他异常
  "data": {
    "suggestion": [...],      // 模糊匹配建议词（只匹配到一条时为空）
    "district": [
      {
        "name": "北京市",
        "gb": "156110000",
        "boundary": "MULTIPOLYGON(((116.666886 40.976711,...)))",   // 轮廓数据（WKT 格式，extensions=true 时）
        "center": { "lng": 116.4074, "lat": 39.9042 },
        "level": 4,                       // 5=国家 4=省 3=市 2=区县
        "children": [                     // childLevel>0 时返回，结构同 district
          { "name": "东城区", "gb": "156110101", "center": {...}, "level": 2, "children": [] }
        ]
      }
    ]
  }
}
```

## 使用建议

- 查某地的编码：`keyword=朝阳区` → 取 `district[].gb`（9 位国标码），用于 search_v2 的 `specify` 参数
- 查完整层级（省→市→区县）：`childLevel=3` 一次拿全
- 查边界（轮廓）做可视化：`extensions=true` + `childLevel=0`（轮廓数据较大，建议单独查询；`boundary` 为 WKT MULTIPOLYGON 字符串，可直接用于 PostGIS/GeoJSON 转换）
- 行政区划编码表下载：https://download.tianditu.gov.cn/download/xzqh/AdminCode.csv
