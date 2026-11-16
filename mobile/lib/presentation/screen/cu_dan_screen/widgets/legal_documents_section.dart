import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../configs/theme/app_color.dart';

class LegalDocItemData {
  final String id;
  final String title;
  final String codeOrSubtitle;
  final String subtext;
  final String rightText;
  final bool isApproved;
  final String? actionLabel;
  final Widget? customIcon;
  final String? previewImageUrl;

  const LegalDocItemData({
    this.id = '',
    required this.title,
    required this.codeOrSubtitle,
    required this.subtext,
    required this.rightText,
    this.isApproved = true,
    this.actionLabel,
    this.customIcon,
    this.previewImageUrl,
  });

  LegalDocItemData copyWith({
    String? id,
    String? title,
    String? codeOrSubtitle,
    String? subtext,
    String? rightText,
    bool? isApproved,
    String? actionLabel,
    Widget? customIcon,
    String? previewImageUrl,
  }) {
    return LegalDocItemData(
      id: id ?? this.id,
      title: title ?? this.title,
      codeOrSubtitle: codeOrSubtitle ?? this.codeOrSubtitle,
      subtext: subtext ?? this.subtext,
      rightText: rightText ?? this.rightText,
      isApproved: isApproved ?? this.isApproved,
      actionLabel: actionLabel,
      customIcon: customIcon ?? this.customIcon,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
    );
  }
}

class LegalDocumentsSection extends StatefulWidget {
  final VoidCallback? onUploadNew;

  const LegalDocumentsSection({
    super.key,
    this.onUploadNew,
  });

  @override
  State<LegalDocumentsSection> createState() => _LegalDocumentsSectionState();
}

class _LegalDocumentsSectionState extends State<LegalDocumentsSection> {
  late List<LegalDocItemData> _docs;

  @override
  void initState() {
    super.initState();
    _docs = [
      const LegalDocItemData(
        id: 'DOC-CCCD-01',
        title: 'CCCD Mặt trước',
        codeOrSubtitle: '079095001234',
        subtext: 'Cấp ngày: 10/06/2021',
        rightText: 'Cục CSQLHC về TTXH',
        isApproved: true,
        previewImageUrl:
            'https://images.unsplash.com/photo-1557053910-d9eadeed1c58?auto=format&fit=crop&w=600&q=80',
      ),
      const LegalDocItemData(
        id: 'DOC-CCCD-02',
        title: 'CCCD Mặt sau',
        codeOrSubtitle: 'Chip điện tử & Vân tay',
        subtext: 'Đặc điểm nhận dạng: Nốt ruồi cánh mũi',
        rightText: '10/06/2021',
        isApproved: true,
        previewImageUrl:
            'https://images.unsplash.com/photo-1557053910-d9eadeed1c58?auto=format&fit=crop&w=600&q=80',
      ),
      const LegalDocItemData(
        id: 'DOC-CT07-01',
        title: 'Xác nhận Tạm trú (CT07)',
        codeOrSubtitle: 'Mã: TT-2024-08A',
        subtext: 'Công an Phường An Phú',
        rightText: 'Hạn: 01/2026',
        isApproved: true,
        customIcon: Icon(Icons.description_outlined,
            color: AppColors.secondary, size: 22),
        previewImageUrl:
            'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80',
      ),
      const LegalDocItemData(
        id: 'DOC-TAMVANG-01',
        title: 'Khai báo Tạm vắng (TamVang)',
        codeOrSubtitle: 'Tùy chọn khi vắng mặt > 30 ngày',
        subtext: 'Chưa có bản ghi phát sinh',
        rightText: '',
        isApproved: false,
        actionLabel: 'Nộp khai báo',
        customIcon: Icon(Icons.flight_takeoff_rounded,
            color: AppColors.textSecondary, size: 22),
      ),
      const LegalDocItemData(
        id: 'DOC-KETHON-01',
        title: 'Đăng ký kết hôn (GiayKetHon)',
        codeOrSubtitle: 'Hồ sơ đồng sở hữu / Bảo lãnh',
        subtext: 'Dành cho cư trú cùng gia đình',
        rightText: '',
        isApproved: false,
        actionLabel: 'Tải lên hồ sơ',
        customIcon: Icon(Icons.favorite_outline_rounded,
            color: AppColors.textSecondary, size: 22),
      ),
    ];
  }

