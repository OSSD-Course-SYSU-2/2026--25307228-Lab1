/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common, wantAgent } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import CommonConstants from '../constants/CommonConstants';
import Logger from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Obtains the WantAgent of an application.
 * @param bundle name
 * @param ability name
 * @returns WantAgent of an application.
 */
export async function createWantAgent(bundleName: string, abilityName: string): Promise<Object> {
  let wantAgentInfo = {
    wants: [
      {
        bundleName: bundleName,
        abilityName: abilityName
      }
    ],
    operationType: wantAgent.OperationType.START_ABILITY,
    requestCode: 0,
    wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
  } as wantAgent.WantAgentInfo;
  let result: Object = new Object();
  try {
    result = await wantAgent.getWantAgent(wantAgentInfo)
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'createWantAgent', `getWantAgent failed, error code=${err.code}, message=${err.message}`);
  }
  return result;
}

/**
 * Publish notification.
 *
 * @param progress Download progress
 * @param title Notification title.
 * @param wantAgentObj The want of application.
 */
export function publishNotification(progress: number, title: string, wantAgentObj: object) {
  let template: notificationManager.NotificationTemplate = {
    name: 'downloadTemplate',
    data: {
      title: `${title}`,
      fileName: `${title}：${CommonConstants.DOWNLOAD_FILE}`,
      progressValue: progress,
      progressMaxValue: CommonConstants.PROGRESS_TOTAL,
      isProgressIndeterminate: false
    }
  };
  let notificationRequest: notificationManager.NotificationRequest = {
    id: CommonConstants.NOTIFICATION_ID,
    notificationSlotType: notificationManager.SlotType.CONTENT_INFORMATION,
    // Construct a progress bar template. The name field must be set to downloadTemplate.
    template: template,
    content: {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
      normal: {
        title: `${title}：${CommonConstants.DOWNLOAD_FILE}`,
        text: ' ',
        additionalText: `${progress}%`
      }
    },
    wantAgent: wantAgentObj
  };
  notificationManager.publish(notificationRequest).catch((err: BusinessError) => {
    Logger.error(`[ANS] publish failed, code is ${err.code}, message is ${err.message}`);
  });
}

/**
 * open notification permission
 */
export function openNotificationPermission(context: common.UIAbilityContext) {
  notificationManager.requestEnableNotification(context).then(() => {
    Logger.info('Enable notification success');
  }).catch((err: BusinessError) => {
    Logger.error(`Enable notification failed, code is ${err.code}, message is ${err.message}`);
  });
}