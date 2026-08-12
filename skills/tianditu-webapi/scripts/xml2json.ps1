#!/usr/bin/env pwsh
# 天地图 /drive 驾车规划响应（XML）转 JSON 的零依赖转换脚本
# 用法：
#   .\xml2json.ps1 -Path response.xml                 # 从文件读取
#   .\xml2json.ps1 -Text "<result>...</result>"        # 从字符串读取
#   curl.exe -s -G "https://api.tianditu.gov.cn/drive" --data-urlencode 'postStr={...}' --data-urlencode "type=search" --data-urlencode "tk=$env:TIANDITU_KEY" | .\xml2json.ps1   # 管道读取
# 注意：管道模式依赖调用方控制台编码——GBK(936) 控制台下 UTF-8 中文会乱码，请先执行
#   [Console]::InputEncoding = [Text.Encoding]::UTF8
# 或改用 -Path/-Text 传入（推荐）。
# 说明：PowerShell 内置 [xml] + ConvertTo-Json 对 XmlDocument 会序列化成空数组嵌套，必须用本脚本的递归转换。

param(
    [string]$Path,
    [string]$Text
)

$ErrorActionPreference = 'Stop'

function ConvertFrom-XmlNode {
    param([System.Xml.XmlNode]$Node)

    if ($Node.NodeType -eq 'Element') {
        $obj = [ordered]@{}
        foreach ($attr in $Node.Attributes) {
            $obj[$attr.Name] = $attr.Value
        }

        $elements = @($Node.ChildNodes | Where-Object { $_.NodeType -eq 'Element' })
        $texts = @($Node.ChildNodes | Where-Object { $_.NodeType -in 'Text', 'CDATA' -and $_.InnerText.Trim() -ne '' })

        if ($elements.Count -eq 0) {
            # 纯文本元素直接输出字符串（更紧凑）；有属性时才保留对象形式
            if ($texts.Count -gt 0) {
                if ($obj.Count -eq 0) {
                    return $texts[0].InnerText
                }
                $obj['#text'] = $texts[0].InnerText
            } elseif ($obj.Count -eq 0) {
                return ''
            }
        } else {
            foreach ($g in ($elements | Group-Object Name)) {
                if ($g.Count -eq 1) {
                    $obj[$g.Name] = ConvertFrom-XmlNode $g.Group[0]
                } else {
                    $obj[$g.Name] = @($g.Group | ForEach-Object { ConvertFrom-XmlNode $_ })
                }
            }
        }
        return $obj
    }

    return $Node.InnerText
}

if ($Path) {
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
} elseif ($Text) {
    $raw = $Text
} else {
    $raw = @($input) -join "`n"
    if ([string]::IsNullOrWhiteSpace($raw)) {
        Write-Error "未提供输入：使用 -Path 指定文件、-Text 传字符串，或从管道传入 XML"
    }
}

try {
    $xml = [xml]$raw
} catch {
    Write-Error "输入不是合法 XML：$($_.Exception.Message)"
}

$result = ConvertFrom-XmlNode $xml.DocumentElement
$result | ConvertTo-Json -Depth 100
