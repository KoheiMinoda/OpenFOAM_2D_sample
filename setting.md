初回のみの環境構築
一行ずつゆっくりコピペするのがオススメ

# Windows 側

コマンドプロンプトを開く

WSL の状態確認

```
wsl -l -v
```

まだなら Ubuntu を導入（22.04 か 24.04 推奨）

```
wsl --install -d Ubuntu-22.04
```

デフォルトを WSL2 に

```
wsl --set-default-version 2
```

# WSL 側

## WSL の起動

```
WSL
```

## 初期セットアップ

```
sudo apt update
sudo apt -y full-upgrade
sudo apt -y install ca-certificates lsb-release curl gpg software-properties-common
```

## OpenFOAM v13 の導入

GCP鍵の登録

```
curl -fsSL https://dl.openfoam.org/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/openfoam.gpg
```

レポジトリ追加

```
echo "deb http://dl.openfoam.org/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/openfoam.list
```

インストール

```
sudo apt update
sudo apt -y install openfoam13
```

## シェル設定 （毎回の読み込みを自動化）

```
echo '. /opt/openfoam13/etc/bashrc' >> ~/.bashrc
. ~/.bashrc
```

## 可視化・メッシュ・動画ツール

```
sudo apt -y install paraview gmsh ffmpeg
```

WSL で ParaView が不安定な場合

```
echo 'export LIBGL_ALWAYS_SOFTWARE=1' >> ~/.bashrc
. ~/.bashrc
```

## 動作確認

バージョン表示

```
foamVersion
```

ソルバのパス確認

```
which icoFoam
```

## 並列実行回り

```
sudo apt -y install openmpi-bin
mpirun --version
```
