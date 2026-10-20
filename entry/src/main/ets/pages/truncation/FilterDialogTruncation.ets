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
 * 反例：截断 / 购票场景文字截断
 * 购票页 + 「筛选条件」弹窗。弹窗卡片固定 570vp 高、内容不可滚动，
 * 在折叠屏展开态（窗口高度变小 / 宽度变大）下，底部「座位类型」文字被卡片下沿裁掉约 1/3。
 */

interface FilterGroupData {
  groupLabel: string;
  groupOptions: string[];
}

@CustomDialog
struct TicketFilterDialog {
  controller: CustomDialogController;

  private trainTypes: FilterGroupData = {
    groupLabel: '车次类型',
    groupOptions: ['高铁(G)', '动车(D)', '直达(Z)', '特快(T)', '快速(K)', '城际(C)']
  };
  private trainModels: FilterGroupData = {
    groupLabel: '车组型号',
    groupOptions: ['CRH380', 'CR400AF', 'CR400BF', 'CRH2A', 'CRH3A', 'CRH4A']
  };
  private seatTypes: FilterGroupData = {
    groupLabel: '座位类型',
    groupOptions: ['商务座', '一等座', '二等座']
  };

  @Builder
  filterGroup(section: FilterGroupData) {
    Column() {
      Text(section.groupLabel)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .margin({ bottom: 14 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(section.groupOptions, (chipLabel: string) => {
          Text(chipLabel)
            .fontSize(16)
            .fontColor('#333333')
            .width('31.5%')
            .height(50)
            .textAlign(TextAlign.Center)
            .backgroundColor('#F2F2F2')
            .borderRadius(10)
            .margin({ bottom: 16 })
        }, (chipLabel: string) => chipLabel)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 34 })
  }

  build() {
    Column() {
      Text('筛选条件')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 50 })

      this.filterGroup(this.trainTypes)
      this.filterGroup(this.trainModels)
      this.filterGroup(this.seatTypes)
    }
    .width('69%')
    .height(570)
    .padding({ left: 28, right: 28, top: 32, bottom: 24 })
    .backgroundColor(Color.White)
    .borderRadius(24)
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct FilterDialogTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  @State trainNo: string = 'G7';
  private filterDialog: CustomDialogController = new CustomDialogController({
    builder: TicketFilterDialog(),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  });

  aboutToAppear(): void {
    // 进入页面即拉起弹窗
    setTimeout(() => {
      this.filterDialog.open();
    }, 600);
  }

  @Builder
  trainCard(seatName: string, price: string) {
    Row() {
      Text(seatName)
        .fontSize(14)
        .fontColor('#555555')

      Blank()

      Text(price)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#E03131')
    }
    .width('100%')
    .height(72)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.Start }) {
          Text('购票')
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .width('100%')
            .textAlign(TextAlign.Center)

          Text('‹')
            .fontSize(30)
            .fontColor(Color.White)
            .width(48)
            .height(48)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.pageStack.pop();
            })
        }
        .width('100%')
        .height(56)
        .backgroundColor('#1B6FE3')

        Column() {
          Row() {
            Column() {
              Text('北京')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
              Text('出发地')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Center)
            .layoutWeight(1)

            Text('›')
              .fontSize(28)
              .fontColor('#666666')

            Column() {
              Text('上海')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
              Text('目的地')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Center)
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 18, bottom: 18 })

          Row() {
            Text('车次列表')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')

            Blank()

            Button('筛选')
              .fontSize(14)
              .height(32)
              .backgroundColor('#1B6FE3')
              .onClick(() => {
                this.filterDialog.open();
              })
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text(this.trainNo)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
            Text('高铁(G)')
              .fontSize(12)
              .fontColor('#1B6FE3')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#E7F0FF')
              .borderRadius(4)
              .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 10 })

          this.trainCard('二等座', '¥553')
          this.trainCard('二等座', '¥553')
          this.trainCard('二等座', '¥327')
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F3F3F3')
    }
    .hideTitleBar(true)
  }
}
