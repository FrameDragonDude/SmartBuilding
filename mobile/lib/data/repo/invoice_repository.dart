import 'package:dio/dio.dart';
import '../../common/network/api_client.dart';
import '../model/invoice_data_model.dart';

class InvoiceRepository {
  final ApiClient apiClient;

  InvoiceRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<ResidentInvoiceSummaryModel> getResidentInvoices({
    String residentId = 'Res1',
    String? status,
    int? year,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/invoices/resident',
        queryParameters: {
          'residentId': residentId,
          if (status != null && status.isNotEmpty) 'status': status,
          if (year != null) 'year': year,
        },
      );
      return ResidentInvoiceSummaryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải danh sách hóa đơn: $e');
    }
  }

  Future<ResidentInvoiceDetailModel> getResidentInvoiceDetail(String invoiceId) async {
    try {
      final response = await apiClient.dio.get('/invoices/$invoiceId/resident-detail');
      return ResidentInvoiceDetailModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải chi tiết hóa đơn: $e');
    }
  }

  Future<bool> submitPayment({
    required String invoiceId,
    required double amount,
    String paymentMethod = 'VNPay',
    String? payerNote,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/invoices/$invoiceId/pay',
        data: {
          'paymentMethod': paymentMethod,
          'amount': amount,
          'payerNote': payerNote,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Thanh toán thất bại!';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi thanh toán hóa đơn: $e');
    }
  }
}
