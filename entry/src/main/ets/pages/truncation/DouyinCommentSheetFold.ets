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
 * 反例：截断 / 抖音评论弹层文字折行（文字折行）
 *
 * 反例主题：评论长句逐字折行、@用户名被拆成两行错位。
 *
 * 复刻对象：抖音视频页 + 评论半屏弹层 —— 深色视频流（深灰渐变底、左下
 *   「@吃货小分队官方号」昵称 + 视频文案「打卡中关村宝藏煲仔饭…」+ 原声行、
 *   右侧操作栏 点赞12.3万 / 评论527 / 收藏8642 / 分享2301）；底部弹起的评论弹层
 *   （深色圆角面板：拖拽条、「527条评论」标题 + 关闭叉、评论行 = 渐变头像圈 +
 *   @昵称 + 评论正文 + 日期/回复/点赞数，底部「说点什么...」输入栏）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准：
 *   弹层高按窗口高的 66% 起始；评论行内头像 34vp、昵称 13vp、评论 14vp/行高 20vp、
 *   日期点赞 10vp；昵称栏宽写死 96vp（反例根源）、评论正文栏宽写死 230vp
 *   （反例根源），文字字号却按窗口宽度等比放大。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 昵称 13vp（7 字昵称约 91vp 放得进 96vp 栏宽）、
 *                                 评论 14vp（约 16 字/行，34 字评论折 3 行），
 *                                 排版尚属正常；
 *   双屏态竖屏    664.7×939.6vp —— 昵称放大到 18.8vp（7 字约 132vp 塞不进 96vp），
 *                                 「深夜食堂干饭人」被拆成「深夜食堂干/饭人」两行错位；
 *                                 评论放大到 20.2vp、栏宽仍 230vp（约 11 字/行），
 *                                 长句逐字折行成 4 行，行高时疏时密；
 *   双屏态横屏    939.6×664.7vp —— 昵称 26.6vp、评论 28.6vp（栏内仅剩 8 字/行），
 *                                 一条 34 字评论被逐字折成 5 行，昵称拆成 3 行，
 *                                 评论弹层几乎被竖排文字撑满。
 *
 * 问题表现：
 *   评论弹层里昵称栏宽（96vp）与评论正文栏宽（230vp）都按单屏基准写死，
 *   昵称与正文字号却按窗口宽度等比放大；窗口一宽，栏内每行容纳的字数骤减，
 *   长评论被逐字折行、「@用户名」被从中间拆开折到第二行并与正文错位，
 *   整块评论区像被「竖排」了一样难以阅读。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const DCS_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const DCS_STATUS_BAR_FALLBACK: number = 32;
const DCS_BOTTOM_INSET_FALLBACK: number = 8;

const DCS_VIDEO_BG_START: string = '#2A2A2C';
const DCS_VIDEO_BG_END: string = '#101012';
const DCS_SHEET_BG: string = '#1C1C1E';
const DCS_TEXT_MAIN: string = '#F5F5F5';
const DCS_TEXT_SUB: string = '#9A9A9E';
const DCS_TEXT_LIGHT: string = '#6C6C70';
const DCS_INPUT_BG: string = '#2C2C2E';
const DCS_LIKE_RED: string = '#FE3B5F';

/** 视频文案：昵称 14vp、正文 13vp、原声 11vp；操作栏图标 26vp、数字 10vp */
const DCS_AUTHOR_FONT: number = 14;
const DCS_VIDEO_DESC_FONT: number = 13;
const DCS_MUSIC_FONT: number = 11;
const DCS_RAIL_ICON: number = 26;
const DCS_RAIL_FONT: number = 10;

/** 弹层：占窗口高比例、圆角 12vp、拖拽条 36x4vp、标题 15vp、关闭叉 18vp */
const DCS_SHEET_HEIGHT_RATIO: number = 0.66;
const DCS_SHEET_RADIUS: number = 12;
const DCS_GRABBER_WIDTH: number = 36;
const DCS_GRABBER_HEIGHT: number = 4;
const DCS_SHEET_TITLE_FONT: number = 15;
const DCS_CLOSE_FONT: number = 18;

