# Tiêu chuẩn nghiệm thu cho các thay đổi tiếp theo

Mỗi thay đổi phải có vấn đề cụ thể, hành vi mong muốn, bằng chứng trước/sau và giới hạn còn lại. Không dùng “không thấy lỗi”, “model uy tín”, “84 test đạt” hoặc số mặt phát hiện để thay cho kiểm định chất lượng sản phẩm.

## Quy trình bắt buộc trong dự án

1. Tái hiện lỗi hoặc đo baseline trước khi sửa; ghi input, môi trường và điều kiện cache. Với lỗi logic quan trọng, viết test thất bại trước.
2. Sửa phạm vi cần thiết; giữ source ảnh, model key và khả năng phục hồi. Không tự hạ ngưỡng, giảm độ phân giải hoặc dùng lại cache để làm đẹp số đo.
3. Chạy test phù hợp với phần sửa; dùng dữ liệu tạm cho hỏng/xóa file, không phá dữ liệu thật. Test phải đo hành vi, tránh lặp lại cách viết của hàm.
4. Chạy model thật cho các đường ML thay đổi; mở output thật, kiểm tra kích thước, tính đọc được và ảnh hưởng nội dung. Test giả lập chỉ chứng minh logic điều phối.
5. Thử toàn bộ luồng ở trình duyệt: chọn → xử lý → theo dõi → xem → tải → mở file; kiểm tra đổi ảnh, tải lại trang, lỗi mạng, bàn phím và bố cục liên quan.
6. Báo cáo đạt/chưa đạt theo tiêu chí dưới đây. Không công bố chức năng đã được kiểm định nếu nhánh quan trọng còn chưa chạy.

## Tiêu chí theo thành phần

| Thành phần | Phải kiểm tra | Chặn nghiệm thu khi |
|---|---|---|
| Upload | Sai định dạng, byte/pixel lớn, EXIF, trùng, disk thấp; download raw đúng byte | Mất raw, đổi hướng sai, tạo metadata/file dở không có cách phát hiện |
| Index mặt | Nhiều/không mặt, lỗi một ảnh, pipeline key, gián đoạn và phục hồi | Mất phần hoàn tất, trộn vector khác model, báo ready khi việc chưa xong |
| Search | Gộp theo ảnh, top-K, threshold, vector NaN/zero/sai chiều, album cách ly | Sai ảnh/album, lỗi 500 do dữ liệu hỏng, dùng key không khớp |
| Style | Preset/profiles, giữ tỷ lệ, blend, model lỗi, atomic output, checksum | Dùng PNG hỏng, kết quả gắn ảnh khác, thay ảnh đầu vào bằng ảnh giả |
| Queue | Giới hạn, đồng thời, lỗi từng ảnh, dừng/tiếp tục/đóng, idempotency | Lô lỗi toàn bộ báo thành công, vượt admission, mất tiến độ hoặc gọi API tiền lặp |
| Export | Đủ file/manifest, CRC, decode ảnh, Range của URL nguồn, RAM/disk có giới hạn | ZIP thiếu file mà báo đủ, source JPEG cũ được gọi byte-original |
| Chat | Schema, kế hoạch bất biến, timeout, lỗi model/API, chi phí và chế độ rõ | Mock được trình bày như API thật; preset bị gọi là style bất kỳ đã tái tạo chính xác |
| UI | Nhãn, disabled/busy, focus, reload, đổi lựa chọn giữa job, 430/1440 px | Gắn nhầm kết quả, bấm lặp tạo việc trùng, che lỗi hoặc tiến độ giả |
| Phát hành | Kiểm tra dependency, source ZIP, cấu hình local, artifact riêng | Chứa API key/ảnh/embedding/model riêng hoặc có test bắt buộc còn lỗi |

## Đánh giá nhận diện

Cần danh sách query có ground truth gallery, bao gồm người lạ, mặt nhỏ/nghiêng/che/mờ và ảnh nhiều người. Tách buổi chụp giữa query và gallery. Khi có đủ người, tách danh tính calibration/test. Tránh dùng crop hoặc biến thể của cùng ảnh làm test độc lập.

Chọn ngưỡng trên validation theo false-match mục tiêu, khóa ngưỡng trước test. Báo Precision@K, Recall@K, mAP@K, người lạ vẫn trả ảnh, detection failure và latency theo kích thước kho. Ghi model key, checkpoint/revision, preprocessing và số người/query. Không so sánh AdaFace/FaceNet ở cùng một ngưỡng tùy ý.

Chưa có ground truth của album hiện tại nên chưa đặt con số accuracy đạt/chưa đạt. Nhóm phải chọn yêu cầu sử dụng rồi đặt mức chấp nhận trước khi xem kết quả test. Script sẵn có: `scripts/benchmark.py`, `scripts/evaluate.py`; manifest mẫu `data/benchmark.example.json`.

## Đánh giá tốc độ và khả năng chịu tải

Đo cold start riêng; đo warm inference không cache riêng; đo cache riêng. So sánh runtime với cùng ảnh, preset, strength, pixel và encode. Ghi thời gian decode/inference/encode/lưu/đóng ZIP khi có thể; báo median và p95 sau đủ lượt, kèm RAM cực đại/disk, lỗi và cấu hình CPU/GPU.

Một lô 68 ảnh không đủ kết luận tốc độ ổn định hoặc 10.000 ảnh. Test hàng đợi 200 ảnh giả không đo ML. Muốn nghiệm thu quy mô lớn: tăng số ảnh thật có kiểm soát, theo dõi RSS, độ trễ API tương tác, disk growth và chất lượng output; chạy soak, dừng/tiếp tục và restart giữa chừng trên bản sao dữ liệu.

Chưa lượng tử hóa INT8; nếu bổ sung phải đo sai lệch và chất lượng, không chỉ throughput. Không hứa NPU/FPGA/ARM khi chưa chạy đúng phần cứng.

## Lệnh tái kiểm tra

```powershell
$env:TEMP = 'D:\prjdpl\.cache\tmp'
$env:TMP = $env:TEMP
.\.venv\Scripts\python.exe -m pytest -q --basetemp .cache/pytest-manual --junitxml artifacts/audit/manual.xml
.\.venv\Scripts\python.exe -m pip check
.\.venv\Scripts\python.exe scripts/audit_live.py
.\.venv\Scripts\python.exe scripts/package_source.py
```

Thư mục TEMP phải tồn tại; `--basetemp` có thể bị pytest dọn nên chỉ trỏ tới thư mục test dùng riêng. `audit_live.py` yêu cầu server local đang chạy và lô gần nhất đã hoàn tất. Kiểm tra UI bằng trang Hệ thống và thao tác thực tế; XML/JSON không thay kiểm tra trực quan.

Báo cáo mỗi lần phát hành phải ghi: thay đổi, lỗi trước sửa, test/model thật/UI đã chạy, số đo có điều kiện, rủi ro còn lại và cách quay lại bản sao nếu thay đổi dữ liệu. Không dọn ổ hoặc xóa dữ liệu ngoài phạm vi dự án để làm test qua.
