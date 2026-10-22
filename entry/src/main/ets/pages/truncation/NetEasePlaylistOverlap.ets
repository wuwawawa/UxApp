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
 * 反例：截断 / 网易云歌单曲名压歌手（文字重叠）
 *
 * 复刻对象：网易云音乐「歌单」页 —— 红色渐变头（返回 + 歌单 + 搜索）、
 *   歌单信息卡（渐变封面占位 + 标题「一人一首成名曲 | 华语经典热歌」 +
 *   云音乐官方 / 收藏数）、白色圆角歌单列表（「播放全部 (326)」 + 收藏 / 列表图标）、
 *   6 行歌曲（序号、上方歌名 + 下方歌手的窄列、右侧时长）、
 *   底部迷你播放条（封面占位 + 晴天 - 周杰伦 + 播放 / 列表按钮）。
 *
 * 设计基准（vp，按单屏态 459.6vp 宽绘制）：红色头高 154vp（含状态栏）；歌单信息卡高 110vp、
 *   封面 92×92vp；歌名 15vp 字 / 行高 21vp；歌手 11vp 字，从行顶下移 21vp（定值）；
 *   歌曲行定高 48vp、序号列宽 36vp、歌名列宽 238vp、时长列宽 44vp；迷你播放条高 50vp。
 *
 * 三态实测：
 *   单屏态        459.6vp 宽 —— sceneScale 1.00，歌名行高 21vp 刚好停在 21vp 处的歌手行上方，互不压盖；
 *   双屏态竖屏    664.7vp 宽 —— sceneScale 1.45，歌名行高放大到 30.4vp，歌手行还钉在 21vp 定值处，
 *                              长歌名下半截压到歌手名上；
 *   双屏态横屏    939.6vp 宽 —— sceneScale 2.04，歌名行高 42.9vp，与 21vp 处的歌手行重叠过半，
 *                              歌手行底部还超出 48vp 的定高行，压到下一首的序号。
 *
 * 问题表现：
 *   歌手行距行顶 21vp、歌曲行高 48vp 都是设计稿定值，不随窗口放大；歌名 / 歌手字号与
 *   歌名行高却按 sceneScale 放大 —— 宽窗口下放大后的歌名字形伸进下方歌手行，
 *   「这世界那么多人 (电影主题曲)」与「莫文蔚」两行字互相压盖，6 行歌曲无一幸免。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态折叠屏基准宽度（vp），sceneScale 以它为 1.0 */
const NEM_PLAYLIST_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const NEM_STATUS_BAR_FALLBACK: number = 34;
const NEM_BOTTOM_INSET_FALLBACK: number = 8;

/** 歌曲行定高、序号 / 歌名 / 时长列宽（设计稿照抄的固定值，不随窗口放大） */
const NEM_SONG_ROW_HEIGHT: number = 48;
const NEM_INDEX_COL_WIDTH: number = 36;
const NEM_NAME_COL_WIDTH: number = 238;
const NEM_DURATION_COL_WIDTH: number = 44;
/** 歌手行钉在距行顶 21vp 的定值处（反例根源） */
const NEM_ARTIST_FIXED_Y: number = 21;

const NEM_HEADER_RED: string = '#D33A31';
const NEM_HEADER_RED_DEEP: string = '#B02A26';
const NEM_PAGE_BG: string = '#F2F3F5';
const NEM_LIST_BG: string = '#FFFFFF';
const NEM_NAME_TEXT: string = '#333333';
const NEM_ARTIST_TEXT: string = '#888888';
const NEM_INDEX_TEXT: string = '#9B9B9B';
const NEM_HQ_RED: string = '#E63B2E';
const NEM_DIVIDER: string = '#F0F0F0';

/** 歌曲：序号列内容、歌名与歌手同列堆叠、右侧时长 */
interface NeteaseSongRow {
  songKey: string;
  songName: string;
  artistNames: string;
  songDuration: string;
  hqFlag: boolean;
}

const NEM_PLAYLIST_SONGS: NeteaseSongRow[] = [
  { songKey: 'nem-song-1', songName: '这世界那么多人 (电影主题曲)', artistNames: '莫文蔚', songDuration: '04:39', hqFlag: true },
  { songKey: 'nem-song-2', songName: '体面 (电影《前任3》插曲)', artistNames: '于文文', songDuration: '04:26', hqFlag: false },
  { songKey: 'nem-song-3', songName: '后来 (Live版)', artistNames: '刘若英 / 施人诚', songDuration: '05:12', hqFlag: false },
  { songKey: 'nem-song-4', songName: '年少有为', artistNames: '李荣浩', songDuration: '04:33', hqFlag: true },
  { songKey: 'nem-song-5', songName: '像我这样的人', artistNames: '毛不易', songDuration: '03:48', hqFlag: false },
  { songKey: 'nem-song-6', songName: '慢慢喜欢你 (Live版)', artistNames: '莫文蔚', songDuration: '03:39', hqFlag: false }
];

