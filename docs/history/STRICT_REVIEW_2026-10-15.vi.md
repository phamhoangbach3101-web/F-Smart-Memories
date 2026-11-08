# Kiểm tra và nâng cấp ngày 15/10/2026

Ba yêu cầu được xử lý: rà soát nghiêm khắc và thêm tiện ích; cài chatbot thật; thu gọn Studio và sửa chọn mẫu không đổi ảnh.

Cập nhật 16/10: đã thêm menu Qwen / Gemini API và tranh Van Gogh cục bộ. [Hướng dẫn hiện tại](CHAT_PROVIDERS.vi.md) thay thế mô tả thiếu Gemini trong báo cáo lịch sử bên dưới.

## Phát hiện và xử lý

| Vấn đề tái hiện | Thay đổi | Kiểm chứng |
|---|---|---|
| Chọn Udnie sau khi thử màu vẫn thấy bản màu cũ | Preview NST 512 px chạy thật; cache LRU 16; số phiên yêu cầu + AbortController chặn kết quả cũ; 429 khi model bận | API ba preset cho SHA khác nhau; UI Noir → Candy → Udnie hiện đúng Udnie |
| Ảnh cao, màu ở khối riêng, kéo trang liên tục | Canvas giới hạn theo viewport; tab Nghệ thuật/Màu ảnh/Chủ thể; tiêu đề gọn; hàng đợi/lịch sử thu mở | Desktop 1440×950, nút tạo và tạo lô cùng trong viewport; kiểm tra mobile riêng |
| DELETE cũ xóa thẳng file | Chuyển vào Thùng rác, giữ nguồn/tác phẩm/recipe/mask, ẩn khỏi truy vấn active; purge vẫn cần xác nhận riêng | Test delete → ảnh/mask ẩn → restore dùng lại → purge xóa metadata và file |
| Origin lỗi gây 500, trang ngoài có thể gọi GET API local | Parse Origin có xử lý lỗi; từ chối Sec-Fetch-Site cross-site, CORP same-origin, Permissions-Policy | Test Origin khác, null, sai cú pháp, header cross-site trả 403 |
| FAQ không phải model chat | Cài Qwen3-1.7B GGUF Q8 chính chủ, worker llama.cpp CPU được kiểm checksum; 4 luồng, context 4096, một hội thoại xử lý tại một thời điểm | Câu hỏi tiếng Việt và JSON style thực; schema sai dùng gợi ý có sẵn, gắn nhãn rõ |
| Bản INT8 động PyTorch trả lời sai/lạc đề | Loại khỏi ứng dụng; dùng GGUF từ Qwen và runtime llama.cpp chính thức | Đối chiếu câu trả lời thực; không đánh đồng tải model với chất lượng đạt |

## Tiện ích mới: chọn chủ thể

Ảnh xử lý cục bộ → thu cạnh dài tối đa 1024 px → tối đa 12 điểm +/− → Meta SAM 2.1 Tiny → ba mask ứng viên, xếp theo điểm dự đoán của model → người dùng chọn và sửa điểm → blend biên → lưu PNG mới tối đa 2048 px. Điểm dự đoán không phải độ chính xác đã đo. Preview overlay có màu xanh; PNG trong suốt hiển thị trên nền ô để không bị ảnh gốc phía dưới che mất kết quả.

Hiệu ứng: tách PNG nền trong suốt; chủ thể có màu trên nền đen trắng; làm mờ nền; giữ chủ thể trên nền tác phẩm nghệ thuật đã lưu của cùng ảnh. Dùng điểm + trên các phần cần giữ và − ở vùng thừa, không mặc định coi mask đầu tiên là đúng. Chưa có tô mask bằng cọ hay xử lý SAM hàng loạt. Tóc mảnh/kính/vật thể chồng nhau vẫn cần kiểm tra bằng mắt.

Mask lưu SQLite và file PNG có SHA-256, gắn digest ảnh nguồn, điểm và revision model. Lưu tác phẩm có recipe nguồn/mask/effect. Thùng rác giữ mask; xóa vĩnh viễn dọn mask; kiểm tra toàn vẹn kiểm checksum mask. Không sửa ảnh nguồn.

## Chat và sáng tạo

Văn bản → lấy hướng dẫn đúng chủ đề → Qwen chạy trên CPU → câu trả lời. Mô tả style → Qwen đề xuất preset/độ đậm → Pydantic kiểm enum/range → plan ID có thời hạn → người dùng chọn ảnh và bấm tạo → NST cục bộ → PNG + recipe. Model không có công cụ, không tự xóa ảnh, không truy cập album/ảnh/khuôn mặt và không chạy lệnh. Hội thoại chỉ trong tab; worker loopback có token ngẫu nhiên giữ trong RAM. API key thật không đóng gói.

