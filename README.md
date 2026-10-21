# F-Smart Memories

Ứng dụng local tổ chức bộ ảnh, tìm ảnh bằng mô tả hoặc khuôn mặt và tạo phiên bản nghệ thuật. Giao diện tiếng Việt, backend FastAPI, SQLite FTS5, Google SigLIP 2; neural style transfer có backend OpenVINO tăng tốc CPU.

**Trong workspace hiện tại đã cài thư viện và tải trọng số.** Chạy:

Nâng cấp thư viện 15/10/2026: **117 kiểm thử đạt**. Google SigLIP 2 đã lập chỉ mục **68/68 ảnh trong 34,327 giây**; tìm câu tiếng Việt khi model đã nạp có trung vị **0,060 giây** trên máy hiện tại. Xem [cách dùng, database, pipeline và giới hạn](docs/MODERN_UPGRADE.vi.md) cùng [repo/model chính chủ đã đối chiếu](research/TRUSTED_REPOS.vi.md). Số đo tốc độ không thay thế đánh giá độ chính xác trên tập độc lập.

Cách dễ nhất trên Windows: mở thư mục `D:\prjdpl` và nhấp đúp **`Chay-FSmart.cmd`**. Cửa sổ sẽ hiện tiến trình khởi động; trình duyệt mặc định tự mở khi server sẵn sàng. Nếu app đã chạy, trình chạy chỉ mở trình duyệt, không tạo server trùng. Hoặc chạy PowerShell:

```powershell
.\run.ps1
```

