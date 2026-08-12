# 天地图 Web 服务 API Skill

[![skills.sh](https://skills.sh/b/manchan4869/tianditu-webapi)](https://skills.sh/manchan4869/tianditu-webapi/tianditu-webapi)

天地图（国家地理信息公共服务平台）Web 服务 API 的 Agent Skill。零运行时依赖，仅使用 `curl` 调用 REST API。

## 功能

- 🔍 地名搜索 V2.0 八种查询：普通(1)、地名(7)、视野内(2)、周边(3)、多边形(10)、行政区划区域(12)、数据分类(13)、统计(14)
- 🛣️ 驾车规划（最快/最短/避开高速/步行，支持途经点；响应为 XML，附转换脚本）
- 🚌 公交规划（较快捷/少换乘/少步行/不坐地铁）+ 公交站/线路详情 + 返程线路查询
- 📍 地理编码（地址→坐标）与逆地理编码（坐标→地址）
- 🏛️ 行政区划 V2.0（层级/中心点/轮廓边界/国标码）
- 🗺️ 静态地图图片（标注/折线/面/自定义图标/底图叠加）

## 安装

```bash
npx skills add manchan4869/tianditu-webapi
```

或手动将本仓库的 `tianditu-webapi` 目录放入你的 skills 目录（如 `~/.agents/skills/`）。

## 配置

在[天地图控制台](https://cloudcenter.tianditu.gov.cn/center/development/myApp)注册并创建应用（**应用类型选「服务端」**）获取 Key：

```bash
export TIANDITU_KEY="your_key"
```

或编辑 `config.json`（模板见 `config.example.json`）。

## 结构

```
SKILL.md                        # 入口：触发条件/场景判断/配置
recipes/                        # 场景流程（关键词/周边/区域/路线/静态图/编码）
references/                     # API 参考（search_v2/geocoding/administrative/transit/drive/static_map/error_codes）
scripts/xml2json.ps1            # /drive XML 响应 → JSON 转换脚本
```

## 文档

- [天地图服务指南](http://lbs.tianditu.gov.cn/server/guide.html)
- 坐标系统：CGCS2000/WGS-84（与 GPS 一致，区别于高德 GCJ-02）

## License

MIT