  void _showDocDetailDialog(LegalDocItemData item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.isApproved
                    ? AppColors.lightBlueContainer
                    : AppColors.lightSlateContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.isApproved
                    ? Icons.verified_user_rounded
                    : Icons.folder_outlined,
                color: item.isApproved ? AppColors.secondary : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.previewImageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.previewImageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.insert_drive_file_outlined,
                            size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRow('Mã hồ sơ:', item.id.isNotEmpty ? item.id : 'N/A'),
                    const Divider(height: 12),
                    _buildRow('Số hiệu / Chi tiết:', item.codeOrSubtitle),
                    const Divider(height: 12),
                    _buildRow('Thông tin cấp:', item.subtext),
                    if (item.rightText.isNotEmpty) ...[
                      const Divider(height: 12),
                      _buildRow('Cơ quan / Thời hạn:', item.rightText),
                    ],
                    const Divider(height: 12),
                    _buildRow(
                      'Tình trạng:',
                      item.isApproved ? 'Đã duyệt (Hợp lệ)' : 'Chưa nộp / Chờ thẩm định',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.isApproved ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.isApproved ? Colors.green.shade200 : Colors.amber.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.isApproved ? Icons.check_circle_outline : Icons.info_outline,
                      color: item.isApproved ? Colors.green : Colors.amber.shade800,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.isApproved
                            ? 'Hồ sơ đã được Ban Quản Lý Smart Building đối soát và xác thực tính pháp lý.'
                            : 'Hồ sơ chưa hoàn tất. Vui lòng gửi giấy tờ để hoàn tất thủ tục cư trú.',
                        style: TextStyle(
                          fontSize: 11,
                          color: item.isApproved ? Colors.green.shade900 : Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showTamVangModal() {
    final formKey = GlobalKey<FormState>();
    final fromDateController = TextEditingController(text: '20/11/2026');
    final toDateController = TextEditingController(text: '20/12/2026');
    final reasonController = TextEditingController();
    final contactController = TextEditingController(text: '0901234567');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Khai báo Tạm vắng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Khai báo khi cư dân rời khỏi căn hộ liên tục trên 30 ngày để BQL hỗ trợ an ninh và bảo vệ tài sản.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: fromDateController,
                          decoration: InputDecoration(
                            labelText: 'Từ ngày *',
                            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: toDateController,
                          decoration: InputDecoration(
                            labelText: 'Đến ngày *',
                            prefixIcon: const Icon(Icons.event_outlined, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Lý do tạm vắng *',
                      hintText: 'VD: Công tác nước ngoài, về quê nghỉ phép...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập lý do' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactController,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại khẩn cấp *',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          Navigator.pop(modalCtx);
                          setState(() {
                            final idx = _docs.indexWhere((d) => d.id == 'DOC-TAMVANG-01');
                            if (idx != -1) {
                              _docs[idx] = _docs[idx].copyWith(
                                subtext: 'Vắng: ${fromDateController.text} - ${toDateController.text}',
                                rightText: 'Đã tiếp nhận',
                                isApproved: true,
                                actionLabel: null,
                              );
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nộp khai báo tạm vắng thành công! BQL đã tiếp nhận thông tin.'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Xác nhận nộp khai báo',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUploadDocModal({String? initialDocType}) {
    final formKey = GlobalKey<FormState>();
    String docType = initialDocType ?? 'Đăng ký kết hôn (GiayKetHon)';
    final docNumberController = TextEditingController();
    final placeController = TextEditingController();
    final noteController = TextEditingController();
    String? pickedFileName;
    Uint8List? pickedFileBytes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tải lên giấy tờ mới',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: docType,
                        decoration: InputDecoration(
                          labelText: 'Loại hồ sơ pháp lý *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Đăng ký kết hôn (GiayKetHon)',
                              child: Text('Đăng ký kết hôn (GiayKetHon)')),
                          DropdownMenuItem(
                              value: 'Hộ chiếu (Passport)',
                              child: Text('Hộ chiếu (Passport)')),
                          DropdownMenuItem(
                              value: 'Giấy khai sinh con',
                              child: Text('Giấy khai sinh con')),
                          DropdownMenuItem(
                              value: 'Hợp đồng lao động',
                              child: Text('Hợp đồng lao động')),
                          DropdownMenuItem(
                              value: 'Giấy tờ pháp lý khác',
                              child: Text('Giấy tờ pháp lý khác')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => docType = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: docNumberController,
                        decoration: InputDecoration(
                          labelText: 'Số hiệu / Mã giấy tờ *',
                          hintText: 'VD: KH-2024-098, B8972631...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số hiệu' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: placeController,
                        decoration: InputDecoration(
                          labelText: 'Nơi cấp / Cơ quan ban hành',
                          hintText: 'VD: UBND Phường An Phú, TP. Thủ Đức',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Image / File Picker Button
                      InkWell(
                        onTap: () async {
                          try {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(source: ImageSource.gallery);
                            if (image != null) {
                              final bytes = await image.readAsBytes();
                              setModalState(() {
                                pickedFileName = image.name;
                                pickedFileBytes = bytes;
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi chọn ảnh: $e')),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: pickedFileName != null ? AppColors.secondary : AppColors.cardBorder,
                              width: pickedFileName != null ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: pickedFileName != null ? AppColors.lightBlueContainer : AppColors.lightSlateContainer,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                pickedFileName != null ? Icons.image_rounded : Icons.cloud_upload_outlined,
                                color: AppColors.secondary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pickedFileName ?? 'Đính kèm ảnh chụp / Chọn từ thiết bị',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      pickedFileName != null
                                          ? 'Đã chọn ảnh • Bấm để chọn lại'
                                          : 'Bấm vào đây để chọn tệp từ máy tính / điện thoại',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: pickedFileName != null ? AppColors.secondary : AppColors.textSecondary,
                                        fontWeight: pickedFileName != null ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                pickedFileName != null ? Icons.check_circle_rounded : Icons.add_photo_alternate_outlined,
                                color: pickedFileName != null ? Colors.green : AppColors.secondary,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (pickedFileBytes != null) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            pickedFileBytes!,
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noteController,
                        decoration: InputDecoration(
                          labelText: 'Ghi chú thêm cho BQL (tùy chọn)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.pop(modalCtx);
                              setState(() {
                                final existingIdx = _docs.indexWhere((d) => d.title == docType);
                                if (existingIdx != -1) {
                                  _docs[existingIdx] = _docs[existingIdx].copyWith(
                                    codeOrSubtitle: docNumberController.text.trim(),
                                    subtext: placeController.text.trim().isNotEmpty
                                        ? placeController.text.trim()
                                        : 'Đã tải tệp đính kèm',
                                    rightText: 'Chờ duyệt',
                                    isApproved: true,
                                    actionLabel: null,
                                  );
                                } else {
                                  _docs.add(
                                    LegalDocItemData(
                                      id: 'DOC-NEW-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                                      title: docType,
                                      codeOrSubtitle: docNumberController.text.trim(),
                                      subtext: placeController.text.trim().isNotEmpty
                                          ? placeController.text.trim()
                                          : 'Đã tải lên hệ thống',
                                      rightText: 'Chờ duyệt',
                                      isApproved: true,
                                      customIcon: const Icon(Icons.file_present_outlined,
                                          color: AppColors.secondary, size: 22),
                                    ),
                                  );
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã nộp hồ sơ "$docType" lên Ban Quản Lý thành công!'),
                                  backgroundColor: AppColors.secondary,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Gửi hồ sơ thẩm định',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Row
        Row(
          children: [
            const Icon(
              Icons.folder_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Hồ sơ Pháp lý',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),

            // Number Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_docs.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),

            // Top Upload Link
            InkWell(
              onTap: () {
                if (widget.onUploadNew != null) {
                  widget.onUploadNew!();
                } else {
                  _showUploadDocModal();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: const [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Tải lên mới',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Document Cards List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = _docs[index];
            return _buildDocCard(item, index);
          },
        ),
        const SizedBox(height: 14),

        // Black Upload Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (widget.onUploadNew != null) {
                widget.onUploadNew!();
              } else {
                _showUploadDocModal();
              }
            },
            icon: const Icon(
              Icons.upload_file_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: const Text(
              'Tải lên giấy tờ mới (Upload Document)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocCard(LegalDocItemData item, int index) {
    return InkWell(
      onTap: () => _showDocDetailDialog(item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Icon / Thumbnail
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.lightSlateContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: item.customIcon ??
                    Image.network(
                      item.previewImageUrl ??
                          'https://images.unsplash.com/photo-1557053910-d9eadeed1c58?auto=format&fit=crop&w=100&q=80',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.badge_outlined,
                        color: AppColors.secondary,
                        size: 22,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 12),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Approved / Unapproved Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.isApproved
                              ? AppColors.lightBlueContainer
                              : AppColors.lightSlateContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.isApproved
                                  ? Icons.verified_outlined
                                  : Icons.circle,
                              size: 11,
                              color: item.isApproved
                                  ? AppColors.secondary
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.isApproved ? (item.rightText == 'Chờ duyệt' ? 'Chờ duyệt' : 'Đã duyệt') : 'Chưa nộp',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.isApproved
                                    ? AppColors.secondary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Subtitle
                  Text(
                    item.codeOrSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtext and Right Action/Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.subtext,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.actionLabel != null)
                        InkWell(
                          onTap: () {
                            if (item.title.contains('TamVang') || item.title.contains('Tạm vắng')) {
                              _showTamVangModal();
                            } else {
                              _showUploadDocModal(initialDocType: item.title);
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  size: 13,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  item.actionLabel!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (item.rightText.isNotEmpty)
                        Text(
                          item.rightText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
