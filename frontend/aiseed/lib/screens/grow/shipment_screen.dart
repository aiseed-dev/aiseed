import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// 出荷情報投稿画面
class ShipmentScreen extends StatefulWidget {
  const ShipmentScreen({super.key});

  @override
  State<ShipmentScreen> createState() => _ShipmentScreenState();
}

class _ShipmentScreenState extends State<ShipmentScreen> {
  final _naturalController = TextEditingController();
  bool _isPosting = false;
  bool _showStructuredForm = false;

  // 構造化フォーム用
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _noteController = TextEditingController();
  final List<Map<String, dynamic>> _items = [];
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();

  // 投稿履歴
  List<Map<String, dynamic>> _recentShipments = [];

  @override
  void initState() {
    super.initState();
    _loadRecentShipments();
  }

  @override
  void dispose() {
    _naturalController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _noteController.dispose();
    _itemNameController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('出荷情報'),
        backgroundColor: AppColors.naturalistic.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(),
            tooltip: '履歴',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー説明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.naturalistic.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('🌾', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今日の出荷情報を投稿',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '登録者に自動でお知らせが届きます',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 入力モード切り替え
            Row(
              children: [
                Expanded(
                  child: _buildModeButton(
                    icon: Icons.chat,
                    label: 'かんたん入力',
                    isSelected: !_showStructuredForm,
                    onTap: () => setState(() => _showStructuredForm = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeButton(
                    icon: Icons.list_alt,
                    label: 'フォーム入力',
                    isSelected: _showStructuredForm,
                    onTap: () => setState(() => _showStructuredForm = true),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 入力フォーム
            if (_showStructuredForm)
              _buildStructuredForm()
            else
              _buildNaturalInput(),

            const SizedBox(height: 24),

            // 最近の投稿
            if (_recentShipments.isNotEmpty) ...[
              Text(
                '最近の投稿',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._recentShipments.take(3).map((s) => _buildShipmentCard(s)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.naturalistic : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.naturalistic : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNaturalInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '出荷情報を入力',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '例: 「今日10時に道の駅ひまわりにトマト100円とナス150円出します」',
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _naturalController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '今日の出荷情報を自由に入力...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isPosting ? null : _postNatural,
            icon: _isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(_isPosting ? '投稿中...' : '投稿する'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.naturalistic,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStructuredForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 場所
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: '出荷先',
            hintText: '道の駅ひまわり',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 時間
        TextField(
          controller: _timeController,
          decoration: InputDecoration(
            labelText: '時間（任意）',
            hintText: '10:00',
            prefixIcon: const Icon(Icons.access_time),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 商品追加
        Text('商品', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  hintText: '商品名',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _itemPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '円',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add_circle),
              color: AppColors.naturalistic,
              iconSize: 32,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 追加された商品
        ..._items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${item['name']} ${item['price']}円',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _items.remove(item)),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        )),

        const SizedBox(height: 16),

        // 備考
        TextField(
          controller: _noteController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'メッセージ（任意）',
            hintText: '今朝採れたて！',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 投稿ボタン
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isPosting || _items.isEmpty ? null : _postStructured,
            icon: _isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(_isPosting ? '投稿中...' : '投稿する'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.naturalistic,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShipmentCard(Map<String, dynamic> shipment) {
    final items = (shipment['items'] as List? ?? [])
        .map((i) => '${i['name']} ${i['price']}円')
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.naturalistic),
              const SizedBox(width: 4),
              Text(
                shipment['location_name'] ?? '直売所',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                shipment['date'] ?? '',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(items, style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }

  void _addItem() {
    final name = _itemNameController.text.trim();
    final priceText = _itemPriceController.text.trim();

    if (name.isEmpty || priceText.isEmpty) return;

    final price = int.tryParse(priceText);
    if (price == null) return;

    setState(() {
      _items.add({'name': name, 'price': price});
      _itemNameController.clear();
      _itemPriceController.clear();
    });
  }

  Future<void> _postNatural() async {
    final message = _naturalController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final sessionId = await SessionService.getSessionId();
      final userId = await SessionService.getUserId();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/internal/shipment/post'),
        headers: {
          'Content-Type': 'application/json',
          'X-Session-ID': sessionId,
        },
        body: jsonEncode({
          'farmer_id': userId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        _naturalController.clear();
        _showSuccessMessage();
        _loadRecentShipments();
      } else {
        final error = jsonDecode(response.body);
        _showErrorMessage(error['detail'] ?? 'エラーが発生しました');
      }
    } catch (e) {
      _showErrorMessage('通信エラーが発生しました');
    } finally {
      setState(() => _isPosting = false);
    }
  }

  Future<void> _postStructured() async {
    if (_items.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final sessionId = await SessionService.getSessionId();
      final userId = await SessionService.getUserId();
      final today = DateTime.now();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/internal/shipment/post/structured'),
        headers: {
          'Content-Type': 'application/json',
          'X-Session-ID': sessionId,
        },
        body: jsonEncode({
          'farmer_id': userId,
          'date': '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
          'time': _timeController.text.isEmpty ? null : _timeController.text,
          'location_name': _locationController.text.isEmpty ? '直売所' : _locationController.text,
          'items': _items,
          'note': _noteController.text.isEmpty ? null : _noteController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _items.clear();
          _locationController.clear();
          _timeController.clear();
          _noteController.clear();
        });
        _showSuccessMessage();
        _loadRecentShipments();
      } else {
        _showErrorMessage('投稿に失敗しました');
      }
    } catch (e) {
      _showErrorMessage('通信エラーが発生しました');
    } finally {
      setState(() => _isPosting = false);
    }
  }

  Future<void> _loadRecentShipments() async {
    try {
      final userId = await SessionService.getUserId();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/internal/shipment/$userId/history?limit=5'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recentShipments = List<Map<String, dynamic>>.from(data['shipments'] ?? []);
        });
      }
    } catch (e) {
      // エラーは無視
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('出荷情報を投稿しました！'),
        backgroundColor: AppColors.naturalistic,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text('出荷履歴', style: AppTextStyles.titleMedium),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recentShipments.length,
                itemBuilder: (context, index) =>
                    _buildShipmentCard(_recentShipments[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
