# Chọn trợ lý và tạo phong cách — 16/10/2026

Mở Hỏi trợ lý → Nguồn trợ lý. Hai lựa chọn chính luôn hiển thị:

Sửa kết nối ngày 16/10: nhập key → **Lưu và kiểm tra** (hoặc Enter). App báo đang xử lý, gửi [yêu cầu metadata model](https://ai.google.dev/api/models#method:-models.get) với key trong header, không tạo ảnh hay gửi hội thoại. Thành công mở chat và hướng dẫn nhập tin nhắn. Lỗi key/model/mạng hiện ngay trong bảng cài đặt; key đã lưu vẫn ở RAM để thử lại. Kiểm tra metadata không chứng minh tài khoản còn hạn mức tạo nội dung hoặc ảnh. Có nút Về chat để đóng cài đặt. Phiên bản JavaScript được đánh số để tránh dùng file cũ từ cache.

Sửa định dạng key: bỏ bộ lọc chỉ cho chữ/số/gạch dưới/gạch ngang vốn chặn dấu chấm. Nhận key chuẩn AIza… và auth key AQ.…, tối đa 4096 ký tự; dấu chấm và ký tự token được giữ nguyên. Tự bỏ dấu nháy bao ngoài, khoảng trắng/ký tự vô hình ở hai đầu, hoặc nhãn GEMINI_API_KEY=/GOOGLE_API_KEY= khi dán. Khoảng trắng ở giữa, CR/LF chèn header và chuỗi quá dài vẫn bị từ chối. Key AQ. cũng bị che trong tin nhắn và phản hồi. [Google mô tả hai loại key](https://ai.google.dev/gemini-api/docs/api-key), [xác nhận chuyển sang auth key trên diễn đàn Google](https://discuss.ai.google.dev/t/please-restore-standard-key-generation-for-my-account/169946).

Về miễn phí: theo [bảng giá Google](https://ai.google.dev/gemini-api/docs/pricing), Gemini 3.5 Flash-Lite có Free Tier cho văn bản với hạn mức riêng; Nano Banana 2 Lite không có Free Tier API. Có key không đồng nghĩa mọi model hoặc tác vụ tạo ảnh đều miễn phí. Có thể dùng Gemini để trò chuyện trong hạn mức và NST cục bộ (preset, tranh có sẵn hoặc tranh người dùng tải lên) để tránh gọi API tạo ảnh. Đây không phải cam kết tài khoản cụ thể được cấp quota.

| Nguồn | Thiết lập | Dữ liệu xử lý |
|---|---|---|
| Qwen · trên máy | Qwen3-1.7B GGUF Q8 đã tải; máy mới chạy `scripts/fetch_chat_cpu.py` | Hội thoại ở máy, worker llama.cpp chỉ nghe loopback và có token; không có công cụ đọc ảnh |
| Gemini · API | Key của bạn từ [Google AI Studio](https://aistudio.google.com/apikey); nhập ở Cài đặt trợ lý, chọn model và Kết nối Gemini | Văn bản hội thoại gửi Google; không gửi ảnh nguồn, album hay embedding |

Key giữ trong RAM backend của phiên chạy, dùng chung cho các tab nối cùng server local; không phải tài khoản nhiều người dùng. Không dán key vào chat. Đổi nguồn xóa lịch sử trong tab để không chuyển tiếp hội thoại cũ sang dịch vụ mới. Mỗi yêu cầu cũng ghi rõ provider, nên tab Qwen không tự chuyển sang Google khi tab khác đổi lựa chọn. API lỗi được hiển thị, không tự chuyển qua nhà cung cấp khác. Xóa key Gemini quay về Qwen; restart làm mất key đã nhập qua UI. Biến môi trường GEMINI_API_KEY được đọc lại khi khởi động.

Model chat mặc định `gemini-3.5-flash-lite`, lựa chọn khác `gemini-3.8-flash`. Model ảnh: `gemini-3.1-flash-lite-image`, `gemini-nano-banana-2.1`, `gemini-3.1-flash-image`. Đối chiếu [danh mục Google](https://ai.google.dev/gemini-api/docs/models) ngày 16/10/2026. Quyền dùng và hạn mức phụ thuộc tài khoản; không có key miễn phí được cấp kèm app. [Hướng dẫn quản lý key của Google](https://ai.google.dev/gemini-api/docs/api-key).

## Pipeline

1. Chọn nguồn → gửi mô tả phong cách. Qwen chọn preset bằng công thức được kiểm tra; trường hợp cần tham chiếu, Qwen tư vấn tải tranh lên. Công thức sai schema dùng gợi ý có sẵn và gắn nhãn rõ. Gemini trả JSON theo schema và được Pydantic kiểm tra lại; công thức sai bị từ chối.
2. Đề xuất có ba nhánh: preset cục bộ, tranh tham chiếu có sẵn, hoặc ảnh tham chiếu tạo mới qua API. Chỉ lập đề xuất thì chưa tạo ảnh.
3. Chọn ảnh và bấm Tạo ảnh theo mô tả. Preset dùng Fast NST/OpenVINO; tranh/API dùng VGG19 tối ưu ảnh đầu ra trên máy. API ảnh chỉ nhận mô tả texture trừu tượng. Không gửi ảnh người dùng để chỉnh sửa trên Google/OpenAI.
4. Ghi tác phẩm PNG và công thức, giữ nguyên ảnh nguồn. Xóa ảnh tham chiếu tạm khi xong hoặc lỗi. Công thức nhớ provider đã chọn, tránh tạo ảnh bằng một dịch vụ khác sau khi người dùng đổi nguồn chat. Bấm lại cùng đề xuất/ảnh dùng cùng tác vụ để tránh gọi trùng.

“phong cách tranh của vangot”, “Van Gogh”, “vangogh” và “van got” nhận thành Van Gogh. Qwen dùng quy tắc xác định rõ cho trường hợp này, nhãn Tranh tham chiếu có sẵn, không giả là kết quả suy luận từ model. Tranh [Wheat Field with Cypresses](https://www.metmuseum.org/art/collection/search/436535) của Vincent van Gogh có `isPublicDomain=true` trong [Met API](https://collectionapi.metmuseum.org/public/collection/v1/objects/436535). Ảnh tải một lần, khóa SHA-256 trong `fsmart/artworks.py`; thiếu/hỏng thì báo lỗi, không tải URL từ chat. Máy mới: `python scripts/fetch_assets.py --only artworks`. VGG19 512 px, mặc định 50 bước; chậm hơn nhiều so với preset, không phải model Van Gogh riêng và không cam kết bảo toàn chi tiết mặt.

## Kiểm chứng

152 ca hồi quy qua toàn bộ suite; thêm 8 ca kiểm tra ảnh Gemini hỏng, lỗi mạng/giải phóng semaphore và tranh sai checksum. Bản sửa nút kết nối kiểm tra lại 83 ca chat/style và thêm 7 ca xác minh kết nối (90 ca đều đạt). Thử UI ô trống, key sai định dạng, key bị từ chối, Enter kết nối và gửi tin nhắn đều cho phản hồi; API ở QA được giả lập. Không tiêu hạn mức và không kiểm chứng key hay tốc độ Google thật. Đã chạy Qwen thật; ca hỏi vị trí tách chủ thể trả lời đúng trong 12.168 giây khi máy đang chạy kiểm thử. Thời gian này là một ca thử, không phải SLA.

Luồng trình duyệt “phong cách tranh của vangot” → chọn astronaut công khai → Tạo ảnh theo mô tả đã chạy VGG19 thật: 512×512, 50 bước, độ đậm 65%, 271.914 giây trên CPU máy này. Nét cọ có thay đổi, khuôn mặt vẫn có thể biến dạng; không coi đây là chất lượng Van Gogh đã được chấm độc lập. Cần thao tác nhanh hoặc xử lý lô thì dùng bốn preset, không dùng VGG19 tối ưu từng ảnh. Kết quả thử ở `artifacts/ui/van-gogh-real.png`, không đưa ảnh vào ZIP nguồn.

Ứng dụng dành cho máy local, chưa có xác thực nhiều tài khoản hay phân quyền kho ảnh. Chỉ dùng loopback như cấu hình mặc định.