Mở [http://127.0.0.1:8000](http://127.0.0.1:8000). Nếu cổng đang được dùng, mở ứng dụng đang chạy hoặc dùng `.\run.ps1 -Port 8001`.

## Chức năng đã triển khai

- Tìm nội dung bằng mô tả tiếng Việt và tìm ảnh tương tự với Google SigLIP 2 chạy cục bộ; chỉ mục tăng dần, dùng lại embedding sau khi khởi động lại.
- Yêu thích từng ảnh/nhiều ảnh, nhãn và ghi chú lưu SQLite; tìm toàn văn không phân biệt dấu thanh, lọc khung ảnh/số mặt, sắp xếp và phân trang.
- Trình xem ảnh lớn có thông tin và phím ← → / F / E / Esc; bảng tìm thao tác Ctrl K.
- Sáu lựa chọn màu gồm nguyên bản, Cinema, Soft film, Noir, Nordic, Golden hour: preview 640 px, lưu bản mới tối đa 2048 px, áp dụng trên ảnh hoặc tác phẩm; có công thức và checksum. Đây là xử lý màu bằng Pillow, tách biệt NST.
- Thư viện nhiều bộ ảnh có ảnh bìa, tìm tên, tạo/đổi tên bộ; tải nhiều ảnh, bỏ qua ảnh trùng, lưu metadata và thumbnail.
- Trong mỗi bộ có bốn mục: Ảnh, Tìm khuôn mặt, Sáng tạo và Thùng rác. Chuyển nhiều ảnh sang bộ khác hoặc tạo bộ mới từ lựa chọn.
- Bảng chọn ảnh trong Sáng tạo/chat có thumbnail, tìm theo tên, xem trước khi rê chuột hoặc dùng bàn phím, hỗ trợ màn hình nhỏ.
- Xóa từng ảnh/nhiều ảnh vào Thùng rác, Hoàn tác và khôi phục cùng dữ liệu mặt/tác phẩm; xóa vĩnh viễn cần xác nhận riêng.
- Phát hiện nhiều mặt bằng MTCNN; alignment 5 landmark và embedding AdaFace IR50 pretrained WebFace4M.
- Chọn mặt trong ảnh tham chiếu; tìm bằng cosine, gộp các mặt cùng ảnh thành một kết quả.
- Bốn preset Fast Neural Style: Candy, Mosaic, Rain Princess, Udnie; OpenVINO CPU FP32 hoặc PyTorch CPU/CUDA.
- Mức nhanh 512 / cân bằng 768 / chi tiết 1024 px; chạy cả album, lưu tiến độ, dừng/tiếp tục, cache và ZIP kết quả.
- Tải ảnh style bất kỳ: NST tối ưu ảnh đầu ra bằng VGG19 pretrained, không train lại backbone.
- Chỉnh cường độ, xem trước/sau, tải PNG và ZIP ảnh gốc; lưu lịch sử tác phẩm.
- Tác vụ nền có tiến độ; dữ liệu giữ trong SQLite sau khi khởi động lại.
- Công cụ đánh giá retrieval và hiệu chỉnh ngưỡng; có baseline FaceNet tùy chọn.
- Trợ lý nổi có menu Qwen trên máy / Gemini API, hỗ trợ hỏi đáp và mô tả phong cách; OpenAI vẫn là tùy chọn thêm.
- Chọn nhiều ảnh bằng checkbox, chạy style phần đã chọn, đổi tên album; lịch sử tác phẩm có phân trang theo album.
- Trang Hệ thống: CPU/backend/dung lượng và tác vụ thật; kiểm tra toàn vẹn DB, ảnh, checksum, embedding; khôi phục thumbnail hỏng.
- Upload mới giữ nguyên byte file nguồn cùng checksum, tách riêng preview xử lý. Ảnh từ bản cũ chỉ có JPEG đã lưu được ghi rõ trong manifest.
- Queue index/batch có journal theo từng ảnh; chống gửi lặp job, kiểm tra cache hỏng, giới hạn công việc và chặn khi thiếu dung lượng.

Đợt kiểm toán 15/10/2026: **84 test đạt**; lô thật **68/68 ảnh, 0 lỗi, 0 cache, 21,866 giây** ở 512 px trên i7-13620H/OpenVINO CPU đã nạp model. ZIP được mở kiểm tra đủ PNG/CRC. Đây là phép đo trên lô cụ thể, không chứng minh accuracy nhận diện hoặc tốc độ trên mọi máy. Xem [báo cáo và pipeline](docs/SYSTEM_AUDIT.vi.md), [tiêu chuẩn nghiệm thu](docs/QUALITY_STANDARD.vi.md) và [so sánh CPU](docs/CPU_PERFORMANCE.vi.md).

Đây là prototype cho máy cá nhân. Server mặc định chỉ lắng nghe `127.0.0.1`; chưa có đăng nhập hoặc phân quyền nhiều người. Ảnh và embeddings nằm trong `runtime/`; không đưa thư mục này vào Git, source ZIP hoặc chia sẻ công khai. Cửa sổ chạy thường phải giữ mở. Chạy nền tùy chọn: `.\.venv\Scripts\python.exe scripts/launch.py --background --no-browser`; log ở `runtime/logs/`. Nếu tiến trình bị ứng dụng chủ/hệ điều hành dừng, chạy launcher lại.

## Cài trên máy Windows khác

Cần Python 3.10–3.12, Internet khi cài/tải model. CPU đủ chạy preset và demo; GPU giúp tăng tốc, đặc biệt NST tùy chọn.

```powershell
.\setup.ps1 -Python 'C:\duong-dan\python.exe'
.\run.ps1
```

Cũng có thể chạy các lệnh trực tiếp trong terminal nếu chính sách máy không cho chạy file `.ps1`:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt -r requirements-dev.txt
.\.venv\Scripts\python.exe -m pip install -r requirements-ml.txt --index-url https://download.pytorch.org/whl/cpu
.\.venv\Scripts\python.exe scripts/fetch_assets.py
.\.venv\Scripts\python.exe -m uvicorn fsmart.app:app --host 127.0.0.1 --port 8000
```

`requirements-ml.txt` là cặp phiên bản đã kiểm thử tại máy này: torch 2.8.0 + torchvision 0.23.0. Khi dùng GPU, cài wheel CUDA tương ứng theo [PyTorch](https://pytorch.org/get-started/locally/); không dùng wheel CPU nếu muốn CUDA. Kaggle dùng sẵn torch/torchvision của session trước khi cân nhắc cài lại.

Linux/macOS: thay `.venv\Scripts\python.exe` bằng `.venv/bin/python`; các lệnh Python còn lại giống nhau. Chưa chạy kiểm thử trên hai hệ điều hành này.

Sau nâng cấp bộ ảnh và Thùng rác: **102 test đạt**, đã thao tác trình duyệt trên dữ liệu thử riêng, kiểm tra bảng chọn ảnh ở 430 px/1440 px và đối chiếu nguyên 68 ảnh hiện có. Xem [hướng dẫn và kiểm nghiệm bản nâng cấp](docs/COLLECTIONS_AND_PHOTO_TOOLS.vi.md).

## Dùng ứng dụng

1. Mở **Thư viện ảnh**, bấm **Tạo bộ ảnh mới**. Mỗi bộ có ảnh bìa và số ảnh riêng; mở bộ để thao tác.
2. Chọn nhiều ảnh; trình duyệt chia nhóm 12 file/request. Mỗi ảnh không quá 20 MB; không áp trần megapixel tối đa. File upload được giữ nguyên byte và độ phân giải, thumbnail được tạo riêng; chờ lập chỉ mục xong.
3. Trong bộ đang mở, bấm **Tìm khuôn mặt**, tải ảnh tham chiếu rồi chọn đúng mặt. Kết quả chỉ thuộc bộ đó. App tự tìm khi đổi mặt/bộ/ngưỡng; ảnh tham chiếu được khôi phục khi tải lại trang.
4. Chọn ảnh trong kết quả hoặc thư viện để mở **Phòng sáng tạo**.
5. Chọn preset hoặc tải ảnh style riêng, tạo ảnh và tải kết quả. Bảng chọn ảnh có thumbnail và xem trước khi rê chuột; bấm **Chọn ảnh này** để dùng.
6. Tích nhiều ảnh để chuyển bộ, tải nguồn, tạo style hoặc xóa. Nút **⌫** trên mỗi ảnh chuyển ảnh vào **Thùng rác**; dùng **Hoàn tác** hoặc mục **Thùng rác → Khôi phục** khi cần.

Điểm cosine không phải xác suất. Ngưỡng mặc định `0.4` là giá trị thử nghiệm, chưa được hiệu chỉnh trên dữ liệu sinh viên FPT. Chưa tìm thấy mặt hoặc không đủ điểm sẽ không được trả thành kết quả chắc chắn.

Preset giữ tỷ lệ ảnh, mặc định cạnh dài tối đa 512px; có thể chọn 768 hoặc 1024px. NST tùy chọn giới hạn 512px, tối ưu 20–300 bước qua API; giao diện cung cấp 50/150/300 bước. Tăng bước không bảo đảm mọi ảnh đều đẹp hơn. Thanh cường độ là phép trộn ảnh gốc và ảnh stylized.

## Tăng tốc CPU và chạy nhiều ảnh

Đã tích hợp OpenVINO CPU. Trên i7-13620H, benchmark cùng kích thước 512 px giảm từ 1,171 xuống 0,435 giây/ảnh; 1024 px từ 3,773 xuống 1,428 giây/ảnh (median, gồm đọc ảnh/encode PNG, chưa tính cold start). Chạy thật cả 5 ảnh qua app hoàn tất trong 2,718 giây, 0 cache hit. Các số này chỉ áp dụng phép đo tại máy này.

Trong Phòng sáng tạo, chọn preset, chọn mức tốc độ rồi bấm **Tạo style cả album**. Mỗi lô tối đa 10.000 ảnh, tối đa 4 lô hoạt động; hàng đợi xử lý từng ảnh, lưu SQLite và phục hồi khi mở lại server. Có nút dừng/tiếp tục và tải ZIP. Phong cách mới dùng API + VGG19 vẫn tạo từng ảnh và chậm hơn.

Cài máy mới bằng `setup.ps1` sẽ cài OpenVINO và chuẩn bị preset; có thể bỏ bằng `-SkipCPUOptimization`. Đọc [chi tiết triển khai, benchmark và giới hạn](docs/CPU_PERFORMANCE.vi.md).

## Chatbot Qwen / Gemini

Bấm **Hỏi trợ lý** ở góc phải. Menu **Nguồn trợ lý** có **Qwen · trên máy** (đã cài, không cần key) và **Gemini · API** (key của bạn từ Google AI Studio). Chọn Gemini, nhập key rồi bấm **Lưu và kiểm tra** hoặc Enter; kết quả kết nối/lỗi hiện ngay. Kiểm tra metadata không tạo nội dung và không xác nhận hạn mức tạo ảnh/chat. Key chỉ giữ trong RAM đến khi tắt server; không ghi vào SQLite, localStorage hay source ZIP. Đổi nguồn bắt đầu hội thoại mới để tránh gửi lịch sử Qwen sang API. [Hướng dẫn và pipeline](docs/CHAT_PROVIDERS.vi.md).

Trong **Phòng sáng tạo**, chọn ảnh rồi bấm **Mô tả phong cách bằng chat**. Nhập ví dụ “Gam ấm, nét cọ dày, đậm 65%”, xem đề xuất và ảnh được chọn, rồi bấm **Tạo ảnh theo mô tả**. App chạy NST, hiển thị trước/sau và trả PNG ngay trong chat. Có thể mô tả tiếp “nhạt hơn” để nhận đề xuất mới. Câu yêu cầu tạo phong cách rõ ràng trong chế độ Hỏi đáp cũng tự chuyển sang luồng này.

Các cách xử lý:

- **Preset sẵn:** trợ lý chọn Candy/Mosaic/Rain Princess/Udnie và độ đậm. Đây là chọn preset gần mô tả. Chạy NST cục bộ, không gọi API ảnh.
- **Van Gogh:** nhận cả cách viết “vangot”; dùng tranh public domain Wheat Field with Cypresses từ The Met đã tải và kiểm SHA-256 → VGG19 cục bộ, không cần key. Đây là chuyển họa tiết/nét cọ từ tranh tham chiếu, không phải model riêng được huấn luyện cho Van Gogh.
- **Phong cách khác:** tải ảnh style làm tham chiếu cho VGG19, hoặc chọn Gemini/OpenAI để lập công thức rồi bấm tạo ảnh texture qua API ảnh. API chỉ nhận văn bản; ảnh gốc xử lý trên máy. Cần quyền/hạn mức model ảnh, chậm hơn preset. NST không hỗ trợ thay mặt/người/bố cục bằng prompt và không bảo đảm giữ nguyên mọi chi tiết mặt.

Gemini mặc định `gemini-3.5-flash-lite`; có thể chọn `gemini-3.8-flash`. Model ảnh mặc định Nano Banana 2 Lite (`gemini-3.1-flash-lite-image`). Các tên model đối chiếu [danh mục chính thức](https://ai.google.dev/gemini-api/docs/models) ngày 16/10/2026. OpenAI nằm trong **⚙ → OpenAI · tùy chọn khác**, giữ hỗ trợ `gpt-5.4-mini` / `gpt-image-1.5`. Bấm **Xóa key Gemini** hoặc **Ngắt GPT** để xóa key tương ứng trong RAM.

Cũng có thể cấu hình bằng biến môi trường trong PowerShell trước khi chạy app:

```powershell
$env:OPENAI_API_KEY = '<key-cua-ban>'
$env:OPENAI_CHAT_MODEL = 'gpt-5.4-mini'  # tùy chọn
$env:OPENAI_IMAGE_MODEL = 'gpt-image-1.5' # tùy chọn
.\run.ps1
```

Không dán key vào tin nhắn chat. Nếu dùng biến môi trường, khởi động lại server sẽ đọc lại key đó; **Ngắt GPT** chỉ ngắt trong phiên server hiện tại. Gói ChatGPT và hạn mức API là riêng biệt; key cần quyền truy cập model và hạn mức API phù hợp.

Backend gọi [OpenAI Responses API](https://developers.openai.com/api/docs/guides/text), dùng `store=false`, giới hạn lịch sử 10 tin nhắn/20.000 ký tự; hỏi đáp tối đa 1.400 token và lập đề xuất tối đa 1.800 token. GPT trả đề xuất bằng [Structured Outputs](https://developers.openai.com/api/docs/guides/structured-outputs?api-mode=responses), được Pydantic kiểm tra lại trước khi cấp ID đề xuất. Chỉ văn bản hội thoại, tên trang, mã style và độ đậm được gửi; không gửi ảnh gốc, tên album, embedding hay file. Lịch sử chat chỉ nằm trong tab. Đề xuất giữ trong RAM server 30 phút, tối đa 64 đề xuất; khởi động lại hoặc hết hạn cần gửi lại mô tả. `store=false` không đồng nghĩa nhà cung cấp không có bất kỳ chính sách lưu giữ dữ liệu nào.

[Images API](https://developers.openai.com/api/docs/guides/image-generation) chỉ được gọi khi người dùng bấm tạo ở đề xuất phong cách mới; mỗi lần yêu cầu một ảnh tham chiếu 1024×1024, quality low, PNG. Ảnh gốc luôn xử lý trên máy. Server không dùng URL ảnh từ model để tải file, chỉ nhận base64 có kiểm tra định dạng/kích thước, và xóa ảnh tham chiếu tạm sau tác vụ. Tiêu đề phong cách được lưu cùng tác phẩm trong SQLite; không lưu toàn bộ hội thoại. Bấm tạo lặp lại cùng đề xuất/ảnh trả cùng tác vụ để tránh gọi API ảnh hai lần; tác vụ lỗi có thể thử lại. Nếu GPT/API ảnh lỗi, app hiển thị lỗi, không giả kết quả bằng preset.

## Model và trọng số

```powershell
python scripts/fetch_assets.py                  # detection + AdaFace + presets + VGG19 + ảnh mẫu
python scripts/fetch_assets.py --only face
python scripts/fetch_assets.py --only style
python scripts/fetch_assets.py --only vgg
python scripts/fetch_assets.py --only artworks # tranh Van Gogh có kiểm SHA-256
python scripts/fetch_assets.py --only baseline # tải thêm FaceNet VGGFace2
```

Script tải từ nguồn upstream và ghi URL, revision, SHA-256 vào `weights/provenance.json`. Các source third-party tải kèm license vào thư mục model, được giữ nguyên. Nạp trọng số dùng `safetensors` hoặc `torch.load(weights_only=True)`, khớp tên/lớp nghiêm ngặt. Không tự thay bằng trọng số ngẫu nhiên khi tải thất bại.

MTCNN được tải dưới dạng source snapshot của tác giả, không cài package `facenet-pytorch` vào pip vì package có giới hạn phiên bản torch cũ. Snapshot đã chạy được với torch/torchvision nêu trên; model và giấy phép vẫn thuộc tác giả gốc.

AdaFace tải kiến trúc IR50 cùng checkpoint HF cố định revision; bỏ lớp wrapper HF/Transformers và map prefix `model.net.` vào backbone. Input RGB 112px chuẩn hóa [-1,1] theo config của chính checkpoint CVLFace này. Detector giữ cạnh dài tới 2560px; alignment lấy mẫu từ ảnh gốc. Cộng feature của ảnh mặt và bản lật ngang rồi normalize L2. Pipeline key `align-v2-fullres-flip` tách biệt embeddings cũ; đổi pipeline cần lập chỉ mục lại album và trích lại query (app hỗ trợ trích lại từ ảnh tham chiếu đã lưu). Tham khảo [model card tác giả](https://huggingface.co/minchul/cvlface_adaface_ir50_webface4m), [source CVLFace](https://github.com/mk-minchul/CVLface), [MTCNN](https://github.com/timesler/facenet-pytorch), [Fast Neural Style](https://github.com/pytorch/examples/tree/main/fast_neural_style), [NST VGG19](https://docs.pytorch.org/tutorials/advanced/neural_style_tutorial.html).

Điều kiện code và trọng số/dữ liệu có thể khác nhau. Model card AdaFace yêu cầu tuân thủ điều kiện dữ liệu huấn luyện. Xem [bản nghiên cứu](docs/F_SMART_MEMORIES_PLAN.vi.md) và [third-party notices](THIRD_PARTY.md).

## Ảnh mẫu và kiểm thử thực tế

```powershell
python scripts/prepare_demo.py --custom
python -m pytest -q
```

Demo dùng ảnh Grace Hopper từ ví dụ TensorFlow và ảnh NASA astronaut từ scikit-image, cùng một ảnh ghép hai người. Một tranh public domain từ The Met dùng cho NST tùy chọn. URL và checksum có trong provenance. Album có nhãn rõ **Ảnh công khai**, không phải ảnh sinh viên FPT.

Đã chạy kiểm thử trên Windows/Python 3.12/PyTorch CPU:

- 84 bài kiểm thử API/đánh giá/chatbot/tạo style/hàng đợi CPU/toàn vẹn qua pytest: đạt. Nhánh GPT và API ảnh được kiểm thử bằng phản hồi giả lập, chưa gọi API thật vì máy chưa cấu hình key.
- Model thật nhận được 1 + 1 + 2 khuôn mặt trong ba ảnh mẫu.
- Query ảnh Grace Hopper trả về ảnh chân dung và ảnh ghép cùng người.
- Cả bốn preset tạo được ảnh; VGG19 tùy chọn chạy được 20 bước thử nghiệm.
- API tạo tác phẩm, tải PNG và ZIP hoạt động.
- Đã thử trên trình duyệt thật: chat “Gam ấm, nét cọ dày, đậm 65%” → đề xuất cục bộ Rain Princess → bấm tạo → model PyTorch thật trả PNG và trước/sau. Báo cáo `artifacts/style-chat-smoke.json`.

Chi tiết máy đọc được: `artifacts/smoke/report.json`. Các query demo là biến thể của ảnh mẫu, **không phải test độc lập để công bố accuracy**. Báo cáo chưa có Precision/Recall trên ảnh sinh viên FPT.

## Kaggle

Dùng `notebooks/kaggle_full_project.ipynb` và source ZIP `dist/fsmart-memories-source.zip`. Notebook giải nén source vào `/kaggle/working`, giữ torch của Kaggle, tải trọng số, chạy kiểm thử và cho thử pipeline bằng Python. Bật Internet khi tải model và GPU nếu được cấp.

Giao diện web đầy đủ phù hợp chạy trên máy local. Notebook không mở tunnel công khai hoặc gửi ảnh sang API bên ngoài. Có thể mang thư mục `weights/` đã tải từ Kaggle về máy để chạy offline.

## Đánh giá dữ liệu thật

Sao chép `data/benchmark.example.json`, thay đường dẫn và `relevant_photo_ids` bằng ground truth. Đường dẫn ảnh tương đối với file manifest. Tách ảnh query/gallery theo buổi chụp; calibration/test nên tách người khi đủ dữ liệu.

```powershell
python scripts/benchmark.py --manifest data/benchmark.json --threshold 0.4 --k 20
```

Kết quả gồm Precision@K, Recall@K, mAP@K, tỷ lệ query người lạ vẫn trả kết quả, lỗi detection và thời gian. Ảnh lỗi không bị âm thầm loại khỏi kết quả query. `Precision@K` dùng mẫu số K kể cả khi trả ít hơn K; empty relevant list đánh dấu người lạ.

Với cặp ảnh validation đã gán nhãn, tạo JSON có `similarity` và `same_person` dạng boolean cho từng cặp rồi chạy:

```powershell
python scripts/evaluate.py calibrate --pairs data/validation_pairs.json --model-key 'adaface:HASH:align-v2-fullres-flip' --target-far 0.01
```

Lấy model key thực tế từ kết quả search hoặc benchmark, không copy chữ `HASH`. Cấu hình ở `config/calibration.json` chỉ được ứng dụng dùng nếu khớp model key. Hiệu chỉnh trên validation, khóa ngưỡng trước test; pair FAR không đồng nhất với false match ở truy vấn toàn kho.

Baseline FaceNet:

```powershell
python scripts/fetch_assets.py --only baseline
$env:FSM_FACE_MODEL = 'facenet'
python scripts/benchmark.py --manifest data/benchmark.json --threshold 0.6 --output artifacts/facenet
```

Ngưỡng `0.6` ở ví dụ cũng phải chọn lại trên validation. Không so sánh hai model bằng chung một ngưỡng chưa hiệu chỉnh. Đổi model trong ứng dụng cần lập chỉ mục album lại và tải lại query.

## API và cấu trúc

Swagger UI ở [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs), cần mạng để tải asset Swagger từ CDN. Các endpoint lô: `/api/stylize/batch`, `/api/batches`, `/api/batches/{id}/cancel`, `/resume`, `/finish`, `/download`. Các endpoint chính: `/api/albums` (PATCH `/api/albums/{id}` đổi tên), `/api/albums/{id}/photos`, `/api/query`, `/api/query/latest`, `/api/query/{id}`, `/api/query/{id}/refresh`, `/api/search`, `/api/stylize`, `/api/jobs/{id}`, `/api/export`, `/api/chat`, `/api/chat/status`, `/api/chat/config` (POST cấu hình, DELETE ngắt key trong phiên).

`POST /api/system/verify` kiểm tra toàn vẹn; `GET /api/system/status` trả trạng thái thực; `POST /api/system/repair-thumbnails` chỉ tạo lại thumbnail. Reindex nhận JSON `{scope:"failed"|"outdated"|"all"}`; không truyền body giữ tương thích với `all`. `GET /api/outputs?album_id=...&limit=50&offset=0` hỗ trợ phân trang (limit tối đa 100). `POST /api/stylize` hỗ trợ header `Idempotency-Key`; gửi lại cùng key khác tham số trả 409.

Download nguồn theo luồng trình duyệt: `POST /api/exports` với `{photo_ids:[...]}` → URL `GET /api/exports/{token}`, hỗ trợ Range. ZIP chuẩn bị trên đĩa, tối đa 4 ticket trong RAM, TTL 1 giờ; hết hạn được dọn khi có yêu cầu export tiếp theo. Sau restart cần tạo URL mới. ZIP nguồn giới hạn tổng 2 GB, có `manifest.json` phân biệt byte-original và JPEG từ bản cũ; ZIP kết quả lô có `report.json`. Không giữ cả ZIP trong RAM trình duyệt.

```text
fsmart/           backend, model adapters, SQLite, giao diện HTML/CSS/JS
scripts/          tải assets, seed demo, benchmark, hiệu chỉnh ngưỡng, đóng gói
tests/            kiểm thử API, alignment và metric
docs/             lựa chọn model, data, kiến trúc, phân công
notebooks/        notebook Kaggle
weights/          pretrained và upstream source (không commit)
runtime/          ảnh, embeddings, SQLite, output của người dùng (không commit)
artifacts/        kết quả kiểm thử/benchmark (không commit mặc định)
```

Biến môi trường: `FSM_DEVICE=auto|cpu|cuda`, `FSM_FACE_MODEL=adaface|facenet`, `FSM_WEIGHTS_DIR`, `FSM_DATA_DIR`, `FSM_TORCH_THREADS` (mặc định 4). Có hàng đợi nhận diện và hàng đợi style riêng; preset CPU tự chọn OpenVINO nếu đã cài. `FSM_STYLE_BACKEND=auto|torch|openvino`, `FSM_STYLE_THREADS` (mặc định 4). Chưa có multi-user auth, worker phân tán hay kiểm định nhận diện quy mô lớn.


## Studio gọn và trợ lý trên máy (15/10/2026)

Studio có ba tab Nghệ thuật / Màu ảnh / Chủ thể; chọn preset tự xem trước đúng mẫu, lưu tác phẩm là thao tác riêng. Meta SAM 2 thêm chọn vùng bằng điểm, PNG trong suốt, làm mờ nền và giữ màu chủ thể. Qwen3-1.7B GGUF Q8 chạy bằng llama.cpp CPU, không cần API key. Máy hiện tại đã cài.

Máy Windows x64 mới: `./setup.ps1 -WithLocalChat -WithSubjectTools`. Model chat và runtime khoảng 1.88 GB, SAM khoảng 156 MB, tải riêng khỏi ZIP nguồn. [Pipeline, kiểm chứng và giới hạn](docs/STRICT_REVIEW_2026-10-15.vi.md).

Cập nhật 16/10: [chọn Qwen / Gemini và tạo phong cách](docs/CHAT_PROVIDERS.vi.md); [khung xem ảnh giữ đủ nội dung, kiểm tra 24 ca responsive](docs/VIEWER_RESPONSIVE.vi.md).

[Nhập ảnh không áp trần megapixel](docs/LARGE_IMAGES.vi.md): đã thử ảnh 96 MP giữ nguyên file gốc và kích thước; giới hạn 20 MB/file vẫn giữ.
