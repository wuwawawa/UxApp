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
 * 反例：截断 / 爱奇艺会员弹窗权益截断（弹窗截断）
 *
 * 复刻对象：爱奇艺「视频播放」页上的黄金VIP会员弹窗 —— 深色播放页
 *   （返回 + 狂飙 第32集 + 分享/更多、渐变视频占位区、中央播放按钮、底部红色进度线、
 *   剧集信息与31/32/33选集块），弹窗压在半透明遮罩上：
 *   金棕渐变弹窗（皇冠图标 + 「爱奇艺黄金VIP会员」 + 关闭）、5 条会员权益
 *   （跳过广告 / 蓝光画质 / 抢先看 / 观影券 / 专属客服）、
 *   价格行（首月 ¥6 · 原价¥25 划线）、「立即开通」金色大按钮。
 *
 * 设计基准（vp，按单屏态 459.6vp 宽绘制）：弹窗宽 86%、高为设计稿照抄的定值 428vp；
 *   弹窗内顶部留白 14vp、皇冠行 56vp、权益行 48vp×5、间距 12vp、价格行 44vp、
 *   按钮高 46vp；视频占位高 210vp、选集块 40×34vp。
 *
 * 三态实测：
 *   单屏态        459.6vp 宽 —— sceneScale 1.00，弹窗内容约 422vp 装进 428vp 定高，完整显示；
 *   双屏态竖屏    664.7vp 宽 —— sceneScale 1.45，内容撑到约 611vp，第 5 条权益「专属客服」
 *                              下半截被弹窗下沿裁掉，价格行与「立即开通」按钮整体消失；
 *   双屏态横屏    939.6vp 宽 —— sceneScale 2.04，内容约 863vp，第 4 条以下全部被裁掉，
 *                              只剩 3 条权益和一个不完整的弹窗。
 *
 * 问题表现：
 *   会员弹窗高度是设计稿定值 428vp，不随窗口放大；弹窗内的皇冠行、5 条权益行、
 *   价格行与「立即开通」按钮全部按 sceneScale 放大 —— 宽窗口下内容总高远超弹窗定高，
 *   第 5 条权益与「立即开通」按钮被弹窗下沿裁掉，用户根本点不到开通入口。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态折叠屏基准宽度（vp），sceneScale 以它为 1.0 */
const IQY_DIALOG_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const IQY_STATUS_BAR_FALLBACK: number = 34;
const IQY_BOTTOM_INSET_FALLBACK: number = 8;

/** 会员弹窗定高：设计稿照抄的固定值（vp），不随窗口放大 —— 反例根源 */
const IQY_DIALOG_FIXED_HEIGHT: number = 428;

const IQY_VIDEO_DARK: string = '#1C1C1E';
const IQY_PAGE_DARK: string = '#161618';
const IQY_VIDEO_TOP: string = '#454550';
const IQY_VIDEO_BOTTOM: string = '#232328';
const IQY_PROGRESS_RED: string = '#E8372E';
const IQY_TEXT_MAIN: string = '#F0F0F0';
const IQY_TEXT_SUB: string = '#8A8A90';
const IQY_DIALOG_TOP: string = '#3A2C15';
const IQY_DIALOG_BOTTOM: string = '#221A0E';
const IQY_DIALOG_BORDER: string = '#C9A25E';
const IQY_GOLD_TEXT: string = '#E8C377';
const IQY_GOLD_DEEP: string = '#F5D48A';
const IQY_GOLD_FADE: string = '#8A7A5A';
const IQY_BTN_TEXT: string = '#4A3416';
const IQY_BENEFIT_TEXT: string = '#E8D9B0';
const IQY_EPISODE_BG: string = '#2C2C30';

/** 会员权益行：benefitKey 用于 ForEach 键 */
interface IqiyiBenefitEntry {
  benefitKey: string;
  benefitText: string;
}

const IQY_VIP_BENEFITS: IqiyiBenefitEntry[] = [
  { benefitKey: 'iqy-benefit-1', benefitText: '跳过视频广告，追剧更畅快' },
  { benefitKey: 'iqy-benefit-2', benefitText: '蓝光画质，最高 1080P 蓝光帧绮映' },
  { benefitKey: 'iqy-benefit-3', benefitText: '会员抢先看，热门剧集提前 6 集观看' },
  { benefitKey: 'iqy-benefit-4', benefitText: '每月赠送 2 张免费观影券' },
  { benefitKey: 'iqy-benefit-5', benefitText: '专属客服，极速接入优先处理' }
];

