# TiziOverlay

Project này tự build `TiziOverlay.dylib` bằng GitHub Actions trên runner macOS/Xcode.

Dylib chỉ hiển thị:

```text
Telegram_@TiziMod
```

Cấu hình mặc định:

- Màu: xanh nước biển RGB(0,170,255)
- Căn giữa theo chiều ngang
- Vị trí: `Y = 60pt`
- Cỡ chữ: `16pt`
- Có bóng đen nhẹ
- iOS deployment target: 13.0
- Kiến trúc: arm64

## Cách dùng nhanh

### 1. Tạo repository GitHub

Tạo một repo mới trên GitHub.

### 2. Upload toàn bộ project

Upload **toàn bộ nội dung** trong file ZIP này lên repo, bao gồm thư mục ẩn:

```text
.github/workflows/build.yml
```

Cấu trúc repo phải như sau:

```text
TiziOverlay/
├── .github/
│   └── workflows/
│       └── build.yml
├── TiziOverlay.m
├── README.md
└── .gitignore
```

### 3. Chạy build

Trong repo:

```text
Actions
→ Build TiziOverlay
→ Run workflow
```

Đợi job chạy xong.

### 4. Tải file dylib

Ở trang kết quả của workflow, kéo xuống phần:

```text
Artifacts
```

Tải:

```text
TiziOverlay-dylib
```

Bên trong có:

```text
TiziOverlay.dylib
TiziOverlay.dylib.sha256
```

## Inject bằng ESign

Bạn có thể để menu gốc là một dylib riêng, sau đó inject thêm:

```text
TiziOverlay.dylib
```

Sau khi inject xong, ký lại **toàn bộ IPA** bằng ESign rồi mới cài.

## Chỉnh chữ

Trong `TiziOverlay.m`:

```objc
static NSString * const kOverlayText = @"Telegram_@TiziMod";
```

## Chỉnh vị trí

Trong `TiziOverlay.m`:

```objc
static const CGFloat kTopY = 60.0;
```

Ví dụ:

```text
45 = cao hơn
60 = mặc định
75 = thấp hơn
```

## Chỉnh cỡ chữ

```objc
static const CGFloat kFontSize = 16.0;
```

## Chỉnh màu

Mặc định:

```objc
label.textColor = [UIColor colorWithRed:0.0
                                 green:(170.0 / 255.0)
                                  blue:1.0
                                 alpha:1.0];
```

## Lưu ý

GitHub Actions chỉ build và ad-hoc sign file dylib. Khi inject vào IPA bằng ESign,
hãy ký lại toàn bộ app bằng certificate/profile của bạn.