/** 评论行：头像 34vp、昵称 13vp、评论 14vp/行高 20vp、日期点赞 10vp */
const DCS_AVATAR_SIZE: number = 34;
const DCS_NICK_FONT: number = 13;
const DCS_COMMENT_FONT: number = 14;
const DCS_COMMENT_LINE_HEIGHT: number = 20;
const DCS_META_FONT: number = 10;

/** 昵称栏宽写死 96vp（反例根源）：窗口变宽后 7 字昵称塞不下，被拆成两行 */
const DCS_NICK_WIDTH: number = 96;

/** 评论正文栏宽写死 230vp（反例根源）：窗口变宽后逐字折行 */
const DCS_COMMENT_WIDTH: number = 230;

/** 输入栏：高 36vp、文字 13vp */
const DCS_INPUT_HEIGHT: number = 36;
const DCS_INPUT_FONT: number = 13;

/** 评论数据 */
interface DouyinCommentEntry {
  commentNick: string;
  commentText: string;
  commentTime: string;
  commentLikes: string;
  avatarTintStart: string;
  avatarTintEnd: string;
}

const DCS_COMMENTS: DouyinCommentEntry[] = [
  {
    commentNick: '深夜食堂干饭人',
    commentText: '这家店我也去过，他们家的招牌煲仔饭真的很不错，强烈推荐大家去试试看！',
    commentTime: '10月21日',
    commentLikes: '1.2万',
    avatarTintStart: '#FF9A6B',
    avatarTintEnd: '#F2553F'
  },
  {
    commentNick: '爱吃香菜的猫',
    commentText: '楼主拍的太有食欲了，看饿了，明天就去打卡！',
    commentTime: '10月21日',
    commentLikes: '8932',
    avatarTintStart: '#8FD0F0',
    avatarTintEnd: '#3E7BE8'
  },
  {
    commentNick: '打工人小张',
    commentText: '下班路过闻到香味走不动道，价格还实惠，就是排队有点久。',
    commentTime: '10月20日',
    commentLikes: '5621',
    avatarTintStart: '#B7E38B',
    avatarTintEnd: '#5FA83C'
  },
  {
    commentNick: '探店小分队队长',
    commentText: '已经收藏了，周末带家人一起去尝尝招牌煲仔饭。',
    commentTime: '10月20日',
    commentLikes: '3210',
    avatarTintStart: '#C3B1F0',
    avatarTintEnd: '#7A5FD0'
  },
  {
    commentNick: '干饭不想洗碗',
    commentText: '看起来分量很足，两个人吃一份就够了，好评！',
    commentTime: '10月19日',
    commentLikes: '2048',
    avatarTintStart: '#FFD56B',
    avatarTintEnd: '#F2913C'
  },
  {
    commentNick: '西二旗美食雷达',
    commentText: '这家店在中关村软件园附近，地铁西二旗站B口出来走五分钟就到。',
    commentTime: '10月19日',
    commentLikes: '1024',
    avatarTintStart: '#9BE0C8',
    avatarTintEnd: '#3FAE8C'
  }
];

