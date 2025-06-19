# コーディング規約

## 全体的なルール

### テストを書く基準について
- 開発者
    - 基本的に開発した内容は全てテストを書くことを心がける
        - RequestSpec, WorkerSpec, ModelSpec, MailerSpec, DecoratorSpec, HelperSpec
            - view で分岐処理がある場合は RequestSpec でテストを行う
            - validates なども可能であれば shoulda-matchers を使ってテストを行う
- レビュワー
    - RequestSpec, WorkerSpec, MailerSpec が書かれていることを確認する
    - ModelSpec はビジネスロジックのテストが書かれていることを確認する
        - ビジネスロジックとは scope やメソッドなど
        - Rails が標準で用意している validates などは書かれていなくても受容する

### カバレッジを確認して書き忘れているテストがないか確認する
（試験運用中）
- CIがS3にカバレッジレポートをアップするので、レビュー依頼前に確認する
    - これは既存テストなどの関係でハードルが高いのでまずはカバレッジを見る習慣をつける
        - PR にカバレッジレポートを見れるようにURLを記載する
        - テンプレートからブランチ名とアプリケーション名を変えるだけ

## MUST

### バリデーションのコンテキストが複雑な場合は [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers) を使って自動テストを書く
- バリデーションの設定漏れや、変更時のデグレ防止のため
- コンテキストが複雑というのは、if, unless での条件があったり、context を使った分岐があったりするバリデーション
- カスタムバリデーションのようにバリデーション自体が複雑な場合は別途ユニットテストを書く

### [travel](https://github.com/rails/rails/blob/0d304eae601f085274b2e2c04316e025b443da62/activesupport/lib/active_support/testing/time_helpers.rb#L76-L78) を使う時はタイムゾーンによる日にちのずれに気を付ける
- `travel` を使わずに `travel_to` で固定したい日時を指定してしまっても良い
<details>
<summary>例）Time.zone.today</summary>

    irb(main):033:0> travel_to(Time.zone.local(2023, 5, 1))
    => nil
    irb(main):034:0> Time.zone.today
    => Mon, 01 May 2023
    irb(main):035:0> travel(1.month) # 2023/06/01 にしたい
    => nil
    irb(main):036:0> Time.zone.today
    => Wed, 31 May 2023
</details>
<details>
<summary>例）Time.now</summary>

    irb(main):037:0> travel_to(Time.zone.local(2023, 5, 1))
    => nil
    irb(main):038:0> Time.now
    => 2023-04-30 15:00:00 +0000
    irb(main):039:0> travel(1.month)
    => nil
    irb(main):040:0> Time.now
    => 2023-05-30 15:00:00 +0000
</details>

### rspecでテストの観点に使う値は factory ではなく spec ファイルで明示的に指定する
- factoryで入れた値だと、nilなどの場合に気づきにくく、factoryが変わったときにテストも変わって信頼性が下がる
<details>
<summary>例</summary>

❌ BAD
```ruby
context '路線に紐づく駅を指定した場合' do
  let(:station) { create(:common_db_station, :with_railway_line) }

  it '路線名が返ること' do
    get_index
    json = JSON.parse(response.body)
    expect(json.pluck('name')).to match_array([station.railway_lines.first.name])
  end
end
```
<hr>

🟢 GOOD
```ruby
context '路線に紐づく駅を指定した場合' do
  let(:station) { create(:common_db_station) }
  let(:railway_line) { create(:common_db_railway_line, stations: [station], name: '喜連瓜破') }

  before do
    railway_line
  end

  it '路線名が返ること' do
    get_index
    json = JSON.parse(response.body)
    expect(json.pluck('name')).to match_array(['喜連瓜破']) # または match_array([railway_line.name])
  end
end
```
</details>

### FactoryBot のデフォルト値はランダムな値にする
- テストパターンが増え、特定のパターンでエラーになるケースをテストで気づくことができるようになるため
- ランダムでこけるテストができる可能性が高くなるが受容する
- 他のレコードに依存して状態が変わるものは trait を作って trait をランダムに使うようにする
- 完全に状態が変わるものは別の factory を作ることも検討する

### 日付を扱うときはしっかり境界値分析を行うか、必要ない場合は相対時間を使うようにする
- 処理を行う日によってバグが発生するケースに気づけるようにするため
    - 例えば30日があること前提の処理があり、2月に実行するとバグるようなケースなど
