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
 * 反例：未避让安全区 / 微信朋友圈相机按钮压挖孔（挖孔）
 *
 * 复刻对象：微信「朋友圈」页 —— 浅灰顶栏（返回箭头 + 居中「朋友圈」+ 右侧相机图标）、
 *   下方纯文字动态列表（头像、昵称、时间、正文多行、点赞人列表、点赞 / 评论计数行）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   顶栏高 19vp、从窗口顶边铺起；标题 11vp 加粗、垂直居中；返回箭头 16vp；
 *   相机图标 16vp 见方、距窗口右沿 5.5vp；
 *   动态头图 18vp、昵称 11vp、时间 9vp、正文 11.5vp（行高 17vp）、
 *   点赞人 9.5vp、计数行 10vp。
 *
 * 挖孔实测（Pura X Max 模拟器，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 顶栏 0~19vp，相机图标落在 x 439~455vp，
 *                                 挖孔在顶部正中（x 218~242vp），两者不相交；
 *   双屏态竖屏    664.7×939.6vp —— 顶栏放大到 0~27.5vp，相机图标落到 x 633~656vp、
 *                                 y 0~23vp，挖孔在右下角，两者不相交；
 *   双屏态横屏    939.6×664.7vp —— 顶栏放大到 0~38.8vp，相机图标放大到 32.7vp 见方、
 *                                 落在 x 894~923vp、y 9.8~27vp，右上角挖孔圆
 *                                 （x 898~924vp、y 10.2~36.4vp）几乎整块盖住图标，
 *                                 只在左边留一条残边。
 *
 * 问题表现（双屏态横屏）：
 *   顶栏右上角的相机图标正对着前置摄像头挖孔，黑色圆孔把图标压成左侧一条残边，
 *   状态栏的时间与电量也叠在同一行上。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const WX_BASE_WIDTH: number = 459.6;

const WX_PAGE_BG: string = '#EDEDED';
const WX_CARD_BG: string = '#FFFFFF';
const WX_TEXT_MAIN: string = '#191919';
const WX_TEXT_SUB: string = '#7F7F7F';
const WX_TEXT_LINK: string = '#576B95';
const WX_DIVIDER: string = '#E5E5E5';

/** 顶栏：高 19vp、标题 11vp、返回 16vp、相机 16vp、相机距右 5.5vp */
const WX_HEADER_HEIGHT: number = 19;
const WX_TITLE_FONT: number = 11;
const WX_BACK_ICON: number = 16;
const WX_CAMERA_SIZE: number = 16;
const WX_CAMERA_RIGHT_INSET: number = 5.5;

/** 动态：头像 18vp、昵称 11vp、时间 9vp、正文 11.5vp、点赞人 9.5vp、计数 10vp */
const WX_AVATAR_SIZE: number = 18;
const WX_NAME_FONT: number = 11;
const WX_META_FONT: number = 9;
const WX_TEXT_FONT: number = 11.5;
const WX_TEXT_LINE_HEIGHT: number = 17;
const WX_LIKE_USER_FONT: number = 9.5;
const WX_ACTION_FONT: number = 10;
const WX_POST_PAD: number = 10;

/** 动态数据 */
interface WechatMomentItem {
  momentKey: string;
  momentUser: string;
  momentMeta: string;
  momentText: string;
  momentLikeUsers: string;
  momentLikeCount: string;
  momentCommentCount: string;
  momentAvatarTint: string;
}

const WX_MOMENT_LIST: WechatMomentItem[] = [
  {
    momentKey: 'moment-morning',
    momentUser: '张伟',
    momentMeta: '今天 09:12',
    momentText: '早上六点的西湖，雾还没散，跑步的人已经绕着苏堤跑了三圈。改天起早一点，也去跑一段。',
    momentLikeUsers: '李静、王磊、陈晨',
    momentLikeCount: '12',
    momentCommentCount: '3',
    momentAvatarTint: '#5B8DEF'
  },
  {
    momentKey: 'moment-night',
    momentUser: '陈晨',
    momentMeta: '昨天 21:40',
    momentText: '加班到十点，楼下便利店的关东煮只剩最后一串萝卜。收工回家，明天继续。',
    momentLikeUsers: '赵敏、张伟',
    momentLikeCount: '8',
    momentCommentCount: '1',
    momentAvatarTint: '#E8A13F'
  },
  {
    momentKey: 'moment-evening',
    momentUser: '赵敏',
    momentMeta: '昨天 18:05',
    momentText: '周末去看了新开的展，整个厅只放了一段十分钟的影像，站着看完，出来天已经全黑了。',
    momentLikeUsers: '陈晨、李静、王磊、张伟',
    momentLikeCount: '21',
    momentCommentCount: '6',
    momentAvatarTint: '#63C7A0'
  }
];

