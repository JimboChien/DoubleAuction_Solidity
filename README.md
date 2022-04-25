# 啟動 Ganache

```bash
$ ganache-cli -p 7545 --networkId 5777 --gasPrice 0 --gasLimit 9000000 --chainId 5777
```

- `-p` : 將 port 設定為 `7545` (和 `truffle-config.js` 設定的 port 一致)。
- `--networkId` : 將 port 設定為 `5777`。
- `--gasPrice` : 將手續費設定為 0。
- `--gasLimit` : 將手續費上限設定為 9000000 (比預設高)。
- `--chainId` : 將 chainId 設定為 5777。

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
    - Currency Symbol : TEST (可自行設定)
![](https://i.imgur.com/PNYgV1j.png)

2. 將 Ganache 所啟用的錢包匯入至 Metamask 中。
![](https://i.imgur.com/aBF7gNs.png  =x600)

# 網頁操作

1. 輸入框設定：

|輸入框|描述|
|---|---|
|輸入角色|角色可輸入 `seller` 或是 `buyer`。|
|輸入數量|數量單位為 `kW·h(度電) * 100`，如 1.2 度電請輸入 120。|
|輸入價格|價格單位為 `元/kW·h(度電) * 100`，如 1 度電 3 元，請輸入 300。|

2. 按鈕設定：

|按鈕|描述|
|---|---|
|加入拍賣|將輸入的角色、數量、價格，加入至拍賣中。|
|加入預設資料|將預設資料加入至拍賣中，可至`client/src/App.js`中，參考並更改`setDefaultValue`功能。|
|Sort|可將買家及賣家，依價格高低排序(僅顯示於網頁，區塊鏈中並無更動資料，不一定要執行)。|
|Setting|當買、賣家皆完成設定後，先將買、賣家價格依高低排序，以便後續進行計算`Qmv`。完成後可於 `Console` 中查看排序完成的陣列。|
|Qmv|獲得`Qmv`。|
|Shift|計算賣家經過`Qmv`位移後的點位，以便後續計算買賣成交價。|
|Result|獲得結果買賣結果。<br />當`role`為`seller`時，`quantity`為0時表示沒有賣出任何能源，負值表示賣出能源量，`balance`皆為正值，表示獲利，如為0表示沒有能源賣出。<br />當`role`為`buyer`時，`quantity`為皆為正值且等於需求量，`balance`皆為負值，表示成本。|
|Reset|重新設定拍賣，將原本設定及結果刪除。|