- 相対時間を使う時
    - BAD
        - `Time.zone.local(2024, 12, 1)` のように固定の日付を入れる
    - GOOD
        - `Time.zone.today.beginning_of_month` のようにテスト実行日から取るようにする
- 絶対時間がハードコーディングされているコードのテストを行う際はもちろん絶対時間でテストを記述して良い

### 原則 let ではなく let! を使うようにする
- let を使うのは遅延読み込みをする必要がある時のみにする
- let で定義するとテストで使われたり使われなかったりするケースが出てきて可読性が下がってしまう場合があるため

### 参照されない値を let! で定義しない
- 参照されない変数があると可読性が落ちるため
- レコードの作成が必要なケースなどは before ブロックで作成する

### 必要のないレコードは作らない
- テストの高速化のため
- create_list で大量にレコードを作ることはせず、必要な数だけ用意する
- create する必要がない場合は build や build_stubbed でデータを用意する

### 原則 update や let! の上書きなどでデータを書き換えない
- データの状態が分かりにくくなり可読性が落ちるため
- 可能な限り let! などを使ってコンテキスト内で必要なデータを用意できるようにする
- `let!(:params) { valid_params.merge(a: 'a')` のように加工したデータを別変数に定義するのは問題ない

### is_expected 以外で subject を使う時は必ず何をしているかがわかる明示的な名前をつける
- subject が何をしているかがわかりないと可読性が落ちるため
- メソッドのテストはメソッド名をつけるなどわかりやすい名前をつける

### 文字列が含まれるかをテストするケースは他で現れない値にする

- テスト対象以外の箇所による影響を受けないようにするため
- 例えば `expect(response.body).to include customer_name` のテストをするとき
    - BAD
        - `let!(:customer_name) { '会員' }`
    -  GOOD
        - `let!(:customer_name) { 'テスト会員氏名澤田信幸' }`

## SHOULD

### 可能な限り必要なデータが作られないように describe, context のスコープを意識する
- describe 下に let! でデータを用意して複数のcontext 内で使うケースで、そのデータを使わない context が出ないように注意する
    - 不要なデータの生成となってしまうため
- context が大量にあるところに後から追加するケースなどで見逃されることはあると思うので努力目標としておく

### context をネストしない
- 条件がわかりにくくなるため
    - ネストすることで条件がわかりやすくなるような場合はネストしてOK
- ネストしたい場合は、〇〇かつ××の時、のように条件を掛け合わせた context を用意する

### context と it を同階層に置かない
- テストデータの用意が難しくなるため
    - it のために汎用的なデータを用意して、context 内でそのデータを上書きするということをやりたくなってしまうケースがあるため
- 200 OK を返すようなそのテストの基本的なテストケースもそれぞれの context 内で毎回実行する

### 原則 allow_any_instance_of は使わない
- 使う場面が出た時は設計に問題がないか疑う
- RequestSpec での session 埋め込みなど、どうしても使わざるを得ない場面では使用しても良い

## Tips

### スコープのテストを書くときはレコードの生成を規則正しく行わない

- 特にスコープで並び順を指定している場合
- スコープが返すレコードを期待する順番に作るよりも適当な順番で作っておくほうがテストの信頼性が上がるケースがあるはず
```rb
# 例
describe '.order_scope' do
  subject(:order_scope) { described_class.order_scope }
  
  # スコープが返すレコードの順番ではなく適当な順番に作る
  let!(:hoge1) { create(:hoge, :trait3) }
  let!(:hoge2) { create(:hoge, :trait2 }
  let!(:hoge3) { create(:hoge) }
  let!(:hoge4) { create(:hoge), :trait1 }
  
  # hoge1, hoge2, hoge3, hoge4 のような順番ではなく適当な順番に並ぶことになる
  it { is_expected.match([hoge1, hoge4, hoge2, hoge3]) }
end
```

## 要検討

### belongs_to 以外の関連をデフォルトで作らない
- 検討したい内容
    - belongs_to 以外にデフォルトで必ず紐づいて欲しいデータがある時にどうするか
        - has_one 関連は association で関連を作れないか
            - 相互に association が設定されたときにどうなるか検証したい
    - shared_context を使って必要な情報を揃えられないか
        - 必要な情報ごとに context が増えていくことが懸念点なのでうまく設計できないか検討したい
