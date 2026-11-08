# Chat mô tả phong cách → tạo ảnh

Trong Phòng sáng tạo, người dùng chọn ảnh, mở **Mô tả phong cách bằng chat**, nhập yêu cầu, xem đề xuất rồi bấm **Tạo ảnh theo mô tả**. Đề xuất chỉ tư vấn; chỉ nút tạo mới bắt đầu tác vụ ảnh.

## Pipeline

1. **Hiểu mô tả:** GPT-5.4 Mini qua Responses API với Structured Outputs. JSON giới hạn engine, preset, strength, steps, tiêu đề và mô tả texture tham chiếu. Backend kiểm tra schema và ràng buộc chéo, không nhận lệnh/đường dẫn từ output để thực thi.
2. **Đề xuất preset:** Candy/Mosaic/Rain Princess/Udnie, chạy Fast Neural Style trên máy.
3. **Đề xuất mới:** OpenAI Images API tạo một ảnh texture không người/không chữ từ mô tả. Mặc định GPT Image 1.5, một ảnh PNG 1024px, quality low. VGG19 cục bộ tối ưu ảnh đầu ra 50/150/300 bước với ảnh style đó.
4. **Kết quả:** preview, so sánh trước/sau và tải PNG; giữ ảnh gốc. Tiêu đề phong cách được lưu cùng output.

Không có key thì bộ gợi ý theo từ khóa có thể lập đề xuất preset, có nhãn **Gợi ý cục bộ**. Phong cách ngoài preset sẽ yêu cầu bật GPT/API; không âm thầm thay bằng một preset khác. NST chỉ chuyển màu, nét cọ và họa tiết, không có chỉnh mặt, đổi nền, thay bố cục hay tạo nhân vật.

## Bảo mật và hành vi

- Không gửi ảnh gốc, khuôn mặt, embedding, tên album hay tên file cho OpenAI. Chỉ nội dung chat và ngữ cảnh trang/style/độ đậm được gửi. API ảnh chỉ nhận mô tả texture.
- API key giữ trong RAM; đề xuất cũng ở RAM, hết hạn sau 30 phút, tối đa 64 đề xuất. Toàn bộ lịch sử chat không được ghi vào SQLite.
- `/api/stylize/from-chat` chỉ nhận `photo_id` và ID đề xuất do server cấp; client không tự đổi engine, prompt hay tham số model.
- Cùng một đề xuất/ảnh chỉ tạo một tác vụ; retry sau lỗi tạo tác vụ mới. Kiểm tra có VGG19 trước khi gọi API ảnh.
- Ảnh tham chiếu nhận qua base64 có giới hạn và kiểm tra decode, không tải URL do model trả. File tạm được xóa cả khi lỗi.
- Hỏi đáp và lập đề xuất không tự tạo ảnh; tạo ảnh style mới dùng hạn mức API ảnh của người dùng. Lỗi API/model/hạn mức được báo rõ, không giả thành kết quả thành công.

## Kiểm chứng

52 kiểm thử đạt, gồm preset theo mô tả, schema sai, không gửi ảnh gốc, không tốn lượt API ảnh khi mới lập đề xuất, idempotency, retry, thiếu trọng số, dữ liệu ảnh không hợp lệ và hết hạn đề xuất.

Đã kiểm tra trình duyệt với model PyTorch thật: mô tả gam ấm/nét cọ dày/65% → Rain Princess → PNG, preview trước/sau và tải ảnh. GPT và API ảnh chưa được gọi trực tiếp vì chưa có API key; hợp đồng hai API được kiểm thử giả lập. Phần tạo ảnh style mới cần được xác minh bằng tài khoản API có quyền truy cập phù hợp trước khi khẳng định chất lượng thực tế.

Nguồn chính thức: [Structured Outputs](https://developers.openai.com/api/docs/guides/structured-outputs?api-mode=responses), [Images API](https://developers.openai.com/api/reference/resources/images/methods/generate), [VGG19 NST](https://docs.pytorch.org/tutorials/advanced/neural_style_tutorial.html).
