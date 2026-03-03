import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

type FirebaseMessage = Record<string, any>;

type FirebaseMulticastMessage = FirebaseMessage & {
  tokens: string[];
};

type FirebaseBatchResponse = {
  successCount: number;
  failureCount: number;
  [key: string]: any;
};

type FirebaseMessaging = {
  send(payload: FirebaseMessage): Promise<string>;
  sendEachForMulticast(payload: FirebaseMulticastMessage): Promise<FirebaseBatchResponse>;
  subscribeToTopic(tokens: string | string[], topic: string): Promise<any>;
  unsubscribeFromTopic(tokens: string | string[], topic: string): Promise<any>;
};

@Injectable()
export class FirebaseService {
  private readonly logger = new Logger(FirebaseService.name);
  private fcm: FirebaseMessaging | null = null;

  constructor(private configService: ConfigService) {
    try {
      const admin = require('firebase-admin');

      // Initialize Firebase Admin SDK if not already initialized.
      if (!admin.apps.length) {
        const serviceAccountPath = this.configService.get<string>('FIREBASE_SERVICE_ACCOUNT_PATH');
        if (serviceAccountPath) {
          const serviceAccount = JSON.parse(require('fs').readFileSync(serviceAccountPath, 'utf8'));
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
          });
          this.logger.log('Firebase Admin SDK initialized with service account file.');
        } else {
          // Fallback to GOOGLE_APPLICATION_CREDENTIALS env var or default.
          admin.initializeApp();
          this.logger.log('Firebase Admin SDK initialized with default credentials.');
        }
      }

      this.fcm = admin.messaging();
    } catch {
      this.logger.warn(
        'Firebase Admin SDK is not available. Install `firebase-admin` to enable push notifications.',
      );
    }
  }

  private getMessaging(): FirebaseMessaging {
    if (!this.fcm) {
      throw new Error(
        'Firebase Admin SDK is not initialized. Install `firebase-admin` and configure credentials.',
      );
    }
    return this.fcm;
  }

  /**
   * Send a push notification to a single device token.
   */
  async sendToDevice(
    token: string,
    payload: FirebaseMessage,
  ): Promise<{ success: boolean; messageId?: string; error?: any }> {
    try {
      const response = await this.getMessaging().send(payload);
      this.logger.log(`Notification sent successfully to token: ${token}`);
      return { success: true, messageId: response };
    } catch (error) {
      this.logger.error(`Failed to send notification to token ${token}:`, error);
      return { success: false, error };
    }
  }

  /**
   * Send a multicast notification to multiple device tokens.
   */
  async sendToMulticast(tokens: string[], payload: FirebaseMessage): Promise<FirebaseBatchResponse> {
    try {
      const multicastPayload: FirebaseMulticastMessage = {
        ...payload,
        tokens,
      };
      const response = await this.getMessaging().sendEachForMulticast(multicastPayload);
      this.logger.log(
        `Multicast notification sent. Success: ${response.successCount}, Failures: ${response.failureCount}`,
      );
      return response;
    } catch (error) {
      this.logger.error('Failed to send multicast notification:', error);
      throw error;
    }
  }

  /**
   * Send a notification to a topic.
   */
  async sendToTopic(topic: string, payload: FirebaseMessage): Promise<string> {
    try {
      const response = await this.getMessaging().send(payload);
      this.logger.log(`Notification sent to topic ${topic} successfully.`);
      return response;
    } catch (error) {
      this.logger.error(`Failed to send notification to topic ${topic}:`, error);
      throw error;
    }
  }

  /**
   * Subscribe a device token to a topic.
   */
  async subscribeToTopic(tokens: string | string[], topic: string): Promise<any> {
    try {
      const response = await this.getMessaging().subscribeToTopic(tokens, topic);
      this.logger.log(
        `Subscribed ${Array.isArray(tokens) ? tokens.length : 1} token(s) to topic ${topic}.`,
      );
      return response;
    } catch (error) {
      this.logger.error(`Failed to subscribe to topic ${topic}:`, error);
      throw error;
    }
  }

  /**
   * Unsubscribe a device token from a topic.
   */
  async unsubscribeFromTopic(tokens: string | string[], topic: string): Promise<any> {
    try {
      const response = await this.getMessaging().unsubscribeFromTopic(tokens, topic);
      this.logger.log(
        `Unsubscribed ${Array.isArray(tokens) ? tokens.length : 1} token(s) from topic ${topic}.`,
      );
      return response;
    } catch (error) {
      this.logger.error(`Failed to unsubscribe from topic ${topic}:`, error);
      throw error;
    }
  }
}
