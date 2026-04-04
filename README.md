## MIDI to ReaPitch Params (JSFX)

MIDIノートとピッチベンドを統合し、REAPER純正プラグイン **「ReaPitch」** をコントロールするJSFXスクリプト

### 概要

ReaPitchのエンベロープ描くのめんどくさい  
MIDIで操作できねーかなー

### 導入手順

1.  **ファイルの配置**:
    `Options > Show REAPER resource path...` 内の `Effects` フォルダに `.jsfx` ファイルをコピー
2.  **トラック構成**:
    音声トラックに本JSFXとReaPitchを指し、MIDIトラックから音声トラックへ Send (Audio: None / MIDI: All -> All) を作成
3.  **プラグインの順序**:
    **本JSFX** → (任意)**JS: MIDI Delay** → **ReaPitch**  
    間や前後に何か挟まっていてもよいがこの順番は守ること

### ReaPitchの連携設定

各パラメータの `Param > Parameter modulation/MIDI link` から以下を紐付ける

| パラメータ            | 項目      | 設定内容                  |
| :-------------------- | :-------- | :------------------------ |
| **Shift (cents)**     | MIDI link | CC 20 / **Offset: -0.4%** |
| **Shift (semitones)** | MIDI link | CC 21                     |
| **Shift (octaves)**   | MIDI link | CC 22                     |

### 設定のポイント

- **Center Note**: 基準となるノート番号（デフォルトはC4=60）
- **Pitch Bend Range**: MIDI側のベンドレンジ設定と合わせる
- **Cents Offset**: ReaPitchの仕様上、Centsだけ **Offsetを -0.4%** に設定しないと若干ずれる
- **JS: MIDI Delay**: 仕様上MIDI信号が若干先走るので気になるようであれば補正
- 設定済みの本JSFXとReaPitchを複数選択して右クリックから FX Chainとして保存 しておけば使いまわせる
