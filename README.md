# 啟動 Ganache

```bash
$ ganache-cli -p 7545 --networkId 5777 --gasPrice 0 --gasLimit 9000000 --chainId 5777 -a 30
```

- `-p` : 將 port 設定為 `7545` (和 `truffle-config.js` 設定的 port 一致)。
- `--networkId` : 將 port 設定為 `5777`。
- `--gasPrice` : 將手續費設定為 0。
- `--gasLimit` : 將手續費上限設定為 9000000 (比預設高)。
- `--chainId` : 將 chainId 設定為 5777。
- `-a` : 使用 `-a` 創建30個帳戶。

# 編譯及部署智能合約

1. 編譯智能合約：
```bash
$ truffle compile
```

2. 部署智能合約：
```bash
$ truffle migrate
```

> 如在不重啟 Ganache 下重新部署智能合約，使用以下指令：
> ```bash
> $ truffle migrate --reset
> ```

# 啟動 client 端

1. 進入 `client` 資料夾中：
```bash
$ cd client
```

2. 啟動 client 端：
```bash
$ npm start
```

3. 開啟瀏覽器進入 http://localhost:3000/ 。

# 設定 Metamask 錢包

1. 新增 Ganache 私有鏈網路：
    - 網路名稱 : Ganache (可自行設定)
    - RPC URL : http://127.0.0.1:7545 (或 http://localhost:7545)
    - 鏈 ID : 5777
    - Currency Symbol : ETH (可自行設定)
    > ![](https://i.imgur.com/0VAzB6T.png)

2. 將 Ganache 所啟用的錢包以匯入至 Metamask ，即可看到初始給的 `100ETH`。
> <img src="https://i.imgur.com/IgEUldO.png" width="200">

3. 點擊下方藍字 <font color="blue">Import tokens</font>，並將使用 `truffle migrate` 部署後，所得到的智能合約地址輸入即可搜尋到代幣。
> <img src="https://i.imgur.com/CLjiFmc.png" width="600"><img src="https://i.imgur.com/xKhFgvu.png" width="200">

4. 可同時看到 ETH 及 ENG(抵押貸幣)。
> <img src="https://i.imgur.com/Y7Gd7W4.png" width="200">

# 網頁操作

1. 輸入框設定：

| 輸入框   | 描述                                                       |
| :------ | :--------------------------------------------------------- |
| 輸入角色 | 角色可輸入 `seller` 或是 `buyer`。                          |
| 輸入數量 | 數量單位為 `kW·h(度電) * 100`，如 1.2 度電請輸入 120。       |
| 輸入價格 | 價格單位為 `元/kW·h(度電) * 100`，如 1 度電 3 元，請輸入 300。|

2. 按鈕設定：

| 按鈕        | 描述                                                                             |
| :--------- | :------------------------------------------------------------------------------- |
| 加入拍賣    | 將輸入的角色、數量、價格，加入至拍賣中。                                                |
| 加入預設資料 | 將預設資料加入至拍賣中，可至 `client/src/App.js` 中，參考並更改 `setDefaultValue` 功能。 |
| Sort       | 可將買家及賣家，依價格高低排序(僅顯示於網頁，區塊鏈中並無更動資料，不一定要執行)。            |
| Qmv        | 計算出 `Qmv` 。                                                                   |
| Shift      | 計算賣家經過 `Qmv` 位移後的點位，並計算買賣交易對。                                     |
| Result     | 獲得結果買賣結果。將顯示交易對的買家及賣家所成交的數量及單價。                             |
| Settlement | 根據結果．結算買賣家代幣餘額。                                                        |
| Reset      | 重新設定拍賣，將原本設定及結果刪除。                                                   |

# Client端範例

1. 啟動 Ganache 並匯入錢包（Account2 為賣家，Account3 為買家）：

2. 部署智能合約，並新增代幣(ENG)：

3. 加入拍賣，完成後買家將以以太幣兌換成代幣（只有買家需要先抵押）：

4. 能源中心在買賣家加入拍賣後，呼叫智能合約計算Qmv，並計算配對結果，最後顯示結果：

5. 能源中心執行 Settlement 來依據配對結果移轉 ENG 代幣：
![5](https://user-images.githubusercontent.com/39701397/165732774-ea9f714a-148a-4573-a754-df95ab3d99ec.gif)

最後可看到：
- Account2(賣家) ENG 代幣為 0，表示該賣家價格設定過高，沒有賣出能源。
- Account3(買家) ENG 代幣由原本 44800 減少為 11160，表示該買家以低於電網價格購買到能源。
