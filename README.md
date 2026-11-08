# Codex 鍩虹鎸囦护瑕嗙洊鍖?
鐢ㄤ竴浠芥敼鍐欏悗鐨?base instructions 鏇挎崲 Codex 鐨勯粯璁ゅ熀纭€鎸囦护锛屽苟杩藉姞涓€鏉?developer 浼樺厛绾у０鏄庛€傜洰鏍囨槸璁╂ā鍨嬩粠鐢ㄦ埛鐩爣涓庡繀瑕佹潯浠舵帹瀵兼渶鐭疄鐜帮紝鎶婃棤渚濇嵁鐨勯槻寰℃€х紪绋嬨€侀闃叉€ф娊璞″拰渚嬭楠岃瘉鍘嬪埌鏈€浣庛€?
## 鍓嶇疆鏉′欢

- Windows锛孭owerShell 5.1 鎴?PowerShell 7+
- Codex 宸插畨瑁呭苟鍚姩杩囪嚦灏戜竴娆★紝瀛樺湪 `%USERPROFILE%\.codex\config.toml`
- 閰嶇疆涓嶅湪榛樿浣嶇疆鏃讹紝璁剧疆鐜鍙橀噺 `CODEX_HOME` 鎸囧悜瀹?
## 瀹夎

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

鑴氭湰鎵ц鍥涙锛?
1. 瑙ｆ瀽 `CODEX_HOME` 鎴?`%USERPROFILE%\.codex`锛岀‘璁?`config.toml` 瀛樺湪锛?2. 澶囦唤涓?`config.toml.bak-<鏃堕棿鎴?`锛?3. 鍦ㄩ涓?`[table]` 涔嬪墠鍐欏叆涓や釜椤跺眰閿€斺€擿model_instructions_file` 鎸囧悜鏈寘 `instructions.md` 鐨勭粷瀵硅矾寰勶紙璺緞鍦ㄨ繍琛屾椂鐢辫剼鏈綅缃帹瀵硷紝鑴氭湰鍐呮病鏈夌粷瀵硅矾寰勶級锛宍developer_instructions` 璇诲彇 `developer-instructions.txt`锛?4. 鍥炶鏍￠獙涓や釜閿悇鍑虹幇涓€娆°€?
閲嶅杩愯浼氭浛鎹㈡棫鍊硷紝涓嶄細鍙犲姞銆?
## 楠岃瘉

瀹屽叏閫€鍑?Codex锛堝寘鎷墭鐩樿繘绋嬶級锛岄噸鏂版墦寮€锛屾柊寮€浼氳瘽鍚庤闂畠绯荤粺鎻愮ず璇嶇殑绗竴鍙ャ€傚畨瑁呮垚鍔熸椂鍥炵瓟浠?`You are Codex, a coding agent.` 寮€澶淬€?
涔熷彲浠ョ洿鎺ユ煡鐪嬮厤缃細

```powershell
Select-String -Path "$env:USERPROFILE\.codex\config.toml" -Pattern 'model_instructions_file|developer_instructions'
```

## 鍗歌浇

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

鍒犻櫎涓や釜椤跺眰閿苟鐣欎笅澶囦唤锛汣odex 閲嶅惎鍚庡洖鍒伴粯璁ゅ熀纭€鎸囦护銆?
## 鐢熸晥鑼冨洿

| 椤?| 鏄惁鍙楁湰鍖呭奖鍝?|
|---|---|
| base instructions | 鏇挎崲涓?`instructions.md`锛堟爣鍑?Responses 妯″紡锛?|
| developer 娈?| 杩藉姞 `developer-instructions.txt` 鐨勫唴瀹?|
| `approvals` / `permissions` / `auto_review` | 涓嶅彈褰卞搷锛岀敱鏈嶅姟绔ā鍨嬮厤缃笅鍙?|
| 鏈嶅姟绔?`persistent_instructions` | 浠嶇劧瀛樺湪锛涘叾涓缓璁€渧erifying that a change took effect鈥濈殑鍚庣画宸ヤ綔鐢?developer 娈靛帇鍒?|
| 宸叉墦寮€鐨勪細璇?| 涓嶉噸杞斤紝闇€瑕佹柊浼氳瘽 |

## 鍏煎鎬?
**Responses Lite 涓嬩笉鏇挎崲锛屽彧杩藉姞銆?* 鏍囧噯 Responses 妯″紡涓紝`model_instructions_file` 鏁存鏇挎崲妯″瀷鑷甫鐨勫熀纭€鎸囦护锛涘紑鍚?Responses Lite 鍚庯紝鍚屼竴浠藉唴瀹逛細浣滀负涓€鏉″悗缃?developer 娑堟伅鍔犲叆锛屾ā鍨嬪悓鏃剁湅鍒板畼鏂?base 韬唤涓庤嚜瀹氫箟鎸囦护銆傞渶瑕佹暣娈垫浛鎹㈡椂鍏抽棴 Responses Lite銆傚弬瑙?[openai/codex#38355](https://github.com/openai/codex/issues/38355)銆?
**瀹樻柟閰嶇疆 schema 瀵规瀛楁鏈夋槑纭姖闃汇€?* `codex-rs/core/config.schema.json` 鍘熸枃锛?
> Optional path to a file containing model instructions that will override the built-in instructions for the selected model. Users are STRONGLY DISCOURAGED from using this field, as deviating from the instructions sanctioned by Codex will likely degrade model performance.

浣跨敤鍓嶅厛纭杩欐槸浣犺鐨勫彇鑸嶃€俙experimental_instructions_file` 宸插簾寮冨苟鏇村悕涓?`model_instructions_file`銆?
## 鏂囦欢

| 鏂囦欢 | 鐢ㄩ€?|
|---|---|
| `instructions.md` | 鏀瑰啓鍚庣殑 base instructions |
| `developer-instructions.txt` | developer 浼樺厛绾у０鏄庯紝鍙嚜琛屼慨鏀瑰悗閲嶈 |
| `install.ps1` | 瀹夎 |
| `uninstall.ps1` | 鍗歌浇 |

## 鏉ユ簮涓庤鍙?
`instructions.md` 鍩轰簬 Codex 妯″瀷缂撳瓨涓殑 base instructions 鏀瑰啓锛屽師鏂?21,534 瀛楄妭锛孲HA-256 `d12e6dbdfd4a4ddb26a1f6048b69a32b8b32f74e4add9791d1dff7f4cac0b032`銆備粨搴撲笉鍖呭惈涓婃父鍘熸枃銆傛湰鍖呬笌 OpenAI 鏃犻毝灞炲叧绯伙紝涓嶅惈瀹樻柟瀹夎鍖呫€佸嚟鎹垨閬ユ祴銆傝剼鏈互 MIT 璁稿彲鎻愪緵锛沗instructions.md` 鏄涓婃父鍩虹鎸囦护鐨勬敼鍐欙紝鍏跺師濮嬬増鏉冨綊涓婃父浣滆€呫€?