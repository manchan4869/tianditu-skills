# 地理编码与逆地理编码参考

同一端点 `https://api.tianditu.gov.cn/geocoder`，两种编码用不同参数区分。**地址解析仅限国内**。

## 地理编码（地址 → 坐标）

请求：

```bash
curl -G "https://api.tianditu.gov.cn/geocoder" \
  --data-urlencode 'ds={"keyWord":"北京市海淀区莲花池西路28号"}' \
  --data-urlencode "type=geocode" \
  --data-urlencode "tk=$TIANDITU_KEY"
```

参数：`ds` = JSON 字符串 `{"keyWord":"结构化地址"}`（必须 URL 编码），`type=geocode` 指定地理编码方向。

返回（官方示例与实测一致）：

```json
{
  "status": "0",               // "0"=正常 "101"=结果为空 "404"=出错
  "msg": "ok",
  "searchVersion": "6.4.9V",
  "location": {
    "score": 100,              // 匹配评分
    "level": "门址",           // 类别名称
    "lon": "116.290158",
    "lat": "39.894696",
    "keyWord": "北京市海淀区莲花池西路28号"
  }
}
```

> 官方参数表另列 `typeRound`（附近相似点，开启周边查询时返回），官方返回示例未含此字段，以实际返回为准。

## 逆地理编码（坐标 → 地址）

请求：

```bash
curl -G "https://api.tianditu.gov.cn/geocoder" \
  --data-urlencode 'postStr={"lon":116.37304,"lat":39.92594,"ver":1}' \
  --data-urlencode "type=geocode" \
  --data-urlencode "tk=$TIANDITU_KEY"
```

参数：`postStr` = `{"lon":经度,"lat":纬度,"ver":1}`（ver 必须为 1）。

返回：

```json
{
  "status": 0,               // 0=正确 1=错误 404=出错
  "msg": "OK",
  "result": {
    "formatted_address": "北京市西城区...",
    "location": { "lon": 116.37304, "lat": 39.92594 },
    "addressComponent": {
      "address": "最近地点", "address_distince": 0, "address_position": "方向",
      "city": "北京市",
      "poi": "最近POI", "poi_distince": 0, "poi_position": "方向",
      "road": "最近道路", "road_distince": 0, "road_position": "方向"
    }
  }
}
```

## 注意事项

- **经纬度顺序是经度在前**（lon, lat），与 QGIS 等软件的 x,y 一致
- 地理编码用 `ds` 传地址、逆地理编码用 `postStr` 传坐标，两者都以 `type=geocode` 标识；逆地理编码的 `ver` 参数必须为 1
- 旧版资料常见 `type=regeocode` 写法，以当前官方文档（type=geocode）为准
- 天地图坐标为 CGCS2000/WGS-84，**不要**把高德(GCJ-02)/百度(BD-09)坐标直接传入，会产生偏移
- 坐标合法范围：经度 -180~180，纬度 -90~90
