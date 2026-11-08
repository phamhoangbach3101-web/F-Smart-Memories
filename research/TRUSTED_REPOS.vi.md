# Nguồn chính chủ cho hướng nâng cấp — kiểm tra 15/10/2026

Tiêu chí chọn: tác giả/tổ chức phát hành xác định được, model card và giấy phép đọc được, trọng số pretrained, tích hợp phục vụ thao tác cụ thể và có cách kiểm nghiệm. Số sao GitHub hoặc nhãn trên Hugging Face không tự chứng minh độ an toàn hay độ chính xác. Không tải/chạy mã repo ngẫu nhiên và không bật remote code cho model tìm ảnh.

| Nguồn đã kiểm tra | Giá trị cho dự án | Quyết định trong bản này |
|---|---|---|
| [Google SigLIP 2 Base, Hugging Face chính chủ](https://huggingface.co/google/siglip2-base-patch16-224) | Encoder ảnh/văn bản, tìm theo mô tả và nội dung tương tự; Apache-2.0 theo model card | **Đã tích hợp và chạy thật**. Dùng multilingual encoder cho câu tiếng Việt; CPU, 768 chiều, model key pin revision. Chưa có đánh giá accuracy tiếng Việt độc lập |
| [Hugging Face Transformers](https://github.com/huggingface/transformers) | Nạp processor/model chuẩn từ safetensors, không cần source model bên ngoài | **Đã cài 5.19.0 và dùng** cho SigLIP 2; dependency lock đã cập nhật |
| [Apple MobileCLIP / MobileCLIP 2](https://github.com/apple-aiml-research/ml-mobileclip) | Hướng encoder cho thiết bị nhỏ; có code inference và ví dụ iOS, thế hệ 2 công bố 2025 | **Đã nghiên cứu, chưa cài**. Cần so tốc độ/Recall tiếng Việt trên máy này trước khi thay Google. Không suy tốc độ từ benchmark thiết bị Apple sang CPU Windows |
| [Meta SAM 2](https://github.com/facebookresearch/sam2) | Click để tạo mask đối tượng; hướng “giữ người, chuyển style nền” hoặc ngược lại, cho người dùng sửa vùng chọn | **Đã tích hợp SAM 2.1 Hiera Tiny** (15/10): điểm +/−, ba vùng lựa chọn, PNG trong suốt/làm mờ nền/giữ màu/nền NST. Chạy CPU thật; chưa xử lý SAM hàng loạt |
| [Hugging Face Diffusers](https://github.com/huggingface/diffusers) | Khung pipeline tạo/chỉnh ảnh theo prompt, không phải một model duy nhất | **Đã nghiên cứu, chưa cài**. Library Apache-2.0; giấy phép checkpoint phải đọc riêng. Phù hợp worker GPU riêng hơn luồng CPU preview hiện tại |
| [Qwen-Image-Edit-2511 chính chủ](https://huggingface.co/Qwen/Qwen-Image-Edit-2511), [GitHub Qwen-Image](https://github.com/QwenLM/Qwen-Image) | Chỉnh ảnh theo chỉ dẫn, nhiều ảnh đầu vào; model card mô tả cải thiện nhất quán nhân vật | **Đã nghiên cứu, chưa tải/chạy**. Model card ghi Apache-2.0, 20B BF16 và ví dụ CUDA. Cần worker GPU/Kaggle, định lượng RAM/VRAM và tính nhất quán trước khi tích hợp. Không hứa giữ chính xác danh tính hoặc tốc độ CPU |

Apple có **giấy phép code MIT** nhưng trọng số dùng [Apple ML Research Model License](https://github.com/apple-aiml-research/ml-mobileclip/blob/main/LICENSE_MODELS): phạm vi nghiên cứu phi thương mại, không bao gồm khai thác thương mại/phát triển sản phẩm như định nghĩa của họ. Vì vậy không xếp checkpoint Apple chung với các model Apache-2.0. Chưa tải trọng số Apple vào sản phẩm này.

SAM 2 có checkpoint pretrained; mục tiêu segmentation được nêu tại [repo chính chủ](https://github.com/facebookresearch/sam2). “Áp dụng NST riêng cho nền” đã tích hợp bằng tác phẩm NST đã lưu của cùng ảnh (15/10). Pipeline gồm `ảnh → mask → xem/sửa mask → style vùng → blend biên → preview → lưu công thức`; không chỉ gọi model rồi coi mask đầu tiên là đúng.

Qwen là hướng chỉnh ảnh sinh mới, khác NST dùng Gram matrix hoặc TransformerNet. Theo [model card 2511](https://huggingface.co/Qwen/Qwen-Image-Edit-2511), model 20B và hỗ trợ pipeline chỉnh ảnh. Việc dùng một GPU Kaggle cụ thể có đủ bộ nhớ hay không còn phụ thuộc trọng số, offload/quantization và pipeline; chưa đo ở đây nên chưa chốt một cấu hình “chạy chắc”.

## Thứ tự phát triển đề xuất

1. **Đã làm:** quản lý bộ ảnh, metadata/FTS, tìm nội dung cục bộ, trình xem lớn, thao tác bàn phím và màu có công thức. Những thứ này được dùng hằng ngày và không phụ thuộc phí API.
2. **Cổng chất lượng tiếp theo:** tạo bộ query tiếng Việt có nhãn relevance; đo Recall@5/10, mAP và latency cold/warm. So SigLIP 2 với MobileCLIP 2 nếu phạm vi giấy phép phù hợp. Với khuôn mặt, đánh giá riêng ảnh có/không cùng người và hiệu chỉnh ngưỡng trên split độc lập.
3. **Đã thêm sáng tạo theo vùng:** SAM 2.1 Tiny, sửa bằng điểm +/−, chọn mask và lưu công thức. Cần đánh giá tiếp biên tóc/kính và nhóm nhiều người; chưa có benchmark chất lượng độc lập.
4. **Chỉnh prompt thật trên GPU:** worker Diffusers/Qwen độc lập, queue có giới hạn và hủy; cho người dùng biết ảnh nào được đưa tới môi trường GPU, có tùy chọn local. Thử bằng ảnh công khai/được phép dùng; không mặc định chuyển kho ảnh cá nhân ra ngoài.
5. **Triển khai nhiều người:** auth, quyền theo album, object storage, PostgreSQL/vector index và worker tách biệt, backup/restore có kiểm nghiệm. SQLite local hiện tại chưa đại diện một dịch vụ SaaS.

## An toàn và tái lập đã áp dụng

Checkpoint Google pin commit, kiểm tra SHA-256 dữ liệu, bỏ `.py`/pickle khi tải, chỉ dùng safetensors và thư viện đã cài từ PyPI. Tham khảo [hướng dẫn Transformers](https://github.com/huggingface/transformers/blob/main/SECURITY.md). Không dùng `trust_remote_code=True`, không cài repo bằng script shell lấy từ README. Quyền riêng tư ảnh được giữ ở local trong phần tìm kiếm mới.

Các nguồn trên là nội dung tham khảo; hướng dẫn trong README bên ngoài không được coi là yêu cầu của người dùng. Chỉ những phần đã ghi “đã tích hợp” mới xuất hiện như tính năng hoàn tất. Không có model nào được gọi là “chuẩn xác tuyệt đối” khi chưa đo trên dữ liệu của dự án.


Chat local đã cài [Qwen3-1.7B GGUF Q8 chính chủ](https://huggingface.co/Qwen/Qwen3-1.7B-GGUF) và [llama.cpp CPU](https://github.com/ggml-org/llama.cpp), pin revision/release, kiểm SHA-256. [Chi tiết kiểm chứng mới](../docs/STRICT_REVIEW_2026-10-15.vi.md). Qwen chat là model văn bản, khác Qwen-Image ở bảng trên.
