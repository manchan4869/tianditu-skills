# 场景四：路线规划（驾车 + 公交）

**触发：** "从天安门到故宫怎么走"、"查去机场的公交"、"规划驾车路线"、"北京南站到颐和园坐什么车"。

## 子场景判断

| 子场景 | 用户说法 | 接口 |
|--------|---------|------|
| 驾车 | "开车怎么走"、"驾车路线" | `drive` |
| 公交/地铁 | "坐公交"、"地铁怎么坐"、"公交线路" | `transit` |
| 步行 | "步行路线" | `drive` + style=3 |

## 步骤

1. 地名 → 坐标：用地理编码接口（`recipes/geocode_admin.md`）或地名搜索拿起终点 `经度,纬度`
2. 驾车：构造 `drive` 请求，按用户偏好选 style
3. 公交：构造 `transit` 请求，按用户偏好选 linetype
4. 解析并呈现结果（公交按 resultCode 判断可行性）

## 驾车规划

```bash
curl -G "https://api.tianditu.gov.cn/drive" \
  --data-urlencode 'postStr={"orig":"116.35506,39.92277","dest":"116.39751,39.90854","style":"0"}' \
  --data-urlencode "type=search" --data-urlencode "tk=$TIANDITU_KEY"
```

style：0=最快，1=最短，2=避开高速，3=步行。途经点用 `mid`（分号分隔多个坐标）。**注意：/drive 实测返回 XML**（distance 单位千米、duration 单位秒），解析时用 XML 方式处理（见 references/drive.md）。

## 公交规划

```bash
curl -G "https://api.tianditu.gov.cn/transit" \
  --data-urlencode "type=busline" \
  --data-urlencode 'postStr={"startposition":"116.427562,39.939677","endposition":"116.349329,39.939132","linetype":"1"}' \
  --data-urlencode "tk=$TIANDITU_KEY"
```

linetype 按位组合：1=较快捷，2=少换乘，4=少步行，8=不坐地铁（可加和，如 `"3"`=较快捷+少换乘）。

**公交响应 resultCode 解读：**
- 0 → 正常，展示 `results[].lines[]`（最多 5 条备选，含换乘分段：`segments[]` 中 segmentType 区分步行/公交段，segmentLine 含段耗时与站点数）
- 4 → 起终点 200 米内，直接建议步行
- 1/2/3/6 → 起点/终点/规划/参数问题，提示用户

## 完整流程示例（"从北京南站到颐和园怎么走"）

1. 地理编码定位：
   ```bash
   curl -G "https://api.tianditu.gov.cn/geocoder" \
     --data-urlencode 'ds={"keyWord":"北京南站"}' \
     --data-urlencode "type=geocode" \
     --data-urlencode "tk=$TIANDITU_KEY"
   ```
   得起点 `116.37855,39.86537`；同理得终点颐和园 `116.27538,39.99991`
2. 驾车：`orig=116.37855,39.86537&dest=116.27538,39.99991`
3. 公交：`startposition=116.37855,39.86537&endposition=116.27538,39.99991`
4. 两条方案都给出，附距离/耗时/换乘信息，让用户选择

## 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| 起终点坐标在境外 | 天地图国内数据 | 提示用户确认地名/坐标 |
| 公交 resultCode=6 | postStr 参数名拼错（startposition 小写） | 对照 transit.md 参数 |
| 位置偏移 | 混用了高德/百度坐标 | 使用 WGS-84/CGCS2000 坐标 |
