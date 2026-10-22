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
 * 反例：留白过多 / 马蜂窝攻略上下空档
 *
 * 复刻对象：马蜂窝 App 攻略详情页，双屏展开态。顶部白色标题栏：返回箭头、
 *   居中标题「攻略详情」、右侧收藏与分享；正文区是标题「三亚5天4晚自由行超全攻略：
 *   人均1500玩转海岛」、作者行（旅行家小蜂 · LV.12 · 黄色「+ 关注」按钮）、
 *   六段攻略正文（交通 / 住宿 / 行程 / 美食 / 防坑）、「行程美图」照片九宫格
 *   （两排三个渐变占位）、「热门评论」三条评论与结尾「到底啦」。
 *   版块与版块之间的竖向间距按窗口高度线性放大，展开态（尤其竖屏）被拉出
 *   一大段空档，整个版面稀稀拉拉；同时内容列仍固定在 459.6vp 基准宽贴左排布。
 *
 * 设计基准：以单屏折叠态 459.6×672vp 为基准宽度 1:1 还原移动端排版。
 *   尺寸 / 字号按 窗口宽度 / 459.6 换算（sceneScale）后把倍率钳制在 1.03；
 *   版块间距额外按 窗口高度 / 672 线性放大（每高 1vp 间距加 0.28vp）
 *   ——复现 Web 端「用视口高度撑开版块间距」的适配缺陷。
 *   标题 20vp / 行高 30vp；作者头像 44vp 圆；正文 15vp / 行高 24vp；
 *   照片占位高 105vp、圆角 8vp；评论字 13vp / 行高 20vp；头部高 80vp。
 *
 * 三态实测（版块间距 = 14.4vp + max(0, (窗口高 − 672) × 0.28)）：
 *   单屏态      459.6×672vp   —— 间距 14vp，版面紧凑（正常形态）；
 *   双屏态竖屏  664.7×939.6vp —— 间距拉大到约 89.4vp，正文与美图、美图与评论区
 *                                之间各空出一大段，6 个版块间隙共多出约 450vp，
 *                                版面稀稀拉拉；内容列 473.4vp，右侧另空 191.3vp；
 *   双屏态横屏  939.6×664.7vp —— 竖向间距正常（14.4vp），但内容列 473.4vp，
 *                                右侧空出 466.2vp，约占宽度的 50%。
 *
 * 问题表现：
 *   展开态竖屏下攻略正文与评论区之间空出一大段纯背景，读者要滚过一屏多的空白
 *   才能到下一个版块；版面像没加载完一样稀稀拉拉；
 *   横屏下则是整条内容带贴左、右半屏空无一物。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：页面外圈浅灰、内容列纯白、近黑正文、灰副标题、马蜂窝黄 */
const WSMFW_PAGE_BG: string = '#F5F6F7';
const WSMFW_TEXT_MAIN: string = '#1F1F26';
const WSMFW_TEXT_SUB: string = '#9A9AA6';
const WSMFW_BRAND_YELLOW: string = '#FF9D00';
const WSMFW_LV_GOLD: string = '#B9802E';
const WSMFW_LV_BG: string = '#FBF3E4';
const WSMFW_DIVIDER: string = '#EFEFF2';

/** 基准：单屏折叠态 459.6×672vp；宽窗口下缩放倍率钳制在 1.03 */
const WSMFW_BASE_WIDTH: number = 459.6;
const WSMFW_MAX_SCALE: number = 1.03;
const WSMFW_BASE_HEIGHT: number = 672;
/** 版块间距随窗口高度放大的系数（每高 1vp 加 0.28vp） */
const WSMFW_GAP_GROW: number = 0.28;
/** 基准版块间距 */
const WSMFW_BLOCK_GAP: number = 14;

/** 头部：状态栏占位 36vp + 内容行 44vp = 80vp */
const WSMFW_STATUS_PAD: number = 36;
const WSMFW_HEADER_HEIGHT: number = 80;
const WSMFW_HEADER_PAD_SIDE: number = 14; const WSMFW_HEADER_ICON: number = 20;
const WSMFW_HEADER_ICON_GAP: number = 18; const WSMFW_TITLE_FONT: number = 17;

