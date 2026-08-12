# 场景一：关键词搜索（普通搜索/地名搜索）

**触发：** 用户给出明确的搜索类别或地点名，无位置限定（如"找医院"、"北京大学在哪"、"搜美食"）。

## 步骤

1. 从用户请求中提取精确的 `keyWord`
2. 构造请求：`queryType=1`（普通搜索，含地铁公交）或 `queryType=7`（仅地名）；带范围限定时传 `mapBound`+`level`，带行政区域限定时传 `specify`
3. 可选：`dataTypes` 限定分类（编码见 error_codes.md）、`show=2` 获取详细信息
4. 返回结果按 `pois[]` 解析，坐标为 `lonlat` 字段（`经度,纬度`）

## 请求

```bash
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"医院","level":12,"mapBound":"116.02524,39.83833,116.65592,39.99185","queryType":1,"start":0,"count":10,"show":2}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"
```

> 官方文档将 `mapBound`（范围）与 `level`（级别 1-18）标为 queryType=1/7 的必填参数。需要限定时直接传；用户给了城市名时，可先用行政区划接口（recipes/geocode_admin.md）拿城市范围填充 mapBound；只想限定在某个城市时，用 `specify` + queryType=12（行政区划区域搜索，见 recipes/region_search.md）更简单。

## 结果解析

```json
{
  "count": 10,
  "pois": [
    { "name": "北京协和医院", "address": "...", "lonlat": "116.42127,39.91264",
      "city": "北京市", "county": "东城区", "typeName": "综合医院", "phone": "..." }
  ],
  "status": { "infocode": 1000, "cndesc": "服务正常" }
}
```

给用户的回答中应包含：名称、地址、坐标（若有用）、电话（如有）。

## 变体

- **分类限定**：`"dataTypes":"050000"` 只搜科教文化类（多个用逗号）
- **统计需求**（"北京有多少公园"）：用 queryType=14 统计搜索（见 region_search.md）
- **线路搜索**：搜地铁/公交线路名时 `poiType=103` 出现在 lineData 中，可配合 transit ID 查询拿详情

## 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| 2003 缺少必填参数 | queryType=1/7 缺 mapBound 或 level | 补全范围与级别 |
| 2004 枚举值错误 | queryType 写错 | 检查 queryType ∈ {1,2,3,7,10,12,13,14} |
| 3001 没有数据 | 关键词过细 | 简化关键词或去掉 dataTypes |
