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
 * 反例：截断 / 滴滴送货首页头部叠字（头部溢出）
 *
 * 复刻对象：滴滴送货「送货」首页（横屏）。薄荷绿渐变头部（左侧竖排品牌字、右侧消息 / 我的两个线框图标）、
 *   白色面板里的两行频道（跑腿 / 🔥四轮小件（选中胶囊）/ 微面 / 小面 / 中面 / 依维柯，
 *   小货 / 中货 / 4米2 / 5米2 / 6米8 / 7米6 / 9米6 …，右侧青绿胶囊「全部 ⌄」）、
 *   页面中间的白色厢式小货车插画（车斗里两只橙色纸箱）、车上「0.9 ~ 1.1米」、车右「0.4 ~ 0.6米」、
 *   底部四项 TabBar（首页 / 车主 / 送货 / 我的，选中「送货」为橙色）。
 *
 * 设计基准（vp 量测值，密度 2.75，vp = px / 2.75）：参考截图 3184×2232px = 1157.8×811.6vp，
 *   页面按 1157.8vp 宽 1:1 复刻，窗口更宽时内容列居中、头部 / TabBar 通栏铺满，更窄时整页等比缩小。
 *   头部薄荷绿渐变带高 130.5vp（px 0→359，横向 #DAFDE9→#D3FBFB）；
 *   竖排品牌字列宽 45vp、字号 33vp / 行高 44.7vp（px 88~90 一字），首行落在 y=26vp 之上被头部上沿切掉；
 *   标题行「滴滴送货 | 武汉 ⌄」字号 42vp（「武汉」实测 x 745~964px、y 99~207px）、上沿 y≈36vp；
 *   压在上面的另一份标题字号 46vp、左移 24vp / 上移 12vp；
 *   头部右侧消息图标 52.7×45vp（px 2578~2722 / 86~209）、我的图标 44×45vp（px 2862~2982 / 91~214）；
 *   头部左下的白色圆角色块 95×41.5vp、其下青绿短横 16.7×3.6vp。
 *   频道行字 42vp（墨迹高 107~111px）；第一行：跑腿 x=57.5vp、选中胶囊 167.3~432vp（px 460~1187）、
 *   高 79.6vp（px 512~731）、圆角 39.8vp、底色 #E1F5F3，微面 458.5vp、小面 595.3vp、中面 733.8vp、依维柯 866.2vp；
 *   第二行：小货 57.8vp、中货 196.4vp、4米2 329.1vp、5米2 472.7vp、6米8 613.8vp、7米6 755.6vp、9米6 892.7vp，
 *   行宽取 1220vp（大于内容列宽，右侧被面板裁掉）；
 *   「全部」胶囊 x=942.4vp、y=167.3vp（px 2592~3099 / 818~1055）、184.7×86.5vp、圆角 43.2vp、底色 #00A789；
 *   车上标注「0.9 ~ 1.1米」32vp（px 1462~1935 / 1182~1259），车右标注列宽 48.4vp（px 133）、
 *   字号 32vp / 行高 34.7vp（px 1426~1807，断成 4 行）；小货车插画从截图 x 960~2180 / y 1380~1890（1220×510px）
 *   裁成 443.6×185.5vp；底部 TabBar 高 89.8vp（px 1985~2232）、图标 19.3vp 高、文字 10.5vp，
 *   四项按内容列四等分居中，选中项 #FF7C58。
 *
 * 三态实测（内容列宽 = min(窗口宽, 1157.8vp)，整页按该比例缩放）：
 *   单屏态        459.6×672vp    —— 内容列 459.6vp（×0.397），头部 51.8vp、TabBar 35.6vp；
 *   双屏态竖屏    664.7×939.6vp  —— 内容列 664.7vp（×0.574），头部 74.9vp、TabBar 51.5vp；
 *   双屏态横屏    939.6×664.7vp  —— 内容列 939.6vp（×0.812），头部 105.9vp、TabBar 72.9vp。
 *
 * 问题表现：
 *   头部只有 130.5vp 高，装不下 33vp 的两行品牌字与 42/46vp 的标题行：左侧「送」「货」竖排两行从 y=26vp
 *   一直排到 104vp，与「滴滴送货 | 武汉」压在同一段区域里互相叠字，字号最大的一行上半截被头部上沿切平；
 *   白色圆角色块又把「货」的左下角盖掉一部分。
 *   第二行频道排到 9米6（x=892.7vp）仍未收住，右侧「全部」按钮从 942.4vp 起直接压在「9米6」上，
 *   只剩「9」的左半截露在外面。
 *   车右侧「0.4 ~ 0.6米」被挤进 48.4vp 宽的列里，断成「0.4 / ~ / 0.6 / 米」四行竖排。
 *   底部 TabBar 图标下沿 37.5vp、文字上沿 44vp，四项的图标与文字挤在一起。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 参考截图宽度：3184px / 2.75 = 1157.8vp，页面按它 1:1 复刻 */
