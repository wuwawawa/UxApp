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
 * 反例：截断 / QQ音乐歌词行被裁（文字截断）
 *
 * 复刻对象：QQ音乐「歌曲播放」页 —— 深色背景、顶部返回 + 分享 + 更多、
 *   左侧歌名「晴天」/ 周杰伦 / 专辑:叶惠美 与逐行歌词、
 *   右侧绿色渐变方形封面占位（黑胶纹理圆环 + 波形图标）、
 *   进度条（01:23 / 04:29）、播放控制（收藏 / 上一曲 / 播放 / 下一曲 / 目录）、
 *   随机播放 / 循环 / 音量一行小图标。
 *
 * 设计基准（vp，按单屏态 459.6vp 宽绘制）：歌词列左缘 20vp、行宽 212vp、
 *   普通行 13vp 字 / 行高 22vp、当前行 15vp 加粗；封面 130×130vp、
 *   圆角 8vp，左缘钉在 236vp（按基准宽度算出来的定值 —— 反例根源）；
 *   进度条宽 380vp、控制按钮大 56vp。
 *
 * 三态实测：
 *   单屏态        459.6vp 宽 —— sceneScale 1.00，歌词列右缘 232vp，封面左缘 236vp，刚好错开 4vp；
 *   双屏态竖屏    664.7vp 宽 —— sceneScale 1.45，歌词行放大到约 306vp 宽、伸到 335vp，
 *                              封面还钉在 236vp 处，压住每行歌词的尾部 99vp；
 *   双屏态横屏    939.6vp 宽 —— sceneScale 2.04，歌词行宽约 433vp、伸到 474vp，
 *                              封面（236~502vp）把长句从第 9 个字起整段盖住，句尾全部丢失。
 *
 * 问题表现：
 *   封面左缘用的是按 459.6vp 基准宽度算出的定值 236vp，没有随窗口放大；
 *   歌词行宽与字号却按 sceneScale 放大 —— 宽窗口下放大的歌词行伸进封面底下，
 *   「故事的小黄花从出生那年就飘着」等长句的句尾被绿色封面整段盖住，看不到完整歌词。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态折叠屏基准宽度（vp），sceneScale 以它为 1.0 */
const QQM_PLAYER_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const QQM_STATUS_BAR_FALLBACK: number = 34;
const QQM_BOTTOM_INSET_FALLBACK: number = 8;

/** 封面左缘定值：按 459.6vp 基准宽度算出的坐标，不随窗口放大（反例根源） */
const QQM_ART_FIXED_X: number = 236;
/** 封面尺寸 / 圆角（vp） */
const QQM_ART_SIZE: number = 130;
const QQM_ART_RADIUS: number = 8;
/** 歌词列：左缘、行宽、行高、字号 */
const QQM_LYRIC_LEFT: number = 20;
const QQM_LYRIC_WIDTH: number = 212;
const QQM_LYRIC_LINE_HEIGHT: number = 22;
const QQM_LYRIC_FONT: number = 13;
const QQM_LYRIC_ACTIVE_FONT: number = 15;

const QQM_PAGE_BG: string = '#121212';
const QQM_TEXT_MAIN: string = '#F5F5F5';
const QQM_TEXT_SUB: string = '#8A8A8A';
const QQM_GREEN: string = '#31C27C';
const QQM_GREEN_DEEP: string = '#1FA366';
const QQM_TRACK_BG: string = '#3A3A3A';

/** 歌词行：isActiveLine 标记当前高亮行 */
interface QqLyricLine {
  lineKey: string;
  lineText: string;
  isActiveLine: boolean;
}

const QQM_LYRIC_LINES: QqLyricLine[] = [
  { lineKey: 'qqm-line-1', lineText: '故事的小黄花从出生那年就飘着', isActiveLine: false },
  { lineKey: 'qqm-line-2', lineText: '童年的荡秋千随记忆一直晃到现在', isActiveLine: false },
  { lineKey: 'qqm-line-3', lineText: 'Re So So Si Do Si La', isActiveLine: false },
  { lineKey: 'qqm-line-4', lineText: '吹着前奏望着天空我想起花瓣', isActiveLine: true },
  { lineKey: 'qqm-line-5', lineText: '为你翘课的那天花落的那一天', isActiveLine: false },
  { lineKey: 'qqm-line-6', lineText: '教室的那一间我怎么看不见', isActiveLine: false },
  { lineKey: 'qqm-line-7', lineText: '消失的下雨天我好想再淋一遍', isActiveLine: false }
];