@Component
export struct NetEasePlaylistOverlapPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = NEM_PLAYLIST_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = NEM_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = NEM_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, NEM_HEADER_RED);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：窗口越宽，页面整体放大越多（单屏态为 1.0） */
  private sceneScale(): number {
    const widthRatio: number = this.winWidthVp / NEM_PLAYLIST_BASE_WIDTH;
    return widthRatio < 1 ? 1 : widthRatio;
  }

  /** 把设计基准值（vp）换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 红色头部与歌单信息卡
  // ------------------------------------------------------------------

  @Builder
  playlistHeader() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Text('歌单')
          .fontSize(this.vs(16))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)

        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(this.vs(20))
              .fontColor([Color.White])
          }
          .width(this.vs(32))
          .height(this.vs(32))
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.pageStack.pop();
          })

          Blank()

          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(this.vs(18))
            .fontColor([Color.White])
        }
        .width('100%')
        .padding({ left: this.vs(8), right: this.vs(12) })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(this.vs(44))

      Row({ space: this.vs(12) }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(this.vs(92))
            .height(this.vs(92))
            .borderRadius(this.vs(8))
            .linearGradient({
              angle: 135,
              colors: [['#7EA8E8', 0.0], ['#B88BD8', 0.6], ['#E88CB8', 1.0]]
            })

          SymbolGlyph($r('sys.symbol.waveform'))
            .fontSize(this.vs(30))
            .fontColor(['#FFFFFF'])
        }
        .width(this.vs(92))
        .height(this.vs(92))

        Column({ space: this.vs(6) }) {
          Text('一人一首成名曲 | 华语经典热歌')
            .fontSize(this.vs(15))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .lineHeight(this.vs(21))
            .maxLines(2)

          Row({ space: this.vs(6) }) {
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width(this.vs(18))
                .height(this.vs(18))
                .borderRadius(this.vs(9))
                .backgroundColor('#F5D8A0')

              SymbolGlyph($r('sys.symbol.person_fill'))
                .fontSize(this.vs(10))
                .fontColor(['#8A5A2A'])
            }
            .width(this.vs(18))
            .height(this.vs(18))

            Text('网易云音乐官方 · 收藏 382万')
              .fontSize(this.vs(10))
              .fontColor('#E8D5D5')
              .maxLines(1)
          }
          .alignItems(VerticalAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(this.vs(110))
      .padding({ left: this.vs(14), right: this.vs(14) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ top: this.statusBarHeightVp })
    .linearGradient({
      angle: 180,
      colors: [[NEM_HEADER_RED, 0.0], [NEM_HEADER_RED_DEEP, 1.0]]
    })
  }

  // ------------------------------------------------------------------
  // 播放全部条与歌曲列表
  // ------------------------------------------------------------------

  @Builder
  playAllBar() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(26))
          .height(this.vs(26))
          .borderRadius(this.vs(13))
          .backgroundColor(NEM_HQ_RED)

        SymbolGlyph($r('sys.symbol.play_fill'))
          .fontSize(this.vs(13))
          .fontColor([Color.White])
      }
      .width(this.vs(26))
      .height(this.vs(26))

      Text('播放全部')
        .fontSize(this.vs(14))
        .fontWeight(FontWeight.Medium)
        .fontColor(NEM_NAME_TEXT)
        .margin({ left: this.vs(6) })

      Text('(326)')
        .fontSize(this.vs(11))
        .fontColor(NEM_ARTIST_TEXT)
        .margin({ left: this.vs(2) })

      Blank()

      SymbolGlyph($r('sys.symbol.star'))
        .fontSize(this.vs(17))
        .fontColor(['#666666'])

      Divider()
        .vertical(true)
        .height(this.vs(16))
        .strokeWidth(this.vs(1))
        .color(NEM_DIVIDER)
        .margin({ left: this.vs(14), right: this.vs(14) })

      SymbolGlyph($r('sys.symbol.list_bullet'))
        .fontSize(this.vs(17))
        .fontColor(['#666666'])
    }
    .width('100%')
    .height(this.vs(44))
    .padding({ left: this.vs(12), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(NEM_LIST_BG)
    .border({ width: { bottom: this.vs(1) }, color: NEM_DIVIDER })
  }

  @Builder
  songRow(songItem: NeteaseSongRow, songIndex: number) {
    Row() {
      // 序号列：定宽 36vp
      Text((songIndex + 1).toString().padStart(2, '0'))
        .fontSize(this.vs(13))
        .fontColor(songIndex === 0 ? NEM_HQ_RED : NEM_INDEX_TEXT)
        .width(NEM_INDEX_COL_WIDTH)
        .textAlign(TextAlign.Center)

      // 歌名 + 歌手同列堆叠：歌手钉在 21vp 定值处，歌名行高随 sceneScale 放大（反例核心）
      Stack({ alignContent: Alignment.TopStart }) {
        Row({ space: this.vs(3) }) {
          if (songItem.hqFlag) {
            Text('HQ')
              .fontSize(this.vs(8))
              .fontColor(NEM_HQ_RED)
              .border({ width: this.vs(1), color: NEM_HQ_RED, radius: this.vs(2) })
              .padding({ left: this.vs(2), right: this.vs(2), top: this.vs(1), bottom: this.vs(1) })
              .margin({ top: this.vs(3) })
          }

          Text(songItem.songName)
            .fontSize(this.vs(15))
            .fontColor(NEM_NAME_TEXT)
            .lineHeight(this.vs(21))
            .maxLines(1)
        }
        .width(NEM_NAME_COL_WIDTH)
        .alignItems(VerticalAlign.Top)

        Text(songItem.artistNames + ' - ' + songItem.songName)
          .fontSize(this.vs(11))
          .fontColor(NEM_ARTIST_TEXT)
          .lineHeight(this.vs(15))
          .maxLines(1)
          .width(NEM_NAME_COL_WIDTH)
          .position({ x: 0, y: NEM_ARTIST_FIXED_Y })
      }
      .layoutWeight(1)
      .height(NEM_SONG_ROW_HEIGHT)
      .clip(false)

      // 时长列：定宽 44vp
      Text(songItem.songDuration)
        .fontSize(this.vs(11))
        .fontColor(NEM_INDEX_TEXT)
        .width(NEM_DURATION_COL_WIDTH)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(NEM_SONG_ROW_HEIGHT)
    .padding({ left: this.vs(10), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(NEM_LIST_BG)
    .border({ width: { bottom: this.vs(1) }, color: NEM_DIVIDER })
    .clip(false)
  }

  @Builder
  songList() {
    Column() {
      ForEach(NEM_PLAYLIST_SONGS, (songItem: NeteaseSongRow, songIndex: number) => {
        this.songRow(songItem, songIndex)
      }, (songItem: NeteaseSongRow) => songItem.songKey)
    }
    .width('100%')
  }

  @Builder
  listFooter() {
    Column() {
      Text('已加载 6/326 首，下拉加载更多')
        .fontSize(this.vs(11))
        .fontColor(NEM_INDEX_TEXT)
        .margin({ top: this.vs(14) })
    }
    .width('100%')
    .height(this.vs(60))
    .alignItems(HorizontalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 底部迷你播放条
  // ------------------------------------------------------------------

  @Builder
  miniPlayerBar() {
    Row({ space: this.vs(8) }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(34))
          .height(this.vs(34))
          .borderRadius(this.vs(4))
          .linearGradient({
            angle: 135,
            colors: [['#8FD8B8', 0.0], ['#4CA88A', 1.0]]
          })

        SymbolGlyph($r('sys.symbol.waveform'))
          .fontSize(this.vs(16))
          .fontColor([Color.White])
      }
      .width(this.vs(34))
      .height(this.vs(34))

      Column() {
        Text('晴天')
          .fontSize(this.vs(12))
          .fontColor(NEM_NAME_TEXT)
          .maxLines(1)

        Text('周杰伦 - 叶惠美')
          .fontSize(this.vs(9))
          .fontColor(NEM_ARTIST_TEXT)
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      SymbolGlyph($r('sys.symbol.play_circle_fill'))
        .fontSize(this.vs(24))
        .fontColor(['#444444'])

      SymbolGlyph($r('sys.symbol.list_bullet'))
        .fontSize(this.vs(20))
        .fontColor(['#444444'])
    }
    .width('100%')
    .height(this.vs(50))
    .padding({ left: this.vs(12), right: this.vs(16) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(NEM_LIST_BG)
    .border({ width: { top: this.vs(1) }, color: NEM_DIVIDER })
    .position({ x: 0, y: this.winHeightVp - this.vs(50) - this.bottomInsetVp })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Scroll() {
          Column() {
            this.playlistHeader()
            this.playAllBar()
            this.songList()
            this.listFooter()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(NEM_PAGE_BG)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)

        this.miniPlayerBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(NEM_PAGE_BG)
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
