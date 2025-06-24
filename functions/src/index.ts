import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";

initializeApp();

const db = getFirestore();

export const sendInvitePush = onDocumentCreated(
  {
    region: "asia-northeast3",
    document: "matches/{matchCode}",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    if (!data) return;

    const inviteeUid = data.inviteeUid as string;
    const inviterUid = data.inviterUid as string;
    const exercise = data.exerciseType as string;
    const goal = `${data.goalValue}${data.goalUnit}`;
    const matchCode = event.params.matchCode;

    const tokenDoc = await db.doc(`tokens/${inviteeUid}`).get();
    const fcmToken = tokenDoc.get("fcmToken") as string | undefined;

    if (!fcmToken) {
      logger.info(`NO TOKEN for ${inviteeUid}`);
      return;
    }

    const message = {
      token: fcmToken,
      notification: {
        title: "운동 초대가 왔어요!",
        body: `${exercise} ${goal} 함께 하실래요?`,
      },
      data: {
        type: "invitation",
        matchCode,
        inviterUid,
        exercise,
        goal,
      },
      android: {priority: "high" as const},
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };

    await getMessaging().send(message);
    logger.info(`Push sent to ${inviteeUid}`);
  }
);
