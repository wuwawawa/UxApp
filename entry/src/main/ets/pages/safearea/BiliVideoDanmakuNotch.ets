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
 * 反例：未避让安全区 / B站视频弹幕条压挖孔（挖孔）
 *
 * 复刻对象：哔哩哔哩「视频详情」页 —— 深色顶栏（返回 + 居中弹幕输入条「发个弹幕见证当下」
 *   + 弹幕开关 + 右侧分享/更多）、16:9 视频画面（面包烘焙视频，画面右缘竖排
 *   UP主头像/关注、点赞30.6万、投币2.9万、收藏5.6万、分享5612）、白色信息区
 *   （UP行 + 标题「108种面包的做法，你学废了吗」+ #美食 #烘焙 #面包 标签 + 简介 +
 *   评论 999+ 两条热评），底部「打开App，查看更多精彩评论」条。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（真机 Pura X Max 双屏竖屏截图
 *   1828×2584px、密度 2.75 等比折算，页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   顶栏行高 24vp；弹幕条宽 331vp、高 17vp（截图 x128~1445、y113~180 量出）；
 *   右侧分享图标距弹幕条 11vp、更多图标再距 15vp、右边距 34.7vp；视频区高 259vp
 *   （y108~1138，约 16:9）；操作列距右 8vp，头像 25vp，图标 20vp + 计数 8.5vp。
 *
 * 挖孔实测（Pura X Max，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 顶栏从窗口顶边铺起（y 0~24vp），弹幕条位于
 *                                 y 3.5~20.5vp、x 32~363vp，顶部正中的挖孔圆
 *                                 （x 218~242vp、y 9.5~33.5vp）从正中穿过弹幕条
 *                                 下半段，占位文字「发个弹幕见证当下」被黑孔盖住，
 *                                 时间/电量图标同时叠在弹幕条上；
 *   双屏态竖屏    664.7×939.6vp —— 弹幕条放大到 x 46~525vp、y 5~29vp，仍贴窗口
 *                                 顶边铺开，状态栏图标压在弹幕条上（挖孔在右下角，
 *                                 不与弹幕条相交）；
 *   双屏态横屏    939.6×664.7vp —— 弹幕条放大到 x 65~742vp、y 7~42vp，同样贴顶
 *                                 铺开压住状态栏区域，右上角挖孔圆（x 898~924vp）
 *                                 与放大后的「更多」图标（x 832~867vp）相邻。
 *
 * 问题表现：
 *   单屏态下弹幕输入条正对前置摄像头挖孔，黑色圆孔把「发个弹幕见证当下」占位文字
 *   从中间削掉一截，状态栏时间、电量同时叠在条上；双屏两个方向顶栏同样贴着窗口
 *   顶边铺开，状态栏图标与返回箭头、弹幕开关互相压盖。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const BLV_BASE_WIDTH: number = 459.6;

const BLV_VIDEO_BG: string = '#0B0B0F';
const BLV_PAGE_BG: string = '#FFFFFF';
const BLV_TEXT_MAIN: string = '#1A1A1A';
const BLV_TEXT_SUB: string = '#61666D';
const BLV_TEXT_LIGHT: string = '#9E9E9E';
const BLV_PINK: string = '#FB7299';
const BLV_BLUE: string = '#23AEDB';
const BLV_PILL_BG: string = 'rgba(0,0,0,0.42)';
const BLV_PILL_BORDER: string = 'rgba(255,255,255,0.28)';
const BLV_DANMAKU_COLOR: string = '#FFFFFF';

/** 顶栏：行高 24vp、返回 20vp、弹幕条 331×17vp、图标 17vp */
const BLV_TOP_BAR_HEIGHT: number = 24;
const BLV_BACK_SIZE: number = 20;
const BLV_PILL_WIDTH: number = 331;
const BLV_PILL_HEIGHT: number = 17;
const BLV_PILL_RADIUS: number = 8.5;
const BLV_SIDE_ICON_SIZE: number = 17;
const BLV_PILL_TEXT_FONT: number = 8.5;
const BLV_PILL_GAP_1: number = 11;
const BLV_PILL_GAP_2: number = 15;
const BLV_PILL_RIGHT_PAD: number = 34.7;

