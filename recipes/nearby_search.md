# 场景二：周边搜索

**触发：** 同时含「位置」和「搜索类别」，如"天安门附近酒店"、"北京南站周边美食"。位置可以是地名或经纬度。

## 步骤

1. 确定中心点坐标：
   - 用户给经纬度 → 直接用
   - 用户给地名 → 先用逆地理编码？不，用**地理编码/地名搜索**转坐标（`recipes/geocode_admin.md` 中地理编码，或 queryType=12 行政区划区域搜索定位）
2. 确定半径 `queryRadius`（米，**最大 10000**）。用户没提时默认 2000 米
3. 构造请求：`queryType=3`，带 `pointLonlat`（中心点）、`queryRadius`
4. 结果中每个 POI 带 `distance` 字段（`<1km` 为米，`≥1km` 为 km），可据此排序

## 请求

```bash
curl -G "https://api.tianditu.gov.cn/v2/search" \
  --data-urlencode 'postStr={"keyWord":"酒店","queryRadius":2000,"pointLonlat":"116.39751,39.90854","queryType":3,"start":0,"count":10}' \
  --data-urlencode "type=query" --data-urlencode "tk=$TIANDITU_KEY"
```

## 结果解析

```json
{
  "count": 10,
  "pois": [
    { "name": "某某酒店", "address": "...", "lonlat": "116.40127,39.90564",
      "distance": "850m", "city": "北京市", "county": "东城区" }
  ],
  "status": { "infocode": 1000, "cndesc": "服务正常" }
}
```

回答时应按 `distance` 从近到远排序呈现。

## 变体

- **指定分类**：`"dataTypes":"080000"`（住宿服务）更精准
- **扩大范围**：`queryRadius=10000`（最大 10 公里）
- **"XX区的YY"**（行政区限定，非半径）：用 queryType=12 行政区划区域搜索（region_search.md）

## 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| 2005 经纬度错误 | pointLonlat 格式错误 | 检查 `经度,纬度` 顺序 |
| 2004 枚举值错误 | queryRadius 超 10000 米 | 限制在 10 公里内 |
| 3001 没有数据 | 半径过小/类别过窄 | 加大半径或简化关键词 |