/** 内容列左右内边距 */
const WSMFW_CONTENT_PAD: number = 16;

/** 攻略标题块 */
const WSMFW_GUIDE_TITLE_FONT: number = 20; const WSMFW_GUIDE_TITLE_LINE: number = 30;
const WSMFW_META_FONT: number = 12;

/** 作者行 */
const WSMFW_AVATAR_SIZE: number = 44; const WSMFW_NAME_FONT: number = 14;
const WSMFW_LV_FONT: number = 10; const WSMFW_AUTHOR_SUB_FONT: number = 11;
const WSMFW_FOLLOW_W: number = 72; const WSMFW_FOLLOW_H: number = 30;
const WSMFW_FOLLOW_FONT: number = 13;

/** 正文 */
const WSMFW_BODY_FONT: number = 15; const WSMFW_BODY_LINE: number = 24; const WSMFW_PARA_GAP: number = 10;

/** 照片九宫格 */
const WSMFW_SECTION_TITLE_FONT: number = 15; const WSMFW_SECTION_MORE_FONT: number = 12;
const WSMFW_PHOTO_H: number = 105; const WSMFW_PHOTO_GAP: number = 8;
const WSMFW_PHOTO_ICON: number = 18; const WSMFW_PHOTO_RADIUS: number = 8;

/** 评论 */
const WSMFW_CMT_AVATAR: number = 34; const WSMFW_CMT_NAME_FONT: number = 13;
const WSMFW_CMT_TIME_FONT: number = 11; const WSMFW_CMT_FONT: number = 13;
const WSMFW_CMT_LINE: number = 20; const WSMFW_CMT_LIKE_FONT: number = 11;
const WSMFW_CMT_GAP: number = 14; const WSMFW_FOOTER_FONT: number = 12;

/** 攻略正文段落 */
interface MfwGuideParagraph {
  paraKey: string;
  paraText: string;
}

/** 照片占位 */
interface MfwGuidePhoto {
  photoKey: string;
  photoTopColor: string;
  photoBottomColor: string;
}

/** 评论 */
interface MfwGuideComment {
  commentKey: string;
  commenterName: string;
  commentTime: string;
  commentText: string;
  likeCount: string;
  avTopColor: string;
  avBottomColor: string;
}

const WSMFW_PARAGRAPHS: MfwGuideParagraph[] = [
  { paraKey: 'mfw-para-intro', paraText: '三亚真的是一座去了还想再去的城市，这次 5 天 4 晚人均只花了 1500，把行程、住宿、防坑要点全部整理在这篇攻略里，照抄就能玩。' },
  { paraKey: 'mfw-para-traffic', paraText: '【交通】机票建议提前 30 天以上预订，广州出发往返含税经常有 600 以内的价格；落地后别在机场坐黑车，机场大巴 8 号线到市区只要 20 块一个人。' },
  { paraKey: 'mfw-para-hotel', paraText: '【住宿】第一次来建议住大东海，性价比最高；亚龙湾适合度假躺酒店，海棠湾适合带孩子泡酒店。旺季记得提前一个月订，价格能差出一倍。' },
  { paraKey: 'mfw-para-route', paraText: '【行程】Day1 大东海＋鹿回头夜景；Day2 蜈支洲岛一整天；Day3 南山文化苑＋天涯海角；Day4 亚龙湾热带天堂森林公园；Day5 第一市场海鲜＋买手信。' },
  { paraKey: 'mfw-para-food', paraText: '【美食】第一市场加工店记得先比价再下单，和乐蟹、龙虾、芒果螺都可以砍价；椰子鸡推荐沿江路上那家本地人排队的老店，晚上七点前去不用等位。' },
  { paraKey: 'mfw-para-trap', paraText: '【防坑】不要相信路边「免费接送」「低价一日游」，潜水一定提前在平台订好套餐，到店再付的几乎都会加价；出租车打表，拒绝一口价。' }
];

