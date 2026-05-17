# Map Editor Assistance

*Author: 0-0000*

---

## Features

1. Enable all originally disabled items in the map editor(`HideFromEditor = true`).

2. For ground devices(`BuildOnGroundOnly=true`), if it has `PopulationCap`, let it *100.

3. All the `Prerequisite` of materials are removed.

4. When you select a node, you can press **Ctrl+M** to collect some basic information about the structure where the node is located in the log.

5. You can press **Ctrl+N** to clear all isolated nodes(without any links).

6. Add a **Block Setting Interface** which enables you to change block values visually, instead of the complex shorcuts.

7. Add a **Structure Setting Interface** which enables you to change its owner or collect information(Feature 5) visually.

### Structure Information

The results are output through the console log(`Log`).

The output format: `Structure $: $m, $e, $e-, N $, F $, L $, lenO $, len $, lenB $, D $`, each `$` represents a regarding value:

1. `Strutrue`: The structure's id

2. `m`: The **metal cost** to construct the structure, include device costs(except `reactor` and `derrick`), ignore foundation costs and invulnerable materials(`Invulnerable=true`).

3. `e`: The **energy cost**  to construct the structure, just like `m`.

4. `e-`: the **energy consuming rate**(in seconds) to run all energy-consuming links in the structure. No matter whether the shield is disabled or the portal is connected.

5. `N`: the number of all the **nodes**(include segmented nodes and foundations) in the strcuture. The same below.

6. `F`: The number of all the **foundations** in the strcuture.

7. `L`: The number of all the **links**(include segmented links) in the strcuture.

8. `len0`: The **original length**(ignore compression/expansion) of all the links in the strcuture. Ignore invulnerable materials.

9. `len`: the **actual length**(consider compression/expansion) of all the links in the strcuture. Ignore invulnerable materials.

10. `lenB`: the **actual length** of all the invulnerable links in the strcuture.

11. `D`: the number of all **devices** the strcuture controls.

> Note: if dlc2 isn't actived. The output format: `Structure $: $m, $e, $e-, N $, F $, L $, len $, lenB $, D $`.
> 
> With `len0`, the original length disabled, as it can't get the actual original length of a link in that case.
> 
> The metal/energy cost of links is estimated by the actual length of each link, which could be **overestimated or underestimated**, depeding on whether the structure is compressed or stretched.

### Block Setting Interface

The interface shows when you select any blocks and hides when you have no block selection. It can modify the flags and owner of selected blocks. However, you might take these notes:

1. The show/hide switch will **not be applied immediately** until you **make further key inputs**(include mouse inputs), for example you can press some keyboard keys that aren't any shorcuts to update this interface, like single **Shift**.

2. Forts may add a new vertex for a block when you click the buttons in some cases. That will change the selected block' shape, but this mod will withdraw the new created vertex and restore the block. And that will probably change the block's info-texts's world position.

3. **Don't apply the buttons for new block**(the new block before losing focus). In that case this mod won't restore its shape. Undo if that happens. To easily use the interface for the block, you can **right click the block** to reselect the block.

4. Supports owner changes from *Background* or to *Background* poorly. It won't make the block transparent and will dismiss its original surface. You are expected to make this change by hand(Tip: **5** sets to *Background*, **1,2,3,4** from *Background*)

### Structure Setting Interface