@Component
export struct QqMusicLyricTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = QQM_PLAYER_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = QQM_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = QQM_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, QQM_PAGE_BG);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：窗口越宽，页面整体放大越多（单屏态为 1.0） */
  private sceneScale(): number {
    const widthRatio: number = this.winWidthVp / QQM_PLAYER_BASE_WIDTH;
    return widthRatio < 1 ? 1 : widthRatio;
  }

  /** 把设计基准值（vp）换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶栏与音质标签
  // ------------------------------------------------------------------

  @Builder
  qualityChip(chipLabel: string, chipActive: boolean) {
    Text(chipLabel)
      .fontSize(this.vs(9))
      .fontColor(chipActive ? QQM_GREEN : QQM_TEXT_SUB)
      .border({ width: this.vs(1), color: chipActive ? QQM_GREEN : '#5A5A5A', radius: this.vs(7) })
      .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(2), bottom: this.vs(2) })
      .maxLines(1)
  }

  @Builder
  qualityChipRow() {
    Row({ space: this.vs(6) }) {
      this.qualityChip('SQ 无损', true)
      this.qualityChip('臻品音质2.0', false)
      this.qualityChip('MV', false)
    }
    .margin({ top: this.vs(4), bottom: this.vs(8) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  playerTopBar() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(20))
          .fontColor([QQM_TEXT_MAIN])
      }
      .width(this.vs(32))
      .height(this.vs(32))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.pageStack.pop();
      })

      Blank()

      SymbolGlyph($r('sys.symbol.share'))
        .fontSize(this.vs(18))
        .fontColor([QQM_TEXT_SUB])

      SymbolGlyph($r('sys.symbol.line_3_horizontal'))
        .fontSize(this.vs(18))
        .fontColor([QQM_TEXT_SUB])
        .margin({ left: this.vs(16) })
    }
    .width('100%')
    .height(this.vs(44))
    .margin({ top: this.statusBarHeightVp })
    .padding({ left: this.vs(8), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 歌词列与封面（封面钉在 236vp 定值处 —— 反例核心）
  // ------------------------------------------------------------------

  @Builder
  lyricColumn() {
    Column({ space: this.vs(2) }) {
      Text('晴天')
        .fontSize(this.vs(20))
        .fontWeight(FontWeight.Bold)
        .fontColor(QQM_TEXT_MAIN)

      Text('周杰伦 / 专辑: 叶惠美')
        .fontSize(this.vs(11))
        .fontColor(QQM_TEXT_SUB)
        .margin({ top: this.vs(2) })

      this.qualityChipRow()

      ForEach(QQM_LYRIC_LINES, (lineItem: QqLyricLine) => {
        Text(lineItem.lineText)
          .fontSize(lineItem.isActiveLine ? this.vs(QQM_LYRIC_ACTIVE_FONT) : this.vs(QQM_LYRIC_FONT))
          .fontWeight(lineItem.isActiveLine ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(lineItem.isActiveLine ? QQM_TEXT_MAIN : QQM_TEXT_SUB)
          .lineHeight(this.vs(QQM_LYRIC_LINE_HEIGHT))
          .maxLines(1)
          .width(this.vs(QQM_LYRIC_WIDTH))
      }, (lineItem: QqLyricLine) => lineItem.lineKey)
    }
    .width(this.vs(QQM_LYRIC_WIDTH))
    .alignItems(HorizontalAlign.Start)
    .position({ x: this.vs(QQM_LYRIC_LEFT), y: this.vs(16) })
    .clip(false)
  }

  @Builder
  albumArtBlock() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(this.vs(QQM_ART_SIZE))
        .height(this.vs(QQM_ART_SIZE))
        .borderRadius(this.vs(QQM_ART_RADIUS))
        .linearGradient({
          angle: 135,
          colors: [['#4CD394', 0.0], [QQM_GREEN, 0.55], [QQM_GREEN_DEEP, 1.0]]
        })

      Column()
        .width(this.vs(78))
        .height(this.vs(78))
        .borderRadius(this.vs(39))
        .border({ width: this.vs(1), color: '#66D9A8' })

      Column()
        .width(this.vs(52))
        .height(this.vs(52))
        .borderRadius(this.vs(26))
        .border({ width: this.vs(1), color: '#4ABA85' })

      SymbolGlyph($r('sys.symbol.waveform'))
        .fontSize(this.vs(26))
        .fontColor([Color.White])
    }
    .width(this.vs(QQM_ART_SIZE))
    .height(this.vs(QQM_ART_SIZE))
    .position({ x: QQM_ART_FIXED_X, y: this.vs(8) })
  }

  @Builder
  playerMainArea() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.lyricColumn()
      this.albumArtBlock()
    }
    .width('100%')
    .layoutWeight(1)
    .clip(false)
  }

  // ------------------------------------------------------------------
  // 进度条与播放控制
  // ------------------------------------------------------------------

  @Builder
  progressRow() {
    Row({ space: this.vs(8) }) {
      Text('01:23')
        .fontSize(this.vs(10))
        .fontColor(QQM_TEXT_SUB)

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(this.vs(2))
          .backgroundColor(QQM_TRACK_BG)
          .borderRadius(this.vs(1))

        Row()
          .width('34%')
          .height(this.vs(2))
          .backgroundColor(QQM_GREEN)
          .borderRadius(this.vs(1))

        Column()
          .width(this.vs(8))
          .height(this.vs(8))
          .borderRadius(this.vs(4))
          .backgroundColor(Color.White)
          .position({ x: this.vs(119), y: -this.vs(3) })
      }
      .layoutWeight(1)
      .height(this.vs(6))

      Text('04:29')
        .fontSize(this.vs(10))
        .fontColor(QQM_TEXT_SUB)
    }
    .width('100%')
    .padding({ left: this.vs(16), right: this.vs(16) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  controlRow() {
    Row() {
      SymbolGlyph($r('sys.symbol.heart'))
        .fontSize(this.vs(20))
        .fontColor([QQM_TEXT_SUB])

      SymbolGlyph($r('sys.symbol.backward_end_fill'))
        .fontSize(this.vs(28))
        .fontColor([QQM_TEXT_MAIN])
        .margin({ left: this.vs(26) })

      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(56))
          .height(this.vs(56))
          .borderRadius(this.vs(28))
          .linearGradient({
            angle: 135,
            colors: [['#4CD394', 0.0], [QQM_GREEN_DEEP, 1.0]]
          })

        SymbolGlyph($r('sys.symbol.play_fill'))
          .fontSize(this.vs(26))
          .fontColor([Color.White])
      }
      .width(this.vs(56))
      .height(this.vs(56))
      .margin({ left: this.vs(26) })

      SymbolGlyph($r('sys.symbol.forward_end_fill'))
        .fontSize(this.vs(28))
        .fontColor([QQM_TEXT_MAIN])
        .margin({ left: this.vs(26) })

      SymbolGlyph($r('sys.symbol.list_bullet'))
        .fontSize(this.vs(20))
        .fontColor([QQM_TEXT_SUB])
        .margin({ left: this.vs(26) })
    }
    .width('100%')
    .height(this.vs(64))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  modeRow() {
    Row() {
      SymbolGlyph($r('sys.symbol.shuffle'))
        .fontSize(this.vs(16))
        .fontColor([QQM_TEXT_SUB])

      Blank()

      SymbolGlyph($r('sys.symbol.repeat'))
        .fontSize(this.vs(16))
        .fontColor([QQM_GREEN])

      Blank()

      SymbolGlyph($r('sys.symbol.speaker_wave_2'))
        .fontSize(this.vs(16))
        .fontColor([QQM_TEXT_SUB])
    }
    .width('100%')
    .padding({ left: this.vs(60), right: this.vs(60) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  playTipRow() {
    Row({ space: this.vs(4) }) {
      SymbolGlyph($r('sys.symbol.heart'))
        .fontSize(this.vs(11))
        .fontColor([QQM_TEXT_SUB])

      Text('3.2万人 · 觉得好听就点个赞吧')
        .fontSize(this.vs(9))
        .fontColor(QQM_TEXT_SUB)
    }
    .width('100%')
    .height(this.vs(18))
    .margin({ top: this.vs(6) })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        this.playerTopBar()
        this.playerMainArea()
        this.progressRow()
        this.controlRow()
        this.modeRow()
        this.playTipRow()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(QQM_PAGE_BG)
      .padding({ bottom: this.bottomInsetVp })
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
