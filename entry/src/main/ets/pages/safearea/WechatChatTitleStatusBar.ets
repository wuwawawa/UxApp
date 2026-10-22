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
 * 反例：未避让安全区 / 微信聊天标题压状态栏（状态栏）
 *
 * 复刻微信群聊页：浅灰聊天背景（#EDEDED），顶部导航行（返回 ‹、居中群名
 * 「测试群(28)」、右侧 … 菜单点），中间消息流（居中时间条 14:02、三条对方发来的
 * 灰白气泡、两条自己发出的绿色气泡，头像 36vp 方圆角），底部输入栏
 * （语音图标、白色输入胶囊、表情、加号）。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75），vp = px / 2.75。
 *   顶部导航带：高 90vp 固定（不随窗口宽度变化），内容底对齐：
 *           标题行 44vp（返回键 44×44vp、群名 17vp 加粗、菜单点 4.5×4.5vp×3），
 *           按 sceneScale = 窗口宽 / 459.6 等比放大；
 *           导航带下方 0.5vp 分隔线（固定不缩放）；
 *   消息区：时间条 11vp 灰字；气泡内边距 12/9vp、圆角 7.5vp、行高 21vp、
 *           文字 15vp、最大宽 255vp、头像 36vp（圆角 6vp）、条间距 14vp；
 *   输入栏：高 54vp（随窗口等比放大），语音 / 表情 / 加号图标 24vp、
 *           输入胶囊高 38vp、圆角 6vp。
 *
 * 三态实测（同一套设计值，按窗口宽度换算；状态栏占屏幕顶部约 0～40vp）：
 *   单屏态      459.6×672vp   —— ×1.000：标题行 y 46～90，在状态栏下方正常显示
 *   双屏态竖屏  664.7×939.6vp —— ×1.446：标题行 y 26.4～90，上沿 13.6vp 压进状态栏，
 *                                「测试群(28)」与状态栏时间同一行
 *   双屏态横屏  939.6×664.7vp —— ×2.044：标题行 y 0.1～90，整行滑进状态栏，
 *                                群名与运营商、电量图标叠在一起
 *
 * 问题表现（双屏态）：
 *   导航行不避让状态栏：窗口变宽后标题行放大并顶进状态栏，横屏时群名整行
 *   与时间、运营商图标重叠，返回键也压在状态栏上。
 *   单屏态下导航行完整显示在状态栏下方。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），整页横向尺寸的基准 */
const WC_BASE_WIDTH: number = 459.6;

/** 配色 */
const WC_PAGE_BG: string = '#EDEDED';
const WC_NAV_BG: string = '#EDEDED';
const WC_TITLE_TEXT: string = '#1A1A1A';
const WC_TIME_TEXT: string = '#9B9B9B';
const WC_INCOMING_BG: string = '#F7F7F7';
const WC_INCOMING_BORDER: string = '#E4E4E4';
const WC_OUTGOING_BG: string = '#95EC69';
const WC_AVATAR_IN_BG: string = '#D4D7DC';
const WC_AVATAR_OUT_BG: string = '#5B7CD9';
const WC_HAIRLINE: string = '#DCDCDC';

/** 顶部导航带：高度固定；条内标题行底对齐并随窗口宽度等比放大 */
const WC_NAV_BAND: number = 90;
const WC_TITLE_ROW: number = 44;
const WC_TITLE_FONT: number = 17;
const WC_BACK_SPAN: number = 24;
const WC_NAV_SIDE: number = 6;

/** 消息区 */
const WC_BUBBLE_FONT: number = 15;
const WC_BUBBLE_LINE: number = 21;
const WC_BUBBLE_RADIUS: number = 7.5;
const WC_BUBBLE_MAX_WIDTH: number = 255;
const WC_BUBBLE_GAP: number = 14;
const WC_AVATAR_SIZE: number = 36;
const WC_SIDE: number = 12;
const WC_TIME_FONT: number = 11;

/** 输入栏 */
const WC_INPUT_BAR: number = 54;
const WC_INPUT_PILL: number = 38;
const WC_INPUT_ICON: number = 24;

/** 消息流条目：时间条 / 对方消息 / 自己消息 */
interface WechatChatEntry {
  entryKey: string;
  /** 'time' 时间条；'in' 对方灰白气泡；'out' 自己绿色气泡 */
  entryKind: string;
  entryText: string;
}

