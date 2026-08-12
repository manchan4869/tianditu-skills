# 公交规划参考

地址：`https://api.tianditu.gov.cn/transit`，请求参数 `type=busline`。

## 1. 公交线路规划

请求：

```bash
curl -G "https://api.tianditu.gov.cn/transit" \
  --data-urlencode "type=busline" \
  --data-urlencode 'postStr={"startposition":"116.427562,39.939677","endposition":"116.349329,39.939132","linetype":"1"}' \
  --data-urlencode "tk=$TIANDITU_KEY"
```

参数（postStr 内，全部小写）：

| 参数 | 说明 |
|------|------|
| startposition | 起点坐标 `"经度,纬度"` |
| endposition | 终点坐标 `"经度,纬度"` |
| linetype | 规划类型，**按位判断**，可组合：第0位(值1)=较快捷，第1位(值2)=少换乘，第2位(值4)=少步行，第3位(值8)=不坐地铁。例：`"1"`=较快捷，`"3"`=较快捷+少换乘，`"8"`=不坐地铁 |

返回结构（官方示例与实测一致）：

```json
{
  "resultCode": 0,          // 见下表
  "hasSubway": false,       // 实测返回布尔值：false=不包含地铁 true=包含地铁（官方文档标 0/1，以实测为准）
  "results": [              // 请求几种 linetype 返回几种结果
    {
      "lineType": 1,
      "lines": [            // 最多 5 条线路
        {
          "lineName": "地铁２号线 |",
          "segments": [     // 各段（步行/公交/地铁）
            {
              "segmentType": 3,   // 1-4，段类型
              "stationStart": { "name": "东直门站", "uuid": "133017", "lonlat": "116.427562,39.939677" },
              "stationEnd": { "name": "西直门站", "uuid": "133057", "lonlat": "116.349329,39.939132" },
              "segmentLine": [   // ⚠️ 数组！每个元素为一段乘车/步行
                {
                  "segmentStationCount": 5,   // 经过站点数
                  "segmentTime": 12,          // 段耗时（分钟）
                  "segmentTransferTime": 0,   // 换乘耗时（分钟）
                  "segmentDistance": 7918.48, // 段距离（米）
                  "direction": "地铁２号线",   // 完整线路名/方向
                  "SEndTime": "05:09-05:09",  // 发收车时间
                  "linePoint": "116.427562,39.939677;...",  // 段坐标串（分号分隔）
                  "lineName": "地铁２号线",
                  "byuuid": "23213"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

**resultCode 编码表：**

| 编码 | 含义 |
|------|------|
| 0 | 正常返回线路 |
| 1 | 找不到起点 |
| 2 | 找不到终点 |
| 3 | 规划线路失败 |
| 4 | 起终点距离 200 米以内，不规划，建议步行 |
| 5 | 起终点距离 500 米内，返回线路 |
| 6 | 输入参数错误 |

## 2. ID 搜索（公交站/线路详情）

根据前端搜索得到的 uuid 查公交站或公交线的详细信息。站 uuid 返回 Station 数据，线 uuid 返回 Lineinfo 数据。

```bash
curl -G "https://api.tianditu.gov.cn/transit" \
  --data-urlencode "type=busline" \
  --data-urlencode 'postStr={"uuid":"23212"}' \
  --data-urlencode "tk=$TIANDITU_KEY"
```

线路详情（Lineinfo）关键字段：`lineName`（线路名）、`lineType`（1=公交 2=地铁 3=磁悬浮）、`length`（米）、`startTime`/`endTime`（hh:mm 发收车时间）、`totalTime`（全程分钟）、`stationCount`、`interval`（发车间隔秒）、`totalPrice`（全程票价，分）、`linePoint`（坐标 x,y;x,y）、`station[]`（站点数组）。

站点数据（Station）：`name`、`uuid`、`lonlat`、`linedata[]`（途经线路）。

## 3. 站点返程线路查询

查询经过某站点的线路是否有反向线路（是否成对）：

```bash
curl -G "https://api.tianditu.gov.cn/transit" \
  --data-urlencode "type=busline" \
  --data-urlencode 'postStr={"lineUuid":"21169","stationUuid":"128156"}' \
  --data-urlencode "tk=$TIANDITU_KEY"
```

**响应：** 返回该线路完整 Lineinfo（同 ID 搜索结构），核心字段 `isbidirectional`（1=双向，0=单向）判断是否成对。**实测返回字段名为小写**（`linename`/`stationnum`/`isbidirectional`/`startprice` 等），与官方参数表的驼峰写法（lineName/isBidirectional）不同，解析时注意。

## 注意事项

- 所有坐标 `经度,纬度` 顺序
- 公交规划不返回多城市跨市公交，跨市建议分城市查询
- 步行段距离小于 20 米时该线段不返回（说明两点极近）