/** 视频区：高 259vp（16:9） */
const BLV_VIDEO_HEIGHT: number = 259;
const BLV_DANMAKU_FONT: number = 10;

/** 操作列：头像 25vp、图标 20vp、计数 8.5vp、距右 8vp */
const BLV_ACT_AVATAR: number = 25;
const BLV_ACT_ICON: number = 20;
const BLV_ACT_LABEL_FONT: number = 8.5;
const BLV_ACT_RIGHT_INSET: number = 8;
const BLV_ACT_TOP_INSET: number = 63;
const BLV_ACT_ITEM_GAP: number = 7;

/** UP行：头像 25vp、昵称 11.5vp、关注按钮高 17vp */
const BLV_UP_AVATAR: number = 25;
const BLV_UP_NAME_FONT: number = 11.5;
const BLV_FOLLOW_HEIGHT: number = 17;
const BLV_FOLLOW_FONT: number = 9.5;

/** 标题 12vp / 标签 9.5vp / 简介 10vp */
const BLV_TITLE_FONT: number = 12;
const BLV_TAG_FONT: number = 9.5;
const BLV_BRIEF_FONT: number = 10;

/** 评论：头像 20vp、昵称 9vp、正文 10.5vp */
const BLV_CMT_AVATAR: number = 20;
const BLV_CMT_NAME_FONT: number = 9;
const BLV_CMT_TEXT_FONT: number = 10.5;
const BLV_CMT_META_FONT: number = 8.5;

/** 底部「打开App」条：高 44vp、按钮高 30vp */
const BLV_OPEN_BAR_HEIGHT: number = 44;
const BLV_OPEN_PILL_HEIGHT: number = 30;
const BLV_OPEN_FONT: number = 10.5;

/** 弹幕文字样本（真机截图画面上可见的弹幕内容） */
interface BiliDanmakuItem {
  danmakuText: string;
  danmakuLeft: number;
  danmakuTop: number;
}

const BLV_DANMAKU_LIST: BiliDanmakuItem[] = [
  { danmakuText: '这也太治愈了吧', danmakuLeft: 58, danmakuTop: 32 },
  { danmakuText: '深夜放毒预定', danmakuLeft: 214, danmakuTop: 96 },
  { danmakuText: '面包脑袋狂喜', danmakuLeft: 96, danmakuTop: 156 }
];

/** 操作列数据 */
interface BiliActionItem {
  actionIcon: Resource;
  actionLabel: string;
}

const BLV_ACTION_LIST: BiliActionItem[] = [
  { actionIcon: $r('sys.symbol.hand_thumbsup'), actionLabel: '30.6万' },
  { actionIcon: $r('sys.symbol.coins'), actionLabel: '2.9万' },
  { actionIcon: $r('sys.symbol.star'), actionLabel: '5.6万' },
  { actionIcon: $r('sys.symbol.share'), actionLabel: '5612' }
];

/** 评论数据 */
interface BiliCommentItem {
  commentUser: string;
  commentText: string;
  commentTime: string;
  commentLikes: string;
  commentTint: string;
}

const BLV_COMMENT_LIST: BiliCommentItem[] = [
  {
    commentUser: '会飞的鱼',
    commentText: '跟着做了两次，第二次终于没有烤成砖头，感谢UP主！',
    commentTime: '10-20',
    commentLikes: '2333',
    commentTint: '#5B8DEF'
  },
  {
    commentUser: '早八人的胃',
    commentText: '凌晨三点看面包视频是什么惩罚游戏，好想吃刚出炉的餐包',
    commentTime: '10-21',
    commentLikes: '1896',
    commentTint: '#E8635A'
  }
];