@Component
export struct IqiyiVipDialogTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = IQY_DIALOG_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = IQY_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = IQY_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, IQY_VIDEO_DARK);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：窗口越宽，页面整体放大越多（单屏态为 1.0） */
  private sceneScale(): number {
    const widthRatio: number = this.winWidthVp / IQY_DIALOG_BASE_WIDTH;
    return widthRatio < 1 ? 1 : widthRatio;
  }

  /** 把设计基准值（vp）换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 底层视频播放页
  // ------------------------------------------------------------------

  @Builder
  videoTopBar() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(20))
          .fontColor([IQY_TEXT_MAIN])
      }
      .width(this.vs(32))
      .height(this.vs(32))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.pageStack.pop();
      })

      Text('狂飙 第32集')
        .fontSize(this.vs(14))
        .fontColor(IQY_TEXT_MAIN)
        .margin({ left: this.vs(4) })

      Blank()

      SymbolGlyph($r('sys.symbol.share'))
        .fontSize(this.vs(16))
        .fontColor([IQY_TEXT_MAIN])

      SymbolGlyph($r('sys.symbol.line_3_horizontal'))
        .fontSize(this.vs(16))
        .fontColor([IQY_TEXT_MAIN])
        .margin({ left: this.vs(14) })
    }
    .width('100%')
    .height(this.vs(40))
    .padding({ left: this.vs(8), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  videoBlock() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [[IQY_VIDEO_TOP, 0.0], [IQY_VIDEO_BOTTOM, 1.0]]
        })

      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(64))
          .height(this.vs(64))
          .borderRadius(this.vs(32))
          .backgroundColor('#33000000')
          .border({ width: this.vs(1), color: '#66FFFFFF' })

        SymbolGlyph($r('sys.symbol.play_round_triangle_fill'))
          .fontSize(this.vs(28))
          .fontColor([IQY_TEXT_MAIN])
      }
      .width(this.vs(64))
      .height(this.vs(64))
      .position({ x: '40%', y: '32%' })

      Column() {
        Row()
          .width('66%')
          .height(this.vs(2))
          .backgroundColor(IQY_PROGRESS_RED)
          .borderRadius(this.vs(1))

        Row()
          .width(this.vs(8))
          .height(this.vs(8))
          .borderRadius(this.vs(4))
          .backgroundColor(IQY_PROGRESS_RED)
          .margin({ left: '64%', top: -this.vs(3) })
      }
      .width('100%')
      .padding({ left: this.vs(12), right: this.vs(12), bottom: this.vs(8) })
    }
    .width('100%')
    .height(this.vs(210))
    .clip(true)
  }

  @Builder
  episodeChip(epLabel: string, epActive: boolean) {
    Text(epLabel)
      .fontSize(this.vs(12))
      .fontColor(epActive ? IQY_GOLD_TEXT : IQY_TEXT_SUB)
      .width(this.vs(40))
      .height(this.vs(34))
      .textAlign(TextAlign.Center)
      .backgroundColor(IQY_EPISODE_BG)
      .borderRadius(this.vs(6))
      .border({ width: epActive ? this.vs(1) : 0, color: IQY_DIALOG_BORDER })
  }

  @Builder
  episodeInfoSection() {
    Column() {
      Row({ space: this.vs(8) }) {
        Text('狂飙')
          .fontSize(this.vs(16))
          .fontWeight(FontWeight.Bold)
          .fontColor(IQY_TEXT_MAIN)

        Text('会员抢先看')
          .fontSize(this.vs(9))
          .fontColor(IQY_GOLD_TEXT)
          .border({ width: this.vs(1), color: IQY_DIALOG_BORDER, radius: this.vs(3) })
          .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(1), bottom: this.vs(1) })

        Text('悬疑 · 2023 · 张译 / 张颂文 · 更新至39集')
          .fontSize(this.vs(10))
          .fontColor(IQY_TEXT_SUB)
          .maxLines(1)
          .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: this.vs(8) }) {
        this.episodeChip('31', false)
        this.episodeChip('32', true)
        this.episodeChip('33', false)
        this.episodeChip('34', false)

        Text('更多 ▾')
          .fontSize(this.vs(11))
          .fontColor(IQY_TEXT_SUB)
          .margin({ left: this.vs(4) })
      }
      .width('100%')
      .margin({ top: this.vs(14) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: this.vs(14), right: this.vs(14), top: this.vs(12) })
    .backgroundColor(IQY_PAGE_DARK)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  videoLayer() {
    Column() {
      Column() {
        this.videoTopBar()
      }
      .width('100%')
      .padding({ top: this.statusBarHeightVp })
      .alignItems(HorizontalAlign.Start)

      this.videoBlock()
      this.episodeInfoSection()
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(IQY_PAGE_DARK)
    .clip(true)
  }

  // ------------------------------------------------------------------
  // 会员弹窗（定高 428vp，内容按 sceneScale 放大 —— 反例核心）
  // ------------------------------------------------------------------

  @Builder
  vipLogoRow() {
    Row({ space: this.vs(8) }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(34))
          .height(this.vs(34))
          .borderRadius(this.vs(17))
          .linearGradient({
            angle: 135,
            colors: [['#F7DFA0', 0.0], ['#D8A24E', 1.0]]
          })

        SymbolGlyph($r('sys.symbol.crown_fill'))
          .fontSize(this.vs(18))
          .fontColor(['#4A3416'])
      }
      .width(this.vs(34))
      .height(this.vs(34))

      Column() {
        Text('爱奇艺黄金VIP会员')
          .fontSize(this.vs(15))
          .fontWeight(FontWeight.Bold)
          .fontColor(IQY_GOLD_DEEP)

        Text('黄金会员 · 影视全能看')
          .fontSize(this.vs(9))
          .fontColor(IQY_GOLD_FADE)
          .margin({ top: this.vs(2) })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(this.vs(14))
        .fontColor(['#A89868'])
        .onClick(() => {
          this.pageStack.pop();
        })
    }
    .width('100%')
    .height(this.vs(56))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  benefitRow(benefitItem: IqiyiBenefitEntry) {
    Row({ space: this.vs(8) }) {
      SymbolGlyph($r('sys.symbol.checkmark_circle'))
        .fontSize(this.vs(16))
        .fontColor([IQY_GOLD_TEXT])

      Text(benefitItem.benefitText)
        .fontSize(this.vs(12.5))
        .fontColor(IQY_BENEFIT_TEXT)
        .maxLines(1)
        .layoutWeight(1)
    }
    .width('100%')
    .height(this.vs(48))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  vipPriceRow() {
    Row() {
      Text('首月')
        .fontSize(this.vs(11))
        .fontColor(IQY_GOLD_FADE)
        .margin({ top: this.vs(12) })

      Text('¥')
        .fontSize(this.vs(16))
        .fontWeight(FontWeight.Bold)
        .fontColor(IQY_GOLD_DEEP)
        .margin({ left: this.vs(2) })

      Text('6')
        .fontSize(this.vs(34))
        .fontWeight(FontWeight.Bold)
        .fontColor(IQY_GOLD_DEEP)

      Text('/月')
        .fontSize(this.vs(11))
        .fontColor(IQY_GOLD_FADE)
        .margin({ left: this.vs(2), top: this.vs(12) })

      Blank()

      Text('原价¥25')
        .fontSize(this.vs(11))
        .fontColor(IQY_GOLD_FADE)
        .decoration({ type: TextDecorationType.LineThrough })
    }
    .width('100%')
    .height(this.vs(44))
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  openVipBtn() {
    Row({ space: this.vs(4) }) {
      Text('立即开通')
        .fontSize(this.vs(16))
        .fontWeight(FontWeight.Bold)
        .fontColor(IQY_BTN_TEXT)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(this.vs(14))
        .fontColor([IQY_BTN_TEXT])
    }
    .width('100%')
    .height(this.vs(46))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .linearGradient({
      angle: 90,
      colors: [['#F7DFA0', 0.0], ['#E5B35F', 1.0]]
    })
    .borderRadius(this.vs(23))
    .shadow({ radius: this.vs(8), color: '#4DE5B35F', offsetX: 0, offsetY: this.vs(2) })
  }

  @Builder
  vipDialog() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 弹窗内容：皇冠行 → 5 条权益 → 价格行 → 开通按钮，全部按 sceneScale 放大
      Column() {
        this.vipLogoRow()

        ForEach(IQY_VIP_BENEFITS, (benefitItem: IqiyiBenefitEntry) => {
          this.benefitRow(benefitItem)
        }, (benefitItem: IqiyiBenefitEntry) => benefitItem.benefitKey)

        Column() {
          this.vipPriceRow()
          this.openVipBtn()
        }
        .width('100%')
        .margin({ top: this.vs(12) })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: this.vs(16), right: this.vs(16), top: this.vs(14) })
      .alignItems(HorizontalAlign.Start)
    }
    .width('86%')
    .height(IQY_DIALOG_FIXED_HEIGHT)
    .linearGradient({
      angle: 180,
      colors: [[IQY_DIALOG_TOP, 0.0], [IQY_DIALOG_BOTTOM, 1.0]]
    })
    .border({ width: this.vs(1), color: IQY_DIALOG_BORDER, radius: this.vs(16) })
    .shadow({ radius: this.vs(20), color: '#66000000', offsetX: 0, offsetY: this.vs(4) })
    .clip(true)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        this.videoLayer()

        // 半透明遮罩：压暗播放页
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.6)
          .hitTestBehavior(HitTestMode.None)

        this.vipDialog()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(IQY_PAGE_DARK)
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
