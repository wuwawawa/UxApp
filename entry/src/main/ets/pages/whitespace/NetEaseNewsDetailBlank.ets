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
 * 反例：留白过多 / 网易新闻正文两侧空档
 *
 * 复刻对象：网易新闻 App 新闻详情页，双屏态。顶部整窗宽的红色渐变头：左返回箭头、
 *   居中标题「新闻详情」、右侧分享图标与「3562跟帖」胶囊；头图下方全部内容
 *   ——新闻标题「神舟十九号航天员乘组完成首次出舱活动 全程高清回顾」、
 *   来源行（新华社 · 02-14 08:31 · 约3分钟 · 红色「+ 关注」）、五段正文、
 *   「相关推荐」卡片（三条相关新闻）、免责声明，以及底部跟帖栏
 *   （「写跟帖...」输入胶囊 + 收藏 / 分享）——全部固定在 459.6vp 的单屏内容列里
 *   贴窗口左缘排布，右侧直到屏幕边缘全是页面底色。
 *
 * 设计基准：以单屏折叠态 459.6×672vp 为基准宽度 1:1 还原移动端排版。
 *   所有尺寸 / 字号按 窗口宽度 / 459.6 换算（sceneScale）后把倍率钳制在 1.04
 *   ——宽窗口下正文列只放大 4%，不铺满窗口，右侧留白随窗口宽度线性增大。
 *   状态栏占位 36vp；头部高 84vp（红渐变 #D43C33 → #F0625A）；
 *   标题 21vp / 行高 32vp；来源行字 14/12vp；正文 16vp / 行高 27vp；
 *   相关新闻行标题 15vp；底部跟帖栏高 56vp。
 *
 * 三态实测（内容列宽 = 459.6 × sceneScale，右缘之外全是页面底色的空白）：
 *   单屏态      459.6×672vp   —— 内容列与窗口同宽，无额外留白（正常形态）；
 *   双屏态竖屏  664.7×939.6vp —— 内容列 478.0vp，右侧空出 186.7vp，约占宽度的 28%，
 *                                正文窄窄一条贴左边，右侧大片空白像没加载完；
 *   双屏态横屏  939.6×664.7vp —— 内容列 478.0vp，右侧空出 461.6vp，约占宽度的 49%。
 *
 * 问题表现：
 *   正文、相关推荐、免责声明的文字列全部锁死在一条手机宽度里贴左排；
 *   双屏展开后窗口宽了一倍，文字列却不挪一步，右侧整块空白
 *   看起来就像正文只加载了一半；顶部红色头图横贯整窗，
 *   把下方右侧的大片留白衬得格外刺眼。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：浅灰页面、白卡片、近黑正文、灰副标题、网易红、链接蓝 */
const WSNES_PAGE_BG: string = '#F4F5F6';
const WSNES_CARD_BG: string = '#FFFFFF';
const WSNES_TEXT_MAIN: string = '#1F1F26';
const WSNES_TEXT_BODY: string = '#333340';
const WSNES_TEXT_SUB: string = '#8E8E99';
const WSNES_RED_TOP: string = '#D43C33';
const WSNES_RED_BOTTOM: string = '#F0625A';
const WSNES_RED_MAIN: string = '#D43C33';
const WSNES_RED_BG: string = '#FDECEA';
const WSNES_LINK_BLUE: string = '#4E7BB5';
const WSNES_DIVIDER: string = '#EFEFF2';
const WSNES_INPUT_BG: string = '#F2F3F5';

/** 基准：单屏折叠态窗口宽 459.6vp；宽窗口下缩放倍率钳制在 1.04 */
const WSNES_BASE_WIDTH: number = 459.6;
const WSNES_MAX_SCALE: number = 1.04;

/** 头部：状态栏占位 36vp + 内容行 48vp = 84vp */
const WSNES_STATUS_PAD: number = 36;
const WSNES_HEADER_HEIGHT: number = 84;
const WSNES_HEADER_PAD_SIDE: number = 14;
const WSNES_HEADER_ICON: number = 20;
const WSNES_HEADER_ICON_GAP: number = 16;
const WSNES_TITLE_FONT: number = 17;
const WSNES_FOLLOW_PILL_H: number = 26;
const WSNES_FOLLOW_PILL_FONT: number = 12;
const WSNES_FOLLOW_PILL_PAD_H: number = 10;

/** 内容列内边距 */
const WSNES_CONTENT_PAD: number = 16;

