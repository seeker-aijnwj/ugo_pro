import 'chariow_payment_service.dart';

enum PaymentProvider {
  chariow,
  cinetpay, // futur
}

class PaymentGatewayService {
  PaymentGatewayService._();
  static final instance = PaymentGatewayService._();

  Future<void> startPayment({
    required int amount,
    required PaymentProvider provider,
  }) async {
    switch (provider) {
      case PaymentProvider.chariow:
        return ChariowPaymentService.instance.pay(amount: amount);

      case PaymentProvider.cinetpay:
        throw UnimplementedError(
          'CinetPay sera activé après création de l’entreprise',
        );
    }
  }
}