Just like Block Setting Interface, this interface shows and hides with your structure selection(identified by node or device, **link selection can't be identified**). Currently It can modify the owner of selected structure or collect its information without Ctrl+M. You might take these notes:

1. The show/hide switch will **not be applied immediately** until **further key inputs**. The trick is as same as that of Block Setting Interface.
2. The owner change feature **isn't available if dlc2 isn't active**.

## Precautions

- Don't load this mod in non-edit modes, as it changed some game datas.

- Remove this mod from the map files before publish.(Remove this mod from `Mods`)

## License Notice

**In Short:** You are free to use, modify, and distribute this code  under the **MIT License**. However, you **must keep my copyright notice** intact.

It's okay to make your own revised versions of this mod and even **publish them to Steam Forts Community**, as long as you comply with the license.

---

## 功能

1. 在地图编辑器中启用所有原本被禁用的物品(`HideFromEditor = true`)

2. 对于地面装置(`BuildOnGroundOnly=true`)，如果有建造上限(`PopulationCap`)，则建造上限 *100

3. 所有材料的前置(`Prerequisite`)被移除

4. 当你选中节点时，可以按 **Ctrl+M** 来在统计并在日志中输出该节点所在结构的基本信息

5. 按 **Ctrl+N** 清除所有孤立节点(没有连接的节点)

6. 新增一个**地形块设置界面**，让你可以可视化地修改地形块属性而不需要使用复杂的快捷键

7. 新增一个**结构设置界面**，让你可以可视化修改其所属队伍或统计信息(功能 4)

### 地形块设置界面

该界面会在你选中任何地形块时显示并在未选中地形块时隐藏，它可以修改地形块标志和所有者。不过你需要注意以下事项：

1. 界面的显示/隐藏**不会立即生效**，除非你**进一步进行键盘操作**(包括鼠标操作)，例如你可以按下某些非快捷键的按键来更新本界面，比如单个 **Shift** 键。

2. Forts 在某些情况下会在你点击该界面按钮时为地形块新增节点，这会改变地形块的形状，不过本模组会删除新增的那个节点并复原地形块，这同时很可能也会改变这个地形块属性文本的位置。

3. **不要对新地形块直接使用本界面**(在失去焦点前的新地形块)，那样模组就不会复原地形块形状了，这是你应该撤销操作。要便捷的对这样的地形块使用本界面，你可以**右击这个地形块**重新选择这个块。

4. 不是很好地支持从或到*背景*的所有者转换，这样不会让地形块变得透明且会使其失去表面，你应该自行做这样的修改(Tip: **5** 修改为*背景*，**1,2,3,4** 变为其它所有者)

### 结构设置界面

和地形块设置界面一样，本界面同样随着你的结构选择(通过节点或装置判断，**不能通过选择连接来判断**)而显示和隐藏。目前本界面可以修改选中结构的所属队伍或无需快捷键 Ctrl+M 地统计结构信息。注意以下事项：

1. 界面的显示/隐藏**不会立即生效**，除非你**进一步进行键盘操作**，参见地形块设置界面的描述。
2. 改变所属队伍的功能**在 dlc2 未启用时不可用**。

### 结构信息

结果通过控制台输出(`Log`)，格式如下：`Structure $: $m, $e, $e-, N $, F $, L $, lenO $, len $, lenB $, D $`，其中每个 `$` 符号对应相关数值，具体如下：

1. `Strutrue`: 表示结构 id

2. `m`: 表示建造该结构所需的金属，包括所有装置，但不包含核心(`reactor`)和油井(`derrick`)，不计算地基消耗，不计算任何屏障材料(`Invulnerable=true`)

3. `e`: 表示建造该结构所需的能源，规则同 `m`

4. `e-`: 表示该结构所有消耗能源的材料的总消耗速率，按所有该材料都为启动状态计算，无论能量盾是否关闭或者传送门是否连通

5. `N`: 表示该结构的节点数，包含绳子的分段节点，下同

6. `F`: 表示该结构的地基节点数

7. `L`: 表示该结构的连接数

8. `len0`: 表示结构的原始连接总长度，不受材料的当前拉伸程度影响，不计算任何屏障材料

9. `len`: 表示结构的当前连接总长度，受材料的当前拉伸程度影响，不计算任何屏障材料

10. `lenB`: 表示结构的所有屏障材料的当前总长度

11. `D`: 表示该结构控制的装置总数

> Note: 如果你 dlc2 未启用，输出格式变为: `Structure $: $m, $e, $e-, N $, F $, L $, len $, lenB $, D $`
> 
> `len0`，即连接原始长度不再显示，因为模组无法在这种情况下准确获取材料的原始长度
> 
> 结构连接的金属/能源花费会通过连接的原始长度估算。这可能导致**高估或者低估**，取决于你的结构是压缩的还是被拉伸的。

## 注意事项

- 不要在非编辑模式下使用该模组，它会改变部分游戏数据

- 在完成编辑发布地图前，请先将本模组从地图文件中移除(在 `Mods` 中将该模组名移除)

## 许可声明

**简要来说:** 您可以在 **MIT许可证** 下自由使用、修改和分发此代码。但是，您**必须保留我的版权声明**不变

只要遵守许可协议，你可以自行制作你的本模组改版，甚至将其**发布到Steam Forts社区上**