/** 新闻标题块 */
const WSNES_NEWS_TITLE_FONT: number = 21;
const WSNES_NEWS_TITLE_LINE: number = 32;
const WSNES_SOURCE_FONT: number = 14;
const WSNES_TIME_FONT: number = 12;

/** 正文段落 */
const WSNES_BODY_FONT: number = 16;
const WSNES_BODY_LINE: number = 27;
const WSNES_PARA_GAP: number = 12;

/** 相关推荐 */
const WSNES_SECTION_TITLE_FONT: number = 15;
const WSNES_REL_TITLE_FONT: number = 15;
const WSNES_REL_TITLE_LINE: number = 21;
const WSNES_REL_META_FONT: number = 11;
const WSNES_REL_GAP: number = 12;
const WSNES_CARD_RADIUS: number = 10;
const WSNES_CARD_PAD: number = 14;

/** 免责声明 */
const WSNES_DISCLAIM_FONT: number = 11;
const WSNES_DISCLAIM_LINE: number = 17;

/** 底部跟帖栏 */
const WSNES_BAR_HEIGHT: number = 56;
const WSNES_BAR_PAD_SIDE: number = 14;
const WSNES_BAR_ICON: number = 20;
const WSNES_BAR_GAP: number = 16;
const WSNES_INPUT_PILL_H: number = 36;
const WSNES_INPUT_PILL_RADIUS: number = 18;
const WSNES_INPUT_FONT: number = 13;
const WSNES_INPUT_PAD_H: number = 14;

/** 正文段落 */
interface NeteaseNewsParagraph {
  paraKey: string;
  paraText: string;
}

/** 相关新闻条目 */
interface NeteaseRelatedItem {
  relatedKey: string;
  relatedTitle: string;
  relatedSource: string;
  relatedCommentCount: string;
}

const WSNES_PARAGRAPHS: NeteaseNewsParagraph[] = [
  {
    paraKey: 'nes-para-open',
    paraText: '据中国载人航天工程办公室消息，北京时间今日凌晨，神舟十九号航天员乘组圆满完成首次出舱活动，整个出舱过程历时约 8 小时，三名航天员状态良好。'
  },
  {
    paraKey: 'nes-para-crew',
    paraText: '出舱活动由航天员蔡旭哲、宋令东执行，王浩泽留守舱内进行配合支持。这也是我国航天员在新一代「飞天」舱外航天服加持下完成的最长一次出舱任务。'
  },
  {
    paraKey: 'nes-para-task',
    paraText: '在地面科研人员的全程支持下，乘组先后完成了舱外设备安装、全景相机抬升、外部管路检查等既定任务，各项操作精准顺利，空间站组合体运行稳定。'
  },
  {
    paraKey: 'nes-para-airlock',
    paraText: '值得注意的是，本次出舱首次启用了问天实验舱新增的气闸舱出舱通道，出舱准备时间较此前缩短约一半，出舱效率整体提升了约 30%。'
  },
  {
    paraKey: 'nes-para-next',
    paraText: '后续，乘组还将按计划开展大量空间科学实验与技术试验，继续验证空间站长期在轨运营的关键技术，为后续任务积累宝贵经验。'
  }
];

const WSNES_RELATED: NeteaseRelatedItem[] = [
  {
    relatedKey: 'nes-rel-hotpot',
    relatedTitle: '神舟十九号乘组太空吃火锅？航天员能量餐大揭秘',
    relatedSource: '环球网军事',
    relatedCommentCount: '8902跟帖'
  },
  {
    relatedKey: 'nes-rel-sample',
    relatedTitle: '中国空间站第十批空间科学实验样品顺利返回',
    relatedSource: '科技日报',
    relatedCommentCount: '3411跟帖'
  },
  {
    relatedKey: 'nes-rel-next',
    relatedTitle: '下一次出舱活动已在规划 或与国外航天员联合实施',
    relatedSource: '央视新闻',
    relatedCommentCount: '1.2万跟帖'
  }
];