const WSMFW_PHOTOS_ROW1: MfwGuidePhoto[] = [
  { photoKey: 'mfw-photo-sea', photoTopColor: '#0E4C6E', photoBottomColor: '#3D8FB5' },
  { photoKey: 'mfw-photo-sand', photoTopColor: '#C78A3B', photoBottomColor: '#E8BE7E' },
  { photoKey: 'mfw-photo-boat', photoTopColor: '#1F3A5F', photoBottomColor: '#4872A8' }
];

const WSMFW_PHOTOS_ROW2: MfwGuidePhoto[] = [
  { photoKey: 'mfw-photo-sunset', photoTopColor: '#8A3A2E', photoBottomColor: '#D08A64' },
  { photoKey: 'mfw-photo-forest', photoTopColor: '#1F5C3D', photoBottomColor: '#4E9170' },
  { photoKey: 'mfw-photo-street', photoTopColor: '#40222E', photoBottomColor: '#8A5566' }
];

const WSMFW_COMMENTS: MfwGuideComment[] = [
  {
    commentKey: 'mfw-cmt-yuan', commenterName: '蜂蜂_阿圆', commentTime: '2025-11-08',
    commentText: '太全了！刚订了 12 月的机票，直接照抄行程，蹲一个后续更新～',
    likeCount: '326', avTopColor: '#E8628A', avBottomColor: '#B2446A'
  },
  {
    commentKey: 'mfw-cmt-zhou', commenterName: '旅行摄影师老周', commentTime: '2025-11-06',
    commentText: '补充一句：鹿回头的日落比夜景更值得看，下午五点半上山正合适，光线绝了。',
    likeCount: '158', avTopColor: '#2E5F94', avBottomColor: '#5A8FCB'
  },
  {
    commentKey: 'mfw-cmt-bee', commenterName: '小红薯变身小蜜蜂', commentTime: '2025-11-03',
    commentText: '第一市场加工店强烈推荐 6 号摊，上次吃的和乐蟹绝了，四个人吃到扶墙才 380。',
    likeCount: '92', avTopColor: '#C9822B', avBottomColor: '#E8B45E'
  }
];

