# Sửa luồng tìm khuôn mặt — 15/10/2026

Sau khi tải ảnh tham chiếu, giao diện cũ chỉ phát hiện và đánh dấu mặt, rồi chờ người dùng bấm nút tìm nằm dưới ảnh preview dài. Màn hình bên phải vẫn hiện trạng thái ban đầu, dù query đã có và kho ảnh đã được lập chỉ mục. Đây là lỗi luồng sử dụng, không thể kết luận model không có kết quả từ màn hình đó.

## Thay đổi

- Tự tìm sau khi tải ảnh, chọn mặt, đổi album hoặc điều chỉnh ngưỡng; hủy kết quả cũ nếu một lựa chọn mới đã thay thế nó.
- Đưa nút tìm lại và lựa chọn album lên đầu bảng. Tách rõ đang phát hiện mặt, đang tìm, không vượt ngưỡng và lỗi xử lý.
- Khôi phục ảnh tham chiếu đã lưu khi tải lại trang; chỉ trả metadata/bounding box, không trả embedding cho trình duyệt. Có thể trích lại feature khi pipeline thay đổi.
- Tìm kiếm trả số ảnh đã xử lý, đang chờ, lỗi và dùng model cũ. Album toàn feature cũ báo cần lập chỉ mục, không trả một danh sách rỗng gây hiểu nhầm.
- Detector giữ cạnh dài tới 2560px, min face 20px. Alignment lấy mẫu từ ảnh gốc; cộng feature của crop và bản lật ngang rồi normalize. Giữ RGB theo config của chính checkpoint CVLFace đang dùng, không áp quy tắc BGR của checkpoint AdaFace khác.
- Key pipeline mới `align-v2-fullres-flip` ngăn trộn feature hai phiên bản. Khung mặt tương đồng được hiển thị trên từng ảnh kết quả.

## Xác minh trực tiếp

Đã lập chỉ mục lại 5 ảnh đang có trong máy: 5 ảnh thành công, không có lỗi. Với ảnh tham chiếu hiện tại và ngưỡng giữ nguyên **0,40**, 3 ảnh vượt ngưỡng với điểm khoảng **0,669 / 0,600 / 0,519**. Hai ảnh còn lại có điểm cao nhất khoảng **0,329 / 0,279**, nên chưa được coi là kết quả khớp. Không hạ ngưỡng để ép đủ 5 kết quả, không suy ra người dùng có hay không có mặt trong hai ảnh đó từ điểm thấp.

Đã kiểm tra qua giao diện: tải lại trang tự khôi phục query và tìm ra 3 kết quả; chọn lại ảnh tham chiếu qua trình duyệt cũng tự tìm mà không bấm nút tìm. Đã xác nhận nút tìm lại nằm trong phần nhìn thấy ở kích thước desktop của ca báo lỗi. Tổng **37 bài kiểm thử đạt**, gồm khôi phục query, cập nhật phiên bản, trạng thái index và giữ độ phân giải ảnh gốc khi alignment.

Đây là kiểm tra chức năng trên ca lỗi cụ thể, không phải accuracy trên benchmark độc lập. Ảnh và báo cáo có dữ liệu cá nhân được giữ trong `runtime/` và `artifacts/face-debug/`, không nằm trong source ZIP.

Tham chiếu cấu hình checkpoint: [model config](https://huggingface.co/minchul/cvlface_adaface_ir50_webface4m/blob/main/config.json), [base wrapper của tác giả](https://huggingface.co/minchul/cvlface_adaface_ir50_webface4m/blob/main/models/base/__init__.py).