@Component
export struct NetEaseNewsDetailBlankPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

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

  /** 整页缩放比：窗口宽度 / 单屏基准宽度（459.6vp），
   *  放大倍率钳制在 1.04 —— 宽窗口下正文列只轻微放大、不铺满窗口（留白反例根源） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return Math.min(this.winWidthVp / WSNES_BASE_WIDTH, WSNES_MAX_SCALE);
  }

  /** 把基准宽度下的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶部：整窗宽红色渐变头（返回 + 标题 + 分享 / 跟帖胶囊）
  // ------------------------------------------------------------------

  @Builder
  commentPill() {
    Row({ space: this.vs(4) }) {
      SymbolGlyph($r('sys.symbol.message'))
        .fontSize(this.vs(14))
        .fontColor([Color.White])

      Text('3562跟帖')
        .fontSize(this.vs(WSNES_FOLLOW_PILL_FONT))
        .fontColor(Color.White)
        .maxLines(1)
    }
    .height(this.vs(WSNES_FOLLOW_PILL_H))
    .padding({
      left: this.vs(WSNES_FOLLOW_PILL_PAD_H),
      right: this.vs(WSNES_FOLLOW_PILL_PAD_H)
    })
    .backgroundColor('#33FFFFFF')
    .borderRadius(this.vs(WSNES_FOLLOW_PILL_H / 2))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  headerBand() {
    Stack({ alignContent: Alignment.Center }) {
      Text('新闻详情')
        .fontSize(this.vs(WSNES_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .maxLines(1)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(WSNES_HEADER_ICON))
          .fontColor([Color.White])
          .width(this.vs(44))
          .height(this.vs(44))
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Row({ space: this.vs(WSNES_HEADER_ICON_GAP) }) {
          SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
            .fontSize(this.vs(WSNES_HEADER_ICON))
            .fontColor([Color.White])

          this.commentPill()
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: this.vs(WSNES_HEADER_PAD_SIDE),
        right: this.vs(WSNES_HEADER_PAD_SIDE)
      })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(WSNES_HEADER_HEIGHT))
    .linearGradient({
      angle: 180,
      colors: [[WSNES_RED_TOP, 0.0], [WSNES_RED_BOTTOM, 1.0]]
    })
    .padding({ top: this.vs(WSNES_STATUS_PAD) })
  }

  // ------------------------------------------------------------------
  // 新闻标题 + 来源行
  // ------------------------------------------------------------------

  @Builder
  newsTitleBlock() {
    Column({ space: this.vs(10) }) {
      Text('神舟十九号航天员乘组完成首次出舱活动 全程高清回顾')
        .fontSize(this.vs(WSNES_NEWS_TITLE_FONT))
        .lineHeight(this.vs(WSNES_NEWS_TITLE_LINE))
        .fontWeight(FontWeight.Bold)
        .fontColor(WSNES_TEXT_MAIN)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({ space: this.vs(8) }) {
        Text('新华社')
          .fontSize(this.vs(WSNES_SOURCE_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(WSNES_LINK_BLUE)
          .maxLines(1)

        Text('02-14 08:31 · 约3分钟')
          .fontSize(this.vs(WSNES_TIME_FONT))
          .fontColor(WSNES_TEXT_SUB)
          .maxLines(1)

        Blank()

        Text('+ 关注')
          .fontSize(this.vs(WSNES_FOLLOW_PILL_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(WSNES_RED_MAIN)
          .maxLines(1)
          .height(this.vs(WSNES_FOLLOW_PILL_H))
          .padding({
            left: this.vs(WSNES_FOLLOW_PILL_PAD_H),
            right: this.vs(WSNES_FOLLOW_PILL_PAD_H)
          })
          .textAlign(TextAlign.Center)
          .backgroundColor(WSNES_RED_BG)
          .borderRadius(this.vs(WSNES_FOLLOW_PILL_H / 2))
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: this.vs(14) })
  }

  // ------------------------------------------------------------------
  // 正文段落
  // ------------------------------------------------------------------

  @Builder
  articleBlock() {
    Column({ space: this.vs(WSNES_PARA_GAP) }) {
      ForEach(WSNES_PARAGRAPHS, (para: NeteaseNewsParagraph) => {
        Text(para.paraText)
          .fontSize(this.vs(WSNES_BODY_FONT))
          .lineHeight(this.vs(WSNES_BODY_LINE))
          .fontColor(WSNES_TEXT_BODY)
          .width('100%')
      }, (para: NeteaseNewsParagraph) => para.paraKey)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: this.vs(WSNES_PARA_GAP) })
  }

  // ------------------------------------------------------------------
  // 相关推荐
  // ------------------------------------------------------------------

  @Builder
  relatedRow(item: NeteaseRelatedItem, showDivider: boolean) {
    Column() {
      Row({ space: this.vs(8) }) {
        Text(item.relatedTitle)
          .fontSize(this.vs(WSNES_REL_TITLE_FONT))
          .lineHeight(this.vs(WSNES_REL_TITLE_LINE))
          .fontColor(WSNES_TEXT_MAIN)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(14))
          .fontColor([WSNES_TEXT_SUB])
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: this.vs(8) }) {
        Text(item.relatedSource)
          .fontSize(this.vs(WSNES_REL_META_FONT))
          .fontColor(WSNES_TEXT_SUB)
          .maxLines(1)

        Text(item.relatedCommentCount)
          .fontSize(this.vs(WSNES_REL_META_FONT))
          .fontColor(WSNES_LINK_BLUE)
          .maxLines(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (showDivider) {
        Row()
          .width('100%')
          .height(this.vs(0.5))
          .backgroundColor(WSNES_DIVIDER)
          .margin({ top: this.vs(WSNES_REL_GAP / 2) })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: this.vs(WSNES_REL_GAP / 2), bottom: this.vs(WSNES_REL_GAP / 2) })
  }

  @Builder
  relatedCard() {
    Column() {
      Text('相关推荐')
        .fontSize(this.vs(WSNES_SECTION_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(WSNES_TEXT_MAIN)
        .maxLines(1)

      ForEach(WSNES_RELATED, (item: NeteaseRelatedItem) => {
        this.relatedRow(item, item.relatedKey !== 'nes-rel-next')
      }, (item: NeteaseRelatedItem) => item.relatedKey)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(this.vs(WSNES_CARD_PAD))
    .backgroundColor(WSNES_CARD_BG)
    .borderRadius(this.vs(WSNES_CARD_RADIUS))
    .margin({ top: this.vs(WSNES_PARA_GAP) })
  }

  @Builder
  disclaimerBlock() {
    Text('特别声明：本文为网易自媒体平台「网易号」作者上传并发布，仅代表该作者观点。网易平台仅提供信息存储服务。')
      .fontSize(this.vs(WSNES_DISCLAIM_FONT))
      .lineHeight(this.vs(WSNES_DISCLAIM_LINE))
      .fontColor(WSNES_TEXT_SUB)
      .width('100%')
      .margin({ top: this.vs(WSNES_PARA_GAP) })
  }

  // ------------------------------------------------------------------
  // 底部跟帖栏：写跟帖输入胶囊 + 收藏 / 分享
  // ------------------------------------------------------------------

  @Builder
  commentBar() {
    Row({ space: this.vs(WSNES_BAR_GAP) }) {
      Row({ space: this.vs(6) }) {
        SymbolGlyph($r('sys.symbol.message'))
          .fontSize(this.vs(14))
          .fontColor([WSNES_TEXT_SUB])

        Text('写跟帖...')
          .fontSize(this.vs(WSNES_INPUT_FONT))
          .fontColor(WSNES_TEXT_SUB)
          .maxLines(1)
      }
      .height(this.vs(WSNES_INPUT_PILL_H))
      .layoutWeight(1)
      .padding({ left: this.vs(WSNES_INPUT_PAD_H), right: this.vs(WSNES_INPUT_PAD_H) })
      .backgroundColor(WSNES_INPUT_BG)
      .borderRadius(this.vs(WSNES_INPUT_PILL_RADIUS))
      .alignItems(VerticalAlign.Center)

      SymbolGlyph($r('sys.symbol.heart'))
        .fontSize(this.vs(WSNES_BAR_ICON))
        .fontColor([WSNES_TEXT_MAIN])

      SymbolGlyph($r('sys.symbol.star'))
        .fontSize(this.vs(WSNES_BAR_ICON))
        .fontColor([WSNES_TEXT_MAIN])

      SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
        .fontSize(this.vs(WSNES_BAR_ICON))
        .fontColor([WSNES_TEXT_MAIN])
    }
    .width('100%')
    .height(this.vs(WSNES_BAR_HEIGHT))
    .padding({
      left: this.vs(WSNES_BAR_PAD_SIDE),
      right: this.vs(WSNES_BAR_PAD_SIDE)
    })
    .backgroundColor(WSNES_CARD_BG)
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 内容列：固定基准宽度、贴窗口左缘，右侧留白
  // ------------------------------------------------------------------

  @Builder
  contentStage() {
    Row() {
      Column() {
        Scroll() {
          Column() {
            this.newsTitleBlock()

            this.articleBlock()

            this.relatedCard()

            this.disclaimerBlock()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: this.vs(WSNES_CONTENT_PAD),
            right: this.vs(WSNES_CONTENT_PAD)
          })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .align(Alignment.Start)

        this.commentBar()
      }
      .width(this.vs(WSNES_BASE_WIDTH))
      .height('100%')
      .backgroundColor(WSNES_PAGE_BG)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(VerticalAlign.Top)
    .backgroundColor(WSNES_PAGE_BG)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        this.contentStage()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSNES_PAGE_BG)
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
