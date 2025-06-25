import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";

initializeApp();
const db = getFirestore();

// 1. 초대 전송 시 푸시 (matches/{matchCode} 생성 시)
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
    const fcmToken = tokenDoc.get("fcmToken") as string|undefined;
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
          aps: {sound: "default"},
        },
      },
    };

    await getMessaging().send(message);
    logger.info(`Push sent to ${inviteeUid}`);
  },
);

// 2. users/{uid} 문서에서 inviteStatus가 'invited'로 바뀔 때 푸시
export const notifyInvitedUser = onDocumentUpdated(
  {
    region: "asia-northeast3",
    document: "users/{uid}",
  },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    const uid = event.params.uid;

    if (
      before?.inviteStatus === after?.inviteStatus ||
      after?.inviteStatus !== "invited"
    ) {
      return;
    }

    const fcmToken = after?.fcmToken as string|undefined;
    if (!fcmToken) {
      logger.info(`NO TOKEN for ${uid}`);
      return;
    }

    const inviterUid = after?.fromUid as string|undefined;
    const nickname = after?.nickname ?? "메이트";

    const message = {
      token: fcmToken,
      notification: {
        title: "메이트 초대 도착!",
        body: `${nickname}님이 메이트 초대를 보냈어요. 지금 확인해보세요.`,
      },
      data: {
        type: "friend_invitation",
        fromUid: inviterUid ?? "",
      },
      android: {priority: "high" as const},
      apns: {
        payload: {
          aps: {sound: "default"},
        },
      },
    };

    await getMessaging().send(message);
    logger.info(`초대 알림 전송 완료 to ${uid}`);
  },
);
