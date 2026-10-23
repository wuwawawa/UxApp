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
 * 反例：未避让安全区 / QQ音乐歌词页歌名压挖孔（挖孔）
 *
 * 复刻对象：QQ音乐「歌词」模式播放页 —— 顶栏（返回箭头 + 居中歌名 + 右侧分享图标）、
 *   歌手与专辑行、整屏居中歌词（当前行高亮放大、其余行灰字）、播放进度条（已播时长 / 总时长）、
 *   播放控制行（上一首 / 播放暂停 / 下一首）、底部功能行（播放模式、音质、评论、播放列表）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   顶栏高 44vp、从窗口顶边铺起，歌名 17vp 加粗、垂直居中；返回箭头 24vp、分享图标 16vp；
 *   歌手行 12vp；歌词行高 30vp（当前行 26vp、其余 15vp）；进度条高 3vp、圆点 8vp；
 *   控制行圆钮 52vp、两侧切换键 28vp；底部功能行 4 项、文字 10vp。
 *
 * 挖孔实测（Pura X Max 模拟器，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 顶栏 0~44vp，歌名「七里香」三字落在 x 205~256vp、
 *                                 y 约 12.7~25.5vp，挖孔圆（x 218~242vp、y 9.5~33.5vp）
 *                                 正好吃掉中间一字「里」，「七」「香」各缺一角；
 *   双屏态竖屏    664.7×939.6vp —— 顶栏放大到 0~63.6vp、歌名放大到 24.6vp、
 *                                 落在 x 295~369vp，挖孔在右下角，两者不相交；
 *   双屏态横屏    939.6×664.7vp —— 顶栏放大到 0~90vp、歌名落到 x 417~521vp，
 *                                 挖孔在右上角（x 898~924vp），两者不相交。
 *
 * 问题表现（单屏态）：
 *   顶栏正中偏上的歌名被前置摄像头挖孔从中间穿过，中间一字「里」整块消失，左右两字
 *   各被啃掉一角；状态栏时间、电量图标压在顶栏两端。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const QQ_BASE_WIDTH: number = 459.6;

const QQ_PAGE_BG: string = '#1B1B1F';
const QQ_TEXT_MAIN: string = '#F2F2F2';
const QQ_TEXT_SUB: string = '#9A9AA2';
const QQ_TEXT_DIM: string = '#6E6E76';
const QQ_GREEN: string = '#31C27C';

/** 顶栏：高 44vp、歌名 17vp、两端图标 16~24vp */
const QQ_HEADER_HEIGHT: number = 44;
const QQ_SONG_FONT: number = 17;
const QQ_SIDE_ICON: number = 16;
const QQ_BACK_ICON: number = 22;

/** 歌手行：高 34vp、文字 12vp */
const QQ_ARTIST_ROW_HEIGHT: number = 34;
const QQ_ARTIST_FONT: number = 12;

/** 歌词：行高 30vp、当前行 26vp、其余行 15vp */
const QQ_LYRIC_ROW_HEIGHT: number = 30;
const QQ_LYRIC_ACTIVE_FONT: number = 26;
const QQ_LYRIC_FONT: number = 15;

/** 进度条：高 3vp、圆点 8vp、时长文字 10.5vp */
const QQ_PROGRESS_HEIGHT: number = 3;
const QQ_PROGRESS_DOT: number = 8;
const QQ_TIME_FONT: number = 10.5;

/** 控制行：圆钮 52vp、两侧切换键 28vp */
const QQ_PLAY_BUTTON: number = 52;
const QQ_SKIP_ICON: number = 28;

/** 底部功能行：图标 18vp、文字 10vp */
const QQ_ACTION_ICON: number = 18;
const QQ_ACTION_FONT: number = 10;

/** 歌词行数据 */
interface QqLyricLine {
  lyricKey: string;
  lyricText: string;
  lyricActive: boolean;
}

const QQ_LYRIC_LINES: QqLyricLine[] = [
  { lyricKey: 'lyric-1', lyricText: '窗外的麻雀 在电线杆上多嘴', lyricActive: false },
  { lyricKey: 'lyric-2', lyricText: '你说这一句 很有夏天的感觉', lyricActive: false },
  { lyricKey: 'lyric-3', lyricText: '手中的铅笔 在纸上来来回回', lyricActive: false },
  { lyricKey: 'lyric-4', lyricText: '我用几行字形容你是我的谁', lyricActive: true },
  { lyricKey: 'lyric-5', lyricText: '秋刀鱼的滋味 猫跟你都想了解', lyricActive: false },
  { lyricKey: 'lyric-6', lyricText: '初恋的香味 就这样被我们寻回', lyricActive: false },
  { lyricKey: 'lyric-7', lyricText: '那温暖的阳光 像刚摘的鲜艳草莓', lyricActive: false }
];

/** 底部功能项数据 */
interface QqActionItem {
  actionKey: string;
  actionLabel: string;
  actionSymbol: Resource;
}

const QQ_ACTION_LIST: QqActionItem[] = [
  { actionKey: 'act-mode', actionLabel: '单曲循环', actionSymbol: $r('sys.symbol.arrow_clockwise') },
  { actionKey: 'act-quality', actionLabel: '臻品音质', actionSymbol: $r('sys.symbol.bolt') },
  { actionKey: 'act-comment', actionLabel: '999+ 评论', actionSymbol: $r('sys.symbol.message') },
  { actionKey: 'act-list', actionLabel: '播放列表', actionSymbol: $r('sys.symbol.doc_text') }
];