Qwen local giúp hỏi đáp và chọn bốn preset; không sinh mọi phong cách tùy ý. Phong cách mới ngoài preset cần ảnh style tự tải lên cho VGG19 hoặc OpenAI Images API đã có trong app, yêu cầu key/hạn mức riêng. Đã chọn nhánh “tải model chatbot” trong yêu cầu “model hoặc Gemini key”. Không tự cấp, thu gom hay dùng key Gemini của người khác; Gemini chưa được nối như một provider trong bản này.

Máy mới Windows x64: `./setup.ps1 -WithLocalChat -WithSubjectTools`; riêng model: `scripts/fetch_chat_cpu.py` (~1.88 GB cả runtime), `scripts/fetch_segmentation.py` (~156 MB). Máy hiện tại đã tải. Khi tải SAM cần requirements-semantic.txt; không chạy source `.py` từ repo model, dùng safetensors và `trust_remote_code=False`. Chat dùng GGUF dữ liệu và binary từ release chính thức đã kiểm hash, không dùng INT8 thử nghiệm.

## Đo thực tế và giới hạn

Ảnh công khai astronaut 512×512, i7-13620H, 4 luồng; không suy ra tốc độ bộ ảnh lớn hoặc accuracy:

- Preview Candy đầu tiên: 2.502 s; Mosaic 0.292 s; Udnie 0.334 s. Ba checksum khác nhau. Cache giới hạn, không tạo lịch sử tác phẩm.
- SAM lần đầu 5.779 s; lần đã nạp, thêm điểm khác qua UI: 1.691 s. Ba vùng cho người dùng chọn.
- Chat GGUF lần kiểm tra hướng dẫn theo chủ đề: khôi phục ảnh 5.984 s (có nạp), làm mờ nền 4.643 s. Có thể chậm hơn với hội thoại dài hoặc CPU đang bận. Model nhỏ vẫn có thể trả lời sai; chưa có benchmark độ đúng độc lập.

Ảnh/metadata thật phải đối chiếu manifest trước/sau và chạy kiểm tra toàn vẹn sau khi khởi động lại. Các thao tác thêm ảnh, tách chủ thể và lưu hiệu ứng trong QA dùng kho `.cache/collections-ui-runtime` riêng. Không dùng ảnh thật để thử xóa/purge. Kết quả pytest cuối, UI và dữ liệu được ghi ở `artifacts/strict-final.json`/ảnh `artifacts/ui/` trên máy; artifacts cá nhân không nằm trong ZIP nguồn.

## Đánh giá thẳng

Đủ nền tảng cho ứng dụng cá nhân chạy local và demo nhóm có thao tác kiểm chứng. Chưa phải SaaS: thiếu tài khoản, quyền theo album, đa người dùng và vận hành Internet. Nhận diện/tìm nội dung chưa có bộ dữ liệu độc lập gán nhãn để chốt accuracy. SAM cần kiểm vùng; Qwen nhỏ không thay thế model lớn và có thể bịa. Không dùng chữ “hoàn hảo” để thay kiểm thử.

Nguồn: [Meta SAM 2.1](https://huggingface.co/facebook/sam2.1-hiera-tiny), [Transformers SAM 2](https://huggingface.co/docs/transformers/model_doc/sam2), [Qwen GGUF chính chủ](https://huggingface.co/Qwen/Qwen3-1.7B-GGUF), [llama.cpp](https://github.com/ggml-org/llama.cpp).


## Kết quả chốt bản chạy

130 bài pytest đạt (49.67 s), không có bài lỗi; một cảnh báo deprecation từ Starlette/httpx. Tất cả JavaScript và setup.ps1 qua kiểm tra cú pháp. Kho thật: 68 ảnh, 453 vector mặt, 90 tác phẩm, 0 ảnh lỗi/đang chờ/thùng rác; kiểm tra toàn vẹn đạt, id/bộ ảnh/digest của 68 ảnh khớp manifest trước khi nâng cấp. Ba tác phẩm Mosaic thêm sau bản backup cũ được giữ lại; không suy ra rằng số tác phẩm chưa thay đổi.

UI thực đã thử Noir → Candy → Udnie, ba mask SAM → chọn vùng 2 → lưu PNG, chat Qwen tiếng Việt trên cổng 8000 và nút Tạo ảnh theo mô tả. Không phát hiện lỗi JavaScript trong log của hai tab được kiểm tra. Mobile 430×900 không tràn ngang; ảnh nằm trước công cụ. Chat qua UI nạp lần đầu và trả lời khôi phục trong 7.844 s. Đây là kết quả ca thử, không phải cam kết SLA hoặc accuracy.