@Component
export struct MafengwoGuideBlankPage {
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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 整页缩放比：窗口宽度 / 单屏基准宽度（459.6vp），倍率钳制在 1.03 */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return Math.min(this.winWidthVp / WSMFW_BASE_WIDTH, WSMFW_MAX_SCALE);
  }

  /** 把基准宽度下的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 版块之间的竖向间距：基准 14vp，再随窗口高度线性放大 ——
   *  展开态竖屏（939.6vp 高）下每个版块间隙被拉到约 89vp，
   *  正文与评论区之间空出一大段（留白反例根源） */
  private blockGapVp(): number {
    const extra: number = (this.winHeightVp - WSMFW_BASE_HEIGHT) * WSMFW_GAP_GROW;
    return this.vs(WSMFW_BLOCK_GAP) + (extra > 0 ? extra : 0);
  }

  // ------------------------------------------------------------------
  // 顶部：白色标题栏（返回 + 标题 + 收藏 / 分享）
  // ------------------------------------------------------------------

  @Builder
  headerBand() {
    Stack({ alignContent: Alignment.Center }) {
      Text('攻略详情')
        .fontSize(this.vs(WSMFW_TITLE_FONT)).fontWeight(FontWeight.Bold)
        .fontColor(WSMFW_TEXT_MAIN).maxLines(1)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(WSMFW_HEADER_ICON)).fontColor([WSMFW_TEXT_MAIN])
          .width(this.vs(44)).height(this.vs(44))
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Row({ space: this.vs(WSMFW_HEADER_ICON_GAP) }) {
          SymbolGlyph($r('sys.symbol.heart'))
            .fontSize(this.vs(WSMFW_HEADER_ICON)).fontColor([WSMFW_TEXT_MAIN])

          SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
            .fontSize(this.vs(WSMFW_HEADER_ICON)).fontColor([WSMFW_TEXT_MAIN])
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%').height('100%')
      .padding({ left: this.vs(WSMFW_HEADER_PAD_SIDE), right: this.vs(WSMFW_HEADER_PAD_SIDE) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%').height(this.vs(WSMFW_HEADER_HEIGHT))
    .backgroundColor(Color.White).padding({ top: this.vs(WSMFW_STATUS_PAD) })
  }

  // ------------------------------------------------------------------
  // 攻略标题块
  // ------------------------------------------------------------------

  @Builder
  guideTitleBlock() {
    Column({ space: this.vs(8) }) {
      Text('三亚5天4晚自由行超全攻略：人均1500玩转海岛')
        .fontSize(this.vs(WSMFW_GUIDE_TITLE_FONT)).lineHeight(this.vs(WSMFW_GUIDE_TITLE_LINE))
        .fontWeight(FontWeight.Bold).fontColor(WSMFW_TEXT_MAIN)
        .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({ space: this.vs(6) }) {
        SymbolGlyph($r('sys.symbol.eye'))
          .fontSize(this.vs(WSMFW_META_FONT)).fontColor([WSMFW_TEXT_SUB])

        Text('3.2万浏览 · 2025-11-10 发布 · 三亚')
          .fontSize(this.vs(WSMFW_META_FONT)).fontColor(WSMFW_TEXT_SUB).maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
    .padding({ left: this.vs(WSMFW_CONTENT_PAD), right: this.vs(WSMFW_CONTENT_PAD), top: this.vs(WSMFW_BLOCK_GAP) })
  }

  // ------------------------------------------------------------------
  // 作者行：头像 + 名称 + 关注按钮
  // ------------------------------------------------------------------

  @Builder
  authorRow() {
    Row({ space: this.vs(10) }) {
      Stack({ alignContent: Alignment.Center }) {
        SymbolGlyph($r('sys.symbol.person'))
          .fontSize(this.vs(18)).fontColor([Color.White])
      }
      .width(this.vs(WSMFW_AVATAR_SIZE)).height(this.vs(WSMFW_AVATAR_SIZE))
      .linearGradient({ angle: 135, colors: [['#FFB84D', 0.0], ['#FF9D00', 1.0]] })
      .borderRadius(this.vs(WSMFW_AVATAR_SIZE / 2))

      Column({ space: this.vs(3) }) {
        Row({ space: this.vs(6) }) {
          Text('旅行家小蜂')
            .fontSize(this.vs(WSMFW_NAME_FONT)).fontWeight(FontWeight.Medium)
            .fontColor(WSMFW_TEXT_MAIN).maxLines(1)

          Text('LV.12')
            .fontSize(this.vs(WSMFW_LV_FONT)).fontColor(WSMFW_LV_GOLD).maxLines(1)
            .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(2), bottom: this.vs(2) })
            .backgroundColor(WSMFW_LV_BG).borderRadius(this.vs(7))
        }
        .alignItems(VerticalAlign.Center)

        Text('发布了 86 篇攻略')
          .fontSize(this.vs(WSMFW_AUTHOR_SUB_FONT)).fontColor(WSMFW_TEXT_SUB).maxLines(1)
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)

      Text('+ 关注')
        .fontSize(this.vs(WSMFW_FOLLOW_FONT)).fontWeight(FontWeight.Medium)
        .fontColor(Color.White).maxLines(1)
        .width(this.vs(WSMFW_FOLLOW_W)).height(this.vs(WSMFW_FOLLOW_H))
        .textAlign(TextAlign.Center).backgroundColor(WSMFW_BRAND_YELLOW)
        .borderRadius(this.vs(WSMFW_FOLLOW_H / 2))
    }
    .width('100%').alignItems(VerticalAlign.Center)
    .padding({ left: this.vs(WSMFW_CONTENT_PAD), right: this.vs(WSMFW_CONTENT_PAD) })
    .margin({ top: this.blockGapVp() })
  }

  // ------------------------------------------------------------------
  // 攻略正文
  // ------------------------------------------------------------------

  @Builder
  articleBlock() {
    Column({ space: this.vs(WSMFW_PARA_GAP) }) {
      ForEach(WSMFW_PARAGRAPHS, (para: MfwGuideParagraph) => {
        Text(para.paraText)
          .fontSize(this.vs(WSMFW_BODY_FONT))
          .lineHeight(this.vs(WSMFW_BODY_LINE))
          .fontColor(WSMFW_TEXT_MAIN)
          .width('100%')
      }, (para: MfwGuideParagraph) => para.paraKey)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: this.vs(WSMFW_CONTENT_PAD), right: this.vs(WSMFW_CONTENT_PAD) })
    .margin({ top: this.blockGapVp() })
  }

  // ------------------------------------------------------------------
  // 行程美图：两排三个渐变占位
  // ------------------------------------------------------------------

  @Builder
  photoRow(photos: MfwGuidePhoto[]) {
    Row({ space: this.vs(WSMFW_PHOTO_GAP) }) {
      ForEach(photos, (photo: MfwGuidePhoto) => {
        Stack({ alignContent: Alignment.Center }) {
          SymbolGlyph($r('sys.symbol.camera'))
            .fontSize(this.vs(WSMFW_PHOTO_ICON)).fontColor([Color.White]).opacity(0.9)
        }
        .layoutWeight(1).height(this.vs(WSMFW_PHOTO_H))
        .linearGradient({ angle: 140, colors: [[photo.photoTopColor, 0.0], [photo.photoBottomColor, 1.0]] })
        .borderRadius(this.vs(WSMFW_PHOTO_RADIUS))
      }, (photo: MfwGuidePhoto) => photo.photoKey)
    }
    .width('100%').alignItems(VerticalAlign.Top)
    .margin({ top: this.vs(WSMFW_PHOTO_GAP) })
  }

  @Builder
  photoBlock() {
    Column() {
      Row({ space: this.vs(6) }) {
        Text('行程美图（18）')
          .fontSize(this.vs(WSMFW_SECTION_TITLE_FONT)).fontWeight(FontWeight.Bold)
          .fontColor(WSMFW_TEXT_MAIN).maxLines(1)

        Blank()

        Text('查看全部')
          .fontSize(this.vs(WSMFW_SECTION_MORE_FONT)).fontColor(WSMFW_TEXT_SUB).maxLines(1)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(WSMFW_SECTION_MORE_FONT)).fontColor([WSMFW_TEXT_SUB])
      }
      .width('100%').alignItems(VerticalAlign.Center)

      this.photoRow(WSMFW_PHOTOS_ROW1)

      this.photoRow(WSMFW_PHOTOS_ROW2)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
    .padding({ left: this.vs(WSMFW_CONTENT_PAD), right: this.vs(WSMFW_CONTENT_PAD) })
    .margin({ top: this.blockGapVp() })
  }

  // ------------------------------------------------------------------
  // 热门评论
  // ------------------------------------------------------------------

  @Builder
  commentRow(cmt: MfwGuideComment, showDivider: boolean) {
    Column() {
      Row({ space: this.vs(10) }) {
        Stack({ alignContent: Alignment.Center }) {
          SymbolGlyph($r('sys.symbol.person'))
            .fontSize(this.vs(14)).fontColor([Color.White])
        }
        .width(this.vs(WSMFW_CMT_AVATAR)).height(this.vs(WSMFW_CMT_AVATAR))
        .linearGradient({ angle: 135, colors: [[cmt.avTopColor, 0.0], [cmt.avBottomColor, 1.0]] })
        .borderRadius(this.vs(WSMFW_CMT_AVATAR / 2))

        Column({ space: this.vs(4) }) {
          Row({ space: this.vs(8) }) {
            Text(cmt.commenterName)
              .fontSize(this.vs(WSMFW_CMT_NAME_FONT)).fontWeight(FontWeight.Medium)
              .fontColor(WSMFW_TEXT_MAIN).maxLines(1)

            Text(cmt.commentTime)
              .fontSize(this.vs(WSMFW_CMT_TIME_FONT)).fontColor(WSMFW_TEXT_SUB).maxLines(1)
          }
          .alignItems(VerticalAlign.Center)

          Text(cmt.commentText)
            .fontSize(this.vs(WSMFW_CMT_FONT)).lineHeight(this.vs(WSMFW_CMT_LINE))
            .fontColor(WSMFW_TEXT_MAIN).maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: this.vs(4) }) {
            SymbolGlyph($r('sys.symbol.heart'))
              .fontSize(this.vs(WSMFW_CMT_LIKE_FONT)).fontColor([WSMFW_TEXT_SUB])

            Text(cmt.likeCount)
              .fontSize(this.vs(WSMFW_CMT_LIKE_FONT)).fontColor(WSMFW_TEXT_SUB).maxLines(1)
          }
          .alignItems(VerticalAlign.Center)
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)
      }
      .width('100%').alignItems(VerticalAlign.Top)

      if (showDivider) {
        Row()
          .width('100%').height(this.vs(0.5))
          .backgroundColor(WSMFW_DIVIDER)
          .margin({ top: this.vs(WSMFW_CMT_GAP / 2) })
      }
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  commentBlock() {
    Column({ space: this.vs(WSMFW_CMT_GAP / 2) }) {
      Row({ space: this.vs(6) }) {
        Text('热门评论')
          .fontSize(this.vs(WSMFW_SECTION_TITLE_FONT)).fontWeight(FontWeight.Bold)
          .fontColor(WSMFW_TEXT_MAIN).maxLines(1)

        Text('（128）')
          .fontSize(this.vs(WSMFW_META_FONT)).fontColor(WSMFW_TEXT_SUB).maxLines(1)

        Blank()

        Text('写评论')
          .fontSize(this.vs(WSMFW_SECTION_MORE_FONT)).fontColor(WSMFW_BRAND_YELLOW).maxLines(1)
      }
      .width('100%').alignItems(VerticalAlign.Center)

      ForEach(WSMFW_COMMENTS, (cmt: MfwGuideComment) => {
        this.commentRow(cmt, cmt.commentKey !== 'mfw-cmt-bee')
      }, (cmt: MfwGuideComment) => cmt.commentKey)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
    .padding({ left: this.vs(WSMFW_CONTENT_PAD), right: this.vs(WSMFW_CONTENT_PAD), top: this.vs(WSMFW_CMT_GAP / 2) })
    .margin({ top: this.blockGapVp() })
  }

  @Builder
  endFooter() {
    Text('—— 到底啦，快出发吧 ——')
      .fontSize(this.vs(WSMFW_FOOTER_FONT)).fontColor(WSMFW_TEXT_SUB)
      .maxLines(1).width('100%').textAlign(TextAlign.Center)
      .padding({ top: this.vs(WSMFW_BLOCK_GAP), bottom: this.vs(WSMFW_BLOCK_GAP) })
      .margin({ top: this.blockGapVp() })
  }

  // ------------------------------------------------------------------
  // 内容列：固定基准宽度、贴窗口左缘，右侧留白；版块间距随窗口高度放大
  // ------------------------------------------------------------------

  @Builder
  contentStage() {
    Row() {
      Column() {
        Scroll() {
          Column() {
            this.guideTitleBlock()

            this.authorRow()

            this.articleBlock()

            this.photoBlock()

            this.commentBlock()

            this.endFooter()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .align(Alignment.Start)
      }
      .width(this.vs(WSMFW_BASE_WIDTH))
      .height('100%')
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(VerticalAlign.Top)
    .backgroundColor(WSMFW_PAGE_BG)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        this.contentStage()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSMFW_PAGE_BG)
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