@Component
export struct QqMusicLyricNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = QQ_BASE_WIDTH;
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
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / QQ_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 顶栏：返回 + 居中歌名 + 分享 */
  @Builder
  lyricHeader() {
    Stack({ alignContent: Alignment.Center }) {
      Text('七里香')
        .fontSize(this.vs(QQ_SONG_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(QQ_TEXT_MAIN)
        .maxLines(1)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(QQ_BACK_ICON))
          .fontColor([QQ_TEXT_MAIN])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
          .fontSize(this.vs(QQ_SIDE_ICON))
          .fontColor([QQ_TEXT_MAIN])
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(10), right: this.vs(14) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(QQ_HEADER_HEIGHT))
  }

  @Builder
  artistRow() {
    Text('周杰伦 · 七里香')
      .fontSize(this.vs(QQ_ARTIST_FONT))
      .fontColor(QQ_TEXT_SUB)
      .width('100%')
      .height(this.vs(QQ_ARTIST_ROW_HEIGHT))
      .textAlign(TextAlign.Center)
  }

  @Builder
  lyricLine(line: QqLyricLine) {
    Text(line.lyricText)
      .fontSize(this.vs(line.lyricActive ? QQ_LYRIC_ACTIVE_FONT : QQ_LYRIC_FONT))
      .fontWeight(line.lyricActive ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(line.lyricActive ? QQ_GREEN : QQ_TEXT_DIM)
      .width('100%')
      .height(this.vs(QQ_LYRIC_ROW_HEIGHT + (line.lyricActive ? 10 : 0)))
      .textAlign(TextAlign.Center)
      .maxLines(1)
  }

  /** 歌词区：整屏居中滚动 */
  @Builder
  lyricArea() {
    Scroll() {
      Column() {
        ForEach(QQ_LYRIC_LINES, (line: QqLyricLine) => {
          this.lyricLine(line)
        }, (line: QqLyricLine) => line.lyricKey)
      }
      .width('100%')
      .padding({ top: this.vs(60), bottom: this.vs(60) })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .align(Alignment.Center)
  }

  /** 进度条：已播 / 进度 / 总时长 */
  @Builder
  progressBar() {
    Column() {
      Row() {
        Row()
          .width('42%')
          .height(this.vs(QQ_PROGRESS_HEIGHT))
          .backgroundColor(QQ_GREEN)
          .borderRadius(this.vs(QQ_PROGRESS_HEIGHT / 2))

        Circle()
          .width(this.vs(QQ_PROGRESS_DOT))
          .height(this.vs(QQ_PROGRESS_DOT))
          .fill(QQ_GREEN)

        Row()
          .layoutWeight(1)
          .height(this.vs(QQ_PROGRESS_HEIGHT))
          .backgroundColor('#3A3A40')
          .borderRadius(this.vs(QQ_PROGRESS_HEIGHT / 2))
      }
      .width('100%')
      .height(this.vs(QQ_PROGRESS_DOT))
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('01:32')
          .fontSize(this.vs(QQ_TIME_FONT))
          .fontColor(QQ_TEXT_DIM)

        Blank()

        Text('04:59')
          .fontSize(this.vs(QQ_TIME_FONT))
          .fontColor(QQ_TEXT_DIM)
      }
      .width('100%')
      .margin({ top: this.vs(8) })
    }
    .width('100%')
    .padding({ left: this.vs(20), right: this.vs(20) })
    .alignItems(HorizontalAlign.Start)
  }

  /** 控制行：上一首 / 播放 / 下一首 */
  @Builder
  controlRow() {
    Row() {
      Column()
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(this.vs(QQ_SKIP_ICON))
        .fontColor([QQ_TEXT_MAIN])

      Column() {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(this.vs(QQ_PLAY_BUTTON))
            .height(this.vs(QQ_PLAY_BUTTON))
            .fill(QQ_GREEN)

          Row({ space: this.vs(4) }) {
            Row()
              .width(this.vs(4))
              .height(this.vs(15))
              .backgroundColor(Color.White)
              .borderRadius(this.vs(1))

            Row()
              .width(this.vs(4))
              .height(this.vs(15))
              .backgroundColor(Color.White)
              .borderRadius(this.vs(1))
          }
          .alignItems(VerticalAlign.Center)
        }
        .width(this.vs(QQ_PLAY_BUTTON))
        .height(this.vs(QQ_PLAY_BUTTON))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(this.vs(QQ_SKIP_ICON))
        .fontColor([QQ_TEXT_MAIN])

      Column()
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height(this.vs(QQ_PLAY_BUTTON + 10))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  actionItem(action: QqActionItem) {
    Column({ space: this.vs(5) }) {
      SymbolGlyph(action.actionSymbol)
        .fontSize(this.vs(QQ_ACTION_ICON))
        .fontColor([QQ_TEXT_SUB])

      Text(action.actionLabel)
        .fontSize(this.vs(QQ_ACTION_FONT))
        .fontColor(QQ_TEXT_SUB)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  /** 底部功能行 */
  @Builder
  actionRow() {
    Row() {
      ForEach(QQ_ACTION_LIST, (action: QqActionItem) => {
        this.actionItem(action)
      }, (action: QqActionItem) => action.actionKey)
    }
    .width('100%')
    .height(this.vs(48))
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        this.lyricHeader()
        this.artistRow()
        this.lyricArea()
        this.progressBar()

        Row()
          .width('100%')
          .height(this.vs(14))

        this.controlRow()
        this.actionRow()
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: this.vs(10) })
      .backgroundColor(QQ_PAGE_BG)
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
