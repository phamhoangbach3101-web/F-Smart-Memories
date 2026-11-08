# Hiển thị trọn ảnh — 16/10/2026

Lỗi khung xem lớn: ảnh chỉ đặt max-height theo phần trăm trong ô grid có kích thước nội tại, nên ảnh lớn có thể đẩy ô cao hơn vùng nhìn và bị overflow cắt. Đã đặt rõ hàng grid co được, kích thước vùng ảnh và width/height của ảnh trước khi dùng object-fit: contain. Ảnh giữ tỷ lệ; khoảng trống quanh ảnh được chấp nhận để giữ đủ nội dung.

Desktop giữ thanh đóng/chuyển ảnh và chia vùng ảnh với bảng thông tin cuộn độc lập. Mobile xếp ảnh trên thông tin; phần nội dung cuộn trong hộp thoại, trang phía sau khóa cuộn. Thumbnail thư viện, lịch sử, bìa bộ ảnh và bảng chọn cũng dùng contain; bỏ phóng to thumbnail khi rê chuột để không cắt mép ảnh.

Đã thao tác trên trình duyệt với ba ảnh kiểm tra có dấu màu ở bốn góc: 900×1600, 1800×1200 và 2400×400. Mỗi ảnh kiểm tra ở 1920×1080, 1440×900, 1366×768, 1024×600, 800×600, 430×900, 375×667 và 667×375: 24/24 ca đạt. Kiểm tra ảnh đã tải, contain, kích thước ảnh nằm trong stage, dialog và thanh công cụ nằm trong viewport, không tràn ngang. Thao tác cuối bảng thông tin tiếp cận được bằng bàn phím trên mobile. Không ghi nhận lỗi JavaScript của tab QA.

Ảnh thử nằm trong album riêng ở `.cache/collections-ui-runtime`, không thêm vào kho cá nhân. Báo cáo số đo `artifacts/layout-viewport-checks.json`; ảnh minh chứng `artifacts/ui/viewer-full-frame-desktop.jpg` và `viewer-full-frame-mobile.jpg`. Đây là các kích thước đã kiểm chứng, không phải bảo đảm cho mọi trình duyệt/zoom chưa thử.
