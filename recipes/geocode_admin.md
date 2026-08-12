# 场景六：地理编码 / 逆地理编码 / 行政区划

**触发：** 地址与经纬度互转、查行政区划编码/层级/边界、确认某坐标在哪个行政区。

## 子场景判断

| 子场景 | 用户说法 | 接口 |
|--------|---------|------|
| 地理编码 | "这个地址的坐标"、"XX在哪（需要坐标）" | `geocoder` + ds |
| 逆地理编码 | "这个坐标是哪里"、"116.39,39.90 在哪个区" | `geocoder` + postStr |
| 行政区划 | "北京的区划编码"、"朝阳区有哪些街道"、"某省的边界" | `/v2/administrative` |

## 地理编码（地址 → 坐标）

```bash
curl -G "https://api.tianditu.gov.cn/geocoder" \
  --data-urlencode 'ds={"keyWord":"北京市海淀区莲花池西路28号"}' \
  --data-urlencode "type=geocode" \
  --data-urlencode "tk=$TIANDITU_KEY"
```

返回 `location.lon/lat`（经度,纬度）。仅限国内地址。

## 逆地理编码（坐标 → 地址）

```bash
curl -G "https://api.tianditu.gov.cn/geocoder" \
  --data-urlencode 'postStr={"lon":116.37304,"lat":39.92594,"ver":1}' \
  --data-urlencode "type=geocode" --data-urlencode "tk=$TIANDITU_KEY"
```

返回 `result.formatted_address`（详细地址）、`result.addressComponent`（最近地点/POI/道路及距离方向）。

## 行政区划查询

```bash
# 查"朝阳区"及其上级、下级（childLevel=1 返回下一级，3 返回全部层级）
curl -G "https://api.tianditu.gov.cn/v2/administrative" \
  --data-urlencode "keyword=朝阳区" \
  --data-urlencode "childLevel=1" \
  --data-urlencode "tk=$TIANDITU_KEY"
```

```bash
# 查边界轮廓（extensions=true，数据较大，建议 childLevel=0）
curl -G "https://api.tianditu.gov.cn/v2/administrative" \
  --data-urlencode "keyword=156110105" \
  --data-urlencode "extensions=true" \
  --data-urlencode "tk=$TIANDITU_KEY"
```

返回 `district[]`：`name`（名称）、`gb`（9 位国标码）、`center.lng/lat`（中心点）、`level`（5=国家 4=省 3=市 2=区县）、`children[]`（下级）、`boundary`（轮廓，extensions=true 时）。

## 典型串联用法

1. **地名 → 坐标 → 周边搜索**：地理编码得坐标 → 填到 queryType=3 的 pointLonlat
2. **地名 → 行政区编码 → 区域搜索**：行政区划接口得 gb 码 → 填到 queryType=12/13/14 的 specify
3. **坐标 → 行政区**：逆地理编码确认归属区县，或行政区划接口按名称匹配
4. **route_planning 前置**：路线规划前用地理编码把起终点地名转坐标

## 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| 地理编码 status=101 | 地址结果为空 | 地址需精确完整（省市区+街道+门牌） |
| 坐标对不上 | 输入了 GCJ-02/BD-09 坐标 | 天地图用 WGS-84/CGCS2000 |
| 行政区划无结果 | keyword 写错/编码不完整 | 用名称模糊查（支持中文） |