const DDH_REFERENCE_WIDTH: number = 1157.8;

/** 头部薄荷绿渐变带高 359px = 130.5vp；底部 TabBar 247px = 89.8vp */
const DDH_HEADER_HEIGHT: number = 130.5;
const DDH_TABBAR_HEIGHT: number = 89.8;

const DDH_MINT_START: string = '#DAFDE9';
const DDH_MINT_END: string = '#D3FBFB';
const DDH_INK: string = '#323433';
const DDH_TEXT: string = '#333333';
const DDH_SUB: string = '#666666';
const DDH_PILL_BG: string = '#E1F5F3';
const DDH_PILL_TEXT: string = '#05B294';
const DDH_TEAL: string = '#00A789';
const DDH_TEAL_DASH: string = '#0AA57C';
const DDH_TABBAR_BG: string = '#FFFFFF';
const DDH_SELECTED: string = '#FF7C58';
const DDH_CONTENT_END: string = '#FAFBFF';

/** 头部：竖排品牌字列（x 5px / y -69.4vp 起 4 行，只露出后两行）33vp / 行高 44.7vp / 列宽 45vp */
const DDH_LOGO_X: number = 1.8;
const DDH_LOGO_Y: number = -69.4;
const DDH_LOGO_WIDTH: number = 45;
const DDH_LOGO_FONT: number = 33;
const DDH_LOGO_LINE: number = 44.7;

/** 标题：压在上面的那份 46vp（x 52vp / y 20vp），下面那份 42vp（x 76vp / y 32vp） */
const DDH_TITLE_X: number = 52;
const DDH_TITLE_Y: number = 20;
const DDH_TITLE_FONT: number = 46;
const DDH_ROW_X: number = 76;
const DDH_ROW_Y: number = 32;
const DDH_ROW_FONT: number = 42;
const DDH_CHEVRON_FONT: number = 34;

/** 头部右侧两个线框图标 */
const DDH_CHAT_X: number = 937;
const DDH_CHAT_Y: number = 31;
const DDH_CHAT_W: number = 52.7;
const DDH_CHAT_H: number = 45;
const DDH_PERSON_X: number = 1040;
const DDH_PERSON_Y: number = 33;
const DDH_PERSON_W: number = 44;
const DDH_PERSON_H: number = 45;

/** 头部左下白色圆角色块（px 0~261 / 244~358）与其下青绿短横（px 86~131 / 348~358） */
const DDH_BLOB_Y: number = 88.8;
const DDH_BLOB_W: number = 95;
const DDH_BLOB_H: number = 41.5;
const DDH_BLOB_RADIUS: number = 30;
const DDH_DASH_X: number = 31.3;
const DDH_DASH_Y: number = 126.5;
const DDH_DASH_W: number = 16.7;
const DDH_DASH_H: number = 3.6;

/** 频道行：字 42vp、行高 42vp；两行文字框上沿（相对内容列顶部）71.7vp / 182.6vp */
const DDH_CHIP_FONT: number = 42;
const DDH_CHIP_LINE: number = 42;
const DDH_ROW1_TOP: number = 71.7;
const DDH_ROW2_TOP: number = 182.6;
/** 频道行内容宽度：1220vp，比内容列（1157.8vp）宽 */
const DDH_CHIP_ROW_WIDTH: number = 1220;
const DDH_CHIP_ROW_HEIGHT: number = 300;

/** 选中胶囊：px 460~1187 / 512~731 */
const DDH_PILL_X: number = 167.3;
const DDH_PILL_Y: number = 55.7;
const DDH_PILL_W: number = 264.7;
const DDH_PILL_H: number = 79.6;
const DDH_PILL_RADIUS: number = 39.8;
const DDH_FLAME_FONT: number = 34;

