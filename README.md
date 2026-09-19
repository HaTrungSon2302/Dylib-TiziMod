# TiziReplace

Bản v2 này **không tạo thêm một dòng chữ mới**.

Nó tìm UILabel/UIButton có chữ:

```text
PennyIOS & EreenModz
```

và đổi chính UI đó thành:

```text
Telegram_@TiziMod
```

Đồng thời:
- đổi màu xanh nước biển RGB(0,170,255)
- chữ đậm 16pt
- canh giữa
- đưa về Y = 60pt tính từ mép trên
- thêm bóng đen nhẹ

## Build

Upload toàn bộ project lên GitHub, giữ nguyên:

```text
.github/workflows/build.yml
```

Sau đó:

```text
Actions
→ Build TiziReplace
→ Run workflow
```

Khi build xong tải artifact:

```text
TiziReplace-dylib
```

Bên trong có:

```text
TiziReplace.dylib
```

## Inject bằng ESign

Inject:
1. dylib menu gốc
2. `TiziReplace.dylib`

Không inject `TiziOverlay.dylib` cũ nữa, vì bản cũ tạo một label riêng và sẽ gây hai dòng chữ.

Sau khi inject xong, ký lại toàn bộ IPA bằng ESign.

## Quan trọng

Bản này chỉ thay được chữ nếu menu gốc dùng `UILabel`, `UIButton` hoặc UIKit tương tự.

Nếu chữ `PennyIOS & EreenModz` được vẽ trực tiếp bằng **Dear ImGui / Metal** thì UIKit không nhìn thấy nó; khi đó dylib này sẽ không thay đổi chữ nhưng cũng không tạo thêm chữ thứ hai.

Nếu thử bản này mà chữ gốc vẫn còn nguyên, đó là dấu hiệu mạnh cho thấy watermark được render bằng ImGui.
