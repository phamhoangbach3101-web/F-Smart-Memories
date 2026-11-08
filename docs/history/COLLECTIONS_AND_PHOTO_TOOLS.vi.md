# Bộ ảnh, chọn ảnh trực quan và Thùng rác

Bản nâng cấp ngày 15/10/2026. Mở `http://127.0.0.1:8000/`, tải lại trang để nhận giao diện mới.

## Thao tác

1. **Thư viện ảnh → Tạo bộ ảnh mới**: đặt tên và thêm ảnh. Trang tổng quan có ảnh bìa, số ảnh và ô tìm tên bộ (bỏ qua dấu tiếng Việt).
2. Mở một bộ: dùng các tab **Ảnh / Tìm khuôn mặt / Sáng tạo / Thùng rác**. Đổi bộ bằng danh sách trên đầu hoặc quay lại **Tất cả bộ ảnh**. Lịch sử tác phẩm và hàng đợi hiển thị theo bộ.
3. Tích các ảnh → **Chuyển sang bộ ảnh**: chọn bộ có sẵn hoặc nhập tên bộ mới. Giữ ID ảnh, file nguồn, vector khuôn mặt và tác phẩm. Nếu một ảnh trùng hoặc đang xử lý, cả lựa chọn giữ nguyên; không chuyển dở một phần.
4. Trong Sáng tạo hoặc đề xuất chatbot, bấm **Chọn ảnh có xem trước**. Rê chuột lên từng dòng để đổi ảnh lớn bên cạnh. Có thể tìm theo tên, dùng phím lên/xuống hoặc chạm vào dòng; bấm **Chọn ảnh này** để xác nhận. Chỉ tải danh sách 100 ảnh/lần và dùng thumbnail; không tải toàn bộ ảnh gốc dung lượng lớn.
5. Nút **⌫** hoặc **Xóa ảnh đã chọn** đưa ảnh vào Thùng rác sau xác nhận. Dùng **Hoàn tác** ngay hoặc mở **Thùng rác**, chọn ảnh và **Khôi phục**. Dữ liệu mặt và tác phẩm được giữ để khôi phục.
6. **Xóa vĩnh viễn** trong Thùng rác yêu cầu đánh dấu xác nhận rồi bấm nút xóa. Bước này xóa ảnh, vector mặt và tác phẩm đi kèm, không thể hoàn tác trong ứng dụng. Chuyển vào Thùng rác chưa giải phóng dung lượng.

## Pipeline và bảo vệ dữ liệu

Chuyển bộ và thay đổi trạng thái Thùng rác chạy trong giao dịch SQLite dưới khóa ghi. Mọi ID được kiểm tra trước khi cập nhật; tác vụ index/style đang dùng ảnh sẽ chặn thao tác quản lý ảnh. Bộ đích kiểm tra trùng checksum trước khi chuyển.

Các luồng thư viện, tìm kiếm khuôn mặt, tạo style, lịch sử và tải ZIP chỉ dùng ảnh đang hoạt động. Ảnh trong Thùng rác có đường lấy thumbnail riêng. ZIP nguồn được chuẩn bị trước đó có chứa ảnh vừa xóa được vô hiệu hóa. Khôi phục bỏ trạng thái Thùng rác, không cần chạy lại model. Chặn tiếp tục lô đang dừng nếu còn ảnh cần xử lý nằm trong Thùng rác.

Xóa vĩnh viễn cập nhật DB rồi dọn file. Nếu Windows khóa file đang tải, API báo số lỗi dọn file và ghi log; không tuyên bố đã giải phóng hết dung lượng. Chưa có journal dọn file riêng bảo đảm phục hồi khi mất điện giữa bước DB và xóa file. Endpoint DELETE ảnh cũ vẫn giữ hành vi xóa vĩnh viễn để tương thích; giao diện mới dùng Thùng rác.

Frontend bỏ phản hồi cũ khi đổi bộ hoặc đổi truy vấn, hủy tìm kiếm đang chờ và xóa lựa chọn ảnh của bộ trước. Chatbot chấp nhận tên các trang mới; nút chọn ảnh trực quan được gắn sau khi đề xuất đã vào trang để cập nhật thumbnail/tên đúng.

## Kiểm nghiệm

- Toàn bộ **102 test đạt**, gồm 8 test quản lý bộ ảnh, 7 test Thùng rác/tìm tên ảnh và 3 tình huống chatbot trên trang mới. Có một cảnh báo deprecation từ Starlette TestClient; không có test thất bại. Kết quả: `artifacts/collections/tests.xml`.
- Kiểm tra trình duyệt bằng bộ dữ liệu màu riêng ở cổng 8001: tạo bộ C, chuyển ảnh từ A sang C, đưa vào Thùng rác, Hoàn tác và Khôi phục. Kiểm tra nút xóa vĩnh viễn bị vô hiệu khi chưa đánh dấu; không bấm xóa vĩnh viễn ảnh người dùng. Backend purge được kiểm thử trên dữ liệu tạm của test.
- Trên bộ thật: danh sách chọn có đủ 68 ảnh; tìm tên và xem trước bằng bàn phím tải được ảnh. Chọn từ đề xuất chatbot cập nhật đúng tên ảnh. Trang tìm mặt vẫn trả 5/68 ảnh vượt ngưỡng 0,40 cho tham chiếu đã lưu; đây là kết quả truy vấn, không phải phép đo accuracy.
- Kiểm tra bảng chọn ở 430 × 900 và 1440 × 950: danh sách cuộn riêng, khung xem trước và nút xác nhận hiển thị; không tràn ngang ở màn hình nhỏ. Ảnh chụp: `artifacts/ui/photo-picker-mobile.jpg`, `artifacts/ui/photo-picker-desktop.jpg`.
- Đối chiếu ID/bộ/checksum của toàn bộ **68 ảnh không đổi**, Thùng rác dữ liệu thật 0 ảnh. Kiểm tra toàn vẹn đạt: 68 preview, 68 thumbnail, 453 embedding và 87 PNG kết quả hợp lệ tại thời điểm kiểm tra. Kết quả: `artifacts/collections/live-system.json`.

102 test chủ yếu dùng model giả để kiểm tra logic và vòng đời dữ liệu; không dùng để suy ra chất lượng nhận diện hoặc benchmark neural style. Các giới hạn ảnh nguồn bản cũ và accuracy vẫn theo báo cáo kiểm toán hệ thống. Chưa kiểm tải 10.000 ảnh thật, chưa có tài khoản/phân quyền nhiều người, không tự xóa Thùng rác theo lịch.