@Component
export struct WechatMomentCameraNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = WX_BASE_WIDTH;
  @State winHeightVp: number = 672;

  private pageActive: boolean = false;
  private windowToken: number = 0;

  aboutToAppear(): void {
    this.pageActive = true;
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

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / WX_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 顶栏：返回 + 居中标题 + 相机 */
  @Builder
  momentHeader() {
    Stack({ alignContent: Alignment.Center }) {
      Text('朋友圈')
        .fontSize(this.vs(WX_TITLE_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(WX_TEXT_MAIN)
        .maxLines(1)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(WX_BACK_ICON))
          .fontColor([WX_TEXT_MAIN])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Stack({ alignContent: Alignment.Center }) {
          SymbolGlyph($r('sys.symbol.camera'))
            .fontSize(this.vs(WX_CAMERA_SIZE - 3))
            .fontColor([WX_TEXT_MAIN])
        }
        .width(this.vs(WX_CAMERA_SIZE))
        .height(this.vs(WX_CAMERA_SIZE))
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(8), right: this.vs(WX_CAMERA_RIGHT_INSET) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(WX_HEADER_HEIGHT))
    .backgroundColor(WX_CARD_BG)
  }

  @Builder
  momentActions(item: WechatMomentItem) {
    Row() {
      Row({ space: this.vs(4) }) {
        SymbolGlyph($r('sys.symbol.heart'))
          .fontSize(this.vs(11))
          .fontColor([WX_TEXT_SUB])

        Text(item.momentLikeCount)
          .fontSize(this.vs(WX_ACTION_FONT))
          .fontColor(WX_TEXT_SUB)
      }
      .alignItems(VerticalAlign.Center)

      Row({ space: this.vs(4) }) {
        SymbolGlyph($r('sys.symbol.message'))
          .fontSize(this.vs(11))
          .fontColor([WX_TEXT_SUB])

        Text(item.momentCommentCount)
          .fontSize(this.vs(WX_ACTION_FONT))
          .fontColor(WX_TEXT_SUB)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ left: this.vs(22) })

      Blank()

      Text('···')
        .fontSize(this.vs(WX_ACTION_FONT + 2))
        .fontColor(WX_TEXT_LINK)
        .backgroundColor('#F2F2F2')
        .borderRadius(this.vs(3))
        .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(2), bottom: this.vs(2) })
    }
    .width('100%')
    .height(this.vs(20))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  momentPost(item: WechatMomentItem) {
    Row() {
      Column() {
        Text(item.momentUser.substring(0, 1))
          .fontSize(this.vs(10))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(this.vs(WX_AVATAR_SIZE))
      .height(this.vs(WX_AVATAR_SIZE))
      .justifyContent(FlexAlign.Center)
      .backgroundColor(item.momentAvatarTint)
      .borderRadius(this.vs(3))

      Column() {
        Text(item.momentUser)
          .fontSize(this.vs(WX_NAME_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(WX_TEXT_LINK)

        Text(item.momentText)
          .fontSize(this.vs(WX_TEXT_FONT))
          .fontColor(WX_TEXT_MAIN)
          .lineHeight(this.vs(WX_TEXT_LINE_HEIGHT))
          .margin({ top: this.vs(4) })

        Text('❤ ' + item.momentLikeUsers)
          .fontSize(this.vs(WX_LIKE_USER_FONT))
          .fontColor(WX_TEXT_LINK)
          .backgroundColor('#F7F7F7')
          .borderRadius(this.vs(3))
          .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(4), bottom: this.vs(4) })
          .margin({ top: this.vs(6) })

        Row() {
          Text(item.momentMeta)
            .fontSize(this.vs(WX_META_FONT))
            .fontColor(WX_TEXT_SUB)

          Blank()
        }
        .width('100%')
        .margin({ top: this.vs(6) })

        this.momentActions(item)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.vs(8) })
    }
    .width('100%')
    .padding(this.vs(WX_POST_PAD))
    .backgroundColor(WX_CARD_BG)
    .alignItems(VerticalAlign.Top)
  }

  build() {
    NavDestination() {
      Column() {
        this.momentHeader()

        Scroll() {
          Column() {
            ForEach(WX_MOMENT_LIST, (item: WechatMomentItem) => {
              this.momentPost(item)

              Divider()
                .strokeWidth(this.vs(0.5))
                .color(WX_DIVIDER)
            }, (item: WechatMomentItem) => item.momentKey)

            Row()
              .width('100%')
              .height(this.vs(16))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(WX_PAGE_BG)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WX_PAGE_BG)
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
