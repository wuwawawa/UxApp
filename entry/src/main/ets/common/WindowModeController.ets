/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 页面级沉浸式窗口状态协调器。
 *
 * 多个案例页都需要 setWindowLayoutFullScreen(true)，并在离开时恢复。
 * 这些接口都是异步的：如果 A 页返回时发出的 false 晚于 B 页进入时发出的 true 生效，
 * B 页就会退化成非沉浸式，窗口高度少掉系统栏高度，顶部内容被多裁一截。
 * 这里用「页面 token 集合 + 串行队列」保证：
 *   1. 只要有案例页在前台，窗口目标状态就保持沉浸式；
 *   2. 最后一个案例页退出后才恢复非沉浸式；
 *   3. 期间来的新请求不会与旧请求并发，旧请求结束后会继续应用最新目标。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const DEFAULT_SYSTEM_BAR_COLOR: string = '#000000';

export class WindowModeController {
  /** 当前仍在台前的案例页 token，使用 token 而不是简单计数，避免“新页面已 acquire、旧页面才 release”时把计数减成 0 */
  private static activeTokens: Set<number> = new Set<number>();
  private static nextToken: number = 0;
  private static hostWindow: window.Window | undefined = undefined;

  private static wantFullScreen: boolean = false;
  private static wantStatusBarColor: string = DEFAULT_SYSTEM_BAR_COLOR;
  private static wantNavigationBarColor: string = DEFAULT_SYSTEM_BAR_COLOR;

  /** 是否正有一次窗口调用在途 */
  private static applying: boolean = false;
  /** 在途期间是否又产生了新目标 */
  private static pending: boolean = false;

  /** 案例页进入前台：登记 token，并请求沉浸式与对应的系统栏内容色 */
  static acquire(win: window.Window, systemBarContentColor: string): number {
    WindowModeController.nextToken += 1;
    const token: number = WindowModeController.nextToken;
    WindowModeController.activeTokens.add(token);
    WindowModeController.hostWindow = win;
    WindowModeController.wantFullScreen = true;
    WindowModeController.wantStatusBarColor = systemBarContentColor;
    WindowModeController.wantNavigationBarColor = systemBarContentColor;
    WindowModeController.requestApply();
    return token;
  }

  /** 案例页退出前台：注销 token，最后一个页面退出后恢复非沉浸式 */
  static release(token: number): void {
    WindowModeController.activeTokens.delete(token);
    if (WindowModeController.activeTokens.size > 0) {
      return;
    }
    WindowModeController.wantFullScreen = false;
    WindowModeController.wantStatusBarColor = DEFAULT_SYSTEM_BAR_COLOR;
    WindowModeController.wantNavigationBarColor = DEFAULT_SYSTEM_BAR_COLOR;
    WindowModeController.requestApply();
  }

  private static requestApply(): void {
    if (WindowModeController.applying) {
      WindowModeController.pending = true;
      return;
    }
    WindowModeController.applying = true;
    WindowModeController.pending = false;
    WindowModeController.applyCurrentState();
  }

  private static applyCurrentState(): void {
    const win: window.Window | undefined = WindowModeController.hostWindow;
    if (win === undefined) {
      WindowModeController.applying = false;
      return;
    }
    const fullScreen: boolean = WindowModeController.wantFullScreen;
    const statusColor: string = WindowModeController.wantStatusBarColor;
    const navigationColor: string = WindowModeController.wantNavigationBarColor;

    win.setWindowLayoutFullScreen(fullScreen).then(() => {
      WindowModeController.applySystemBarColors(win, statusColor, navigationColor);
    }).catch((error: BusinessError) => {
      console.error(`setWindowLayoutFullScreen failed, code=${error.code}`);
      WindowModeController.applySystemBarColors(win, statusColor, navigationColor);
    });
  }

  private static applySystemBarColors(win: window.Window, statusColor: string, navigationColor: string): void {
    win.setWindowSystemBarProperties({
      statusBarContentColor: statusColor,
      navigationBarContentColor: navigationColor
    }).then(() => {
      WindowModeController.finishApply();
    }).catch((error: BusinessError) => {
      console.error(`setWindowSystemBarProperties failed, code=${error.code}`);
      WindowModeController.finishApply();
    });
  }

  private static finishApply(): void {
    WindowModeController.applying = false;
    if (WindowModeController.pending) {
      WindowModeController.requestApply();
    }
  }
}
