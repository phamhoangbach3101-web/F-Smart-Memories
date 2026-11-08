# Tăng tốc CPU và xử lý theo lô

Bản đo ngày 15/10/2026 trên Windows, Intel Core i7-13620H (10 core/16 logical processors), PyTorch 2.8.0+cpu, OpenVINO 2026.4.1. Mỗi runtime dùng 4 luồng. Không cần train lại hoặc mua API để chạy các preset.

## Phần đã triển khai

- Dùng trọng số TransformerNet của [PyTorch Fast Neural Style](https://github.com/pytorch/examples/tree/main/fast_neural_style), chuyển trực tiếp sang OpenVINO CPU FP32. Không lượng tử hóa INT8 hoặc đổi trọng số. [Intel hỗ trợ chuyển từ PyTorch](https://docs.openvino.ai/2026/openvino-workflow/model-preparation/convert-model-pytorch.html).
- Giữ tỷ lệ ảnh, đệm tới bội số 4 rồi cắt lại. Ba chế độ cạnh dài tối đa 512/768/1024 px; không phóng lớn ảnh nhỏ. 512 là mặc định mới, tiết kiệm thời gian bằng cách giảm kích thước đầu ra. Ảnh nhập mới giữ raw upload; ảnh nhập từ bản cũ chỉ còn JPEG đã lưu, được ghi rõ trong manifest.
- Cache model đã chuyển theo hash trọng số/kiến trúc và phiên bản OpenVINO; giữ tối đa 2 model OpenVINO đã compile trong RAM. Lần đầu cần nạp/compile, có thể mất vài giây. Lựa chọn hiệu năng và cache theo [hướng dẫn latency của Intel](https://docs.openvino.ai/2026/openvino-workflow/running-inference/optimize-inference/optimizing-latency.html).
- CPU tự chọn OpenVINO khi có thư viện; CUDA tiếp tục dùng PyTorch. Nếu OpenVINO lỗi ở chế độ auto, app dùng PyTorch và công bố backend/fallback qua `/api/health`. Không cam kết tốc độ giống nhau trên mọi CPU.
- Hàng đợi style lưu từng ảnh trong SQLite, tối đa 10.000 ảnh/lô và 4 lô đang hoạt động. Một worker style xử lý từng ảnh, nhường lượt giữa ảnh để tác vụ tạo một ảnh có thể chạy xen kẽ. Đây là xử lý nhiều ảnh có giới hạn tài nguyên, không phải tensor batch 10.000 ảnh nằm trong RAM.
- Dừng sau ảnh đang chạy; tiếp tục từ ảnh còn lại, thử lại riêng ảnh lỗi. Khởi động lại server sẽ tự phục hồi lô chưa hoàn tất. Cache kết quả phân biệt ảnh, trọng số, preset, cường độ, tiêu đề và kích thước; không tính cache hit là suy luận mới.
- ZIP kết quả được ghi file tạm trên ổ đĩa, gồm PNG và `report.json`; file ZIP tạm xóa sau khi trả xong. PNG dùng nén mức 1, vẫn lossless, có thể lớn hơn PNG nén mặc định.
- Worker lập chỉ mục khuôn mặt và worker style có hàng đợi/khóa riêng. Giữ nguyên AdaFace RGB/full-resolution alignment/flip và ngưỡng tìm mặt; không giảm chất lượng nhận diện để tăng số đo style. Giữ một kết nối SQLite để WAL không phải đóng/checkpoint sau mỗi giao dịch ngắn.
- Trình duyệt chia tải ảnh thành nhóm 12 file/request; không còn giới hạn chọn tổng cộng 50 ảnh. Giới hạn từng ảnh vẫn 20 MB; đã bỏ trần megapixel tối đa. Tải và lập chỉ mục có thể mất lâu hơn chuyển style; ảnh rất lớn cần đủ RAM và dung lượng trống.

## Kết quả đo cùng độ phân giải

5 ảnh nhóm có sẵn trên máy, mỗi cấu hình 2 lượt, Mosaic, độ đậm 65%. Tính cả JPEG decode, resize, suy luận, blend và PNG encode trong RAM; không tính model cold start, HTTP, ghi output/SQLite hoặc cache kết quả. Thứ tự PyTorch/OpenVINO được luân phiên giữa hai lượt. Số đo là median trên 10 lần xử lý/cấu hình.

| Cạnh dài | PyTorch CPU | OpenVINO CPU | Tăng tốc cùng kích thước |
|---|---:|---:|---:|
| 512 px, PNG mức 1 | 1,171 s/ảnh | 0,435 s/ảnh | 2,69 lần |
| 1024 px, PNG mức 1 | 3,773 s/ảnh | 1,428 s/ảnh | 2,64 lần |
| 512 px, PNG mức 6 | 1,132 s/ảnh | 0,456 s/ảnh | 2,48 lần |

Sai lệch trung bình lớn nhất trên một ảnh giữa hai runtime ở cùng kích thước là 0,00102 mức màu trên thang 0–255 (sau blend/uint8). Đây là kiểm tra tương đương runtime trên tập nhỏ, không phải đánh giá thẩm mỹ hoặc accuracy nhận diện.

Luồng trình duyệt thật: **5/5 ảnh, 0 lỗi, 0 cache hit, 2,718 giây**, tương đương 1,839 ảnh/giây cho lô này ở 512 px, bao gồm lưu PNG/SQLite. ZIP đã mở kiểm tra đủ 5 PNG, kích thước 512×341 (3 ảnh), 512×277 và 512×288. Lần tạo một ảnh đầu tiên sau nạp server mất 5,96 giây do cold start; không dùng thời gian ấm để hứa mọi lần đều nhanh như nhau.

Máy còn chạy các ứng dụng khác nên số đo dao động. Chưa đo trên chip NPU/FPGA, thiết bị ARM hoặc lô 10.000 ảnh thật. Hàng đợi 200 ảnh đã kiểm thử với model giả để xác nhận điều phối/lưu kết quả, không dùng phép thử đó để công bố tốc độ ML. Đây chưa phải pipeline video 30 FPS.

## Kiểm tra sau đợt audit

Sau khi cập nhật Pillow 12.3.0 và fingerprint xử lý, đã chạy lô **68 ảnh thật** từ giao diện: Mosaic 75%, profile fast 512 px, **68/68 hoàn tất, 0 lỗi, 0 cache hit, 21,866 giây (3,11 ảnh/giây)**. Model OpenVINO đã nạp; thời gian worker gồm decode/resize/inference/blend/encode và lưu output/SQLite, không gồm upload/lập chỉ mục/đóng ZIP hoặc cold start. ZIP 34.516.064 byte được kiểm tra CRC và decode đủ 68 PNG; cạnh dài tối đa 512.

Đây là tập ảnh khác và lần đo khác với bảng 5 ảnh ở trên; không dùng để suy ra tỷ lệ tăng tốc mới so với PyTorch. Bộ số đo cùng độ phân giải trong bảng là baseline trước cập nhật Pillow. Cache model/kết quả mới có cả phiên bản xử lý/Pillow, do đó lần đầu có thể cần compile lại. Báo cáo mới: `artifacts/audit/live-system.json`. Xem [kiểm toán](SYSTEM_AUDIT.vi.md) và [tiêu chuẩn nghiệm thu](QUALITY_STANDARD.vi.md).

## Cách dùng

Mở Phòng sáng tạo → chọn một trong 4 preset → chọn Nhanh 512 / Cân bằng 768 / Chi tiết 1024 → **Tạo ảnh nghệ thuật** hoặc **Tạo style cả album**. Kết quả lô có ở Hàng đợi của bạn; nút ZIP tải các ảnh đã hoàn tất và báo cáo. Có thể dùng API `photo_ids` để chọn một phần album.

Chatbot vẫn chọn preset và độ đậm theo mô tả. Nếu muốn một phong cách mới từ API ảnh rồi NST VGG19, luồng đó vẫn cần thời gian gọi mạng và tối ưu nhiều bước; chưa được đưa vào chế độ nhanh cả album. Không tự đổi một yêu cầu style mới thành preset rồi báo đã tạo đúng mô tả.

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements-cpu.txt
.\.venv\Scripts\python.exe scripts/prepare_cpu.py
.\.venv\Scripts\python.exe scripts/benchmark_cpu.py --images runtime/photos --limit 5 --rounds 2
```

`FSM_STYLE_BACKEND=auto|torch|openvino` (mặc định auto), `FSM_STYLE_THREADS=4` cho OpenVINO; `FSM_TORCH_THREADS=4` cho PyTorch. `prepare_cpu.py` chỉ chuẩn bị preset; benchmark đọc ảnh cục bộ, không gửi ảnh ra ngoài và không tạo tác phẩm trong album. Chi tiết số đo ở `artifacts/performance/after.json`, `live-bulk.json` (không nằm trong source ZIP).

API: `POST /api/stylize` nhận thêm form `profile`; `POST /api/stylize/from-chat` nhận thêm JSON `profile`; `POST /api/stylize/batch` nhận `{album_id, photo_ids?, style, strength, profile}`. Theo dõi bằng `GET /api/jobs/{id}` hoặc `GET /api/batches`; `POST /api/batches/{id}/cancel`, `/resume`; `GET /api/batches/{id}/download`.
