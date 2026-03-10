// // lib/app/core/services/otp_email_service.dart
// import 'package:email_otp/email_otp.dart';

// /// Utilitaire simple autour du package email_otp.
// /// Tu peux l'utiliser si tu veux éviter de configurer dans l'écran.
// class OtpEmailService {
//   static bool _initialized = false;

//   /// À appeler au démarrage de l'app (ex: main() ou Splash).
//   static void init({
//     String appName = 'U-GO',
//     int otpLength = 4,
//     int expiryMs = 300000, // 5 minutes
//   }) {
//     if (_initialized) return;
//     EmailOTP.config(
//       appName: appName,
//       otpLength: otpLength,
//       otpType: OTPType.numeric,
//       expiry: expiryMs,
//       emailTheme: EmailTheme.v6,
//     );
//     _initialized = true;
//   }

//   /// Si tu veux envoyer via un SMTP perso (Gmail/SendGrid),
//   /// dé-commente et renseigne tes creds.
//   static void setSmtp({
//     required String host,
//     required int port, // 25, 465, 587
//     required bool useSsl, // true: ssl, false: tls
//     required String username,
//     required String password,
//   }) {
//     EmailOTP.setSMTP(
//       host: host,
//       emailPort: port == 465
//           ? EmailPort.port465
//           : (port == 587 ? EmailPort.port587 : EmailPort.port25),
//       secureType: useSsl ? SecureType.ssl : SecureType.tls,
//       username: username,
//       password: password,
//     );
//   }

//   static Future<bool> sendCode(String email) => EmailOTP.sendOTP(email: email);
//   static Future<bool> verifyCode(String otp) => EmailOTP.verifyOTP(otp: otp);
//   static bool isExpired() => EmailOTP.isExpired();

//   static String? debugLastOtp() {
//     try {
//       return EmailOTP.getOTP();
//     } catch (_) {
//       return null;
//     }
//   }
// }
