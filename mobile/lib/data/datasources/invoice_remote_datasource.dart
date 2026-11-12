import 'package:dio/dio.dart';
import '../../common/network/api_client.dart';
import '../model/invoice_data_model.dart';
import '../url/api_urls.dart';

abstract class IInvoiceRemoteDataSource {
  Future<ResidentInvoiceSummaryModel> getResidentInvoices({
    String residentId = 'Res1',
    String? status,
    int? year,
  });

  Future<ResidentInvoiceDetailModel> getResidentInvoiceDetail(String invoiceId);

  Future<bool> submitPayment({
    required String invoiceId,
    required double amount,
    String paymentMethod = 'VNPay',
    String? payerNote,
  });
}

class InvoiceRemoteDataSourceImpl implements IInvoiceRemoteDataSource {
  final ApiClient apiClient;

  InvoiceRemoteDataSourceImpl({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  @override
  Future<ResidentInvoiceSummaryModel> getResidentInvoices({
    String residentId = 'Res1',
    String? status,
    int? year,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiUrls.residentInvoices,
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

  @override
  Future<ResidentInvoiceDetailModel> getResidentInvoiceDetail(String invoiceId) async {
    try {
      final response = await apiClient.dio.get(ApiUrls.invoiceDetail(invoiceId));
      return ResidentInvoiceDetailModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải chi tiết hóa đơn: $e');
    }
  }

  @override
  Future<bool> submitPayment({
    required String invoiceId,
    required double amount,
    String paymentMethod = 'VNPay',
    String? payerNote,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiUrls.payInvoice(invoiceId),
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
