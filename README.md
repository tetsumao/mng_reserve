# 管理システム(システム連携デモ)

「管理システム」と「予約システム」の２つのシステムの構成で双方からアイテムの予約を登録でき、管理システムからのシステム連携処理によりデータ同期を行う。
以下、管理システムの予約はMNG予約、予約システムの予約はWEB予約として区別する。

* アイテムマスタは管理システムで管理し、予約システムは管理システムのデータで同期する。

* 予約システムではWEB予約の登録のみ。編集・削除はできない。

* 管理システムではMNG予約の登録・編集・削除が可能で、WEB予約に関しては編集のみ可能。

* MNG予約とWEB予約では、常にMNG予約が優先される。

* 管理システムがWEB予約を取り込むとき、問題なければ同等情報のMNG予約を作成し元のWEB予約とidで紐づける。

* WEB予約とMNG予約紐づいた場合、MNG予約情報が使用される。(WEB予約は申請時の情報)

* 数量が超過するWEB予約は紐づくMNG予約を作成できない。そのWEB予約か他のMNG予約を編集して数量の問題を解消することでMNG予約を作成できるようになる。