/** 「全部」按钮：px 2592~3099 / 818~1055 */
const DDH_ALL_X: number = 942.4;
const DDH_ALL_Y: number = 167.3;
const DDH_ALL_W: number = 184.7;
const DDH_ALL_H: number = 86.5;
const DDH_ALL_RADIUS: number = 43.2;
const DDH_ALL_FONT: number = 44;

/** 车上标注「0.9 ~ 1.1米」与车右竖排列 */
const DDH_DIM_X: number = 527.6;
const DDH_DIM_Y: number = 297.7;
const DDH_DIM_W: number = 180;
const DDH_DIM_FONT: number = 32;
const DDH_VTEXT_X: number = 866.2;
const DDH_VTEXT_Y: number = 384.7;
const DDH_VTEXT_W: number = 48.4;
const DDH_VTEXT_FONT: number = 32;
const DDH_VTEXT_LINE: number = 34.7;

/** 小货车插画：截图为 px 960~2180 / 1380~1890（1220×510px），按 443.6×185.5vp 摆放 */
const DDH_CAR_X: number = 349.1;
const DDH_CAR_Y: number = 371.3;
const DDH_CAR_W: number = 443.6;
const DDH_CAR_H: number = 185.5;

/** TabBar：图标上沿 18.2vp、高 19.3vp；文字上沿 44vp、字号 10.5vp */
const DDH_TAB_ICON_TOP: number = 18.2;
const DDH_TAB_ICON_SIZE: number = 19.3;
const DDH_TAB_LABEL_TOP: number = 6.5;
const DDH_TAB_LABEL_FONT: number = 10.5;

/** TabBar 一项的业务标识（名称加前缀，避免与工程内其它文件重复声明） */
interface DdhTabEntry {
  tabLabel: string;
  tabKind: number;
}

const DDH_TABS: DdhTabEntry[] = [
  { tabLabel: '首页', tabKind: 0 },
  { tabLabel: '车主', tabKind: 1 },
  { tabLabel: '送货', tabKind: 2 },
  { tabLabel: '我的', tabKind: 3 }
];