@Component
export struct DouyinCommentSheetFoldPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = DCS_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = DCS_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = DCS_BOTTOM_INSET_FALLBACK;

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
      const avoidArea: window.AvoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const topInset: number = this.getUIContext().px2vp(avoidArea.topRect.height);
      if (topInset > 0) {
        this.statusBarHeightVp = topInset;
      }
      const bottomInset: number = this.getUIContext().px2vp(avoidArea.bottomRect.height);
      if (bottomInset > 0) {
        this.bottomInsetVp = bottomInset;
      }
      this.windowToken = WindowModeController.acquire(win, DCS_VIDEO_BG_END);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / DCS_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 弹层高度：按窗口高 66% 起底（随窗口高度变化） */
  private sheetHeightVp(): number {
    return this.winHeightVp * DCS_SHEET_HEIGHT_RATIO;
  }

  /** 视频左下：作者 + 文案 + 原声 */
  @Builder
  videoCaption() {
    Column() {
      Text('@吃货小分队官方号')
        .fontSize(this.vs(DCS_AUTHOR_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(DCS_TEXT_MAIN)

      Text('打卡中关村宝藏煲仔饭，第38期 #美食探店 #宝藏小店 #下班去哪吃')
        .fontSize(this.vs(DCS_VIDEO_DESC_FONT))
        .fontColor(DCS_TEXT_MAIN)
        .maxLines(2)
        .lineHeight(this.vs(18))
        .margin({ top: this.vs(6) })

      Row({ space: this.vs(5) }) {
        Text('♪')
          .fontSize(this.vs(DCS_MUSIC_FONT))
          .fontColor(DCS_TEXT_MAIN)

        Text('原声 - 吃货小分队官方号')
          .fontSize(this.vs(DCS_MUSIC_FONT))
          .fontColor(DCS_TEXT_MAIN)
          .maxLines(1)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.vs(8) })
    }
    .alignItems(HorizontalAlign.Start)
    .position({
      x: this.vs(12),
      y: this.winHeightVp - this.sheetHeightVp() - this.vs(150)
    })
  }

  /** 视频右侧操作栏 */
  @Builder
  actionRail() {
    Column({ space: this.vs(18) }) {
      Column() {
        SymbolGlyph($r('sys.symbol.heart'))
          .fontSize(this.vs(DCS_RAIL_ICON))
          .fontColor([DCS_TEXT_MAIN])

        Text('12.3万')
          .fontSize(this.vs(DCS_RAIL_FONT))
          .fontColor(DCS_TEXT_MAIN)
          .margin({ top: this.vs(3) })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        SymbolGlyph($r('sys.symbol.ellipsis_message_fill'))
          .fontSize(this.vs(DCS_RAIL_ICON))
          .fontColor([DCS_TEXT_MAIN])

        Text('527')
          .fontSize(this.vs(DCS_RAIL_FONT))
          .fontColor(DCS_TEXT_MAIN)
          .margin({ top: this.vs(3) })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        SymbolGlyph($r('sys.symbol.star'))
          .fontSize(this.vs(DCS_RAIL_ICON))
          .fontColor([DCS_TEXT_MAIN])

        Text('8642')
          .fontSize(this.vs(DCS_RAIL_FONT))
          .fontColor(DCS_TEXT_MAIN)
          .margin({ top: this.vs(3) })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
          .fontSize(this.vs(DCS_RAIL_ICON))
          .fontColor([DCS_TEXT_MAIN])

        Text('2301')
          .fontSize(this.vs(DCS_RAIL_FONT))
          .fontColor(DCS_TEXT_MAIN)
          .margin({ top: this.vs(3) })
      }
      .alignItems(HorizontalAlign.Center)
    }
    .position({
      x: this.winWidthVp - this.vs(52),
      y: this.winHeightVp - this.sheetHeightVp() - this.vs(210)
    })
  }

  /** 评论头像：渐变圆 + 首字 */
  @Builder
  commentAvatar(comment: DouyinCommentEntry) {
    Column() {
      Text(comment.commentNick.substring(0, 1))
        .fontSize(this.vs(13))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width(this.vs(DCS_AVATAR_SIZE))
    .height(this.vs(DCS_AVATAR_SIZE))
    .justifyContent(FlexAlign.Center)
    .linearGradient({ angle: 135, colors: [[comment.avatarTintStart, 0], [comment.avatarTintEnd, 1]] })
    .borderRadius(this.vs(DCS_AVATAR_SIZE / 2))
  }

  /**
   * 评论行（反例核心）：昵称栏宽写死 96vp、正文栏宽写死 230vp，
   * 字号随窗口放大后栏内容纳字数骤减，昵称被拆行、长句逐字折行。
   */
  @Builder
  commentRow(comment: DouyinCommentEntry) {
    Row() {
      this.commentAvatar(comment)

      Column() {
        Text('@' + comment.commentNick)
          .fontSize(this.vs(DCS_NICK_FONT))
          .fontColor(DCS_TEXT_SUB)
          .maxLines(3)
          .width(DCS_NICK_WIDTH)

        Text(comment.commentText)
          .fontSize(this.vs(DCS_COMMENT_FONT))
          .lineHeight(this.vs(DCS_COMMENT_LINE_HEIGHT))
          .fontColor(DCS_TEXT_MAIN)
          .margin({ top: this.vs(4) })
          .width(DCS_COMMENT_WIDTH)

        Row({ space: this.vs(12) }) {
          Text(comment.commentTime)
            .fontSize(this.vs(DCS_META_FONT))
            .fontColor(DCS_TEXT_LIGHT)

          Text('回复')
            .fontSize(this.vs(DCS_META_FONT))
            .fontColor(DCS_TEXT_LIGHT)

          Blank()

          SymbolGlyph($r('sys.symbol.heart'))
            .fontSize(this.vs(14))
            .fontColor([DCS_LIKE_RED])

          Text(comment.commentLikes)
            .fontSize(this.vs(DCS_META_FONT))
            .fontColor(DCS_TEXT_LIGHT)
        }
        .width(DCS_COMMENT_WIDTH)
        .alignItems(VerticalAlign.Center)
        .margin({ top: this.vs(6) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: this.vs(10) })
    }
    .alignItems(VerticalAlign.Top)
    .padding({
      left: this.vs(12),
      right: this.vs(12),
      top: this.vs(10),
      bottom: this.vs(10)
    })
  }

  /** 弹层标题行：527条评论 + 关闭叉 */
  @Builder
  sheetHeader() {
    Stack({ alignContent: Alignment.End }) {
      Text('527条评论')
        .fontSize(this.vs(DCS_SHEET_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(DCS_TEXT_MAIN)
        .width('100%')

      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(this.vs(DCS_CLOSE_FONT))
        .fontColor([DCS_TEXT_SUB])
        .margin({ right: this.vs(14) })
        .onClick(() => {
          this.pageStack.pop();
        })
    }
    .width('100%')
    .height(this.vs(40))
  }

  /** 底部输入栏：说点什么... */
  @Builder
  inputBar() {
    Row({ space: this.vs(10) }) {
      Row() {
        Text('说点什么...')
          .fontSize(this.vs(DCS_INPUT_FONT))
          .fontColor(DCS_TEXT_LIGHT)
      }
      .layoutWeight(1)
      .height(this.vs(DCS_INPUT_HEIGHT))
      .padding({ left: this.vs(14) })
      .backgroundColor(DCS_INPUT_BG)
      .borderRadius(this.vs(DCS_INPUT_HEIGHT / 2))
      .alignItems(VerticalAlign.Center)

      SymbolGlyph($r('sys.symbol.face_smiling'))
        .fontSize(this.vs(24))
        .fontColor([DCS_TEXT_SUB])

      SymbolGlyph($r('sys.symbol.heart'))
        .fontSize(this.vs(24))
        .fontColor([DCS_TEXT_SUB])
    }
    .width('100%')
    .padding({
      left: this.vs(12),
      right: this.vs(12),
      top: this.vs(8),
      bottom: this.bottomInsetVp + this.vs(8)
    })
    .backgroundColor(DCS_SHEET_BG)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // 视频层：深色渐变 + 左下文案 + 右侧操作栏
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({ angle: 180, colors: [[DCS_VIDEO_BG_START, 0], [DCS_VIDEO_BG_END, 1]] })

        this.videoCaption()
        this.actionRail()

        // 评论半屏弹层
        Column() {
          Row()
            .width(this.vs(DCS_GRABBER_WIDTH))
            .height(this.vs(DCS_GRABBER_HEIGHT))
            .borderRadius(this.vs(DCS_GRABBER_HEIGHT / 2))
            .backgroundColor('#3A3A3C')
            .margin({ top: this.vs(8) })

          this.sheetHeader()

          Scroll() {
            Column() {
              ForEach(DCS_COMMENTS, (comment: DouyinCommentEntry) => {
                this.commentRow(comment)
              }, (comment: DouyinCommentEntry) => comment.commentNick + comment.commentTime)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)

          this.inputBar()
        }
        .width('100%')
        .height(this.sheetHeightVp())
        .backgroundColor(DCS_SHEET_BG)
        .borderRadius({ topLeft: this.vs(DCS_SHEET_RADIUS), topRight: this.vs(DCS_SHEET_RADIUS) })
        .clip(true)
        .alignItems(HorizontalAlign.Start)
        .position({ x: 0, y: this.winHeightVp - this.sheetHeightVp() })
      }
      .width('100%')
      .height('100%')
      .clip(true)
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
