import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendOtpEmail(String toEmail, String otp) async {
  const String username = 'yz.corporation@gmail.com';
  // ⚠️ SANS espaces
  const String appPassword = 'drkvomcgbpoijvci';

  final message = Message()
    ..from = Address(username, 'U-GO')
    ..recipients.add(toEmail)
    ..subject = 'Votre code OTP'
    ..text = 'Voici votre code de vérification : $otp'
    ..html = "<h3>Votre code OTP est : <b>$otp</b></h3>";

  // 1) Essai 587 / STARTTLS
  final smtp587 = SmtpServer(
    'smtp.gmail.com',
    port: 587,
    username: username,
    password: appPassword,
    ssl: false, // STARTTLS
  );

  // 2) Fallback 465 / SSL si 587 échoue
  final smtp465 = SmtpServer(
    'smtp.gmail.com',
    port: 465,
    username: username,
    password: appPassword,
    ssl: true,
  );

  try {
    await send(message, smtp587);
    return;
  } on MailerException catch (e) {
    // Log utile en dev
    // ignore: avoid_print
    print(
      '[MAILER][587] e=${e.toString()} problems=${e.problems.map((p) => '${p.code}:${p.msg}').join(' | ')}',
    );
    // on tente 465
    try {
      await send(message, smtp465);
      return;
    } on MailerException catch (e2) {
      // ignore: avoid_print
      print(
        '[MAILER][465] e=${e2.toString()} problems=${e2.problems.map((p) => '${p.code}:${p.msg}').join(' | ')}',
      );
      rethrow;
    }
  }
}
