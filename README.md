# Map Editor Assistance

*Author: 0-0000*

[English](#Usage)

[简体中文](#使用)

---

## Usage

This project is for Forts Map Editor. You might load this as a mod in your map in editor mode.

*move.bat* helps to one-click create a copy in Forts local mods folder(*data/mods/MapEditorAssistance*). So you can directly load this project as a Forts mod locally.

For created maps, you can add the mod id(`"MapEditorAssistance"`) to the `Mods` table in your map's mission script(*playermap?.lua*) or *mods.lua*(usually not existed, but it works). Do take these precautions:

- Don't load this mod in non-edit modes, as it changed some game datas.

- Remove this mod from the map files before publish.

## Features

1. Enable all originally disabled items in the map editor(`HideFromEditor = true`).

2. For ground devices(`BuildOnGroundOnly=true`), if it has `PopulationCap`, let it *100.

3. All the `Prerequisite` of materials are removed.

4. When you select a node, you can press **Ctrl+M** to collect some basic information about the structure where the node is located in the log.

5. You can press **Ctrl+N** to clear all isolated nodes(without any links).

6. Add a **Block Setting Interface** which enables you to modify blocks visually, instead of the complex shorcuts.

7. Add a **Structure Setting Interface** which enables you to modify a structure visually.

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

The interface shows when you select any blocks and hides when you have no block selection. It can modify selected blocks in many ways. However, you might take these notes:

1. Forts may add a new vertex for a block when you click the buttons in some cases. That will change the selected block' shape, but this mod will delete the new created vertex to restore the block. And that will probably **change the block's info-texts's world position**.

2. **Don't mix this interface's operation and block vertex creation operation**: Clicking this interface's buttons after creating vertexs for selected block will let the mod **restore its shape wrongly**. After clicking this interface's buttons, **block vertex creation feature by mouse clicking will be suppressed**. So please **reselect block** if you want to switch the two functions.

3. When using this interface(include 'Block Rotation' below), **do not select any vertex of the selected blocks**, as this may cause the mod to misjudge the changes in terrain blocks, resulting in **terrain block mutations**.

4. If you click a button on this interface but move out the mouse and release it outside the button: This will not be considered as a valid operation on this interface, and this mod **won't try to restore the block**.

5. Supports owner changes from *Background* or to *Background* poorly. It won't make the block transparent and will dismiss its original surface. You are expected to make this change by hand(Tip: **5** sets to *Background*, **1,2,3,4** from *Background*)

6. TextButtons with `!` surrounding are related to **Destructive Features**. They require **double click** to apply.

#### Block Rotation

This is the most complex operation in block operation, and it is an innovative feature independent of the Forts map editor.

To rotate a block, the following steps can be followed:

1. Click the "Rotate Block" button on this interface to enter the **rotation mode**. The selected block will be the object that needs to be rotated.
   
   > To enter the rotation mode, you must select **exactly one block**, meaning you cannot attempt to rotate multiple blocks simultaneously.

2. Confirm the rotation centre.
   
   > **Enter**: Use the position pointed by the mouse as the rotation centre.
   > 
   > **Alt+Enter**: Take the bounding box centre of the rotating object as the rotation centre.
   > 
   > **Left Click**: **Exit rotation mode**. Since this can easily lead to terrain block mutations, choose **Enter** to confirm.
   > 
   > A <u>red circle</u> will mark the position of the rotation centre or its preview.

3. Confirm the rotation base line.
   
   > **Left Click**: Take the ray from the rotation centre to the position pointed by the mouse as the base line.
   > 
   > **Enter**: Take the positive direction of the x-axis as the base line.
   > 
   > A <u>white ray</u> will mark or preview the base line.

4. Confirm the rotation final line.
   
   > **Left Click**: Take the ray from the rotation centre to the position pointed by the mouse as the final line. And **Apply Rotation**(from the base line to the final line).
   > 
   > **Ctrl**: Pressing it will display a preview of the rotated terrain block's position, and releasing it will restore.
   > 
   > **Enter**: Exit rotation mode.
   > 
   > A <u>black ray</u> will mark or preview the final line.

Note that in the above steps, **Right Click** will always **exit the rotation mode**, and pressing the **Shift** key will cancel the snap of the mouse position reader(if the **Shift** key is not pressed, the mouse position will be snapped by default).

**Do not perform any other operations in rotation mode**! This may lead to unpredictable results.

### Structure Setting Interface

Just like Block Setting Interface, this interface shows and hides with your structure selection(identified by node or device, **link selection can't be identified**). And this mod will additionally display a double-layered red circle to identify the position and size of the selected structure. You might take these notes:

1. **Destructive Features**(See also Block Setting Interface) require **double click** to apply.
2. The `Remove Structure` feature will bring about undo levels for each device of the structure.
3. `Remove Structure` won't remove belonging ground devices for structures of `none` or `background`. You can convert the structure's owner team to side1 or side2 in advance to prevent it.
4. Due to a bug in the API, sometimes the dynamic script **mistakenly believes that you have selected the last selected node** when you have not actually selected any node. In this case, this interface will also display, but you can easily identify this situation by the double-layered red circle.

## License Notice

**In Short:** You are free to use, modify, and distribute this code  under the **MIT License**. However, you **must keep my copyright notice** intact.

It's okay to make your own revised versions of this mod and even **publish them to Steam Forts Community**, as long as you comply with the license.

---

## 使用

本项目用于 Forts 地图编辑，你应该在编辑模式中在你的地图中将其加载为一个模组。

*move.bat* 可一键在 Forts 本地模组文件夹下创建副本(*data/mods/MapEditorAssistance*)，让你可以直接将本项目作为 Forts 模组加载。

对于已经创建的地图，你应该将模组 id(`"MapEditorAssistance"`)加到地图任务脚本(*playermap?.lua*)或 *mods.lua*(通常不存在，但确实有用) 中。注意以下事项：

- 不要在非编辑模式下使用该模组，它会改变部分游戏数据

- 在完成编辑发布地图前，请先将本模组从地图文件中移除

## 功能

1. 在地图编辑器中启用所有原本被禁用的物品(`HideFromEditor = true`)

2. 对于地面装置(`BuildOnGroundOnly=true`)，如果有建造上限(`PopulationCap`)，则建造上限 *100

3. 所有材料的前置(`Prerequisite`)被移除

4. 当你选中节点时，可以按 **Ctrl+M** 来在统计并在日志中输出该节点所在结构的基本信息

5. 按 **Ctrl+N** 清除所有孤立节点(没有连接的节点)

6. 新增一个**地形块设置界面**，让你可以可视化地修改地形块而不需要使用复杂的快捷键

7. 新增一个**结构设置界面**，让你可以可视化修改结构

### 地形块设置界面

该界面会在你选中任何地形块时显示并在未选中地形块时隐藏，它可以修改地形块标志和所有者。不过你需要注意以下事项：

1. Forts 在某些情况下会在你点击该界面按钮时为地形块新增节点，这会改变地形块的形状，不过本模组会删除新增的那个节点以复原地形块，这同时很可能也会**改变这个地形块的属性文本的位置**。

2. **不要混合使用本界面操作与新建地形块节点功能**：在对选中地形块新建节点后再点击本界面按钮，则模组会**错误地尝试复原地形块形状**，在点击本界面按钮后**点击新建节点的功能则会被抑制**。因此这两种用法相互切换时请**重新选择地形块**。

3. 使用本界面(包括下面的'地形块旋转')时**请勿选中已选地形块的任何节点**，这会导致模组错误预判地形块变化使得**地形块异变**。

4. 如果你点击本界面按钮但是移出鼠标在按钮外处释放，则这不会视为在本界面的有效操作，且**不会试图复原地形块**。

5. 不是很好地支持从或到*背景*的所有者转换，这样不会让地形块变得透明且会使其失去表面，你应该自行做这样的修改(Tip: **5** 修改为*背景*，**1,2,3,4** 变为其它所有者)。

6. 用 `!` 包围的文字按钮对应**破坏性操作**，它们需要**双击**才能生效。

#### 地形块旋转

这是地形块操作中最复杂的操作，它是独立于 Forts 地图编辑器的一个创新功能。

要旋转一个地形块，可分为以下步骤：

1. 点击本界面的"旋转地形块"按钮，进入**旋转模式**，选中的地形块会作为需要旋转的对象。
   
   > 要进入旋转模式，你必须**恰好选择一个地形块**，也就是你不能试图同时旋转多个地形块。

2. 确认旋转中心。
   
   > **Enter**: 以鼠标指向位置作为旋转中心。
   > 
   > **Alt+Enter**: 以旋转对象的边界框中心作为旋转中心。
   > 
   > **左键**: **退出旋转模式**，因为这很容易导致地形块异变，所以选择 **Enter** 来确定
   > 
   > 一个<u>红色圆圈</u>会标识旋转中心的位置或其预览。

3. 确认旋转基准线。
   
   > **左键**: 以从旋转中心到鼠标指向位置的射线为基准线。
   > 
   > **Enter**: 以 x 轴正方向为基准线。
   > 
   > 一条<u>白色射线</u>会标识或预览基准线。

4. 确认旋转终线。
   
   > **左键**: 以从旋转中心到鼠标指向位置的射线为终线，并**应用旋转**(从基准线旋转到终线)。
   > 
   > **Ctrl**: 按下期间会显示旋转后地形块位置的预览，松开后恢复。
   > 
   > **Enter**: 退出旋转模式。
   > 
   > 一条<u>黑色射线</u>会标识或预览终线。

注意，在以上步骤中，**右键**始终会**退出旋转模式**，**Shift** 键在按下期间会取消取鼠标位置操作的自动吸附(如果 **Shift** 没有被按下则默认吸附鼠标位置)。

**不要在旋转模式中做其它操作**！这有可能导致不可预料的结果。

### 结构设置界面

和地形块设置界面一样，本界面同样随着你的结构选择(通过节点或装置判断，**不能通过选择连接来判断**)而显示和隐藏，并且本模组会额外显示双层红色圆圈标识所选结构位置大小。注意以下事项：

1. **破坏性操作**(参见地形块设置界面)需要**双击**才能生效。
2. `移除结构` 功能会给结构中的每个装置都留下撤回状态。
3. `移除结构` 功能不会移除由所有者为"无"或"背景"的结构所有的地面装置，你可以提前将其所有者改为团队 1 或团队 2 来避免这个问题。
4. 由于 API 的 bug，有时在你未选择节点时动态脚本会**误认为你选择了上次选择的节点**，这时本界面也会显示，可通过双层红圈标识来简单地识别这种情况。 

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

## 许可声明

**简要来说:** 您可以在 **MIT许可证** 下自由使用、修改和分发此代码。但是，您**必须保留我的版权声明**不变

只要遵守许可协议，你可以自行制作你的本模组改版，甚至将其**发布到Steam Forts社区上**
