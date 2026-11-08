# Nhập ảnh độ phân giải lớn — 16/10/2026

Đã bỏ trần 25 megapixel: `Settings.max_image_pixels=None`. Bộ đọc ảnh không áp giới hạn tổng pixel mặc định của Pillow, nên ảnh đã nhập cũng mở lại được trong tác vụ nền. Nhánh ảnh tham chiếu trả về từ API vẫn có giới hạn riêng 4.194.304 pixel, kiểm tra trước khi giải mã.

File upload gốc được lưu nguyên byte. Ảnh làm việc giữ độ phân giải sau khi xoay đúng EXIF; thumbnail được tạo riêng. SHA-256 để phát hiện ảnh trùng được tính theo dải dòng, giữ cùng kết quả với dữ liệu cũ nhưng không tạo thêm toàn bộ bản sao bytes trong RAM. Đã bỏ chặn 25 MP ở kiểm tra toàn vẹn để ảnh lớn không bị báo hỏng chỉ vì kích thước.

Không thay giới hạn dung lượng: JPG/PNG/WebP tối đa 20 MB/file, tối đa 128 MB/request; trình duyệt chia nhóm ảnh khi tải. Vẫn cần đủ RAM, dung lượng đĩa và định dạng hợp lệ; bỏ trần megapixel không làm giới hạn bộ nhớ/phần cứng biến mất. Kích thước chạy AI/output preset và VGG19 là cấu hình riêng, không bị nâng lên theo kích thước ảnh upload.

Kiểm tra API tự động với ảnh 6000×5000 (30 MP): nhập, tải file gốc, giữ kích thước, thumbnail, phát hiện trùng và kiểm tra toàn vẹn đều đạt. Kiểm tra thêm EXIF, giới hạn riêng ảnh API và thông báo thiếu RAM. Thử thực tế qua HTTP và trình duyệt ở QA với ảnh 12000×8000 (96 MP), 2.864.304 byte: tải lên, lập chỉ mục bằng model giả lập, giữ nguyên file gốc, mở ảnh đầy đủ và kiểm tra toàn vẹn đều đạt. Thời gian ca thử 8.103 giây, không phải số đo tốc độ nhận diện AI thật.

Báo cáo `artifacts/large-upload-96mp.json`; hình `artifacts/ui/upload-96mp-proof.jpg`. Dữ liệu thử nằm trong `.cache/large-upload-runtime`, tách khỏi kho ảnh cá nhân.
