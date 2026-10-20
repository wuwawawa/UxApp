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
 * 分类占位页。
 *
 * 首页先按问题类型分类，暂未整理案例的分类（未避让安全区 / 边距过大 / 大图大字）
 * 先落到这里，避免点进去白屏；后续补案例时用真实分类页替换对应 @Builder 即可。
 */

@Component
export struct CategoryPlaceholderPage {
  pageStack: NavPathStack = new NavPathStack();
  categoryTitle: string = '';

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('‹')
            .fontSize(28)
            .fontColor('#14161A')
            .width(36)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.pageStack.pop();
            })

          Text(this.categoryTitle)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14161A')
            .margin({ left: 2 })

          Blank()
        }
        .width('100%')
        .height(54)
        .alignItems(VerticalAlign.Center)

        Column() {
          Text('COMING SOON')
            .fontSize(10)
            .letterSpacing(3)
            .fontColor('#B0A99A')

          Text('案例整理中')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14161A')
            .margin({ top: 10 })

          Text('该分类的反例正在复现与归档，后续补充。')
            .fontSize(12)
            .fontColor('#7A756B')
            .margin({ top: 8 })

          Row()
            .width(48)
            .height(3)
            .backgroundColor('#E2452B')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20, top: 6 })
      .backgroundColor('#F4F2EC')
      .alignItems(HorizontalAlign.Start)
    }
    .hideTitleBar(true)
  }
}