@Component
export struct DidiDeliveryHeaderOverflowPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 1157.8;
  @State winHeightVp: number = 811.6;

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

  /** 内容列宽度：参考设计宽 1157.8vp，窗口更宽时保持原宽并居中，更窄时整页等比缩小 */
  private pageWidth(): number {
    return Math.min(this.winWidthVp, DDH_REFERENCE_WIDTH);
  }

  /** 把 1157.8vp 参考宽下的设计值换算到当前内容列宽度 */
  private s(baseVp: number): number {
    return baseVp * this.pageWidth() / DDH_REFERENCE_WIDTH;
  }

  /** 内容区可用高度（去掉头部与 TabBar），仅用于让渐变带铺满 */
  private bodyHeight(): number {
    return Math.max(this.winHeightVp - this.s(DDH_HEADER_HEIGHT) - this.s(DDH_TABBAR_HEIGHT), 0);
  }

  @Builder
  headerChatIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(this.s(44))
        .height(this.s(33))
        .border({ width: this.s(3), color: DDH_INK })
        .borderRadius(this.s(16.5))

      Row({ space: this.s(5.2) }) {
        Column()
          .width(this.s(5))
          .height(this.s(5))
          .backgroundColor(DDH_INK)
          .borderRadius(this.s(2.5))

        Column()
          .width(this.s(5))
          .height(this.s(5))
          .backgroundColor(DDH_INK)
          .borderRadius(this.s(2.5))

        Column()
          .width(this.s(5))
          .height(this.s(5))
          .backgroundColor(DDH_INK)
          .borderRadius(this.s(2.5))
      }
      .alignItems(VerticalAlign.Center)
    }
    .width(this.s(DDH_CHAT_W))
    .height(this.s(DDH_CHAT_H))
    .position({ x: this.s(DDH_CHAT_X), y: this.s(DDH_CHAT_Y) })
  }

  @Builder
  headerPersonIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(this.s(15))
        .height(this.s(15))
        .border({ width: this.s(3), color: DDH_INK })
        .borderRadius(this.s(7.5))
        .position({ x: this.s(14.5), y: this.s(2) })

      Column()
        .width(this.s(30))
        .height(this.s(13))
        .border({
          width: this.s(3),
          color: DDH_INK,
          radius: { topLeft: this.s(15), topRight: this.s(15) }
        })
        .position({ x: this.s(7), y: this.s(23) })
    }
    .width(this.s(DDH_PERSON_W))
    .height(this.s(DDH_PERSON_H))
    .position({ x: this.s(DDH_PERSON_X), y: this.s(DDH_PERSON_Y) })
  }

  @Builder
  headerBand() {
    Stack({ alignContent: Alignment.Top }) {
      Stack({ alignContent: Alignment.TopStart }) {
        // 竖排品牌字：列宽只有 45vp，逐字换行，最上面两行落在头部上沿之外
        Text('滴滴送货')
          .fontSize(this.s(DDH_LOGO_FONT))
          .lineHeight(this.s(DDH_LOGO_LINE))
          .fontWeight(FontWeight.Bold)
          .fontColor(DDH_INK)
          .width(this.s(DDH_LOGO_WIDTH))
          .position({ x: this.s(DDH_LOGO_X), y: this.s(DDH_LOGO_Y) })

        // 字号更大的一份标题
        Text('滴滴送货')
          .fontSize(this.s(DDH_TITLE_FONT))
          .lineHeight(this.s(DDH_TITLE_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(DDH_INK)
          .position({ x: this.s(DDH_TITLE_X), y: this.s(DDH_TITLE_Y) })

        // 「滴滴送货 | 武汉 ⌄」标题行
        Row({ space: this.s(8) }) {
          Text('滴滴送货')
            .fontSize(this.s(DDH_ROW_FONT))
            .lineHeight(this.s(DDH_ROW_FONT))
            .fontWeight(FontWeight.Medium)
            .fontColor(DDH_INK)

          Text('|')
            .fontSize(this.s(DDH_ROW_FONT))
            .lineHeight(this.s(DDH_ROW_FONT))
            .fontColor(DDH_INK)

          Text('武汉')
            .fontSize(this.s(DDH_ROW_FONT))
            .lineHeight(this.s(DDH_ROW_FONT))
            .fontWeight(FontWeight.Medium)
            .fontColor(DDH_INK)

          Text('⌄')
            .fontSize(this.s(DDH_CHEVRON_FONT))
            .fontColor(DDH_INK)
        }
        .alignItems(VerticalAlign.Center)
        .position({ x: this.s(DDH_ROW_X), y: this.s(DDH_ROW_Y) })

        this.headerChatIcon()
        this.headerPersonIcon()

        // 头部左下的白色圆角色块 + 青绿短横，压在品牌字下沿
        Column()
          .width(this.s(DDH_BLOB_W))
          .height(this.s(DDH_BLOB_H))
          .backgroundColor(Color.White)
          .borderRadius({ topRight: this.s(DDH_BLOB_RADIUS) })
          .position({ x: 0, y: this.s(DDH_BLOB_Y) })

        Column()
          .width(this.s(DDH_DASH_W))
          .height(this.s(DDH_DASH_H))
          .backgroundColor(DDH_TEAL_DASH)
          .borderRadius(this.s(2))
          .position({ x: this.s(DDH_DASH_X), y: this.s(DDH_DASH_Y) })
      }
      .width(this.pageWidth())
      .height(this.s(DDH_HEADER_HEIGHT))
      .clip(true)
    }
    .width('100%')
    .height(this.s(DDH_HEADER_HEIGHT))
    .linearGradient({
      angle: 90,
      colors: [[DDH_MINT_START, 0.0], [DDH_MINT_END, 1.0]]
    })
  }

  @Builder
  chipText(chipLabel: string, chipX: number, rowTop: number) {
    Text(chipLabel)
      .fontSize(this.s(DDH_CHIP_FONT))
      .lineHeight(this.s(DDH_CHIP_LINE))
      .fontColor(DDH_TEXT)
      .position({ x: this.s(chipX), y: this.s(rowTop) })
  }

  @Builder
  selectedPill() {
    Row({ space: this.s(13.8) }) {
      Text('🔥')
        .fontSize(this.s(DDH_FLAME_FONT))
        .lineHeight(this.s(DDH_FLAME_FONT))

      Text('四轮小件')
        .fontSize(this.s(DDH_CHIP_FONT))
        .lineHeight(this.s(DDH_CHIP_LINE))
        .fontColor(DDH_PILL_TEXT)
        .fontWeight(FontWeight.Medium)
    }
    .width(this.s(DDH_PILL_W))
    .height(this.s(DDH_PILL_H))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(DDH_PILL_BG)
    .borderRadius(this.s(DDH_PILL_RADIUS))
    .position({ x: this.s(DDH_PILL_X), y: this.s(DDH_PILL_Y) })
  }

  @Builder
  allButton() {
    Row({ space: this.s(6) }) {
      Text('全部')
        .fontSize(this.s(DDH_ALL_FONT))
        .lineHeight(this.s(DDH_ALL_FONT))
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)

      Text('⌄')
        .fontSize(this.s(DDH_CHEVRON_FONT))
        .fontColor(Color.White)
    }
    .width(this.s(DDH_ALL_W))
    .height(this.s(DDH_ALL_H))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(DDH_TEAL)
    .borderRadius(this.s(DDH_ALL_RADIUS))
    .position({ x: this.s(DDH_ALL_X), y: this.s(DDH_ALL_Y) })
    .zIndex(2)
  }

  @Builder
  channelBoard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Stack({ alignContent: Alignment.TopStart }) {
        this.chipText('跑腿', 57.5, DDH_ROW1_TOP)
        this.selectedPill()
        this.chipText('微面', 458.5, DDH_ROW1_TOP)
        this.chipText('小面', 595.3, DDH_ROW1_TOP)
        this.chipText('中面', 733.8, DDH_ROW1_TOP)
        this.chipText('依维柯', 866.2, DDH_ROW1_TOP)

        this.chipText('小货', 57.8, DDH_ROW2_TOP)
        this.chipText('中货', 196.4, DDH_ROW2_TOP)
        this.chipText('4米2', 329.1, DDH_ROW2_TOP)
        this.chipText('5米2', 472.7, DDH_ROW2_TOP)
        this.chipText('6米8', 613.8, DDH_ROW2_TOP)
        this.chipText('7米6', 755.6, DDH_ROW2_TOP)
        this.chipText('9米6', 892.7, DDH_ROW2_TOP)
        this.chipText('13米', 1032, DDH_ROW2_TOP)

        this.allButton()
      }
      .width(this.s(DDH_CHIP_ROW_WIDTH))
      .height(this.s(DDH_CHIP_ROW_HEIGHT))

      // 车上方尺寸标注
      Text('0.9 ~ 1.1米')
        .fontSize(this.s(DDH_DIM_FONT))
        .lineHeight(this.s(DDH_DIM_FONT))
        .fontColor(DDH_SUB)
        .textAlign(TextAlign.Center)
        .width(this.s(DDH_DIM_W))
        .position({ x: this.s(DDH_DIM_X), y: this.s(DDH_DIM_Y) })

      // 车右侧尺寸标注：列宽固定 48.4vp
      Text('0.4 ~ 0.6米')
        .fontSize(this.s(DDH_VTEXT_FONT))
        .lineHeight(this.s(DDH_VTEXT_LINE))
        .fontColor(DDH_SUB)
        .width(this.s(DDH_VTEXT_W))
        .position({ x: this.s(DDH_VTEXT_X), y: this.s(DDH_VTEXT_Y) })

      Image($r('app.media.tr_didi_delivery_car'))
        .objectFit(ImageFit.Contain)
        .width(this.s(DDH_CAR_W))
        .height(this.s(DDH_CAR_H))
        .position({ x: this.s(DDH_CAR_X), y: this.s(DDH_CAR_Y) })
    }
    .width(this.pageWidth())
    .height(this.bodyHeight())
    .clip(true)
  }

  @Builder
  tabIcon(iconKind: number, tint: string) {
    Stack({ alignContent: Alignment.TopStart }) {
      if (iconKind === 0) {
        Column()
          .width(this.s(10.5))
          .height(this.s(12.5))
          .border({ width: this.s(1.5), color: tint })
          .borderRadius(this.s(2.5))
          .position({ x: this.s(1.5), y: this.s(3.2) })

        Column()
          .width(this.s(12.5))
          .height(this.s(10.5))
          .border({ width: this.s(1.5), color: tint })
          .borderRadius(this.s(2.5))
          .position({ x: this.s(5.5), y: this.s(4.6) })
      } else if (iconKind === 1) {
        Column()
          .width(this.s(16.5))
          .height(this.s(13.5))
          .border({ width: this.s(1.5), color: tint })
          .borderRadius({
            topLeft: this.s(6),
            topRight: this.s(6),
            bottomLeft: this.s(3),
            bottomRight: this.s(3)
          })
          .position({ x: this.s(1.7), y: this.s(3.4) })

        Row({ space: this.s(2.4) }) {
          Column()
            .width(this.s(1.7))
            .height(this.s(1.7))
            .backgroundColor(tint)
            .borderRadius(this.s(1))

          Column()
            .width(this.s(1.7))
            .height(this.s(1.7))
            .backgroundColor(tint)
            .borderRadius(this.s(1))
        }
        .position({ x: this.s(5.6), y: this.s(6.2) })

        Row()
          .width(this.s(5.6))
          .height(this.s(2.6))
          .border({
            width: this.s(1.3),
            color: tint,
            radius: { bottomLeft: this.s(2.8), bottomRight: this.s(2.8) }
          })
          .position({ x: this.s(5.7), y: this.s(9.2) })
      } else if (iconKind === 2) {
        Column()
          .width(this.s(9.5))
          .height(this.s(9))
          .border({ width: this.s(1.4), color: tint })
          .borderRadius(this.s(1.6))
          .position({ x: this.s(2), y: this.s(4.2) })

        Column()
          .width(this.s(6))
          .height(this.s(7.2))
          .border({ width: this.s(1.4), color: tint })
          .borderRadius(this.s(1.6))
          .position({ x: this.s(11.6), y: this.s(6) })

        Row({ space: this.s(5.4) }) {
          Column()
            .width(this.s(3))
            .height(this.s(3))
            .backgroundColor(tint)
            .borderRadius(this.s(1.5))

          Column()
            .width(this.s(3))
            .height(this.s(3))
            .backgroundColor(tint)
            .borderRadius(this.s(1.5))
        }
        .position({ x: this.s(4.6), y: this.s(13.4) })
      } else {
        Column()
          .width(this.s(6.4))
          .height(this.s(6.4))
          .border({ width: this.s(1.5), color: tint })
          .borderRadius(this.s(3.2))
          .position({ x: this.s(6.4), y: this.s(2.6) })

        Column()
          .width(this.s(13))
          .height(this.s(6.2))
          .border({
            width: this.s(1.5),
            color: tint,
            radius: { topLeft: this.s(6.5), topRight: this.s(6.5) }
          })
          .position({ x: this.s(3.1), y: this.s(10.4) })
      }
    }
    .width(this.s(DDH_TAB_ICON_SIZE))
    .height(this.s(DDH_TAB_ICON_SIZE))
  }

  @Builder
  tabItem(tabEntry: DdhTabEntry, tabIndex: number) {
    Column() {
      this.tabIcon(tabEntry.tabKind, tabIndex === 2 ? DDH_SELECTED : DDH_INK)
      Text(tabEntry.tabLabel)
        .fontSize(this.s(DDH_TAB_LABEL_FONT))
        .lineHeight(this.s(DDH_TAB_LABEL_FONT + 1.5))
        .fontColor(tabIndex === 2 ? DDH_SELECTED : DDH_TEXT)
        .margin({ top: this.s(DDH_TAB_LABEL_TOP) })
    }
    .width(this.pageWidth() / 4)
    .padding({ top: this.s(DDH_TAB_ICON_TOP) })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  tabBar() {
    Row() {
      ForEach(DDH_TABS, (tabEntry: DdhTabEntry, tabIndex: number) => {
        this.tabItem(tabEntry, tabIndex)
      }, (tabEntry: DdhTabEntry, tabIndex: number) => `${tabEntry.tabLabel}-${tabIndex}`)
    }
    .width(this.pageWidth())
    .height(this.s(DDH_TABBAR_HEIGHT))
    .alignItems(VerticalAlign.Top)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        Column() {
          this.channelBoard()
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .linearGradient({
          angle: 180,
          colors: [[Color.White, 0.0], [Color.White, 0.55], [DDH_CONTENT_END, 1.0]]
        })

        Row() {
          this.tabBar()
        }
        .width('100%')
        .height(this.s(DDH_TABBAR_HEIGHT))
        .justifyContent(FlexAlign.Center)
        .backgroundColor(DDH_TABBAR_BG)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(DDH_TABBAR_BG)
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
