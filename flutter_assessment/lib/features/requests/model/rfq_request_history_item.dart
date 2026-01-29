import '../../quotations/model/rfq_quotation.dart';
import 'rfq_request.dart';

class RfqRequestHistoryItem {
  final RfqRequest request;
  final RfqQuotation? quotation;

  RfqRequestHistoryItem({required this.request, this.quotation});
}


