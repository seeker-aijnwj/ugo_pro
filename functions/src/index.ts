import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

admin.initializeApp();

// Pour lire functions.config() en v2
import * as functions from "firebase-functions";

const nodemailer = require("nodemailer");

const smtpUser = functions.config()?.smtp?.user || "";
const smtpPass = functions.config()?.smtp?.pass || "";
const mailFrom = functions.config()?.otp?.from || `U-GO <${smtpUser}>`;
const appName = functions.config()?.otp?.appname || "U-GO";

function createTransporter() {
    return nodemailer.createTransport({
        service: "Gmail",
        auth: { user: smtpUser, pass: smtpPass },
    });
}

async function sendOtpEmail(to: string, otp: string): Promise<void> {
    const transporter = createTransporter();

    try {
        await transporter.verify();
        logger.info("SMTP connecté ✅");
    } catch (e) {
        logger.error("Erreur SMTP ❌", e);
        return;
    }

    const mailOptions = {
        from: mailFrom,
        to,
        subject: `Votre code de vérification ${appName}`,
        text: `Votre code de vérification est ${otp} (valable 5 minutes).`,
        html: `
      <div style="font-family:Arial,sans-serif;line-height:1.6">
        <h2>${appName}</h2>
        <p>Voici votre code de vérification :</p>
        <div style="font-size:26px;font-weight:bold">${otp}</div>
        <p>Ce code est valable pendant 5 minutes.</p>
        <p>— L'équipe ${appName}</p>
      </div>
    `,
    };

    await transporter.sendMail(mailOptions);
    logger.info(`📧 OTP envoyé à ${to}`);
}

export const onUserWriteSendOtp = onDocumentWritten(
    {
        document: "users/{docId}",
        region: "us-central1",
        memory: "256MiB",
        timeoutSeconds: 60,
    },
    async (event) => {
        try {
            const after = event.data?.after;
            if (!after?.exists) {
                logger.info("Document supprimé → pas d'envoi");
                return;
            }

            const data = after.data();
            const email = data?.email as string | undefined;
            const otp = data?.otp as string | undefined;
            const isVerified = data?.isVerified === true;

            logger.info("📄 Modification détectée", {
                docId: event.params.docId,
                hasEmail: !!email,
                hasOtp: !!otp,
                isVerified,
            });

            if (!email || !otp || isVerified) {
                logger.info("⏭️ Conditions non remplies");
                return;
            }

            await sendOtpEmail(email, otp);
        } catch (error) {
            logger.error("🚨 Erreur OTP :", error);
        }
    }
);