@Component
export struct BiliVideoDanmakuNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = BLV_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的底部手势区高度（vp） */
  @State bottomInsetVp: number = 8;

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
      const bottomInset: number = this.getUIContext().px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).bottomRect.height);
      if (bottomInset > 0) {
        this.bottomInsetVp = bottomInset;
      }
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / BLV_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 顶栏：返回 + 弹幕输入条 + 分享/更多 */
  @Builder
  videoTopBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(this.vs(BLV_BACK_SIZE))
        .fontColor([BLV_DANMAKU_COLOR])
        .onClick(() => {
          this.pageStack.pop();
        })

      Row() {
        SymbolGlyph($r('sys.symbol.message'))
          .fontSize(this.vs(11))
          .fontColor(['rgba(255,255,255,0.55)'])

        Text('发个弹幕见证当下')
          .fontSize(this.vs(BLV_PILL_TEXT_FONT))
          .fontColor('rgba(255,255,255,0.55)')
          .maxLines(1)
          .margin({ left: this.vs(5) })
          .layoutWeight(1)

        Text('弹')
          .fontSize(this.vs(BLV_PILL_TEXT_FONT))
          .fontColor('rgba(255,255,255,0.75)')
          .margin({ left: this.vs(4) })

        Column() {
          Circle()
            .width(this.vs(8))
            .height(this.vs(8))
            .fillOpacity(0.2)
            .fill(Color.White)
        }
        .width(this.vs(13))
        .height(this.vs(8))
        .borderRadius(this.vs(4))
        .backgroundColor('rgba(255,255,255,0.55)')
        .margin({ left: this.vs(3) })
      }
      .width(this.vs(BLV_PILL_WIDTH))
      .height(this.vs(BLV_PILL_HEIGHT))
      .padding({ left: this.vs(8), right: this.vs(7) })
      .borderRadius(this.vs(BLV_PILL_RADIUS))
      .backgroundColor(BLV_PILL_BG)
      .border({ width: this.vs(0.5), color: BLV_PILL_BORDER })
      .alignItems(VerticalAlign.Center)
      .margin({ left: this.vs(4) })

      SymbolGlyph($r('sys.symbol.share'))
        .fontSize(this.vs(BLV_SIDE_ICON_SIZE))
        .fontColor([BLV_DANMAKU_COLOR])
        .margin({ left: this.vs(BLV_PILL_GAP_1) })

      SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
        .fontSize(this.vs(BLV_SIDE_ICON_SIZE))
        .fontColor([BLV_DANMAKU_COLOR])
        .margin({ left: this.vs(BLV_PILL_GAP_2) })
    }
    .width('100%')
    .height(this.vs(BLV_TOP_BAR_HEIGHT))
    .padding({ right: this.vs(BLV_PILL_RIGHT_PAD) })
    .alignItems(VerticalAlign.Center)
  }

  /** 视频画面右缘的操作列：UP头像 + 关注 + 点赞/投币/收藏/分享 */
  @Builder
  videoActionColumn() {
    Column() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          Text('面')
            .fontSize(this.vs(11))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(this.vs(BLV_ACT_AVATAR))
        .height(this.vs(BLV_ACT_AVATAR))
        .justifyContent(FlexAlign.Center)
        .backgroundColor(BLV_PINK)
        .borderRadius(this.vs(BLV_ACT_AVATAR / 2))
        .border({ width: this.vs(1), color: Color.White })

        Column() {
          Text('+')
            .fontSize(this.vs(9))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(this.vs(13))
        .height(this.vs(13))
        .justifyContent(FlexAlign.Center)
        .backgroundColor(BLV_PINK)
        .borderRadius(this.vs(6.5))
        .offset({ x: this.vs(3), y: this.vs(3) })
      }
      .width(this.vs(BLV_ACT_AVATAR))
      .height(this.vs(BLV_ACT_AVATAR))

      ForEach(BLV_ACTION_LIST, (action: BiliActionItem) => {
        Column() {
          SymbolGlyph(action.actionIcon)
            .fontSize(this.vs(BLV_ACT_ICON))
            .fontColor([Color.White])

          Text(action.actionLabel)
            .fontSize(this.vs(BLV_ACT_LABEL_FONT))
            .fontColor(Color.White)
            .margin({ top: this.vs(2) })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ top: this.vs(BLV_ACT_ITEM_GAP) })
      }, (action: BiliActionItem) => action.actionLabel)
    }
    .alignItems(HorizontalAlign.Center)
    .position({ x: this.winWidthVp - this.vs(BLV_ACT_AVATAR + BLV_ACT_RIGHT_INSET), y: this.vs(BLV_ACT_TOP_INSET) })
  }

  /** 视频区：画面 + 弹幕 + 顶栏 + 操作列 */
  @Builder
  videoArea() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.sa_bili_video'))
        .width('100%')
        .height(this.vs(BLV_VIDEO_HEIGHT))
        .objectFit(ImageFit.Cover)

      ForEach(BLV_DANMAKU_LIST, (danmaku: BiliDanmakuItem) => {
        Text(danmaku.danmakuText)
          .fontSize(this.vs(BLV_DANMAKU_FONT))
          .fontColor(BLV_DANMAKU_COLOR)
          .textShadow({
            radius: this.vs(1.5),
            color: 'rgba(0,0,0,0.85)',
            offsetX: 0,
            offsetY: 0
          })
          .position({ x: this.vs(danmaku.danmakuLeft), y: this.vs(danmaku.danmakuTop) })
      }, (danmaku: BiliDanmakuItem) => danmaku.danmakuText)

      this.videoTopBar()

      this.videoActionColumn()
    }
    .width('100%')
    .height(this.vs(BLV_VIDEO_HEIGHT))
    .clip(true)
  }

  /** UP行：头像 + 昵称 + 关注 */
  @Builder
  upRow() {
    Row() {
      Column() {
        Text('面')
          .fontSize(this.vs(11))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(this.vs(BLV_UP_AVATAR))
      .height(this.vs(BLV_UP_AVATAR))
      .justifyContent(FlexAlign.Center)
      .backgroundColor(BLV_PINK)
      .borderRadius(this.vs(BLV_UP_AVATAR / 2))

      Text('小面包的日常生活')
        .fontSize(this.vs(BLV_UP_NAME_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(BLV_TEXT_MAIN)
        .margin({ left: this.vs(8) })

      Blank()

      Text('+ 关注')
        .fontSize(this.vs(BLV_FOLLOW_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .height(this.vs(BLV_FOLLOW_HEIGHT))
        .padding({ left: this.vs(10), right: this.vs(10) })
        .backgroundColor(BLV_PINK)
        .borderRadius(this.vs(BLV_FOLLOW_HEIGHT / 2))
        .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: this.vs(12), right: this.vs(12), top: this.vs(10) })
  }

  /** 标题 + 标签 + 简介 */
  @Builder
  videoBrief() {
    Column() {
      Text('108种面包的做法，你学废了吗')
        .fontSize(this.vs(BLV_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(BLV_TEXT_MAIN)
        .lineHeight(this.vs(18))
        .margin({ top: this.vs(8) })

      Row({ space: this.vs(8) }) {
        Text('#美食')
          .fontSize(this.vs(BLV_TAG_FONT))
          .fontColor(BLV_BLUE)
        Text('#烘焙')
          .fontSize(this.vs(BLV_TAG_FONT))
          .fontColor(BLV_BLUE)
        Text('#面包')
          .fontSize(this.vs(BLV_TAG_FONT))
          .fontColor(BLV_BLUE)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.vs(7) })

      Row() {
        Text('简介：每天更新一道家常面包做法，新手也能一次成功，揉面出手膜的小技巧都在置顶评论')
          .fontSize(this.vs(BLV_BRIEF_FONT))
          .fontColor(BLV_TEXT_LIGHT)
          .maxLines(1)
          .layoutWeight(1)

        Text('展开')
          .fontSize(this.vs(BLV_BRIEF_FONT))
          .fontColor(BLV_BLUE)
          .margin({ left: this.vs(6) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.vs(7) })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: this.vs(12), right: this.vs(12) })
  }

  @Builder
  commentItem(comment: BiliCommentItem) {
    Row() {
      Column() {
        Text(comment.commentUser.substring(0, 1))
          .fontSize(this.vs(10))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(this.vs(BLV_CMT_AVATAR))
      .height(this.vs(BLV_CMT_AVATAR))
      .justifyContent(FlexAlign.Center)
      .backgroundColor(comment.commentTint)
      .borderRadius(this.vs(BLV_CMT_AVATAR / 2))

      Column() {
        Text(comment.commentUser)
          .fontSize(this.vs(BLV_CMT_NAME_FONT))
          .fontColor(BLV_TEXT_SUB)

        Text(comment.commentText)
          .fontSize(this.vs(BLV_CMT_TEXT_FONT))
          .fontColor(BLV_TEXT_MAIN)
          .lineHeight(this.vs(15))
          .margin({ top: this.vs(4) })

        Row() {
          Text(comment.commentTime)
            .fontSize(this.vs(BLV_CMT_META_FONT))
            .fontColor(BLV_TEXT_LIGHT)

          Text('回复')
            .fontSize(this.vs(BLV_CMT_META_FONT))
            .fontColor(BLV_TEXT_LIGHT)
            .margin({ left: this.vs(12) })

          Blank()

          Row({ space: this.vs(3) }) {
            SymbolGlyph($r('sys.symbol.hand_thumbsup'))
              .fontSize(this.vs(10))
              .fontColor([BLV_TEXT_LIGHT])

            Text(comment.commentLikes)
              .fontSize(this.vs(BLV_CMT_META_FONT))
              .fontColor(BLV_TEXT_LIGHT)
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .margin({ top: this.vs(6) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: this.vs(8) })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ top: this.vs(12) })
  }

  /** 评论区：标题 + 热评 */
  @Builder
  commentSection() {
    Column() {
      Row() {
        Text('评论 999+')
          .fontSize(this.vs(BLV_CMT_TEXT_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(BLV_TEXT_MAIN)
      }
      .width('100%')
      .margin({ top: this.vs(14) })

      ForEach(BLV_COMMENT_LIST, (comment: BiliCommentItem) => {
        this.commentItem(comment)
      }, (comment: BiliCommentItem) => comment.commentUser)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: this.vs(12), right: this.vs(12), bottom: this.vs(14) })
  }

  /** 底部「打开App」条 */
  @Builder
  openAppBar() {
    Column() {
      Text('打开App，查看更多精彩评论')
        .fontSize(this.vs(BLV_OPEN_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .height(this.vs(BLV_OPEN_PILL_HEIGHT))
        .padding({ left: this.vs(30), right: this.vs(30) })
        .backgroundColor('#2B333F')
        .borderRadius(this.vs(BLV_OPEN_PILL_HEIGHT / 2))
    }
    .width('100%')
    .height(this.vs(BLV_OPEN_BAR_HEIGHT) + this.bottomInsetVp)
    .padding({ bottom: this.bottomInsetVp })
    .justifyContent(FlexAlign.Center)
    .backgroundColor(BLV_PAGE_BG)
  }

  build() {
    NavDestination() {
      Column() {
        this.videoArea()

        Scroll() {
          Column() {
            this.upRow()
            this.videoBrief()

            Divider()
              .strokeWidth(1)
              .color('#F0F0F0')
              .margin({ top: this.vs(12) })

            this.commentSection()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(BLV_PAGE_BG)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(BLV_PAGE_BG)

        this.openAppBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(BLV_VIDEO_BG)
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