@Component
export struct WechatChatTitleStatusBarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = WC_BASE_WIDTH;

  /** 窗口高度（vp） */
  @State winHeightVp: number = 672;

  private contentScroller: Scroller = new Scroller();
  private pageActive: boolean = false;
  private windowToken: number = 0;

  private chatEntries: WechatChatEntry[] = [];

  aboutToAppear(): void {
    this.pageActive = true;
    this.buildPageData();
    this.enterImmersiveMode();
  }

  aboutToDisappear(): void {
    this.pageActive = false;
    if (this.windowToken > 0) {
      WindowModeController.release(this.windowToken);
      this.windowToken = 0;
    }
  }

  private enterImmersiveMode(): void {
    const hostContext = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      return;
    }
    window.getLastWindow(hostContext).then((win: window.Window) => {
      if (!this.pageActive) {
        return;
      }
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  private buildPageData(): void {
    this.chatEntries = [
      { entryKey: 'wc-msg-time-1', entryKind: 'time', entryText: '14:02' },
      {
        entryKey: 'wc-msg-in-1',
        entryKind: 'in',
        entryText: '周六上午的折叠屏适配复盘会记得参加，带上各端的验收结果'
      },
      {
        entryKey: 'wc-msg-in-2',
        entryKind: 'in',
        entryText: '这是这期的设计稿和问题清单，大家先过一遍'
      },
      {
        entryKey: 'wc-msg-out-1',
        entryKind: 'out',
        entryText: '收到，我昨天在双屏态上全部跑过一遍了'
      },
      {
        entryKey: 'wc-msg-in-3',
        entryKind: 'in',
        entryText: '首页轮播在横屏还是会被状态栏盖住，记得避让'
      },
      {
        entryKey: 'wc-msg-out-2',
        entryKind: 'out',
        entryText: '好，下午用安全区接口把顶部避让补上'
      },
      { entryKey: 'wc-msg-time-2', entryKind: 'time', entryText: '14:05' },
      {
        entryKey: 'wc-msg-in-4',
        entryKind: 'in',
        entryText: '顺便把底部按钮的导航条避让也一起看看'
      }
    ];
  }

  /** 整页缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / WC_BASE_WIDTH;
  }

  /** 把按单屏态量出的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶部导航带：返回 + 群名 + 菜单点
  // ------------------------------------------------------------------

  @Builder
  moreDots() {
    Row({ space: this.vs(3.5) }) {
      Row()
        .width(this.vs(4.5))
        .height(this.vs(4.5))
        .borderRadius(this.vs(2.25))
        .backgroundColor('#3A3A3A')

      Row()
        .width(this.vs(4.5))
        .height(this.vs(4.5))
        .borderRadius(this.vs(2.25))
        .backgroundColor('#3A3A3A')

      Row()
        .width(this.vs(4.5))
        .height(this.vs(4.5))
        .borderRadius(this.vs(2.25))
        .backgroundColor('#3A3A3A')
    }
    .alignItems(VerticalAlign.Center)
    .margin({ right: this.vs(18) })
  }

  @Builder
  navTitleRow() {
    Stack({ alignContent: Alignment.Center }) {
      Text('测试群(28)')
        .fontSize(this.vs(WC_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(WC_TITLE_TEXT)
        .maxLines(1)

      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(this.vs(WC_BACK_SPAN))
            .fontColor([WC_TITLE_TEXT])
        }
        .width(this.vs(WC_TITLE_ROW))
        .height(this.vs(WC_TITLE_ROW))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.pageStack.pop();
        })

        Blank()

        this.moreDots()
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(WC_NAV_SIDE) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(WC_TITLE_ROW))
  }

  @Builder
  navBand() {
    Stack({ alignContent: Alignment.Bottom }) {
      this.navTitleRow()
    }
    .width('100%')
    .height(WC_NAV_BAND)
    .backgroundColor(WC_NAV_BG)
  }

  // ------------------------------------------------------------------
  // 消息流
  // ------------------------------------------------------------------

  @Builder
  chatAvatar(isSelf: boolean) {
    Column() {
      SymbolGlyph($r('sys.symbol.person'))
        .fontSize(this.vs(20))
        .fontColor([isSelf ? Color.White : '#6B7076'])
    }
    .width(this.vs(WC_AVATAR_SIZE))
    .height(this.vs(WC_AVATAR_SIZE))
    .borderRadius(this.vs(6))
    .backgroundColor(isSelf ? WC_AVATAR_OUT_BG : WC_AVATAR_IN_BG)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  incomingRow(entry: WechatChatEntry) {
    Row({ space: this.vs(10) }) {
      this.chatAvatar(false)

      Text(entry.entryText)
        .fontSize(this.vs(WC_BUBBLE_FONT))
        .fontColor('#1A1A1A')
        .lineHeight(this.vs(WC_BUBBLE_LINE))
        .padding({
          left: this.vs(12),
          right: this.vs(12),
          top: this.vs(9),
          bottom: this.vs(9)
        })
        .backgroundColor(WC_INCOMING_BG)
        .border({ width: 0.5, color: WC_INCOMING_BORDER })
        .borderRadius(this.vs(WC_BUBBLE_RADIUS))
        .constraintSize({ maxWidth: this.vs(WC_BUBBLE_MAX_WIDTH) })
    }
    .width('100%')
    .padding({ left: this.vs(WC_SIDE), right: this.vs(WC_SIDE) })
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: this.vs(WC_BUBBLE_GAP) })
  }

  @Builder
  outgoingRow(entry: WechatChatEntry) {
    Row({ space: this.vs(10) }) {
      Text(entry.entryText)
        .fontSize(this.vs(WC_BUBBLE_FONT))
        .fontColor('#1A1A1A')
        .lineHeight(this.vs(WC_BUBBLE_LINE))
        .padding({
          left: this.vs(12),
          right: this.vs(12),
          top: this.vs(9),
          bottom: this.vs(9)
        })
        .backgroundColor(WC_OUTGOING_BG)
        .borderRadius(this.vs(WC_BUBBLE_RADIUS))
        .constraintSize({ maxWidth: this.vs(WC_BUBBLE_MAX_WIDTH) })

      this.chatAvatar(true)
    }
    .width('100%')
    .padding({ left: this.vs(WC_SIDE), right: this.vs(WC_SIDE) })
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.End)
    .margin({ bottom: this.vs(WC_BUBBLE_GAP) })
  }

  @Builder
  timeChip(entry: WechatChatEntry) {
    Text(entry.entryText)
      .fontSize(this.vs(WC_TIME_FONT))
      .fontColor(WC_TIME_TEXT)
      .margin({ top: this.vs(10), bottom: this.vs(10) })
  }

  @Builder
  chatList() {
    Scroll(this.contentScroller) {
      Column() {
        ForEach(this.chatEntries, (entry: WechatChatEntry) => {
          if (entry.entryKind === 'time') {
            this.timeChip(entry)
          } else if (entry.entryKind === 'in') {
            this.incomingRow(entry)
          } else {
            this.outgoingRow(entry)
          }
        }, (entry: WechatChatEntry) => entry.entryKey)

        Row()
          .height(this.vs(10))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .align(Alignment.Top)
  }

  // ------------------------------------------------------------------
  // 底部输入栏
  // ------------------------------------------------------------------

  @Builder
  inputBar() {
    Row({ space: this.vs(11) }) {
      SymbolGlyph($r('sys.symbol.mic'))
        .fontSize(this.vs(WC_INPUT_ICON))
        .fontColor(['#1F2329'])

      Row()
        .layoutWeight(1)
        .height(this.vs(WC_INPUT_PILL))
        .borderRadius(this.vs(6))
        .backgroundColor('#F5F6F7')

      SymbolGlyph($r('sys.symbol.face_smiling'))
        .fontSize(this.vs(WC_INPUT_ICON))
        .fontColor(['#1F2329'])

      SymbolGlyph($r('sys.symbol.plus'))
        .fontSize(this.vs(WC_INPUT_ICON))
        .fontColor(['#1F2329'])
    }
    .width('100%')
    .height(this.vs(WC_INPUT_BAR))
    .padding({ left: this.vs(WC_SIDE), right: this.vs(WC_SIDE) })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        this.navBand()

        Row()
          .width('100%')
          .height(0.5)
          .backgroundColor(WC_HAIRLINE)

        this.chatList()

        this.inputBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WC_PAGE_BG)
      .onAreaChange((oldArea: Area, newArea: Area) => {
        if (typeof newArea.width === 'number' && newArea.width > 0) {
          this.winWidthVp = newArea.width;
        }
        if (typeof newArea.height === 'number' && newArea.height > 0) {
          this.winHeightVp = newArea.height;
        }
      })
    }
    .hideTitleBar(true)
  }
}
