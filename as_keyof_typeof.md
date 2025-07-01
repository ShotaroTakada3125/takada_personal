1. asキーワード：型を断言する
    型アサーションと呼ばれ、開発者がtypescriptに対して「この値は、私が指定する型として扱ってください」と明示的に伝えるためのもの
    使用例：typescriptが自動的に型を推論できない場合、開発者がより具体的な型を知っている場合

    文法
        値 as 型
    例
        let someValue: any = "this is a string";
        let strLength: number = (someValue as string).length;
        // TypeScriptはsomeValueがany型なので.lengthプロパティがあるか不明だが、
        // 開発者がstring型だと断言することで、.lengthにアクセスできるようになる。

2. typeof 演算子：「値の型を取得する」
    変数が持っている「値」から、その「型」を取得することができる
    特定のオブジェクトの「値そのもの」からその構造に対応する「型」を動的に作り出したい場合がある

    例
        const myObject = {
        name: "Alice",
        age: 30
        };

        type MyObjectType = typeof myObject;
        // MyObjectType は { name: string; age: number; } という型になる。

3. keyof 演算子：「型のキー（プロパティ名）の集合を習得する」
    既存の「型」から、その型が持つすべてのプロパティ（キー）を文字列リテラルとして習得することができる
    結果は「ユニオン型」になる
    オブジェクトのキー名を型として扱うことで、安全にプロパティにアクセスしたり、特定のキー名だけを受け入れる関数を定義したりできる

    例
        type User = {
        id: number;
        name: string;
        email?: string; // オプショナルなプロパティ
        };

        type UserKeys = keyof User;
        // UserKeys は "id" | "name" | "email" という型になります。
        // （"id" または "name" または "email" のいずれかの文字列という意味）

4. as keyof typeof
    特定の「値」が持っているプロパティ名のいずれかであることをtypescriptに断言する

    例
        const STAMP_RALLY_IDS_BY_ENV = {
        dev: { VIRTUAL_GROUP_ID: 12, REAL_GROUP_ID: 107 },
        stg: { VIRTUAL_GROUP_ID: 12, REAL_GROUP_ID: 107 },
        prod: { VIRTUAL_GROUP_ID: 42, REAL_GROUP_ID: 41 },
        };

        const currentEnv = (process.env.NEXT_PUBLIC_APP_ENV || 'dev') as keyof typeof STAMP_RALLY_IDS_BY_ENV;

    処理の解説
        1. typeof STAMP_RALLY_IDS_BY_ENV
            typeofが STAMP_RALLY_IDS_BY_ENVという値の型を取得する
            この場合、オブジェクトリテラル型になる

        2. keyof (typeof STAMP_RALLY_IDS_BY_ENV)
            keyofがオブジェクトリテラル型から、そのプロパティ名（キー）の集合を取得する
            結果は "dev" | "stg" | "prod" というユニオン型になる（"dev"、"stg"、"prod"のいずれかの文字列リテラルという意味）

        3. (process.env.NEXT_PUBLIC_APP_ENV || 'dev') as ("dev" | "stg" | "prod")
            asが(process.env.NEXT_PUBLIC_APP_ENV || 'dev')という値が、上で得られた"dev" | "stg" | "prod"という型であることを断言する